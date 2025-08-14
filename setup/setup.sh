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
    apt_retry python3-venv curl python3-pip git || {
      print_err "Unable to install system packages via apt-get."
      exit 1
    }
  else
    print_err "apt-get not found. Please install python3-venv and curl via your package manager."
  fi
else
  # macOS / others: recommend Homebrew
  if command -v brew >/dev/null 2>&1; then
    brew install python3 curl git || true
  else
    print_err "Non-Linux system detected and Homebrew not available. Install python3, curl, and git manually."
  fi
fi

# Ensure pip is available
if ! command -v pip3 >/dev/null 2>&1; then
  print_err "pip3 not found after installing python3-pip. You may need to install pip manually."
fi

# Install uv (prefer --user for non-root, use --break-system-packages in containers)
if python3 -m pip show uv >/dev/null 2>&1; then
  printf 'uv is already installed\n'
else
  if [ "$(id -u)" -eq 0 ]; then
    python3 -m pip install --upgrade pip --break-system-packages
    python3 -m pip install uv --break-system-packages
  else
    # Try user install first, fallback to break-system-packages if needed (for containers)
    if ! python3 -m pip install --user --upgrade pip 2>/dev/null; then
      python3 -m pip install --upgrade pip --break-system-packages 2>/dev/null || true
    fi
    if ! python3 -m pip install --user uv 2>/dev/null; then
      python3 -m pip install uv --break-system-packages 2>/dev/null || {
        print_err "Failed to install uv. Please install manually."
        exit 1
      }
    fi
    # Ensure user's local bin is on PATH suggestion
    local_bin="$(python3 -m site --user-base)/bin"
    if [ -d "$local_bin" ]; then
      printf 'If "uv" is not found after install, add %s to your PATH (e.g. export PATH="$PATH:%s")\n' "$local_bin" "$local_bin"
    fi
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

# Configure git for container environments (fix dubious ownership issues)
if command -v git >/dev/null 2>&1; then
    echo "✅ Git is installed"
    # Fix common container ownership issues
    git config --global --add safe.directory /workspaces/template.python.package 2>/dev/null || true
    git config --global --add safe.directory '*' 2>/dev/null || true
    
    # Set up basic git config if not already configured (fallback for containers)
    if ! git config --global user.name >/dev/null 2>&1; then
        git config --global user.name "${GITHUB_USER:-template.python.package}" 2>/dev/null || true
    fi
    if ! git config --global user.email >/dev/null 2>&1; then
        git config --global user.email "${GITHUB_EMAIL:-template.python.package@hungovercoders.com}" 2>/dev/null || true
    fi
else
    echo "❌ Git is not installed"
fi

# Install Task (Taskfile) - https://taskfile.dev
if command -v task >/dev/null 2>&1; then
    echo "✅ Task is already installed"
else
    echo "📦 Installing Task (Taskfile)..."
    if [ "$(uname -s)" = "Linux" ]; then
        # Install Task using the official installer script
        sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin 2>/dev/null || {
            # Fallback: try installing to user's local bin if no sudo access
            local_bin="$(python3 -m site --user-base)/bin"
            mkdir -p "$local_bin"
            sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b "$local_bin" || {
                print_err "Failed to install Task. Please install manually: https://taskfile.dev/installation/"
            }
        }
    else
        # macOS: recommend manual install or homebrew
        if command -v brew >/dev/null 2>&1; then
            brew install go-task || print_err "Failed to install Task via Homebrew"
        else
            print_err "Please install Task manually: https://taskfile.dev/installation/"
        fi
    fi
    
    # Check if installation was successful
    if command -v task >/dev/null 2>&1; then
        echo "✅ Task is installed"
    else
        echo "❌ Task installation failed"
    fi
fi

if command -v task >/dev/null 2>&1; then
  # Always ensure core dependencies are installed first
  echo "🔧 Installing core dependencies..."
  task install --force || {
    print_err "Failed to install core dependencies. Please check your environment."
    exit 1
  }
  
  # Try to install VS Code extensions, but don't fail the entire setup
  echo "🔌 Attempting to install VS Code extensions..."
  if task install-vscode-extensions --force 2>/dev/null; then
    echo "✅ Extensions installed successfully"
  else
    echo "⚠️  Extension installation skipped (VS Code CLI not available during postcreate)"
    echo "📋 Extensions are configured and will be recommended when VS Code starts"
  fi
  
  echo "✅ Workspace setup completed successfully"
else
  print_err "Task is not installed. Skipping workspace setup."
fi

echo '✅ Setup completed successfully.'

# Reload VS Code window to ensure all extensions are activated
if command -v code >/dev/null 2>&1; then
    echo "🔄 Reloading VS Code window to activate extensions..."
    # Use VS Code CLI to reload the window (works in devcontainers/codespaces)
    code --command workbench.action.reloadWindow 2>/dev/null || {
        echo "ℹ️  Please manually reload VS Code window (Ctrl+Shift+P → 'Developer: Reload Window') to fully activate extensions"
    }
else
    echo "ℹ️  VS Code CLI not available during setup (normal in postcreate)."
    echo "📋 Extensions are configured in .vscode/extensions.json and will be recommended when VS Code starts."
    echo "🚀 Development environment is ready!"
fi