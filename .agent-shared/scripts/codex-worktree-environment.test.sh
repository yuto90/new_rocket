#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
repo_root="$(cd "$script_dir/../.." && pwd -P)"
setup_script="$script_dir/codex-worktree-setup.sh"
cleanup_script="$script_dir/codex-worktree-cleanup.sh"
environment_file="$repo_root/.codex/environments/default.toml"
test_tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/new-rocket-codex-environment.XXXXXX")"

cleanup_test_tmp_root() {
  rm -rf "$test_tmp_root"
}
trap cleanup_test_tmp_root EXIT

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  return 1
}

assert_contains() {
  local file="$1"
  local expected="$2"

  grep -Fq "$expected" "$file" || fail "Expected '$expected' in $file"
}

assert_file_equals() {
  local file="$1"
  local expected="$2"
  local actual

  actual="$(cat "$file")"
  [ "$actual" = "$expected" ] || fail "Expected '$expected' in $file, got '$actual'"
}

assert_file_exists() {
  [ -f "$1" ] || fail "Expected file to exist: $1"
}

create_fixture_repo() {
  local fixture_name="$1"
  local primary_repo="$test_tmp_root/$fixture_name-primary"
  local worktree_repo="$test_tmp_root/$fixture_name-worktree"

  mkdir -p "$primary_repo/.fvm"
  git -C "$primary_repo" init -q
  git -C "$primary_repo" config user.email codex-test@example.com
  git -C "$primary_repo" config user.name codex-test
  printf '{"flutterSdkVersion":"2.8.1","flavors":{}}\n' > "$primary_repo/.fvm/fvm_config.json"
  printf 'name: fixture\n' > "$primary_repo/pubspec.yaml"
  git -C "$primary_repo" add .fvm/fvm_config.json pubspec.yaml
  git -C "$primary_repo" commit -qm 'test fixture'
  git -C "$primary_repo" worktree add -q -b "$fixture_name-branch" "$worktree_repo"

  printf '%s\n%s\n' "$primary_repo" "$worktree_repo"
}

write_fake_fvm() {
  local bin_dir="$1"

  mkdir -p "$bin_dir"
  cat > "$bin_dir/fvm" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >> "$FAKE_FVM_LOG"
EOF
  chmod +x "$bin_dir/fvm"
}

test_environment_toml() {
  python3 - "$environment_file" <<'PY'
import pathlib
import sys
import tomllib

path = pathlib.Path(sys.argv[1])
with path.open("rb") as file:
    config = tomllib.load(file)

assert config["version"] == 1
assert config["name"] == "New Rocket"
assert config["setup"]["script"] == "bash .agent-shared/scripts/codex-worktree-setup.sh"
assert config["cleanup"]["script"] == "bash .agent-shared/scripts/codex-worktree-cleanup.sh"
assert config["actions"] == [
    {"name": "run", "icon": "tool", "command": "fvm flutter run"},
    {"name": "test", "icon": "tool", "command": "fvm flutter test"},
    {"name": "analyze", "icon": "tool", "command": "fvm flutter analyze"},
]
PY
}

test_setup_copies_env_and_runs_fvm_in_order() {
  local repos primary_repo worktree_repo fake_bin call_log
  mapfile -t repos < <(create_fixture_repo "copy-env")
  primary_repo="${repos[0]}"
  worktree_repo="${repos[1]}"
  fake_bin="$test_tmp_root/copy-env-bin"
  call_log="$test_tmp_root/copy-env-fvm.log"

  printf 'TEST_AD_ID=from-primary\n' > "$primary_repo/.env"
  : > "$call_log"
  write_fake_fvm "$fake_bin"

  (
    cd "$worktree_repo"
    PATH="$fake_bin:/usr/bin:/bin" FAKE_FVM_LOG="$call_log" "$setup_script"
  ) >/dev/null

  assert_file_equals "$worktree_repo/.env" 'TEST_AD_ID=from-primary'
  assert_file_equals "$call_log" $'install\nflutter pub get'
}

