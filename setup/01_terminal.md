# Step 1: Terminal

The labs use a **bash or zsh** terminal (Linux-style shell). Pick your system below.

## macOS

You already have one: open **Terminal** (Applications → Utilities, or press Cmd+Space and type "Terminal").
The default shell is zsh, which works for everything in this course.

## Windows: WSL2 with Ubuntu (recommended)

WSL2 runs a real Ubuntu Linux inside Windows, so every command in the labs works exactly as shown.

1. Open the Start menu, type **PowerShell**, right-click it, and choose **Run as administrator**.
2. Run:
   ```powershell
   wsl --install
   ```
3. **Restart** your computer when it finishes.
4. Open the new **Ubuntu** app from the Start menu. The first time, it asks you to create a Linux
   username and password. Choose something you'll remember: you'll need the password for `sudo`.
   (Nothing appears on screen while you type the password. That's normal.)
5. Update Ubuntu and install the tools we use:
   ```bash
   sudo apt update && sudo apt install -y git curl
   ```

From now on, **always use the Ubuntu app** for course work, not PowerShell or Command Prompt.
PowerShell looks similar, but most lab commands (`grep`, `head`, `chmod`, `$(date ...)`, `.sh` scripts)
don't work there.

Tip: your Windows files are visible inside Ubuntu under `/mnt/c/Users/<your-windows-name>/`,
but keep course work in your Linux home folder (`~`) for speed.

## Windows: Git Bash (if WSL2 won't install)

Some university-managed laptops block WSL2. Then install **Git for Windows** from https://git-scm.com,
accept the defaults, and use the **Git Bash** app. It covers all Week 1 labs.

## Any computer: GitHub Codespaces (backup)

If nothing above works, you can use a Linux terminal in your browser:
open https://github.com/codespaces, choose **New codespace**, and pick any of your repos
(for example your `lab1-<username>` repo once it exists). Free accounts include a monthly allowance.

## Check

```bash
echo $SHELL     # should print something ending in bash or zsh
pwd             # prints your current folder
```
