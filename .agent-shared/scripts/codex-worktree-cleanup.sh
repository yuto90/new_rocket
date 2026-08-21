#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '[codex-worktree-cleanup] %s\n' "$*"
}

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

cd "$repo_root"

log "Repository: $repo_root"
log "このリポジトリには worktree 固有の外部リソースの削除処理はありません。"
log ".dart_tool、build、.env は Codex による worktree ディレクトリの削除に含まれます。"
log "共有 FVM キャッシュと Flutter SDK は削除しません。"
log "クリーンアップ前処理が完了しました。"
