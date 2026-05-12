#!/usr/bin/env bash
set -euo pipefail

# Tee all output to a log file so we can inspect after startup, since Ona
# doesn't surface install.sh stdout/stderr in the UI.
exec > >(tee -a /tmp/dotfiles-install.log) 2>&1

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

log() { echo "[dotfiles] $*"; }

# --- Wait for workspace repo ---
# Dotfiles install.sh can run before the target repo finishes cloning.
# Poll until at least one non-dotfiles git repo appears under /workspaces/.

wait_for_workspace_repo() {
    local timeout=120  # seconds
    local interval=2
    local elapsed=0

    while (( elapsed < timeout )); do
        for dir in /workspaces/*/; do
            [[ -d "${dir}.git" ]] || continue
            # Skip the dotfiles repo itself
            local origin
            origin="$(cd "$dir" && git remote get-url origin 2>/dev/null)" || true
            [[ "$origin" == *"/dotfiles"* ]] && continue
            log "Found workspace repo: $dir"
            return 0
        done
        sleep "$interval"
        elapsed=$(( elapsed + interval ))
    done

    log "Timed out after ${timeout}s waiting for a workspace repo to appear"
    return 1
}

# --- Skills ---
# Symlink each skill into the workspace's .ona/skills/ directory.
# Skip skills that already exist (repo-level takes precedence).
# Add symlinked skill names to .ona/skills/.gitignore to prevent git noise.

install_skills() {
    # Find the workspace root. During environment startup this script runs
    # from ~/dotfiles, so "git rev-parse" would resolve to the dotfiles repo
    # itself. Instead, look for git repos under /workspaces, skipping the
    # dotfiles repo. Installs skills into ALL workspace repos found.
    local repos=()
    for dir in /workspaces/*/; do
        [[ -d "${dir}.git" ]] || continue
        # Skip if this is the dotfiles repo itself
        [[ "$(cd "$dir" && git remote get-url origin 2>/dev/null)" == *"/dotfiles"* ]] && continue
        repos+=("${dir%/}")
    done

    if [[ ${#repos[@]} -eq 0 ]]; then
        log "No git repos found under /workspaces — skipping skill installation"
        return
    fi

    for workspace_root in "${repos[@]}"; do
        log "Installing skills into $workspace_root"
        _install_skills_into "$workspace_root"
    done
}

_install_skills_into() {
    local workspace_root="$1"

    local skills_src="$DOTFILES_DIR/.ona/skills"
    local skills_dst="$workspace_root/.ona/skills"

    if [[ ! -d "$skills_src" ]]; then
        log "No skills directory in dotfiles — skipping"
        return
    fi

    mkdir -p "$skills_dst"

    local gitignore="$skills_dst/.gitignore"

    for skill_dir in "$skills_src"/*/; do
        [[ -d "$skill_dir" ]] || continue
        local skill_name
        skill_name="$(basename "$skill_dir")"

        # Skip if skill already exists and is NOT a symlink we created
        if [[ -e "$skills_dst/$skill_name" && ! -L "$skills_dst/$skill_name" ]]; then
            log "Skill '$skill_name' exists in repo — skipping"
            continue
        fi

        # Create or update symlink
        ln -sfn "$skill_dir" "$skills_dst/$skill_name"
        log "Symlinked skill '$skill_name'"

        # Add to .gitignore if not already present
        if [[ ! -f "$gitignore" ]] || ! grep -qxF "$skill_name" "$gitignore"; then
            echo "$skill_name" >> "$gitignore"
            log "Added '$skill_name' to .ona/skills/.gitignore"
        fi
    done
}

# --- Shell ---
# Back up existing .zshrc (if not already our symlink), then symlink ours.

install_shell() {
    local src="$DOTFILES_DIR/shell/.zshrc"
    local dst="$HOME/.zshrc"

    if [[ ! -f "$src" ]]; then
        log "No .zshrc in dotfiles — skipping"
        return
    fi

    # Already symlinked to our file — nothing to do
    if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
        log ".zshrc already symlinked"
        return
    fi

    # Back up existing file
    if [[ -e "$dst" || -L "$dst" ]]; then
        mv "$dst" "${dst}.bak"
        log "Backed up existing .zshrc to .zshrc.bak"
    fi

    ln -s "$src" "$dst"
    log "Symlinked .zshrc"

    # Set default shell to zsh if available
    if command -v zsh >/dev/null 2>&1; then
        local current_shell
        current_shell="$(grep "^$(whoami):" /etc/passwd 2>/dev/null | cut -d: -f7)" || true
        local zsh_path
        zsh_path="$(command -v zsh)"

        if [[ "$current_shell" != "$zsh_path" ]]; then
            if command -v sudo >/dev/null 2>&1; then
                sudo chsh -s "$zsh_path" "$(whoami)" 2>/dev/null && \
                    log "Set default shell to zsh" || \
                    log "Could not set default shell to zsh (chsh failed)"
            else
                log "sudo not available — skipping chsh"
            fi
        else
            log "Default shell already zsh"
        fi
    else
        log "zsh not found — skipping shell change"
    fi
}

# --- Git ---
# Symlink .gitconfig to home directory.

install_git() {
    local src="$DOTFILES_DIR/git/.gitconfig"
    local dst="$HOME/.gitconfig"

    if [[ ! -f "$src" ]]; then
        log "No .gitconfig in dotfiles — skipping"
        return
    fi

    # Already symlinked to our file
    if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
        log ".gitconfig already symlinked"
        return
    fi

    # Back up existing file if present
    if [[ -e "$dst" || -L "$dst" ]]; then
        mv "$dst" "${dst}.bak"
        log "Backed up existing .gitconfig to .gitconfig.bak"
    fi

    ln -s "$src" "$dst"
    log "Symlinked .gitconfig"
}

# --- VS Code ---
# Symlink settings.json to user-level VS Code config.

install_vscode() {
    local src="$DOTFILES_DIR/vscode/settings.json"
    local dst_dir="$HOME/.vscode"
    local dst="$dst_dir/settings.json"

    if [[ ! -f "$src" ]]; then
        log "No VS Code settings in dotfiles — skipping"
        return
    fi

    mkdir -p "$dst_dir"

    # Already symlinked to our file
    if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
        log "VS Code settings already symlinked"
        return
    fi

    # Back up existing file if present
    if [[ -e "$dst" || -L "$dst" ]]; then
        mv "$dst" "${dst}.bak"
        log "Backed up existing VS Code settings"
    fi

    ln -s "$src" "$dst"
    log "Symlinked VS Code settings"
}

# --- Claude Code ---
# Install superpowers plugin for Claude Code.
#
# Race condition: The Ona platform writes Claude's settings.json (proxy/auth
# config) during environment startup. If we install a plugin before that write
# happens, the platform's write can clobber the enabledPlugins entry, leaving
# the plugin installed but disabled. We wait for Claude initialization to
# complete before installing, and explicitly enable the plugin afterward.

wait_for_claude_init() {
    local timeout=120
    local interval=2
    local elapsed=0
    local settings="$HOME/.claude/settings.json"

    while (( elapsed < timeout )); do
        # The platform injects ANTHROPIC_BASE_URL into settings.json when
        # Claude Code is fully initialized.
        if [[ -f "$settings" ]] && grep -q "ANTHROPIC_BASE_URL" "$settings" 2>/dev/null; then
            log "Claude Code initialized (settings.json ready)"
            return 0
        fi
        sleep "$interval"
        elapsed=$(( elapsed + interval ))
    done

    log "Timed out after ${timeout}s waiting for Claude Code initialization"
    return 1
}

install_claude_code() {
    if ! command -v claude >/dev/null 2>&1; then
        log "claude not found — skipping Claude Code plugin install"
        return
    fi

    # Wait for the platform to finish writing Claude's settings.json so our
    # plugin enable state doesn't get clobbered.
    if ! wait_for_claude_init; then
        log "Proceeding with plugin install despite init timeout"
    fi

    # Check if already installed and enabled
    if claude plugin list --json 2>/dev/null | grep -q '"enabled": true'; then
        log "Claude Code superpowers plugin already installed and enabled"
        return
    fi

    # Register the official Claude plugin marketplace if not already present
    if ! claude plugin marketplace list 2>/dev/null | grep -q "claude-plugins-official"; then
        claude plugin marketplace add anthropics/claude-plugins-official 2>/dev/null && \
            log "Added claude-plugins-official marketplace" || \
            { log "Could not add claude-plugins-official marketplace"; return; }
    fi

    # Install if not already present
    if ! claude plugin list 2>/dev/null | grep -q "superpowers"; then
        claude plugin install superpowers@claude-plugins-official --scope user 2>/dev/null && \
            log "Installed Claude Code superpowers plugin" || \
            { log "Could not install Claude Code superpowers plugin"; return; }
    fi

    # Explicitly enable — guards against the race where install succeeded but
    # the platform overwrote settings.json before we got here.
    # Note: `claude plugin enable` exits non-zero if already enabled, so we
    # check the current state afterward instead of relying on the exit code.
    claude plugin enable superpowers@claude-plugins-official 2>/dev/null || true

    if claude plugin list --json 2>/dev/null | grep -q '"enabled": true'; then
        log "Claude Code superpowers plugin is enabled"
    else
        log "Claude Code superpowers plugin could not be enabled"
    fi
}

# --- AGENTS.md ---
# Symlink AGENTS.md into each workspace repo so the superpowers bootstrap
# is loaded automatically. Skip repos that already have their own AGENTS.md.

install_agents_md() {
    local src="$DOTFILES_DIR/AGENTS.md"

    if [[ ! -f "$src" ]]; then
        log "No AGENTS.md in dotfiles — skipping"
        return
    fi

    for dir in /workspaces/*/; do
        [[ -d "${dir}.git" ]] || continue
        [[ "$(cd "$dir" && git remote get-url origin 2>/dev/null)" == *"/dotfiles"* ]] && continue

        local dst="${dir}AGENTS.md"

        # Skip if AGENTS.md exists and is NOT a symlink we created
        if [[ -e "$dst" && ! -L "$dst" ]]; then
            log "AGENTS.md exists in $(basename "$dir") — skipping"
            continue
        fi

        ln -sfn "$src" "$dst"
        log "Symlinked AGENTS.md into $(basename "$dir")"
    done
}

# --- Main ---

log "Installing dotfiles from $DOTFILES_DIR"

# Shell, git, and vscode config don't depend on workspace repos — install first.
install_shell
install_git
install_vscode
install_claude_code

# Skills and AGENTS.md target workspace repos that may still be cloning.
if wait_for_workspace_repo; then
    install_skills
    install_agents_md
else
    log "No workspace repos found — skipping skills and AGENTS.md installation"
fi

log "Done"
