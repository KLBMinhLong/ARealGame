#!/usr/bin/env python3
"""Bounded Godot command checks with honest evidence. Python 3.10+, stdlib only.

This helper is NOT a Stone Knight gameplay test suite. Import can execute editor
plugins/tool scripts. Runtime is opt-in and does not isolate user:// saves.
"""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
import json
import math
from pathlib import Path
import re
import subprocess
import sys
import time

ANSI = re.compile(r"\x1b\[[0-?]*[ -/]*[@-~]")
ERROR_PATTERNS = (
    re.compile(r"^\s*(?:SCRIPT ERROR|ERROR|FATAL ERROR):", re.I),
    re.compile(r"^\s*(?:Parse Error|Parser Error):", re.I),
    re.compile(r"\bFailed to load script\b", re.I),
)
WARNING = re.compile(r"^\s*WARNING:", re.I)


def text(value):
    if value is None:
        return ""
    return value.decode("utf-8", errors="replace") if isinstance(value, bytes) else str(value)


def scan_log(value):
    clean = ANSI.sub("", text(value))
    errors, warnings = [], []
    for line in clean.splitlines():
        if any(pattern.search(line) for pattern in ERROR_PATTERNS):
            errors.append(line)
        if WARNING.search(line):
            warnings.append(line)
    return errors, warnings


def run_step(name, argv, cwd, timeout_s, output_dir, runner=subprocess.run):
    started = time.monotonic()
    result = {
        "name": name,
        "command_argv": [str(arg) for arg in argv],
        "working_directory": str(cwd),
        "started_at_utc": datetime.now(timezone.utc).isoformat(),
        "timeout_seconds": timeout_s,
        "exit_code": None,
        "status": "BLOCKED",
        "reason": "",
    }
    stdout, stderr = "", ""
    try:
        completed = runner(
            result["command_argv"], cwd=str(cwd), capture_output=True,
            text=True, encoding="utf-8", errors="replace", timeout=timeout_s,
            shell=False, check=False,
        )
        stdout, stderr = text(completed.stdout), text(completed.stderr)
        result["exit_code"] = completed.returncode
        result["status"] = "PASS" if completed.returncode == 0 else "FAIL"
        if completed.returncode != 0:
            result["reason"] = "Command returned a non-zero exit code."
    except subprocess.TimeoutExpired as error:
        stdout, stderr = text(error.stdout), text(error.stderr)
        result["status"] = "FAIL"
        result["reason"] = "Command timed out; completion was not verified."
    except OSError as error:
        stderr = str(error)
        result["reason"] = "Executable could not be started."

    error_lines, warning_lines = scan_log(stdout + "\n" + stderr)
    if error_lines:
        result["status"] = "FAIL"
        result["reason"] = "Recognized engine/script errors were found in the logs."
    result["error_lines"] = error_lines
    result["warning_lines"] = warning_lines
    result["duration_seconds"] = round(time.monotonic() - started, 6)
    for stream, value in (("stdout", stdout), ("stderr", stderr)):
        path = output_dir / f"{name}.{stream}.log"
        path.write_text(value, encoding="utf-8")
        result[f"{stream}_log"] = str(path)
    return result, stdout