test_setup_preserves_existing_worktree_env() {
  local repos primary_repo worktree_repo fake_bin call_log
  mapfile -t repos < <(create_fixture_repo "preserve-env")
  primary_repo="${repos[0]}"
  worktree_repo="${repos[1]}"
  fake_bin="$test_tmp_root/preserve-env-bin"
  call_log="$test_tmp_root/preserve-env-fvm.log"

  printf 'TEST_AD_ID=from-primary\n' > "$primary_repo/.env"
  printf 'TEST_AD_ID=from-worktree\n' > "$worktree_repo/.env"
  : > "$call_log"
  write_fake_fvm "$fake_bin"

  (
    cd "$worktree_repo"
    PATH="$fake_bin:/usr/bin:/bin" FAKE_FVM_LOG="$call_log" "$setup_script"
  ) >/dev/null

  assert_file_equals "$worktree_repo/.env" 'TEST_AD_ID=from-worktree'
}

test_setup_fails_when_primary_env_is_missing() {
  local repos worktree_repo fake_bin call_log output_log
  mapfile -t repos < <(create_fixture_repo "missing-env")
  worktree_repo="${repos[1]}"
  fake_bin="$test_tmp_root/missing-env-bin"
  call_log="$test_tmp_root/missing-env-fvm.log"
  output_log="$test_tmp_root/missing-env-output.log"

  : > "$call_log"
  write_fake_fvm "$fake_bin"

  if (
    cd "$worktree_repo"
    PATH="$fake_bin:/usr/bin:/bin" FAKE_FVM_LOG="$call_log" "$setup_script"
  ) >"$output_log" 2>&1; then
    fail 'Setup succeeded without a primary checkout .env'
  fi

  assert_contains "$output_log" '元 checkout の .env が見つかりません'
  assert_file_equals "$call_log" 'install'
}

test_setup_fails_when_fvm_is_missing() {
  local repos primary_repo worktree_repo output_log
  mapfile -t repos < <(create_fixture_repo "missing-fvm")
  primary_repo="${repos[0]}"
  worktree_repo="${repos[1]}"
  output_log="$test_tmp_root/missing-fvm-output.log"

  printf 'TEST_AD_ID=from-primary\n' > "$primary_repo/.env"

  if (
    cd "$worktree_repo"
    PATH="/usr/bin:/bin" "$setup_script"
  ) >"$output_log" 2>&1; then
    fail 'Setup succeeded without FVM'
  fi

  assert_contains "$output_log" 'FVM が見つかりません'
  assert_contains "$output_log" 'dart pub global activate fvm'
}

test_cleanup_preserves_worktree_files() {
  local repos worktree_repo output_log
  mapfile -t repos < <(create_fixture_repo "cleanup")
  worktree_repo="${repos[1]}"
  output_log="$test_tmp_root/cleanup-output.log"

  mkdir -p "$worktree_repo/.dart_tool" "$worktree_repo/build"
  printf 'keep\n' > "$worktree_repo/.dart_tool/marker"
  printf 'keep\n' > "$worktree_repo/build/marker"
  printf 'TEST_AD_ID=keep\n' > "$worktree_repo/.env"

  (cd "$worktree_repo" && "$cleanup_script") >"$output_log"

  assert_file_exists "$worktree_repo/.dart_tool/marker"
  assert_file_exists "$worktree_repo/build/marker"
  assert_file_exists "$worktree_repo/.env"
  assert_contains "$output_log" '外部リソースの削除処理はありません'
}

test_environment_toml
test_setup_copies_env_and_runs_fvm_in_order
test_setup_preserves_existing_worktree_env
test_setup_fails_when_primary_env_is_missing
test_setup_fails_when_fvm_is_missing
test_cleanup_preserves_worktree_files

printf 'codex worktree environment tests passed\n'
