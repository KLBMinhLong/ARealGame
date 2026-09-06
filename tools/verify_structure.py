#!/usr/bin/env python3
"""Optional static checks. Python standard library only; NOT a GDScript parser."""
from pathlib import Path
import re
import sys

root = Path(__file__).resolve().parents[1]
errors = []
checks = 0

def expect(condition, message):
    global checks
    checks += 1
    print(('PASS: ' if condition else 'FAIL: ') + message)
    if not condition:
        errors.append(message)

required = ['project.godot', 'ENGINE_VERSION.txt', 'README.md', 'START_HERE.md',
            'AGENT_RULES.md', 'docs/GAME_BRIEF.md', 'docs/TECH_SPEC.md',
            'docs/TASKS.md', 'docs/TEST_PLAN.md', 'docs/RELEASE_CHECKLIST.md',
            'docs/QA_REPORT.md', 'prompts/00_BOOTSTRAP.md',
            '.agents/rules/00-project.md', 'scenes/main.tscn',
            'scenes/player.tscn', 'scenes/enemy.tscn', 'tests/smoke_test.gd',
            'tools/verify.ps1', 'export_presets.cfg']
for relative in required:
    path = root / relative
    expect(path.is_file() and path.stat().st_size > 0, f'Required file: {relative}')

for path in sorted(root.rglob('*')):
    if not path.is_file() or '.godot' in path.parts:
        continue
    if path.suffix in {'.gd', '.tscn'} or path.name == 'project.godot':
        text = path.read_text(encoding='utf-8')
        for reference in sorted(set(re.findall(r'res://[^"\s)]+', text))):
            expect((root / reference[6:]).is_file(), f'{path.relative_to(root)} references {reference}')
    if path.suffix == '.tscn':
        text = path.read_text(encoding='utf-8')
        ids = set(re.findall(r'^\[ext_resource .*?id="([^"]+)"', text, flags=re.M))
        used = set(re.findall(r'ExtResource\("([^"]+)"\)', text))
        expect(used.issubset(ids), f'Scene resource IDs: {path.relative_to(root)}')

project = (root / 'project.godot').read_text(encoding='utf-8')
expect('renderer/rendering_method="gl_compatibility"' in project, 'Compatibility renderer configured')
expect('run/main_scene="res://scenes/main.tscn"' in project, 'Main scene configured')
for action in ['move_left', 'move_right', 'move_up', 'move_down', 'pause_game', 'restart_game', 'pulse']:
    expect(action + '={' in project, f'Input action configured: {action}')
expect('4.6.3.stable.official [7d41c59c4]' in (root / 'ENGINE_VERSION.txt').read_text(), 'User-reported exact version recorded')
for rule in (root / '.agents' / 'rules').glob('*.md'):
    expect(len(rule.read_text(encoding='utf-8')) < 12000, f'Antigravity rule length: {rule.name}')

# Catch broken relative Markdown links; skip external URLs, anchors, and examples.
for path in sorted(root.rglob('*.md')):
    for link in re.findall(r'(?<!!)\[[^\]]+\]\(([^)]+)\)', path.read_text(encoding='utf-8')):
        if '://' in link or link.startswith('#') or '<' in link:
            continue
        target = link.split('#', 1)[0]
        if target:
            expect((path.parent / target).exists(), f'Markdown link in {path.relative_to(root)}: {target}')
print(f'\nSTATIC_RESULT: {checks - len(errors)}/{checks} checks passed')
print('Static checks do not compile GDScript, run the game, validate engine APIs, or benchmark hardware.')
sys.exit(1 if errors else 0)
