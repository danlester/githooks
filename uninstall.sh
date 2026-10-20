#!/bin/bash
# Remove githooks for the current user. The settings it added (fetch.prune,
# push.autoSetupRemote, pull.ff, aliases) are left alone.

dir=$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)

if [ "$(git config --global --get core.hooksPath)" = "$dir/hooks" ]; then
    git config --global --unset core.hooksPath
fi

for f in "$dir"/bin/*; do
    link="$HOME/.local/bin/$(basename "$f")"
    [ "$(readlink "$link")" = "$f" ] && rm "$link"
done

for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    [ -f "$rc" ] || continue
    sed -i.githooks-bak -e '/^# githooks: background git fetch$/d' -e '/shell\/prompt-fetch\.sh/d' "$rc" &&
        rm -f "$rc.githooks-bak"
done

echo "githooks uninstalled. Open a new shell to stop the prompt fetch."
