#!/bin/bash
# חוסם פקודות שעוקפות את הפרוטוקול

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // ""')

# חסום --no-verify (עוקף pre-commit)
if echo "$command" | grep -q "\-\-no-verify"; then
    echo "🔒 חסום: --no-verify עוקף את הפרוטוקול ואסור." >&2
    exit 2
fi

# חסום force push
if echo "$command" | grep -qE "push.*(--force|-f )"; then
    echo "🔒 חסום: force push פוגע בהיסטוריה." >&2
    exit 2
fi

# חסום מחיקת hooks
if echo "$command" | grep -qE "rm.*\.githooks|rm.*\.git/hooks"; then
    echo "🔒 חסום: מחיקת hooks פוגעת בפרוטוקול." >&2
    exit 2
fi

# חסום שינוי core.hooksPath — רק .githooks מאושר
if echo "$command" | grep -qE "git config.*core\.hooksPath"; then
    if ! echo "$command" | grep -qE "core\.hooksPath\s+\.githooks($|\s)"; then
        echo "🔒 חסום: core.hooksPath חייב להיות .githooks." >&2
        exit 2
    fi
fi

# חסום עריכת settings.json של Claude
if echo "$command" | grep -qE "rm.*\.claude/settings|chmod.*\.claude"; then
    echo "🔒 חסום: שינוי הגדרות Claude פוגע בפרוטוקול." >&2
    exit 2
fi

exit 0
