#!/bin/bash
# חוסם פקודות ופעולות שעוקפות את הפרוטוקול
# חל על: Bash, Edit, Write, NotebookEdit

input=$(cat)
tool=$(echo "$input" | jq -r '.tool_name // ""')
command=$(echo "$input" | jq -r '.tool_input.command // ""')
file_path=$(echo "$input" | jq -r '.tool_input.file_path // ""')

# ─── שכבת הגנה: עריכה ישירה של קבצי הגנה ───
# חל על Edit/Write/NotebookEdit
PROTECTED_PATHS=(
    ".githooks/pre-commit"
    ".githooks/pre-push"
    ".githooks/commit-msg"
    ".claude/settings.json"
    ".claude/hooks/pre-tool.sh"
    ".claude/hooks/session-start.sh"
    ".github/workflows/protocol-enforce.yml"
    ".git/config"
    ".git/hooks/pre-commit"
    ".git/hooks/pre-push"
    ".git/hooks/commit-msg"
)

if [[ "$tool" =~ ^(Edit|Write|NotebookEdit)$ ]] && [[ -n "$file_path" ]]; then
    for protected in "${PROTECTED_PATHS[@]}"; do
        if [[ "$file_path" == *"$protected" ]]; then
            echo "🔒 חסום: עריכת קובץ הגנה ($protected) דורשת הוראה מפורשת מהמשתמש." >&2
            echo "   אם הוראה ניתנה — צור קובץ .allow_protocol_edit ב-repo root עם כותרת ההוראה." >&2
            REPO=$(git -C "$(dirname "$file_path")" rev-parse --show-toplevel 2>/dev/null || echo "")
            if [[ -n "$REPO" && -f "$REPO/.allow_protocol_edit" ]]; then
                # רשום שהפעולה אושרה
                echo "[$(date)] allowed edit: $file_path" >> "$REPO/.git/protocol_audit.log"
                exit 0
            fi
            exit 2
        fi
    done
fi

# ─── שכבת הגנה: פקודות Bash ───
if [[ "$tool" != "Bash" ]]; then
    exit 0
fi

# חסום --no-verify בכל צורה
if echo "$command" | grep -qE -- "(^|[^a-zA-Z0-9_])--no-verify"; then
    echo "🔒 חסום: --no-verify עוקף את הפרוטוקול ואסור." >&2
    exit 2
fi

# חסום core.hooksPath inline override
if echo "$command" | grep -qE "git\s+(-c\s+)?core\.hooksPath\s*="; then
    echo "🔒 חסום: -c core.hooksPath= עוקף hooks." >&2
    exit 2
fi
if echo "$command" | grep -qE "git\s+-c\s+core\.hooksPath"; then
    echo "🔒 חסום: -c core.hooksPath עוקף hooks." >&2
    exit 2
fi

# חסום כל סוגי force push
if echo "$command" | grep -qE "push.*(-{1,2}force|--force-with-lease|--force-if-includes|-f\s|-f$)"; then
    echo "🔒 חסום: force push פוגע בהיסטוריה." >&2
    exit 2
fi
# refspec force (+branch)
if echo "$command" | grep -qE "git\s+push\s+[^[:space:]]+\s+\+"; then
    echo "🔒 חסום: refspec force push (+branch) פוגע בהיסטוריה." >&2
    exit 2
fi

# חסום מחיקה/השמדה של hooks בכל צורה
DANGER_FILES="\.githooks|\.git/hooks|\.claude/settings|\.claude/hooks|\.github/workflows/protocol-enforce"
if echo "$command" | grep -qE "(rm|unlink)\s+.*($DANGER_FILES)"; then
    echo "🔒 חסום: מחיקת קובץ הגנה." >&2
    exit 2
fi
if echo "$command" | grep -qE "find\s+.*($DANGER_FILES).*-delete"; then
    echo "🔒 חסום: find -delete על קובץ הגנה." >&2
    exit 2
fi
if echo "$command" | grep -qE "mv\s+.*($DANGER_FILES)"; then
    echo "🔒 חסום: mv על קובץ הגנה." >&2
    exit 2
fi
# truncate via redirect: > file או echo "" >
if echo "$command" | grep -qE ">\s*[^|&;]*($DANGER_FILES)"; then
    echo "🔒 חסום: redirect (>) לקובץ הגנה — שכתוב/השמדה." >&2
    exit 2
fi
# overwrite via cp — אבל לאפשר sync מ-.githooks ל-.git/hooks
# בדוק את כל הcp שיש בפקודה — אם כולם הם sync לגיטימי, מותר
if echo "$command" | grep -qE "cp\s+.*\s+.*($DANGER_FILES)"; then
    # פצל לפי && ו-; ו-|
    bad_cp=""
    while IFS= read -r segment; do
        if echo "$segment" | grep -qE "cp\s+.*\s+.*($DANGER_FILES)"; then
            if ! echo "$segment" | grep -qE "cp\s+[^[:space:]]*\.githooks/[a-z-]+\s+[^[:space:]]*\.git/hooks/[a-z-]+\s*$"; then
                bad_cp="$segment"
                break
            fi
        fi
    done < <(echo "$command" | tr '&;|' '\n')
    if [[ -n "$bad_cp" ]]; then
        echo "🔒 חסום: cp לקובץ הגנה (חוץ מsync מ-.githooks)." >&2
        echo "   נמצא: $bad_cp" >&2
        exit 2
    fi
fi
if echo "$command" | grep -qE "sed\s+-i\s+.*($DANGER_FILES)"; then
    echo "🔒 חסום: sed -i על קובץ הגנה." >&2
    exit 2
fi

# חסום שינוי core.hooksPath — רק .githooks מאושר
if echo "$command" | grep -qE "git\s+config.*core\.hooksPath"; then
    if ! echo "$command" | grep -qE "core\.hooksPath\s+\.githooks($|\s|$)"; then
        echo "🔒 חסום: core.hooksPath חייב להיות .githooks." >&2
        exit 2
    fi
fi

# חסום aliases מסוכנים
if echo "$command" | grep -qE "git\s+config\s+alias\."; then
    if echo "$command" | grep -qE "(no-verify|force|hooksPath)"; then
        echo "🔒 חסום: alias שעוקף את הפרוטוקול." >&2
        exit 2
    fi
fi

# חסום eval של git
if echo "$command" | grep -qE "eval\s+.*git\s+(commit|push)"; then
    echo "🔒 חסום: eval של git commit/push — עלול לעקוף בדיקות." >&2
    exit 2
fi

exit 0
