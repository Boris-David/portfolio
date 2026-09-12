#!/usr/bin/env bash
#
# Journalise ce qui s'est RÉELLEMENT chargé comme instructions.
#
# Sert à falsifier le scoping : si une règle scopée `paths:` apparaît dans une
# session qui ne touche pas son périmètre, le scoping ne tient pas — et on le
# voit ici au lieu de le supposer.
set -euo pipefail
input="$(cat)"
log_dir="${CLAUDE_PROJECT_DIR:-.}/.claude"
mkdir -p "$log_dir"
printf '%s\t%s\t%s\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  "$(printf '%s' "$input" | jq -r '.load_reason // "?"')" \
  "$(printf '%s' "$input" | jq -r '.file_path // "?"')" \
  >> "$log_dir/instructions-loaded.log"
exit 0
