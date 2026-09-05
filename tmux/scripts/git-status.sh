#!/usr/bin/env bash
# Git branch and status script for tmux statusline
#
# VSCode git sync-like behavior:
#   - Background auto-fetch (every 60s) keeps ahead/behind counts fresh.
#   - Shows push-needed (ahead) and pull-needed (behind) counts.
#   - Shows fetching-in-progress and fetch-failed indicators.
#
# The background fetch is detached so the statusline never blocks; the previous
# (cached) value is shown immediately and the new value appears on the next
# status refresh.
#
# Usage:
#   git-status.sh [directory]          # statusline mode (async fetch + cache + display)
#   git-status.sh [directory] --fetch  # manual fetch mode (sync fetch, prints result)

# --- config ---
FETCH_INTERVAL=60   # seconds between background auto-fetches
FAIL_TTL=60         # seconds to keep showing the fetch-failed indicator
LOCK_TTL=300        # seconds; stale lock/fetching-flag cleanup threshold

dir="${1:-$(pwd)}"
mode="statusline"
[[ "${2:-}" == "--fetch" ]] && mode="fetch"

# Not a directory, or not inside a git repository: nothing to show.
cd "$dir" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree &>/dev/null || exit 0

# Icons (Nerd Font) - using UTF-8 byte sequences
# Note: バイト列は devicon git-branch の U+E725。以前の Powerline U+E0A0(細字)から、#586e75 のステータスライン背景上での視認性と git 感を出すために意図変更（commit 2a13c5f）
ICON_BRANCH=$(printf '\xee\x9c\xa5')
ICON_AHEAD=$(printf '\xef\x81\xa2')       # push needed
ICON_BEHIND=$(printf '\xef\x81\xa3')      # pull needed
ICON_FETCHING=$(printf '\xef\x80\xa1')    # sync in progress (fa-refresh)
ICON_FAIL=$(printf '\xef\x81\xb1')        # fetch failed (fa-exclamation-triangle)
ICON_UPTODATE=$(printf '\xef\x81\x98')    # clean & in sync (fa-check-circle)

# Get branch name; detached HEAD falls back to the short commit hash.
branch=$(git symbolic-ref --short HEAD 2>/dev/null)
[[ -z "$branch" ]] && branch=$(git rev-parse --short HEAD 2>/dev/null)
[[ -z "$branch" ]] && exit 0

# Get upstream (remote/branch). Empty when there is no upstream
# (e.g. detached HEAD or a local-only branch); in that case we can't fetch.
upstream=$(git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)
upstream_remote=""
[[ -n "$upstream" ]] && upstream_remote="${upstream%%/*}"

# --- cache setup ---
# Keyed by the git common dir (shared across worktrees) so all worktrees of a
# repository share one cache entry and one background fetch.
CACHE_DIR="/tmp/tmux-git-status"
mkdir -p "$CACHE_DIR" 2>/dev/null

