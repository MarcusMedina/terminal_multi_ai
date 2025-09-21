#!/bin/bash
# ==============================================================================
#  terminal_multi_ai Installer Script
#  Project by: Marcus Medina (https://github.com/MarcusMedina)
#  GitHub Repo: https://github.com/MarcusMedina/terminal_multi_ai
# ==============================================================================
#  This is the CORPORATE FIREWALL version.
#  It includes all features of the standard script, plus advanced workarounds
#  for proxies and SSL inspection.
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
cat << 'EOF' >> "$BASHRC_FILE"

$START_MARKER
# Configuration for AI Tools & Workflow (managed by script)
# To update, simply re-run the installer script.
# --------------------------------------------------

# ---------------------------
# 🤖 AI Tool Functions (preserves current path)
# ---------------------------
function claude() {
    clear
    pushd ~/claude > /dev/null || return
    export NODE_TLS_REJECT_UNAUTHORIZED=0
    command claude "$@"
    unset NODE_TLS_REJECT_UNAUTHORIZED
    popd > /dev/null
}

function codex() {
    clear
    pushd ~/codex > /dev/null || return
    export NODE_TLS_REJECT_UNAUTHORIZED=0
    command codex "$@"
    unset NODE_TLS_REJECT_UNAUTHORIZED
    popd > /dev/null
}

function gemini() {
    clear
    pushd ~/gemini > /dev/null || return
    ~/py3.12-venv/bin/python3 ~/gemini/gemini.py "$@" 2>/dev/null
    popd > /dev/null
}

# ---------------------------
# 📂 Navigation
# ---------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias ~='cd ~'
alias home='cd ~'
alias desk='cd ~/Desktop'
alias docs='cd ~/Documents'
alias dls='cd /mnt/c/Users/$USER/Downloads'
alias winhome='cd /mnt/c/Users/$USER'

# ---------------------------
# 📋 Listing & Searching
# ---------------------------
alias ll='ls -alF --color=auto'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias path='echo -e ${PATH//:/\\n}'

# ---------------------------
# ⚙️ System
# ---------------------------
alias cls='clear'
alias update='sudo apt update && sudo apt upgrade -y'
alias df='df -h'
alias du='du -h'
alias ports='ss -tulnp'

# ---------------------------
# 🐙 Git
# ---------------------------
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'

# ---------------------------
# 🐍 Python
# ---------------------------
alias py='python3'
alias pipu='pip install --upgrade pip'

# ---------------------------
# 💻 Windows Dev Dirs
# ---------------------------
alias vsc='cd "/mnt/c/Users/$USER/source/Repos/"'
alias idea='cd "/mnt/c/Users/$USER/IdeaProjects/"'
alias mygit='cd /mnt/c/Git'

# ---------------------------
# 🪄 Custom Functions
# ---------------------------
mkcd () { mkdir -p "$1" && cd "$1"; }
alias duck='~/duck_events.sh'

# ---------------------------
# 🔑 API Keys (add your keys below)
# ---------------------------
export ANTHROPIC_API_KEY="your_claude_key_here"
export OPENAI_API_KEY="your_openai_key_here"
export GEMINI_API_KEY="your_gemini_key_here"

$END_MARKER
EOF
success "AI tool configurations have been updated in ~/.bashrc."

info "Creating manifest file for LLMs..."
cat << EOF > ~/llm_tools_manifest.md
# LLM Tool & Environment Manifest

This file lists the available command-line tools and custom aliases that you, the AI, can use to assist me.

## Core AI Tools
- \`claude "prompt"\`: For tasks related to code generation, explanation, and general assistance (Anthropic).
- \`codex "prompt"\`: For OpenAI-based code generation tasks.
- \`gemini "prompt"\`: For general queries, brainstorming, and creative tasks (Google).

## File System Navigation Aliases
- \`vsc\`: Navigates to the Visual Studio Code projects directory (\`/mnt/c/Users/$USER/source/Repos/\`).
- \`idea\`: Navigates to the IntelliJ IDEA projects directory (\`/mnt/c/Users/$USER/IdeaProjects/\`).
- \`mygit\`: Navigates to my personal Git projects directory (\`/mnt/c/Git/\`).
- \`dls\`: Navigates to my Windows Downloads folder.
- \`winhome\`: Navigates to my Windows home folder.

## General Productivity Tools Available
- \`git\`: For all version control tasks.
- \`python3\` / \`py\`: To run Python scripts.
- \`node\`: To run JavaScript files.
- \`ripgrep\` (\`rg\`), \`fd\`, \`bat\`: For fast file searching and viewing.
- \`jq\`: For processing JSON data.
- \`sqlite3\`: To interact with SQLite databases.
EOF
success "LLM manifest created at ~/llm_tools_manifest.md"

echo "----------------------------------------"
echo "🎉 Installation Complete!"
echo ""
echo "IMPORTANT: To apply the changes, run: source ~/.bashrc"
echo "----------------------------------------"