def verify(project, godot, output_root, expected_version=None, smoke_scene=None,
           allow_runtime=False, iterations=120, timeout_s=120.0,
           runner=subprocess.run):
    project = Path(project).resolve()
    output_root = Path(output_root).resolve()
    output_root.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S")
    output_dir = output_root / f"verify-{stamp}-{time.time_ns()}"
    output_dir.mkdir(exist_ok=False)
    report = {
        "schema_version": 1,
        "created_at_utc": datetime.now(timezone.utc).isoformat(),
        "project": str(project),
        "scope": "Only the explicitly selected bounded command checks.",
        "overall": "BLOCKED",
        "reason": "",
        "godot_version": None,
        "version_pin_check": "NOT_RUN",
        "steps": [],
        "not_verified": [
            "Stone Knight feature acceptance and gameplay assertions",
            "Visual quality, audio quality, input feel and human playtest approval",
            "Performance on target hardware and exported-platform compatibility",
            "All runtime paths and all scripts in the repository",
            "Save safety, migration and isolation of user:// data",
        ],
    }

    def finish(status, reason):
        report["overall"], report["reason"] = status, reason
        path = output_dir / "report.json"
        path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        return report, path

    if not (project / "project.godot").is_file():
        return finish("BLOCKED", "The selected project does not contain project.godot.")
    if not godot or not str(godot).strip():
        return finish("BLOCKED", "Provide an existing Godot editor executable.")
    if not math.isfinite(timeout_s) or timeout_s <= 0:
        return finish("BLOCKED", "Timeout must be a finite positive number of seconds.")
    if not isinstance(iterations, int) or iterations <= 0:
        return finish("BLOCKED", "Iterations must be positive; zero disables Godot's iteration limit.")
    if smoke_scene:
        if not allow_runtime:
            return finish("BLOCKED", "Runtime is opt-in: review the scene/save behavior and pass --allow-runtime.")
        if not smoke_scene.startswith("res://"):
            return finish("BLOCKED", "Smoke scene must be an explicit res:// path inside the project.")
        relative = smoke_scene[6:].replace("\\", "/")
        candidate = (project / relative).resolve()
        if not candidate.is_relative_to(project) or not candidate.is_file():
            return finish("BLOCKED", "Smoke scene is missing or resolves outside the project.")
        if candidate.suffix.lower() not in (".tscn", ".scn"):
            return finish("BLOCKED", "Smoke scene must be a Godot scene file, not an arbitrary command.")

    step, stdout = run_step("version", [godot, "--version"], project, timeout_s, output_dir, runner)
    report["steps"].append(step)
    if step["status"] != "PASS":
        return finish(step["status"], "The Godot version command did not pass.")
    version = ANSI.sub("", stdout).strip()
    report["godot_version"] = version
    if not re.match(r"^4\.\d+(?:\.|\s|$)", version):
        return finish("BLOCKED", "This kit targets Godot 4; inspect the executable/version output before proceeding.")
    if expected_version is not None:
        if version != expected_version.strip():
            report["version_pin_check"] = "FAIL"
            return finish("FAIL", "Actual version does not exactly match --expected-version.")
        report["version_pin_check"] = "PASS"

    step, _ = run_step("import", [godot, "--headless", "--path", str(project), "--import"],
                       project, timeout_s, output_dir, runner)
    report["steps"].append(step)
    if step["status"] != "PASS":
        return finish(step["status"], "Import did not pass the helper's command/log checks.")

    if smoke_scene:
        argv = [godot, "--headless", "--path", str(project), "--quit-after", str(iterations), smoke_scene]
        step, _ = run_step("smoke", argv, project, timeout_s, output_dir, runner)
        step["iteration_limit"] = iterations
        step["scene"] = smoke_scene
        report["steps"].append(step)
        if step["status"] != "PASS":
            return finish(step["status"], "The requested bounded smoke scene did not pass.")
    else:
        report["not_verified"].append("No runtime smoke scene was requested or executed.")
    if expected_version is None:
        report["not_verified"].append("Engine version was observed but not compared against a supplied exact pin.")
    return finish("PASS", "Selected commands passed the helper checks; this is not feature completion or human approval.")


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project", default=".", help="Trusted project root containing project.godot.")
    parser.add_argument("--godot", required=True, help="Godot editor executable path or a verified command on PATH.")
    parser.add_argument("--output-dir", default=".artifacts/ai", help="Parent directory for a fresh evidence folder.")
    parser.add_argument("--expected-version", help="Exact observed/pinned output of godot --version.")
    parser.add_argument("--smoke-scene", help="Optional explicit res:// test scene. May execute gameplay/save code.")
    parser.add_argument("--allow-runtime", action="store_true", help="Acknowledge runtime execution; does not isolate saves.")
    parser.add_argument("--iterations", type=int, default=120, help="Positive Godot iterations, NOT seconds.")
    parser.add_argument("--timeout", type=float, default=120.0, help="Finite timeout in seconds for each command.")
    args = parser.parse_args(argv)
    try:
        report, path = verify(args.project, args.godot, args.output_dir, args.expected_version,
                              args.smoke_scene, args.allow_runtime, args.iterations, args.timeout)
    except OSError as error:
        print(f"BLOCKED: could not read/write evidence: {error}", file=sys.stderr)
        return 2
    print(f"{report['overall']}: {report['reason']}")
    print(f"Evidence: {path}")
    print("Feature behavior, visual feel and owner approval are NOT verified by this helper.")
    return {"PASS": 0, "FAIL": 1, "BLOCKED": 2}[report["overall"]]


if __name__ == "__main__":
    sys.exit(main())
