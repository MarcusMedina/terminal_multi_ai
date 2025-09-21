Absolut\! Här är hela den manuella installationsguiden i Markdown-format, redo för dig att kopiera.

-----

# Manual Installation Guide for Terminal AI Tools

This guide provides the detailed, step-by-step commands to manually install and configure the AI command-line tools: **Claude**, **Codex**, and **Gemini**. It is the manual equivalent of what the automated installer scripts do.

**Prerequisites:** 
- This guide assumes you have already set up your base environment as described in the main **Ultimate WSL & AI Dev Environment Guide**, including Python 3.12 (with venv), Node.js, and npm.
- You need API keys or account on Claude and OpenAI
- You also need a Gemini Studio free API

### Step 1: Create Directories and Configure Environments

First, create the dedicated folders for each AI tool and ensure your environments are correctly configured.

```bash
# 1. Create the AI tool directories in your home folder
mkdir -p ~/claude ~/codex ~/gemini

# 2. Ensure your Python venv exists (created in the main guide)
# This command should list the contents of the venv directory
ls ~/py3.12-venv/

# 3. Ensure npm is configured for global installs without sudo (configured in main guide)
npm config get prefix
# Should output: /home/your_user/.npm-global
```

### Step 2: Install Claude and Codex CLIs

These tools are installed globally using `npm`.

```bash
# Install the Claude CLI tool
npm install -g @anthropic-ai/claude-code

# Install the Codex CLI tool
npm install -g @openai/codex
```

### Step 3: Install Python SDKs for Development

Install the necessary Python libraries into your dedicated virtual environment. These are used by the Gemini script and are available if you want to build your own Python apps.

```bash
# Activate the virtual environment
source ~/py3.12-venv/bin/activate

# Install the Python packages
pip install --upgrade google-generativeai anthropic openai python-dotenv sqlite-utils

# Deactivate the environment
deactivate
```

### Step 4: Create the Gemini Command-Line Script

Since Gemini doesn't have an official CLI, we create our own simple but powerful Python script.

```bash
# Create and open the script file with nano
nano ~/gemini/gemini.py
```

Copy and paste the following code into the `nano` editor, then save and exit (`Ctrl+O`, `Enter`, `Ctrl+X`):

```python
#!/usr/bin/env python3
import os
import sys
os.environ.setdefault('GRPC_VERBOSITY', 'ERROR')
os.environ.setdefault('GLOG_minloglevel', '2')
import google.generativeai as genai

def run():
    api_key = os.getenv('GEMINI_API_KEY', '').strip()
    if not api_key:
        print("❌ Error: GEMINI_API_KEY is not set.", file=sys.stderr)
        sys.exit(1)
    
    user_prompt = " ".join(sys.argv[1:])
    if not user_prompt:
        print("Usage: gemini \"your question here\"")
        sys.exit(0)

    try:
        genai.configure(api_key=api_key)
        model = genai.GenerativeModel('gemini-1.5-flash-latest')
        response = model.generate_content(user_prompt)
        print(response.text)
    except Exception as e:
        print(f"An error occurred: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    run()
```

Finally, make the script executable:

```bash
chmod +x ~/gemini/gemini.py
```

### Step 5: Configure Your Shell (`.bashrc`, `.zshrc`, etc.)

This is the most important step. We will add a block of code to your shell's configuration file to create the smart functions and useful aliases.

> **Platform Note:**
>
>   * **On Linux/WSL with Bash:** Use `nano ~/.bashrc`
>   * **On macOS with Zsh:** Use `nano ~/.zshrc`
>   * **On macOS with Bash:** Use `nano ~/.bash_profile`

Open your configuration file:

```bash
# Example for Bash users
nano ~/.bashrc
```

Scroll to the very bottom of the file and paste the entire block of code below.

```bash
# --------------------------------------------------
#  AI_TOOLS_CONFIG_BLOCK_START_V3
#  Configuration for AI Tools & Workflow
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
# 📂 Universal Navigation Aliases
# ---------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias ~='cd ~'
alias home='cd ~'
alias desk='cd ~/Desktop'
alias docs='cd ~/Documents'
alias mygit='cd ~/Git' # Assumes a Git folder in your home directory

# ---------------------------
# 💻 Platform-Specific Aliases (Choose one set)
# ---------------------------

# For WSL users (accessing Windows folders)
alias dls='cd /mnt/c/Users/$USER/Downloads'
alias winhome='cd /mnt/c/Users/$USER'
alias vsc='cd "/mnt/c/Users/$USER/source/Repos/"'
alias idea='cd "/mnt/c/Users/$USER/IdeaProjects/"'

# For native Linux/macOS users (uncomment and customize)
# alias dls='cd ~/Downloads'
# alias vsc='cd ~/Projects/VSCode' # Example path
# alias idea='cd ~/Projects/Idea' # Example path


# ---------------------------
# 🐙 Git & Other Tools
# ---------------------------
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'
alias ll='ls -alF --color=auto'
alias cls='clear'

# ---------------------------
# 🔑 API Keys (add your keys below)
# ---------------------------
export ANTHROPIC_API_KEY="your_claude_key_here"
export OPENAI_API_KEY="your_openai_key_here"
export GEMINI_API_KEY="your_gemini_key_here"

# AI_TOOLS_CONFIG_BLOCK_END_V3
```

Save and exit the file. Finally, reload your shell to apply the changes:

```bash
# For Bash users
source ~/.bashrc

# For Zsh users
source ~/.zshrc
```

### 🚨 For Corporate Firewalls: Manual Troubleshooting

If you encounter timeout errors, apply these settings.

1.  **Configure Proxy (if needed):**
    Find your company's proxy URL (e.g., `http://proxy.company.com:8080`).
    ```bash
    # For npm
    npm config set proxy http://proxy.company.com:8080
    npm config set https-proxy http://proxy.company.com:8080

    # For pip (add --proxy URL to the install command)
    # Example: pip install --proxy http://proxy.company.com:8080 google-generativeai
    ```
2.  **Bypass SSL Inspection (Very Common):**
    ```bash
    # For npm
    npm config set strict-ssl false

    # For WSL users ONLY (uses the Windows certificate store)
    git config --global http.sslBackend schannel

    # For ALL users: Add this line to the TOP of your ~/.bashrc or ~/.zshrc
    export NODE_TLS_REJECT_UNAUTHORIZED=0
    ```
3.  **Update AI Functions for Firewall:**
    For corporate networks, you must update the `claude` and `codex` functions in your shell config file to this more robust version:
    ```bash
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
    ```
