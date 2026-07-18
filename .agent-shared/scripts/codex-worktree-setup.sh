#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '[codex-worktree-setup] %s\n' "$*"
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

require_fvm() {
  if command_exists fvm; then
    return 0
  fi

  log "FVM が見つかりません。'dart pub global activate fvm' でインストールしてください。"
  exit 1
}

install_flutter_sdk() {
  if [ ! -f "$repo_root/.fvm/fvm_config.json" ]; then
    log ".fvm/fvm_config.json が見つからないため、Flutter SDK のバージョンを特定できません。"
    exit 1
  fi

  log "FVM 設定に固定された Flutter SDK を準備します。"
  fvm install
}

copy_env_from_primary_checkout() {
  local git_common_dir primary_checkout source_env

  if [ -f "$repo_root/.env" ]; then
    log "worktree に既存の .env があるため、そのまま使用します。"
    return 0
  fi

  git_common_dir="$(git rev-parse --path-format=absolute --git-common-dir)"
  primary_checkout="$(dirname "$git_common_dir")"
  source_env="$primary_checkout/.env"

  if [ ! -f "$source_env" ]; then
    log "元 checkout の .env が見つかりません。$primary_checkout/.env を用意してから再実行してください。"
    exit 1
  fi

  cp "$source_env" "$repo_root/.env"
  log "元 checkout から .env をコピーしました。"
}

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

cd "$repo_root"

require_fvm

log "Repository: $repo_root"
install_flutter_sdk
copy_env_from_primary_checkout

log "Flutter の依存関係を取得します。"
fvm flutter pub get

log "セットアップが完了しました。"
