#!/bin/bash
# ==============================================================================
#  AI Tools Installer (Corporate v2.3)
#  - Adds `clear` to all AI functions for a clean start.
# ==============================================================================

# Function to display messages
info() { echo "⚙️  $1"; }
success() { echo "✅ $1"; }
ask_yes_no() {
    local prompt="$1"
    local response
    while true; do
        read -p "$prompt" response
        case "$response" in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer y or n.";;
        esac
    done
}

# Sudo/Root Check
if [ "$EUID" -eq 0 ]; then
    echo "❌ Error: Please do not run this script with sudo or as the root user."
    exit 1
fi

echo "🚀 Starting AI Tools Installation..."
echo "----------------------------------------"

PIP_PROXY_OPTION=""
PIP_TRUSTED_HOST_OPTION=""
NPM_INSTALL_FLAGS=""

if ask_yes_no "Are you on a corporate network with a firewall (e.g., at work or school)? (y/n): "; then
    info "Entering corporate network configuration..."
    read -p "  -> Does your network require an HTTP proxy URL? If not, press Enter: " proxy_url
    if [ -n "$proxy_url" ]; then
        npm config set proxy "$proxy_url"; npm config set https-proxy "$proxy_url"
        PIP_PROXY_OPTION="--proxy $proxy_url"
        success "     Proxy configured: $proxy_url"
    else
        info "     No proxy URL configured."
    fi

    if ask_yes_no "  -> Does your firewall perform SSL inspection? (Almost always 'y'): "; then
        info "     Applying all known SSL workarounds..."
        npm config set strict-ssl false
        info "     Setting git SSL backend to 'schannel' to use Windows Certificate Store..."
        git config --global http.sslBackend schannel
        info "     Permanently adding NODE_TLS_REJECT_UNAUTHORIZED=0 to your shell config..."
        if ! grep -q "NODE_TLS_REJECT_UNAUTHORIZED" ~/.bashrc; then
            echo -e "\n# Disable strict SSL for Node.js\nexport NODE_TLS_REJECT_UNAUTHORIZED=0" >> ~/.bashrc
        fi
        export NODE_TLS_REJECT_UNAUTHORIZED=0
        PIP_TRUSTED_HOST_OPTION="--trusted-host pypi.org files.pythonhosted.org"
        success "     SSL workarounds applied."
    fi
    NPM_INSTALL_FLAGS="--unsafe-perm"
else
    info "Proceeding with standard network configuration."
fi
echo "----------------------------------------"

info "[1/4] Installing Claude CLI..."
npm install -g @anthropic-ai/claude-code $NPM_INSTALL_FLAGS
success "Claude CLI installed successfully."

info "[2/4] Installing Codex (OpenAI) CLI..."
npm install -g @openai/codex $NPM_INSTALL_FLAGS
success "Codex CLI installed successfully."

info "[3/4] Installing Python SDKs for Development..."
if [ -f ~/py3.12-venv/bin/activate ]; then
    source ~/py3.12-venv/bin/activate
    pip install --upgrade $PIP_PROXY_OPTION $PIP_TRUSTED_HOST_OPTION google-generativeai anthropic openai python-dotenv sqlite-utils
    deactivate
    success "Python SDKs installed in ~/py3.12-venv."
else
    echo "⚠️  Warning: Python venv not found. Skipping SDK installation."
fi

info "[4/4] Configuring Gemini Python CLI..."
mkdir -p ~/gemini
cat << 'EOF' > ~/gemini/gemini.py
#!/usr/bin/env python3
import os, sys
os.environ.setdefault('GRPC_VERBOSITY', 'ERROR')
os.environ.setdefault('GLOG_minloglevel', '2')
import google.generativeai as genai
def run():
    api_key = os.getenv('GEMINI_API_KEY', '').strip()
    if not api_key:
        print("❌ Error: GEMINI_API_KEY is not set.", file=sys.stderr); sys.exit(1)
    user_prompt = " ".join(sys.argv[1:])
    if not user_prompt:
        print("Usage: gemini \"your question here\""); sys.exit(0)
    try:
        genai.configure(api_key=api_key)
        model = genai.GenerativeModel('gemini-1.5-flash-latest')
        response = model.generate_content(user_prompt)
        print(response.text)
    except Exception as e:
        print(f"An error occurred: {e}", file=sys.stderr); sys.exit(1)
if __name__ == "__main__":
    run()
EOF
chmod +x ~/gemini/gemini.py
success "Gemini CLI configured successfully."

info "Configuring .bashrc with idempotent functions, aliases, and API keys..."
BASHRC_FILE=~/.bashrc
START_MARKER="# AI_TOOLS_CONFIG_BLOCK_START_V3"
END_MARKER="# AI_TOOLS_CONFIG_BLOCK_END_V3"

if grep -q "$START_MARKER" "$BASHRC_FILE"; then
    info "  -> Found existing AI config block. Replacing it with the latest version..."
    sed -i "/$START_MARKER/,/$END_MARKER/d" "$BASHRC_FILE"
else
    info "  -> AI config block not found. Creating..."
fi

info "  -> Writing latest configuration to ~/.bashrc..."
cat << EOF >> "$BASHRC_FILE"

$START_MARKER
# Configuration for AI Tools & Workflow (managed by script)
# To update, simply re-run the installer script.
#

