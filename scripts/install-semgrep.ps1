<#
  scripts/install-semgrep.ps1
  Automates semgrep installation on Windows (PowerShell).

  Behavior:
  - Checks for Python. If not present and `winget` is available, proposes to install Python via winget.
  - Installs/updates pip, attempts to install pipx, then semgrep via pipx.
  - Falls back to `python -m pip install semgrep` if pipx isn't available.
  - Provides a Docker fallback command.

  Usage (run in PowerShell as user):
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    .\scripts\install-semgrep.ps1
#>

function Write-Info($msg) { Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Warn($msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Err($msg) { Write-Host "[ERROR] $msg" -ForegroundColor Red }

Write-Info "Starting semgrep installer script..."

# Helper to check command existence
function Cmd-Exists($name) {
    return (Get-Command $name -ErrorAction SilentlyContinue) -ne $null
}

# 1) Check Python
if (-not (Cmd-Exists python)) {
    Write-Warn "Python is not found on PATH."
    if (Cmd-Exists winget) {
        Write-Info "winget found. Installing Python 3 via winget (requires network)."
        Write-Info "You may be prompted for elevated privileges."
        try {
            winget install --id Python.Python.3 -e --source winget
        } catch {
            Write-Warn "winget install failed or was cancelled. Please install Python manually: https://www.python.org/downloads/"
            exit 1
        }
        Write-Info "Python install requested. Please CLOSE and REOPEN PowerShell, then re-run this script."
        exit 0
    } elseif (Cmd-Exists choco) {
        Write-Info "choco found. Installing Python via Chocolatey (requires admin)."
        try {
            choco install python -y
        } catch {
            Write-Warn "choco install failed. Please install Python manually from https://www.python.org/downloads/"
            exit 1
        }
        Write-Info "Python install requested. Please CLOSE and REOPEN PowerShell, then re-run this script."
        exit 0
    } else {
        Write-Err "No package manager found (winget/choco). Please install Python from https://www.python.org/downloads/ and re-run."
        exit 1
    }
}

Write-Info "Python found. Verifying pip..."

# 2) Upgrade pip
try {
    python -m pip install --upgrade pip
} catch {
    Write-Warn "Failed to upgrade pip. Continuing..."
}

# 3) Try installing pipx
$pipxInstalled = $false
try {
    python -m pip show pipx | Out-Null
    $pipxInstalled = $true
} catch {
    $pipxInstalled = $false
}

if (-not $pipxInstalled) {
    Write-Info "Installing pipx (user install)..."
    try {
        python -m pip install --user pipx
        python -m pipx ensurepath
        Write-Info "pipx installed. You may need to CLOSE and REOPEN PowerShell for PATH to update."
    } catch {
        Write-Warn "pipx installation failed. Will fallback to direct pip install for semgrep."
    }
}

# Ensure pipx exists in this session if possible
if (-not (Cmd-Exists pipx)) {
    # try to locate pipx script in user profile
    $userLocal = "$env:USERPROFILE\\.local\\bin"
    if (Test-Path $userLocal) {
        $env:PATH = "$userLocal;" + $env:PATH
    }
}

# 4) Install semgrep via pipx if available, else fallback to pip
if (Cmd-Exists pipx) {
    Write-Info "Installing semgrep via pipx..."
    try {
        pipx install semgrep
        Write-Info "semgrep installed via pipx."
    } catch {
        Write-Warn "pipx install semgrep failed. Trying pip fallback."
        try { python -m pip install semgrep } catch { Write-Err "pip install semgrep also failed."; exit 1 }
    }
} else {
    Write-Info "pipx not found — installing semgrep via pip."
    try { python -m pip install semgrep } catch { Write-Err "pip install semgrep failed. Consider installing pipx or use Docker fallback."; exit 1 }
}

# 5) Verify semgrep
if (Cmd-Exists semgrep) {
    Write-Info "semgrep is available:"; semgrep --version
    Write-Info "Run a test scan now (from project root): semgrep --config=auto ."
    Write-Info "If semgrep command not found after install, CLOSE and REOPEN PowerShell to refresh PATH."
} else {
    Write-Warn "semgrep command still not found. You can run via Python module or Docker as fallback."
    Write-Info "Fallback: python -m semgrep --version"
    Write-Info "Docker fallback: docker run --rm -v ${PWD}:/src returntocorp/semgrep semgrep --config=auto /src"
}

Write-Info "Done."
