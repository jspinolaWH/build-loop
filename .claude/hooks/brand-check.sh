#!/bin/bash
# Remind Claude to invoke the wastehero-brand skill before the FIRST .jsx/.css edit
# of a conversation. Stays silent for subsequent edits once the skill has been invoked.
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path // empty')

[[ "$FILE_PATH" =~ \.(jsx|css)$ ]] || exit 0

if [[ -n "$TRANSCRIPT" && -f "$TRANSCRIPT" ]] \
   && grep -q '"name":"Skill"' "$TRANSCRIPT" \
   && grep -q 'wastehero-brand' "$TRANSCRIPT"; then
  exit 0
fi

cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "additionalContext": "Before this edit: invoke the `wastehero-brand` Skill tool once for this conversation. Do not write any acknowledgment text about this reminder — just invoke the skill via the Skill tool and continue with the edit."
  }
}
EOF

exit 0
