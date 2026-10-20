# githooks

Personal, system-wide git hooks and helpers that keep local clones in sync with their remotes.

## Install

```bash
git clone https://github.com/danlester/githooks ~/Dev/.githooks
~/Dev/.githooks/install.sh
```

The clone is the live copy: git runs the hooks straight from it, so keep it where it is.
To update, run `git hooks-update`. A notice appears at your prompt (at most once a day) when updates are available.
To remove, run `uninstall.sh`.

## What it does

### Hooks

Installed via a global `core.hooksPath`. Each hook runs our version (in `hooks.d/`) and then the repository's own `.git/hooks/<name>`, so per-repo hooks keep working. Repositories that set their own `core.hooksPath` (e.g. Husky) are unaffected.

- **post-checkout**, when switching branches:
  - fetches `origin` with pruning
  - deletes local branches whose remote branch has gone (usually merged PRs). If a branch has commits that aren't on any remote, they are first saved under `refs/attic/<branch>/<timestamp>`.
    List with `git for-each-ref refs/attic`, restore with `git branch <name> refs/attic/<branch>/<timestamp>`.
  - warns if the new branch is behind its upstream
- **pre-push**: refuses to push a branch whose remote branch was deleted, which would otherwise quietly re-create a merged branch. New branches push normally. Bypass with `--no-verify`.

### Background fetch

Sourced from `~/.bashrc` / `~/.zshrc`. When you're in a repo that hasn't been fetched for 5 minutes, it fetches in the background, so `git status` doesn't report "up to date" against stale data. It never prompts for credentials.

### Commands

| Command | |
|---|---|
| `git new <branch> [<base>]` | Fetch, then create `<branch>` from the remote default branch (or `<base>`) |
| `git sync` | Fetch all remotes with pruning, then fast-forward the current branch |
| `git update` | `git pull --rebase` |
| `git publish` | `git push -u origin HEAD` |
| `git hooks-update` | Update githooks and re-run the install |

### Git settings

`fetch.prune=true`, `push.autoSetupRemote=true`, `pull.ff=only`.
