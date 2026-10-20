#!/bin/bash
# Install githooks for the current user. Safe to re-run.
set -e

dir=$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)

# Global hooks
previous=$(git config --global --get core.hooksPath || true)
if [ -n "$previous" ] && [ "$previous" != "$dir/hooks" ]; then
    echo "⚠️  Replacing previous global core.hooksPath: $previous"
fi
git config --global core.hooksPath "$dir/hooks"

# Git settings
git config --global fetch.prune true
git config --global push.autoSetupRemote true
git config --global pull.ff only
git config --global alias.update 'pull --rebase'
git config --global alias.publish 'push -u origin HEAD'

# Commands: git new, git sync, git hooks-update
mkdir -p "$HOME/.local/bin"
for f in "$dir"/bin/*; do
    ln -sfn "$f" "$HOME/.local/bin/$(basename "$f")"
done
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) echo "⚠️  ~/.local/bin is not on your PATH. Add it to use git new / git sync / git hooks-update." ;;
esac

# Background fetch from the shell prompt
line="GITHOOKS_DIR=\"$dir\"; [ -f \"\$GITHOOKS_DIR/shell/prompt-fetch.sh\" ] && . \"\$GITHOOKS_DIR/shell/prompt-fetch.sh\""
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    [ -f "$rc" ] || continue
    if ! grep -qF "shell/prompt-fetch.sh" "$rc"; then
        printf '\n# githooks: background git fetch\n%s\n' "$line" >>"$rc"
        echo "Added prompt fetch to $rc (open a new shell to start it)"
    fi
done

echo "✅ githooks installed from $dir"
