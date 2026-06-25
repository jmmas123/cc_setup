#!/usr/bin/env bash
# Regression test for notify.sh.
# The notify.sh hook must NEVER spawn a resident notifier process.
# Resident terminal-notifier instances accumulated until launchservicesd's
# 512-thread pool was exhausted, hanging WindowServer and forcing a reboot
# (2026-06-23). See docs/superpowers/specs/2026-06-23-notify-sh-rewrite-design.md.
set -u
NOTIFY="$HOME/.claude/hooks/notify.sh"
GROUP_PAT='terminal-notifier.*-group com.mitchellh.ghostty.claude'
fail=0

# 1. Static: must not reference terminal-notifier or any residency construct.
for pat in 'terminal-notifier' '\-execute' '\-activate' 'disown' 'ghostty-claude-badge' 'ghostty-focus'; do
    if grep -qE "$pat" "$NOTIFY"; then
        echo "FAIL: notify.sh references forbidden pattern: $pat"
        fail=1
    fi
done

# 2. Static: must deliver via osascript 'display notification'.
if ! grep -q 'display notification' "$NOTIFY"; then
    echo "FAIL: notify.sh does not deliver via 'display notification'"
    fail=1
fi

# 3. Runtime: invoking notify.sh exits 0 and spawns no resident notifier.
before=$(pgrep -f "$GROUP_PAT" 2>/dev/null | wc -l | tr -d ' ')
echo '{}' | "$NOTIFY"
rc=$?
sleep 1
after=$(pgrep -f "$GROUP_PAT" 2>/dev/null | wc -l | tr -d ' ')
if [ "$rc" -ne 0 ]; then echo "FAIL: notify.sh exited $rc (expected 0)"; fail=1; fi
if [ "$after" -gt "$before" ]; then
    echo "FAIL: notify.sh spawned a resident terminal-notifier (before=$before after=$after)"
    fail=1
fi

if [ "$fail" -eq 0 ]; then echo "PASS: notify.sh delivers with no resident process"; fi
exit "$fail"
