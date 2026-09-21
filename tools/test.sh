#!/usr/bin/env bash
set -euo pipefail
project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
godot_bin="${GODOT_BIN:-godot}"
"$godot_bin" --headless --path "$project_dir" --editor --quit
for suite in test_forge test_save test_review test_ui; do
  "$godot_bin" --headless --path "$project_dir" --script "res://tests/$suite.gd"
done
