# Terminal multi AI 

*A conceptual image of the developer-AI collaboration that created this project.*

The whole idea was to install Claude, Codex and Gemini on my machine, at first I used Docker but realised WSl would be more efficient so I changed my scripts to that. With some help of the AIs I got a nice script and decided to share it. Here it is.

## 🚀 What is This?

**Terminal\_multi\_ai** is a comprehensive toolkit and guide for supercharging your terminal with a suite of powerful AI assistants: **Google's Gemini**, **Anthropic's Claude**, and **OpenAI's Codex**.

This project provides installer scripts and a detailed guide to transform a standard command line (on WSL, macOS, or Linux) into a powerful, productive, and AI-driven development environment. It sets up everything you need, from the core runtimes to a suite of handy aliases and functions that streamline your daily workflow.

The entire project is a testament to human-AI collaboration, conceived and built by **Marcus Medina** in a dynamic partnership with **Gemini**, with additional insights and contributions from **ChatGPT** and **Claude**.

## ✨ Key Features

  * **Multi-AI Command Line:** Get instant access to Gemini, Claude, and Codex directly from your terminal with simple commands (`gemini`, `claude`, `codex`).
  * **Automated Installation:** Includes two robust installer scripts:
      * `install_ai_tools_standard.sh`: For standard, unrestricted networks.
      * `install_ai_tools_corporate.sh`: A powerful, interactive script with built-in workarounds for tough corporate firewalls, proxies, and SSL inspection.
  * **Smart Shell Functions:** The AI commands are wrapped in smart functions that preserve your current working directory, so your workflow is never interrupted.
  * **Rich Alias Library:** The installer automatically enhances your `.bashrc` (or equivalent) with a huge collection of useful aliases for navigation, file management, Git, and system commands.
  * **Idempotent & Safe:** The scripts are designed to be run multiple times safely. They will intelligently update your configuration without creating duplicates.
  * **LLM Manifest File:** Automatically generates a `llm_tools_manifest.md` file in your home directory, which you can provide to an LLM to give it context about its available tools.
  * **Fun Terminal Greeter:** Includes the optional but awesome [**Duck Events**](https://github.com/MarcusMedina/Duck_events) script, a quirky, informative, and highly customizable welcome message for every new terminal session.

## 🏁 Getting Started

The best way to get started is to follow the main guide, which contains all the prerequisites and step-by-step instructions.

1.  **Start with the Main Guide:**
    The core of this project is [**The Ultimate WSL & AI Dev Environment Guide**](https://www.google.com/search?q=wsl_ai_guide.md). This guide explains how to set up your base environment (WSL, Python, Node.js, etc.) before running the installer scripts.
2.  **Choose Your Installer:**
    Once your base environment is ready, choose the installer script that fits your network situation:
      * For home or open networks, use: `./install_ai_tools_standard.sh`
      * For work, school, or any network with a firewall, use: `./install_ai_tools_corporate.sh`
3.  **Reload and Go\!**
    After the script finishes, reload your shell configuration (`source ~/.bashrc`) and start using your new AI-powered terminal\!

## 🤝 Contributing

This project thrives on collaboration\! Contributions are welcome, whether you are a human or a friendly AI. Here are some ways you can help:

  * **Add More Aliases:** Have a favorite alias that makes your life easier? Add it to the script\!
  * **Improve the Scripts:** Can you make the shell scripting more robust, efficient, or elegant? Go for it.
  * **Support More AIs:** Add functions and configurations for other AI-command-line tools.
  * **Enhance the Guide:** Clarify instructions, fix typos, or add new sections to the main guide.
  * **Report Bugs:** Find an issue? Open a ticket in the "Issues" tab.

### How to Contribute

1.  **Fork** the repository.
2.  Create a new branch (`git checkout -b feature/your-awesome-feature`).
3.  Make your changes.
4.  Commit your changes (`git commit -m 'Add some awesome feature'`).
5.  Push to the branch (`git push origin feature/your-awesome-feature`).
6.  Open a **Pull Request**.

## 💡 Acknowledgements & Credits

This project is a true example of collaborative creativity and would not exist without the unique contributions of its team:

  * **Project Lead & Human Developer:** [Marcus Medina](https://github.com/MarcusMedina)
  * **Primary AI Collaborator & Scripter:** Gemini (Google)
  * **Consulting AI Assistants:** ChatGPT (OpenAI) & Claude (Anthropic)

## 📄 License

This project is licensed under the MIT License. See the `LICENSE` file for details.
