#!/bin/bash
# Vibe Code Workshop — Mac Setup Script

set -euo pipefail

# ── colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; DIM='\033[2m'; RESET='\033[0m'

step=0
total=7

log_step() {
  step=$((step + 1))
  echo ""
  echo -e "${BOLD}${CYAN}[${step}/${total}] $1${RESET}"
}
log_ok()   { echo -e "  ${GREEN}✓${RESET} $1"; }
log_info() { echo -e "  ${DIM}→ $1${RESET}"; }
log_warn() { echo -e "  ${YELLOW}⚠${RESET}  $1"; }

divider() { echo -e "${DIM}────────────────────────────────────────────────${RESET}"; }

clear
echo ""
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${CYAN}║     Vibe Code Workshop — Mac Setup           ║${RESET}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════╝${RESET}"
echo ""

# ── 1. Homebrew ───────────────────────────────────────────────────────────────
log_step "Checking Homebrew"
if command -v brew &>/dev/null; then
  log_ok "Homebrew already installed ($(brew --version | head -1))"
  brew update --quiet 2>&1 | tail -1 || true
else
  log_info "Installing Homebrew…"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  [[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
  log_ok "Homebrew installed"
fi

# ── 2. Git ────────────────────────────────────────────────────────────────────
log_step "Checking Git"
if command -v git &>/dev/null; then
  log_ok "Git already installed ($(git --version | awk '{print $3}'))"
  brew upgrade git 2>/dev/null && log_ok "Git updated" || log_info "Already up to date"
else
  log_info "Installing Git…"
  brew install git
  log_ok "Git installed"
fi

# ── 3. Node.js ────────────────────────────────────────────────────────────────
log_step "Checking Node.js"
if command -v node &>/dev/null; then
  log_ok "Node already installed ($(node --version))"
else
  log_info "Installing Node.js via brew…"
  brew install node
  log_ok "Node.js installed"
fi

# ── 4. Claude Code CLI ────────────────────────────────────────────────────────
log_step "Checking Claude Code CLI"
if command -v claude &>/dev/null; then
  log_ok "Claude Code already installed ($(claude --version 2>/dev/null | head -1))"
  npm update -g @anthropic-ai/claude-code 2>&1 | grep -E "(added|updated|unchanged)" || true
  log_ok "Claude Code is up to date"
else
  log_info "Installing Claude Code CLI…"
  npm install -g @anthropic-ai/claude-code
  log_ok "Claude Code installed"
fi

# ── 5. rr-standards via marketplace ──────────────────────────────────────────
log_step "Adding rr-standards from marketplace"
if claude plugin marketplace add rewards-guilds/rr-standards 2>&1; then
  log_ok "rr-standards added"
else
  log_warn "rr-standards may already be added"
fi

# ── 6. Forge plugin ───────────────────────────────────────────────────────────
log_step "Installing Forge plugin"
if claude plugin install forge 2>&1; then
  log_ok "Forge plugin installed"
else
  log_warn "Forge may already be installed"
fi

# ── 7. MCP integrations ───────────────────────────────────────────────────────
log_step "Configuring MCP integrations"
if claude mcp add --transport http atlassian-v2 https://mcp.atlassian.com/v1/mcp 2>&1; then
  log_ok "Atlassian MCP added"
else
  log_warn "Atlassian MCP may already be configured"
fi

if claude plugin install slack -s user 2>&1; then
  log_ok "Slack plugin installed"
else
  log_warn "Slack plugin may already be installed"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
divider
echo ""
echo -e "${BOLD}${GREEN}  All done! Your machine is ready for the workshop.${RESET}"
echo ""
echo -e "  ${DIM}Next steps:${RESET}"
echo -e "  ${CYAN}1.${RESET} Open Claude Code:  ${BOLD}claude${RESET}"
echo -e "  ${CYAN}2.${RESET} Authenticate Atlassian MCP inside Claude when prompted"
echo -e "  ${CYAN}3.${RESET} Authenticate Slack plugin inside Claude when prompted"
echo ""
echo -e "${DIM}  Press any key to close this window…${RESET}"
read -n 1 -s
