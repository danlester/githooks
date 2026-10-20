# Sourced from ~/.bashrc / ~/.zshrc by install.sh, which sets GITHOOKS_DIR.
#
# On each prompt:
#  - if you're in a git repo that hasn't been fetched for 5 minutes, fetch it
#    in the background, so 'git status' ahead/behind counts stay current
#  - once a day, check whether githooks itself has updates

__githooks_stale() { # <file> <minutes>
    [ ! -f "$1" ] || [ -n "$(find "$1" -mmin +"$2" 2>/dev/null)" ]
}

__githooks_prompt() {
    local gd self
    if gd=$(git rev-parse --git-common-dir 2>/dev/null) &&
        git remote get-url origin >/dev/null 2>&1 &&
        __githooks_stale "$gd/.last-bg-fetch" 5; then
        touch "$gd/.last-bg-fetch" 2>/dev/null
        (GIT_TERMINAL_PROMPT=0 GIT_SSH_COMMAND="${GIT_SSH_COMMAND:-ssh -o BatchMode=yes}" \
            git fetch --quiet --prune origin >/dev/null 2>&1 &)
    fi

    [ -n "$GITHOOKS_DIR" ] && [ -d "$GITHOOKS_DIR/.git" ] || return 0
    self="$GITHOOKS_DIR/.git"
    if [ -f "$self/githooks-update-available" ]; then
        rm -f "$self/githooks-update-available"
        echo "githooks: updates available. Run 'git hooks-update'."
    fi
    if __githooks_stale "$self/.last-update-check" 1440; then
        touch "$self/.last-update-check" 2>/dev/null
        (GIT_TERMINAL_PROMPT=0 git -C "$GITHOOKS_DIR" fetch --quiet >/dev/null 2>&1 &&
            [ "$(git -C "$GITHOOKS_DIR" rev-list --count HEAD..@{u} 2>/dev/null || echo 0)" -gt 0 ] &&
            touch "$self/githooks-update-available" &)
    fi
}

if [ -n "$ZSH_VERSION" ]; then
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd __githooks_prompt
elif [ -n "$BASH_VERSION" ]; then
    case "$(declare -p PROMPT_COMMAND 2>/dev/null)" in
        "declare -a"*)
            [[ " ${PROMPT_COMMAND[*]} " == *" __githooks_prompt "* ]] || PROMPT_COMMAND+=(__githooks_prompt)
            ;;
        *)
            [[ "$PROMPT_COMMAND" == *__githooks_prompt* ]] ||
                PROMPT_COMMAND="__githooks_prompt${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
            ;;
    esac
fi
