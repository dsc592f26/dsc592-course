# Step 2: Git and GitHub

## 2a. Create a GitHub account

If you don't have one, sign up at https://github.com. Pick a professional username: it appears on
every commit and stays on your résumé-visible profile.

Then add your **UNCW email** to your account: GitHub → Settings → Emails → Add email address.

**Submit your GitHub username on the setup form** on the course site. The instructor uses it to invite
you to the course organization and create your lab repos.

## 2b. Install Git

| System | How |
| --- | --- |
| macOS | Run `git --version` in Terminal. If Git isn't installed, macOS offers to install the Command Line Tools: click **Install**. |
| WSL2 (Ubuntu) | Already installed in Step 1 (`sudo apt install -y git`). |
| Git Bash | Comes with Git for Windows. |

Check: `git --version` should print `git version 2.x`.

## 2c. Tell Git who you are

Use the **same email** that is on your GitHub account, or your commits won't be linked to you.
Individual contribution is graded from commits, so this matters.

```bash
git config --global user.name  "Your Name"
git config --global user.email "you@uncw.edu"
git config --global init.defaultBranch main
```

## 2d. Install the GitHub CLI (`gh`) and log in

GitHub no longer accepts your account password for `git push`. The GitHub CLI handles login for you.

| System | Install |
| --- | --- |
| macOS | `brew install gh` (needs Homebrew, https://brew.sh), or download the installer from https://cli.github.com |
| WSL2 (Ubuntu) | `sudo apt install -y gh` |
| Git Bash | In PowerShell: `winget install --id GitHub.cli`, then close and reopen Git Bash |

Then log in:

```bash
gh auth login
```

Choose **GitHub.com** → **HTTPS** → **Yes** (authenticate Git with your GitHub credentials) →
**Login with a web browser**. Copy the one-time code, press Enter, paste the code in the browser, and approve.

Check: `gh auth status` should say "Logged in to github.com".

## 2e. Accept the course organization invite

After you submit your username, you'll get an email invitation to the **`dsc592f26`** organization.
Accept it, or go to https://github.com/dsc592f26 and accept the banner at the top.

You can't see your lab repo until you accept.
