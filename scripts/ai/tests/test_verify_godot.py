"""Helper tests use a fake runner, never a real Godot executable or game project."""
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from verify_godot import scan_log, verify

FAKE_VERSION = "4.0.fake-unit-test"


class VerifyGodotTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.project = self.root / "project with spaces"
        self.project.mkdir()
        (self.project / "project.godot").write_text('; fixture only, not a real game\n', encoding='utf-8')
        self.output = self.root / "evidence"
        self.calls = []

    def runner(self, argv, **kwargs):
        self.calls.append((argv, kwargs))
        output = FAKE_VERSION + "\n" if "--version" in argv else "fixture command completed\n"
        return subprocess.CompletedProcess(argv, 0, output, "")

    def run_verify(self, **kwargs):
        defaults = dict(project=self.project, godot="Godot editor fixture", output_root=self.output, runner=self.runner)
        defaults.update(kwargs)
        return verify(**defaults)

    def test_import_success_is_limited_not_feature_completion(self):
        report, path = self.run_verify(expected_version=FAKE_VERSION)
        self.assertEqual(report["overall"], "PASS")
        self.assertEqual(report["version_pin_check"], "PASS")
        self.assertEqual([s["name"] for s in report["steps"]], ["version", "import"])
        self.assertTrue(report["not_verified"])
        self.assertEqual(json.loads(path.read_text())["overall"], "PASS")

    def test_no_runtime_by_default(self):
        report, _ = self.run_verify()
        self.assertEqual(len(self.calls), 2)
        self.assertFalse(any("--quit-after" in call[0] for call in self.calls))
        self.assertEqual(report["version_pin_check"], "NOT_RUN")

    def test_version_mismatch_stops_before_import(self):
        report, _ = self.run_verify(expected_version="4.0.some-other-fixture")
        self.assertEqual(report["overall"], "FAIL")
        self.assertEqual(len(self.calls), 1)

    def test_missing_project_is_blocked(self):
        report, _ = self.run_verify(project=self.root / "missing")
        self.assertEqual(report["overall"], "BLOCKED")
        self.assertEqual(self.calls, [])
        self.assertFalse((self.root / "missing").exists())

    def test_missing_executable_is_blocked(self):
        def missing(*args, **kwargs):
            raise FileNotFoundError("fixture executable missing")
        report, _ = self.run_verify(runner=missing)
        self.assertEqual(report["overall"], "BLOCKED")
        self.assertIsNone(report["steps"][0]["exit_code"])

    def test_timeout_is_fail_and_keeps_partial_log(self):
        def timeout(argv, **kwargs):
            raise subprocess.TimeoutExpired(argv, 1, output=b"partial fixture output", stderr=b"still running")
        report, _ = self.run_verify(runner=timeout)
        self.assertEqual(report["overall"], "FAIL")
        self.assertIn("partial fixture", Path(report["steps"][0]["stdout_log"]).read_text())

    def test_script_error_with_zero_exit_fails(self):
        def error(argv, **kwargs):
            if "--version" in argv:
                return self.runner(argv, **kwargs)
            return subprocess.CompletedProcess(argv, 0, "", "SCRIPT ERROR: Parse Error: fixture failure\n")
        report, _ = self.run_verify(runner=error)
        self.assertEqual(report["overall"], "FAIL")
        self.assertEqual(report["steps"][-1]["exit_code"], 0)
        self.assertTrue(report["steps"][-1]["error_lines"])

    def test_nonzero_exit_is_fail_without_error_text(self):
        def error(argv, **kwargs):
            if "--version" in argv:
                return self.runner(argv, **kwargs)
            return subprocess.CompletedProcess(argv, 9, "", "fixture aborted")
        report, _ = self.run_verify(runner=error)
        self.assertEqual(report["overall"], "FAIL")

    def test_warning_recorded_not_silently_promoted(self):
        def warning(argv, **kwargs):
            result = self.runner(argv, **kwargs)
            if "--import" in argv:
                result.stderr = "WARNING: fixture warning\n"
            return result
        report, _ = self.run_verify(runner=warning)
        self.assertEqual(report["overall"], "PASS")
        self.assertEqual(len(report["steps"][-1]["warning_lines"]), 1)

    def test_logs_strip_ansi_for_detection(self):
        errors, warnings = scan_log("\x1b[31mERROR: fixture\x1b[0m\nWARNING: fixture warning")
        self.assertEqual(len(errors), 1)
        self.assertEqual(len(warnings), 1)

    def test_smoke_requires_explicit_opt_in(self):
        report, _ = self.run_verify(smoke_scene="res://fixture.tscn")
        self.assertEqual(report["overall"], "BLOCKED")
        self.assertEqual(self.calls, [])

    def test_smoke_scene_missing_is_blocked(self):
        report, _ = self.run_verify(smoke_scene="res://fixture.tscn", allow_runtime=True)
        self.assertEqual(report["overall"], "BLOCKED")
        self.assertEqual(self.calls, [])

    def test_smoke_scene_outside_project_is_blocked(self):
        (self.root / "outside.tscn").write_text("fixture", encoding="utf-8")
        report, _ = self.run_verify(smoke_scene="res://../outside.tscn", allow_runtime=True)
        self.assertEqual(report["overall"], "BLOCKED")
        self.assertEqual(self.calls, [])

    def test_explicit_smoke_is_bounded(self):
        (self.project / "fixture.tscn").write_text("fixture, not executed", encoding="utf-8")
        report, _ = self.run_verify(smoke_scene="res://fixture.tscn", allow_runtime=True, iterations=7)
        self.assertEqual(report["overall"], "PASS")
        command = self.calls[-1][0]
        self.assertEqual(command[command.index("--quit-after") + 1], "7")
        self.assertEqual(report["steps"][-1]["iteration_limit"], 7)
        self.assertGreater(self.calls[-1][1]["timeout"], 0)

    def test_zero_iterations_rejected(self):
        report, _ = self.run_verify(iterations=0)
        self.assertEqual(report["overall"], "BLOCKED")
        self.assertEqual(self.calls, [])

    def test_infinite_timeout_rejected(self):
        report, _ = self.run_verify(timeout_s=float("inf"))
        self.assertEqual(report["overall"], "BLOCKED")
        self.assertEqual(self.calls, [])

    def test_shell_disabled_and_spaced_path_kept_as_one_argument(self):
        self.run_verify()
        argv, kwargs = self.calls[0]
        self.assertEqual(argv[0], "Godot editor fixture")
        self.assertIs(kwargs["shell"], False)
        self.assertEqual(kwargs["cwd"], str(self.project.resolve()))

    def test_non_godot4_is_blocked(self):
        def wrong(argv, **kwargs):
            return subprocess.CompletedProcess(argv, 0, "3.0.fake-unit-test", "")
        report, _ = self.run_verify(runner=wrong)
        self.assertEqual(report["overall"], "BLOCKED")
        self.assertEqual(len(report["steps"]), 1)

    def test_each_check_keeps_separate_evidence(self):
        _, first = self.run_verify()
        _, second = self.run_verify()
        self.assertNotEqual(first, second)
        self.assertTrue(first.exists())
        self.assertTrue(second.exists())


if __name__ == "__main__":
    unittest.main()
