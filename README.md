# ⚙️ gg3-admin-tools

![Version](https://img.shields.io/badge/version-0.1.0-blue)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Languages](https://img.shields.io/badge/Made%20With-Bash-blue)
![Status](https://img.shields.io/badge/Status-Active-brightgreen)

**Administrative Bash scripts for dotfiles management, SSH key setup, and system bootstrapping.**

Maintained by **Juan Garcia** (`@0xjuang`).

---

## 📚 Included Scripts

### `bootstrap-clone.sh` — Dotfiles Bootstrapper
A lightweight script that clones your private dotfiles repository (`.gg3.conf`) and sets up the environment on a fresh system.

- Clones repository into the user's home directory
- Sets up correct permissions and symlinks as needed
- Guides initial bootstrap configuration

> **Note:** This script assumes access to the private dotfiles repository and appropriate SSH keys or Git credentials.

### `gen_key_passthrough.sh` — SSH Key Generator & Passthrough
An interactive SSH key generation tool for secure, isolated keypair creation.

- Prompts user for email and key passphrase (input is not stored)
- Generates a new SSH keypair
- Sets up passthrough-friendly configurations for later automation
- Ensures clean, secure SSH identity management practices

> **Note:** Private keys are **never** saved or displayed in the script itself. Always handle generated keys securely.

---

## 🛤️ Suggested Future Enhancements

- Add an unattended `oh-my-zsh` installation script to automate shell setup without manual input
- Integrate `sys_info.sh` for system diagnostics during bootstrap setup
- Add auto-sync script to update local dotfiles from private repo
- Create SSH agent setup script to streamline key passthrough
- Improve bootstrap-clone.sh for offline cloning and mirror repo support
- Add a secure cleanup script for removing bootstrap artifacts after setup

---

## 🛡️ Notes

- No sensitive credentials are stored inside the scripts.
- User inputs (email, passphrase) are prompted interactively and not saved.
- This project follows modular, reproducible practices for personal system administration.

---

## 📝 License

This project is licensed under the [MIT License](LICENSE).

---

> **Curated under the GG3-DevNet Infrastructure Stack — designed for reproducibility, auditability, and clarity.**

