#!/usr/bin/env bash
# Robust cross-platform-ish setup helper for Debian-based systems (devcontainer / WSL / Linux / macOS)
# Ensures python3-venv, curl and uv are installed. Use sudo if not running as root.
set -euo pipefail

# Helpers
print_err() { printf '%s\n' "$*" >&2; }

# Determine privilege helper
SUDO=""
if [ "$(id -u)" -ne 0 ]; then
  if command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  else
    print_err "This script requires root privileges. Rerun as root or install sudo."
    exit 1
  fi
fi

# Use noninteractive frontend for apt
export DEBIAN_FRONTEND=noninteractive

# Retry apt-get commands to work around transient lock (dpkg lock) issues.
apt_retry() {
  local max_retries=8
  local sleep_sec=2
  local i=0
  until [ "$i" -ge "$max_retries" ]; do
    if $SUDO apt-get update && $SUDO apt-get install -y --no-install-recommends "$@"; then
      return 0
    fi
    i=$((i + 1))
    print_err "apt-get failed (attempt $i/$max_retries). Retrying in ${sleep_sec}s..."
    sleep "$sleep_sec"
  done
  print_err "apt-get failed after $max_retries attempts."
  return 1
}

# Install system packages (Debian/Ubuntu)
# Only attempt apt on Linux; skip on macOS (user should use brew).
if [ "$(uname -s)" = "Linux" ]; then
  # Ensure apt is available
  if command -v apt-get >/dev/null 2>&1; then
    apt_retry python3-venv curl python3-pip || {
      print_err "Unable to install system packages via apt-get."
      exit 1
    }
  else
    print_err "apt-get not found. Please install python3-venv and curl via your package manager."
  fi
else
  # macOS / others: recommend Homebrew
  if command -v brew >/dev/null 2>&1; then
    brew install python3 curl || true
  else
    print_err "Non-Linux system detected and Homebrew not available. Install python3 and curl manually."
  fi
fi

# Ensure pip is available
if ! command -v pip3 >/dev/null 2>&1; then
  print_err "pip3 not found after installing python3-pip. You may need to install pip manually."
fi

# Install uv (prefer --user for non-root)
if python3 -m pip show uv >/dev/null 2>&1; then
  printf 'uv is already installed\n'
else
  if [ "$(id -u)" -eq 0 ]; then
    python3 -m pip install --upgrade pip
    python3 -m pip install uv
  else
    python3 -m pip install --user --upgrade pip
    python3 -m pip install --user uv
    # Ensure user's local bin is on PATH suggestion
    local_bin="$(python3 -m site --user-base)/bin"
    printf 'If "uv" is not found after install, add %s to your PATH (e.g. export PATH="$PATH:%s")\n' "$local_bin" "$local_bin"
  fi
fi

# Check that python3, uv, and curl are installed and available
missing_tools=()
success_tools=()

if command -v python3 >/dev/null 2>&1; then
    echo "✅ Python is installed"
else
    echo "❌ Python is not installed"
fi

if command -v uv >/dev/null 2>&1; then
    echo "✅ Uv is installed"
else
    echo  "❌ Uv is not installed"
fi

if command -v curl >/dev/null 2>&1; then
    echo "✅ Curl is installed"
else
    echo "❌ Curl is not installed"
fi

printf 'Setup completed successfully.\n'