#!/usr/bin/env bash
# Cross-platform installer helper (Linux / macOS / WSL)
set -euo pipefail

# Ensure we're running under bash (so "pipefail" is available).
if [ -z "${BASH_VERSION:-}" ]; then
  if command -v bash >/dev/null 2>&1; then
    exec bash "$0" "$@"
  else
    # No bash available — fall back to POSIX-compatible options (no pipefail).
    set -eu
  fi
else
  # Running under bash — enable strict mode including pipefail.
  set -euo pipefail
fi

BIN_DIR="/usr/local/bin"
FORCE=0

usage(){
  cat <<EOF
Usage: $0 [--bin <dir>] [--force]
--bin <dir>   install directory (default: /usr/local/bin)
--force       reinstall even if task exists
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --bin) BIN_DIR="$2"; shift 2;;
    --force) FORCE=1; shift;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1"; usage; exit 1;;
  esac
done

if command -v task >/dev/null 2>&1 && [ "$FORCE" -ne 1 ]; then
  echo "task already installed: $(task --version 2>/dev/null || echo 'unknown')"
  exit 0
fi

if command -v curl >/dev/null 2>&1 || command -v wget >/dev/null 2>&1; then
  echo "Installing task using the official installer to $BIN_DIR..."
  if command -v curl >/dev/null 2>&1; then
    curl -sSfL https://taskfile.dev/install.sh | sh -s -- -d -b "$BIN_DIR"
  else
    wget -qO- https://taskfile.dev/install.sh | sh -s -- -d -b "$BIN_DIR"
  fi

  if command -v task >/dev/null 2>&1; then
    echo "Installed: $(task --version)"
    exit 0
  fi
fi

# Fallback guidance for common package managers
echo "Automatic installer failed or not available. Try one of the following manually:"
echo ""
echo "Linux (Debian/Ubuntu):"
echo "  sudo apt update && sudo apt install -y curl && curl -sSfL https://taskfile.dev/install.sh | sh -s -- -d -b /usr/local/bin"
echo ""
echo "Linux (Fedora/CentOS):"
echo "  sudo dnf install -y curl && curl -sSfL https://taskfile.dev/install.sh | sh -s -- -d -b /usr/local/bin"
echo ""
echo "Alpine:"
echo "  apk add --no-cache curl && curl -sSfL https://taskfile.dev/install.sh | sh -s -- -d -b /usr/local/bin"
echo ""
echo "macOS (Homebrew):"
echo "  brew install go-task/tap/go-task || curl -sSfL https://taskfile.dev/install.sh | sh -s -- -d -b /usr/local/bin"
echo ""
echo "Windows (PowerShell - run as Administrator):"
echo "  iwr https://taskfile.dev/install.ps1 -UseBasicParsing | iex"
echo ""
echo "If you prefer package managers, look for 'go-task' / 'task' in your distro's repos or use Homebrew/Chocolatey/Scoop."
exit 1