#!/usr/bin/env bash
# GLM usage quota script for tmux statusline
# Output format: GLM: 25%(1h30m)  (残量% とリセットまでの残時間)
#
# Requires: ZAI_API_KEY (~/.config/.env), jq, curl
# Cache: 60 seconds

set -euo pipefail

# Environment variable loading (SSOT: repo直下.env)
[ -f ~/.config/.env ] && source ~/.config/.env

# Skip if ZAI_API_KEY is not set
[ -z "${ZAI_API_KEY:-}" ] && exit 0

# Require jq
command -v jq &>/dev/null || exit 0

GLM_CACHE_FILE="/tmp/claude-glm-usage.cache"
GLM_DATA=""

# Detect the stat mtime flag once: GNU stat uses `-c %Y`, BSD stat (macOS) uses `-f %m`.
# Branching (not `||` fallback) because command substitution merges stdout from
# both sides of `||` — on Linux `stat -f %m` is the filesystem-mode flag, so its
# garbage output would mix into the real value even when the fallback runs.
# (Same pattern as git-status.sh)
if stat -c %Y / >/dev/null 2>&1; then
    stat_mtime() { stat -c %Y "$1"; }
else
    stat_mtime() { stat -f %m "$1"; }
fi

# Cache check (60 seconds)
if [ -f "$GLM_CACHE_FILE" ]; then
    CACHE_MTIME=$(stat_mtime "$GLM_CACHE_FILE" 2>/dev/null)
    [ -n "$CACHE_MTIME" ] && [ $(($(date +%s) - CACHE_MTIME)) -lt 60 ] && GLM_DATA=$(cat "$GLM_CACHE_FILE")
fi

# Fetch from API if cache is stale
if [ -z "$GLM_DATA" ]; then
    GLM_DATA=$(curl -s 'https://api.z.ai/api/monitor/usage/quota/limit' \
        -H "authorization: Bearer $ZAI_API_KEY" 2>/dev/null) || GLM_DATA=""
    [ -n "$GLM_DATA" ] && echo "$GLM_DATA" > "$GLM_CACHE_FILE"
fi

# Extract percentage and nextResetTime
if [ -n "$GLM_DATA" ]; then
    GLM_LIMIT=$(echo "$GLM_DATA" | jq -r '.data.limits[] | select(.type == "TOKENS_LIMIT")' 2>/dev/null)
    GLM_PERCENTAGE=$(echo "$GLM_LIMIT" | jq -r '.percentage // empty' 2>/dev/null)
    GLM_RESET_TIME=$(echo "$GLM_LIMIT" | jq -r '.nextResetTime // empty' 2>/dev/null)

    if [ -n "$GLM_PERCENTAGE" ]; then
        # Calculate remaining time (nextResetTime is in milliseconds)
        GLM_REMAINING=""
        if [ -n "$GLM_RESET_TIME" ] && [ "$GLM_RESET_TIME" -gt 0 ] 2>/dev/null; then
            NOW_MS=$(($(date +%s) * 1000))
            DIFF_MS=$((GLM_RESET_TIME - NOW_MS))
            if [ "$DIFF_MS" -gt 0 ]; then
                DIFF_SEC=$((DIFF_MS / 1000))
                DIFF_HOURS=$((DIFF_SEC / 3600))
                DIFF_MINS=$(((DIFF_SEC % 3600) / 60))
                [ "$DIFF_HOURS" -gt 0 ] && GLM_REMAINING="${DIFF_HOURS}h"
                [ "$DIFF_MINS" -gt 0 ] && GLM_REMAINING+="${DIFF_MINS}m"
                [ -n "$GLM_REMAINING" ] && GLM_REMAINING="(${GLM_REMAINING})"
            fi
        fi
        GLM_PERCENT=$(awk "BEGIN {v = 100 - $GLM_PERCENTAGE; printf (v == int(v)) ? \"%.0f\" : \"%.1f\", v}")
        echo "GLM: ${GLM_PERCENT}%${GLM_REMAINING}"
    fi
fi
