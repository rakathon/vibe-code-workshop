# Vibe Code Workshop — Windows Setup Script
# Run with: Right-click → "Run with PowerShell" (or: powershell -ExecutionPolicy Bypass -File windows-setup.ps1)

$ErrorActionPreference = "Stop"

$step = 0
$total = 6

function Write-Step($msg) {
    $script:step++
    Write-Host ""
    Write-Host "[$step/$total] $msg" -ForegroundColor Cyan -NoNewline
    Write-Host ""
}
function Write-Ok($msg)   { Write-Host "  v " -ForegroundColor Green  -NoNewline; Write-Host $msg }
function Write-Info($msg) { Write-Host "  > " -ForegroundColor DarkGray -NoNewline; Write-Host $msg -ForegroundColor DarkGray }
function Write-Warn($msg) { Write-Host "  ! " -ForegroundColor Yellow -NoNewline; Write-Host $msg -ForegroundColor Yellow }
function Write-Err($msg)  { Write-Host "  x " -ForegroundColor Red    -NoNewline; Write-Host $msg -ForegroundColor Red }
function Write-Divider    { Write-Host "------------------------------------------------" -ForegroundColor DarkGray }

Clear-Host
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "    Vibe Code Workshop -- Windows Setup         " -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# ── 1. Git ────────────────────────────────────────────────────────────────────
Write-Step "Checking Git"
$gitCmd = Get-Command git -ErrorAction SilentlyContinue
if ($gitCmd) {
    $ver = & git --version
    Write-Ok "Git already installed ($ver)"
    Write-Info "To update Git, download from https://git-scm.com/"
} else {
    Write-Info "Git not found. Installing via winget..."
    winget install --id Git.Git -e --source winget --silent
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    Write-Ok "Git installed"
}

# ── 2. Node.js ────────────────────────────────────────────────────────────────
Write-Step "Checking Node.js"
$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
if ($nodeCmd) {
    $ver = & node --version
    Write-Ok "Node.js already installed ($ver)"
} else {
    Write-Info "Node.js not found. Installing via winget..."
    winget install --id OpenJS.NodeJS.LTS -e --source winget --silent
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    Write-Ok "Node.js installed"
}

# ── 3. Claude Code CLI ────────────────────────────────────────────────────────
Write-Step "Checking Claude Code CLI"
$claudeCmd = Get-Command claude -ErrorAction SilentlyContinue
if ($claudeCmd) {
    $ver = & claude --version 2>$null | Select-Object -First 1
    Write-Ok "Claude Code already installed ($ver)"
    Write-Info "Checking for updates..."
    npm update -g "@anthropic-ai/claude-code" 2>&1 | Out-Null
    Write-Ok "Claude Code is up to date"
} else {
    Write-Info "Installing Claude Code CLI via npm..."
    npm install -g "@anthropic-ai/claude-code"
    $ver = & claude --version 2>$null | Select-Object -First 1
    Write-Ok "Claude Code installed ($ver)"
}

# ── 4. rr-standards via marketplace ──────────────────────────────────────────
Write-Step "Adding rr-standards from marketplace"
Write-Info "Running: claude plugin marketplace add rewards-guilds/rr-standards"
try {
    & claude plugin marketplace add rewards-guilds/rr-standards
    Write-Ok "rr-standards added"
} catch {
    Write-Warn "rr-standards may already be added"
}

# ── 5. Forge plugin ───────────────────────────────────────────────────────────
Write-Step "Installing Forge plugin"
Write-Info "Running: claude plugin install forge"
try {
    & claude plugin install forge
    Write-Ok "Forge plugin installed"
} catch {
    Write-Warn "Forge install issue — may already be installed or require auth first"
}

# ── 6. MCP integrations ───────────────────────────────────────────────────────
Write-Step "Configuring MCP integrations"

Write-Info "Adding Atlassian MCP (HTTP transport)..."
try {
    & claude mcp add --transport http atlassian-v2 https://mcp.atlassian.com/v1/mcp
    Write-Ok "Atlassian MCP added"
} catch {
    Write-Warn "Atlassian MCP may already be configured"
}

Write-Info "Installing Slack plugin..."
try {
    & claude plugin install slack -s user
    Write-Ok "Slack plugin installed"
} catch {
    Write-Warn "Slack plugin may already be installed"
}

# ── Done ──────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Divider
Write-Host ""
Write-Host "  All done! Your machine is ready for the workshop." -ForegroundColor Green
Write-Host ""
Write-Host "  Next steps:" -ForegroundColor DarkGray
Write-Host "  1. Open Claude Code: " -NoNewline; Write-Host "claude" -ForegroundColor Cyan
Write-Host "  2. Authenticate Atlassian MCP inside Claude when prompted"
Write-Host "  3. Authenticate Slack plugin inside Claude when prompted"
Write-Host ""
Write-Host "Press any key to close..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
