#!/bin/bash
# ==============================================================================
#  terminal_multi_ai Installer Script
#  Project by: Marcus Medina (https://github.com/MarcusMedina)
#  GitHub Repo: https://github.com/MarcusMedina/terminal_multi_ai
# ==============================================================================
#  This is the STANDARD version for home/unrestricted networks.
#  If you are behind a corporate firewall, use the 'corporate' version.
# ==============================================================================

# Function to display messages
info() { echo "⚙️  $1"; }
success() { echo "✅ $1"; }

# Sudo/Root Check
if [ "$EUID" -eq 0 ]; then
    echo "❌ Error: Please do not run this script with sudo or as the root user."
    exit 1
fi

echo "🚀 Starting AI Tools Installation..."
echo "----------------------------------------"

info "[1/4] Installing Claude CLI..."
npm install -g @anthropic-ai/claude-code
success "Claude CLI installed successfully."

info "[2/4] Installing Codex (OpenAI) CLI..."
npm install -g @openai/codex
success "Codex CLI installed successfully."

info "[3/4] Installing Python SDKs for Development..."
if [ -f ~/py3.12-venv/bin/activate ]; then
    source ~/py3.12-venv/bin/activate
    pip install --upgrade google-generativeai anthropic openai python-dotenv sqlite-utils
    deactivate
    success "Python SDKs installed in ~/py3.12-venv."
else
    echo "⚠️  Warning: Python vεν not found. Skipping SDK installation."
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

# If an old block exists, remove it before adding the new one.
if grep -q "$START_MARKER" "$BASHRC_FILE"; then
    info "  -> Found existing AI config block. Replacing it with the latest version..."
    sed -i "/$START_MARKER/,/$END_MARKER/d" "$BASHRC_FILE"
else
    info "  -> AI config block not found. Creating..."
fi

# Add the new, updated block to the end of the file.
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
    command claude "$@"
    popd > /dev/null
}

function codex() {
    clear
    pushd ~/codex > /dev/null || return
    command codex "$@"
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

