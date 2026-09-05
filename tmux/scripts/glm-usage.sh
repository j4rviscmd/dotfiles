#!/usr/bin/env bash
# GLM usage quota script for tmux statusline
# Output format: 💠 75%(1h30m)
#
# Requires: GLM_TOKEN environment variable, jq, curl
# Cache: 60 seconds

set -euo pipefail

# Environment variable loading (SSOT: repo直下.env)
[ -f ~/.config/.env ] && source ~/.config/.env

# Skip if GLM_TOKEN is not set
[ -z "${GLM_TOKEN:-}" ] && exit 0

# Require jq
command -v jq &>/dev/null || exit 0

GLM_CACHE_FILE="/tmp/claude-glm-usage.cache"
GLM_DATA=""

# Cache check (60 seconds)
if [ -f "$GLM_CACHE_FILE" ]; then
    CACHE_MTIME=$(stat -f %m "$GLM_CACHE_FILE" 2>/dev/null || stat -c %Y "$GLM_CACHE_FILE" 2>/dev/null)
    [ $(($(date +%s) - CACHE_MTIME)) -lt 60 ] && GLM_DATA=$(cat "$GLM_CACHE_FILE")
fi

# Fetch from API if cache is stale
if [ -z "$GLM_DATA" ]; then
    GLM_DATA=$(curl -s 'https://api.z.ai/api/monitor/usage/quota/limit' \
        -H "authorization: Bearer $GLM_TOKEN" 2>/dev/null) || GLM_DATA=""
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
