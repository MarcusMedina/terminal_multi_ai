# The Ultimate WSL & AI Dev Environment Guide

This guide provides a complete walkthrough for setting up a powerful AI-driven development environment on Windows using WSL, as well as on native macOS and Linux systems.

## Part 1: The Windows (WSL) Installation

We'll use the Windows Subsystem for Linux (WSL) to create a powerful, isolated, and fully-featured Linux environment directly on Windows.

### Step 1.1: Install WSL and Ubuntu

Open **PowerShell as an Administrator** and run the following commands to install WSL and the latest Ubuntu distribution.

```powershell
# Install WSL and its required components
wsl --install
wsl --update

# Set WSL 2 as the default version for new installations
wsl --set-default-version 2

# (Optional) To install a specific version of Ubuntu
# wsl --install -d Ubuntu-22.04
```

Reboot your computer if prompted. When you launch Ubuntu for the first time, you will be asked to create a new user account and password.

### Step 1.2: Create Project Folders in Windows

While still in PowerShell, create the folders in your Windows user directory that we will later link to from within WSL.

```powershell
mkdir "$env:USERPROFILE\claude" -Force
mkdir "$env:USERPROFILE\codex" -Force
mkdir "$env:USERPROFILE\gemini" -Force
```

### Step 1.3: Install the Essential Developer Toolkit

Now, inside your new **Ubuntu terminal**, it's time to install a robust set of tools.

```bash
# Update the package manager and install the core toolkit
sudo apt update && sudo apt upgrade -y
sudo apt install -y \
    wget curl git unzip zip build-essential htop nano vim \
    python3.12 python3.12-venv nodejs npm default-jdk \
    ripgrep fd-find bat fzf jq tree

# Install the .NET 8 SDK (LTS Version)
# This adds the official Microsoft package repository to your system
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt update
sudo apt install -y dotnet-sdk-8.0

# (Optional) Install a Preview Version of .NET (e.g., .NET 9)
# Use the dotnet-install script for preview versions
# curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --channel 9.0
# echo 'export DOTNET_ROOT=$HOME/.dotnet' >> ~/.bashrc
# echo 'export PATH=$PATH:$HOME/.dotnet' >> ~/.bashrc
# source ~/.bashrc

# Fix for common command names (bat -> batcat, fd -> fdfind)
# These may require sudo
sudo ln -s /usr/bin/batcat /usr/local/bin/bat
sudo ln -s /usr/bin/fdfind /usr/local/bin/fd
```

### Step 1.4: Configure Python & Node.js Environments

We'll create a dedicated "virtual environment" (venv) for our Python tools and configure `npm` to handle global packages without needing `sudo`.

```bash
# Add pip's user-install directory to the PATH
# This prevents "command not found" warnings after installing pip packages
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Create and prepare the Python venv
python3.12 -m venv ~/py3.12-venv

# Configure npm to use a local directory for global packages
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=$HOME/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

### Step 1.5: Link Windows and WSL Folders (The Smart Way)

Instead of using the fragile `/etc/fstab` for mounting, we will use **symbolic links**. This is a more robust and reliable method for WSL.

```bash
# This command assumes your WSL username is the same as your Windows username
WIN_USER=$(whoami)

# Create the symbolic links
ln -s "/mnt/c/Users/$WIN_USER/claude" ~/claude
ln -s "/mnt/c/Users/$WIN_USER/codex"  ~/codex
ln -s "/mnt/c/Users/$WIN_USER/gemini" ~/gemini
```

Your Windows folders are now perfectly mirrored in your WSL home directory.

### Step 1.6: Install the AI Tools with the Automated Script

Now, choose one of the installer scripts to automatically set up Claude, Codex, and Gemini.

  * **For most users (home, unrestricted networks):**
    Run the standard installer. It's clean, fast, and straightforward.
    ```bash
    ./install_ai_tools_standard.sh
    ```
  * **If you are behind a corporate or school firewall:**
    Run the corporate installer. This interactive script includes powerful workarounds for proxies and SSL inspection.
    ```bash
    ./install_ai_tools_corporate.sh
    ```

These scripts will install the necessary packages, create the Gemini CLI tool, and configure your shell with the powerful functions and aliases listed below.

### Step 1.7: Supercharge Your Shell: Functions & Aliases

The installer script automatically adds the following configuration block to your `~/.bashrc` file. This is the engine that powers your new AI workflow.

```bash
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
```

### Step 1.8: The LLM Manifest File

The installer also creates a file at `~/llm_tools_manifest.md`. This file lists all the tools and aliases available in your environment. You can copy its contents and provide it to an LLM as context to make it aware of the tools it can use to help you.

## Part 2: The macOS & Linux Installation

The process for native macOS and Linux is very similar, using their respective package managers.

### Step 2.1: Install the Essential Developer Toolkit

  * **On macOS (using Homebrew):**
    ```bash
    # Install Homebrew if you don't have it: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew install python@3.12 node openjdk dotnet
    brew install ripgrep fd bat fzf jq tree
    ```
  * **On Linux (Debian/Ubuntu/Pop\!\_OS):**
    This is the same command from the WSL section.
    ```bash
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y python3.12 python3.12-venv nodejs npm default-jdk dotnet-sdk-8.0
    sudo apt install -y ripgrep fd-find bat fzf jq tree
    # Fix command names on Linux
    sudo ln -s /usr/bin/batcat /usr/local/bin/bat
    sudo ln -s /usr/bin/fdfind /usr/local/bin/fd
    ```

### Step 2.2: Configure Environments & Install AI Tools

This process is identical for macOS and Linux.

1.  **Create AI Folders:**
    ```bash
    mkdir -p ~/claude ~/codex ~/gemini
    ```
2.  **Configure Python & Node.js:**
    ```bash
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bash_profile # or ~/.bashrc on Linux
    python3.12 -m venv ~/py3.12-venv
    mkdir -p ~/.npm-global
    npm config set prefix '~/.npm-global'
    echo 'export PATH=$HOME/.npm-global/bin:$PATH' >> ~/.bash_profile # or ~/.bashrc on Linux
    ```
3.  **Run the Installer Script:**
    Choose the appropriate script (`standard` or `corporate`) and run it just like in the WSL guide. It will install the AI tools and configure your shell with all the same powerful functions and aliases.
4.  **Reload Your Shell:**
    ```bash
    source ~/.bash_profile # Or source ~/.bashrc on Linux
    ```