common_dir=$(git rev-parse --git-common-dir 2>/dev/null)
if [[ -n "$common_dir" && "$common_dir" != /* ]]; then
  common_dir="$dir/$common_dir"
fi
if [[ -z "$common_dir" || ! -d "$common_dir" ]]; then
  common_dir="$dir/.git"
fi
common_dir=$(cd "$common_dir" 2>/dev/null && pwd || echo "$common_dir")

# Cross-platform hash (macOS has `md5`, Linux has `md5sum`, fallback to cksum)
if command -v md5 >/dev/null 2>&1; then
  hash=$(printf '%s' "$common_dir" | md5 -q | cut -c1-12)
elif command -v md5sum >/dev/null 2>&1; then
  hash=$(printf '%s' "$common_dir" | md5sum | cut -c1-12)
else
  hash=$(printf '%s' "$common_dir" | cksum | tr -d ' ')
fi

CACHE="$CACHE_DIR/$hash"
FETCHING_FLAG="${CACHE}.fetching"
FAIL_FLAG="${CACHE}.fail"
LOCKDIR="${CACHE_DIR}/lock-${hash}"

# --- helpers ---
now() { date +%s; }

# Detect the stat mtime flag once: GNU stat uses `-c %Y`, BSD stat uses `-f %m`.
# Branching (not `||` fallback) because command substitution merges stdout from
# both sides of `||` — on Linux `stat -f %m` is the filesystem-mode flag, so its
# garbage output would mix into the real value even when the fallback runs.
if stat -c %Y / >/dev/null 2>&1; then
  stat_mtime() { stat -c %Y "$1"; }
else
  stat_mtime() { stat -f %m "$1"; }
fi

file_age() {
  # Echo age in seconds of a file (999999 if missing)
  local f="$1"
  [[ -e "$f" ]] || { echo 999999; return; }
  echo $(( $(now) - $(stat_mtime "$f") ))
}

# Compute ahead/behind from local refs (no fetch). Sets globals ahead/behind.
compute_ahead_behind() {
  ahead=0
  behind=0
  if [[ -n "$upstream" ]]; then
    # Caution: rev-list --left-right --count は「左=upstream側(=behind) 右=HEAD側(=ahead)」の順で出力するため、`read` の変数順 `behind ahead` はこの順序と厳密に対応する。入れ替えると ahead/behind が無言で逆転する（git rev-list --left-right の仕様）
    read -r behind ahead < <(
      git rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null
    )
    [[ "$ahead" =~ ^[0-9]+$ ]] || ahead=0
    [[ "$behind" =~ ^[0-9]+$ ]] || behind=0
  fi
}

# Read ahead/behind from the cache if present, else compute locally.
read_ahead_behind() {
  if [[ -f "$CACHE" ]]; then
    local c_behind c_ahead
    read -r c_behind c_ahead < "$CACHE" 2>/dev/null
    if [[ "$c_ahead" =~ ^[0-9]+$ ]] && [[ "$c_behind" =~ ^[0-9]+$ ]]; then
      ahead=$c_ahead
      behind=$c_behind
      return
    fi
  fi
  compute_ahead_behind
}

# Compute local work-tree status counts. Sets globals staged/dirty/untracked.
compute_worktree_status() {
  staged=0
  dirty=0
  untracked=0
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    index="${line:0:1}"
    worktree="${line:1:1}"
    [[ "$index" =~ [MADRC] ]] && ((staged++))
    [[ "$worktree" =~ [MD] ]] && ((dirty++))
    [[ "$index" == "?" ]] && ((untracked++))
  done < <(git status --porcelain 2>/dev/null)
}

# Perform fetch and update cache. Requires an upstream. Returns 0 on success.
do_fetch() {
  [[ -z "$upstream_remote" ]] && return 1
  touch "$FETCHING_FLAG" 2>/dev/null
  if git fetch "$upstream_remote" --quiet --prune 2>/dev/null; then
    compute_ahead_behind
    echo "$behind $ahead" > "$CACHE"
    rm -f "$FAIL_FLAG" "$FETCHING_FLAG" 2>/dev/null
    return 0
  else
    rm -f "$FETCHING_FLAG" 2>/dev/null
    touch "$FAIL_FLAG" 2>/dev/null
    return 1
  fi
}

# --- manual fetch mode ---
if [[ "$mode" == "fetch" ]]; then
  if [[ -z "$upstream_remote" ]]; then
    echo "git: no upstream"
    exit 0
  fi
  if mkdir "$LOCKDIR" 2>/dev/null; then
    trap 'rmdir "$LOCKDIR" 2>/dev/null' EXIT
    if do_fetch; then
      compute_worktree_status
      msg="git: fetched"
      [[ $ahead -gt 0 ]] && msg+=" ↑${ahead}"
      [[ $behind -gt 0 ]] && msg+=" ↓${behind}"
      [[ $staged -gt 0 ]] && msg+=" +${staged}"
      [[ $dirty -gt 0 ]] && msg+=" ~${dirty}"
      [[ $untracked -gt 0 ]] && msg+=" ?${untracked}"
      echo "$msg"
    else
      echo "git: fetch failed"
    fi
  else
    echo "git: fetch already running"
  fi
  exit 0
fi

# --- statusline mode ---

# Kick off a background fetch when the last attempt is stale and none is in
# progress. Both the success cache and the fail flag count as the "last attempt"
# time, so a persistent network failure does not retry every status refresh.
if [[ -n "$upstream_remote" ]]; then
  cache_a=$(file_age "$CACHE")
  fail_a=$(file_age "$FAIL_FLAG")
  last_try=$(( cache_a < fail_a ? cache_a : fail_a ))
  if [[ "$last_try" -ge "$FETCH_INTERVAL" ]] && [[ ! -e "$FETCHING_FLAG" ]]; then
    # Clean up a stale lock left by a crashed fetch before trying again.
    if [[ -d "$LOCKDIR" ]] && [[ $(file_age "$LOCKDIR") -ge "$LOCK_TTL" ]]; then
      rmdir "$LOCKDIR" 2>/dev/null
    fi
    # Detach the fetch so the statusline never blocks on the network.
    (
      if mkdir "$LOCKDIR" 2>/dev/null; then
        trap 'rmdir "$LOCKDIR" 2>/dev/null' EXIT
        do_fetch
      fi
    ) </dev/null >/dev/null 2>&1 &
  fi
fi

# --- build output ---

# Local working-tree status counts (staged/dirty/untracked)
compute_worktree_status

# ahead/behind (cached; refreshed in the background by the fetch above)
read_ahead_behind

output="${ICON_BRANCH} ${branch}"
[[ $staged -gt 0 ]] && output+=" +${staged}"
[[ $dirty -gt 0 ]] && output+=" ~${dirty}"
[[ $untracked -gt 0 ]] && output+=" ?${untracked}"

# Fetch-state indicators (or an up-to-date mark when everything is clean & in sync)
if [[ -e "$FETCHING_FLAG" ]]; then
  output+=" ${ICON_FETCHING}"
elif [[ -e "$FAIL_FLAG" ]] && [[ $(file_age "$FAIL_FLAG") -lt "$FAIL_TTL" ]]; then
  output+=" ${ICON_FAIL}"
elif [[ $staged -eq 0 && $dirty -eq 0 && $untracked -eq 0 && $ahead -eq 0 && $behind -eq 0 ]]; then
  output+=" ${ICON_UPTODATE}"
fi

[[ $ahead -gt 0 ]] && output+=" ${ICON_AHEAD}${ahead}"
[[ $behind -gt 0 ]] && output+=" ${ICON_BEHIND}${behind}"

echo "$output"
