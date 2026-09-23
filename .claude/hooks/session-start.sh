#!/bin/bash
# Installs the tools the /watch skill needs (ffmpeg, yt-dlp) in Claude Code on the web.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

if ! command -v ffmpeg >/dev/null 2>&1 || ! command -v ffprobe >/dev/null 2>&1; then
  apt-get update -qq
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq ffmpeg >/dev/null
fi

# Upgrade each session: sites like YouTube break old yt-dlp versions quickly.
pip install -q -U yt-dlp

# Mark /watch setup as done so it skips its first-run questions.
# The Whisper key comes from the GROQ_API_KEY environment variable, never this file.
CONFIG_FILE="$HOME/.config/watch/.env"
mkdir -p "$(dirname "$CONFIG_FILE")"
touch "$CONFIG_FILE"
chmod 600 "$CONFIG_FILE"
grep -q '^SETUP_COMPLETE=' "$CONFIG_FILE" || echo 'SETUP_COMPLETE=true' >> "$CONFIG_FILE"
