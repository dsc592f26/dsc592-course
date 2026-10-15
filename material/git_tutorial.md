# Git and GitHub tutorial

**Contents**

1. [What is version control?](#1-what-is-version-control)
2. [Git and GitHub](#2-git-and-github)
3. [One-time setup](#3-one-time-setup)
4. [How Git thinks: the three places your work lives](#4-how-git-thinks-the-three-places-your-work-lives)
5. [The everyday workflow (Lab 1B)](#5-the-everyday-workflow-lab-1b)
6. [Branches](#6-branches)
7. [Pull requests](#7-pull-requests)
8. [Merge conflicts](#8-merge-conflicts)
9. [Keeping files out of Git: `.gitignore`](#9-keeping-files-out-of-git-gitignore)
10. [Starting your own repository](#10-starting-your-own-repository)
11. [Databricks Git folders](#11-databricks-git-folders)
12. [More GitHub features](#12-more-github-features)
13. [Best practices for this course](#13-best-practices-for-this-course)
14. [Command reference](#14-command-reference)
15. [Common problems](#15-common-problems)
16. [More resources](#16-more-resources)

---

## 1. What is version control?

**Version control** is a system that records changes to files over time, so you can go back to any earlier version,
see who changed what and why, and work with others without overwriting each other's work.

It gives you:

- **History:** every saved version, with a message explaining the change
- **Undo:** go back to a version that worked
- **Collaboration:** several people work on the same project at once
- **Branches:** try an idea separately, then merge it in when it works
- **Backup:** a copy of everything on a server (GitHub)

Common version control systems are Git, Mercurial and SVN. **Git** is by far the most widely used, and it's what
employers expect.

**Why it matters for data engineering:** pipelines are code. In industry, every SQL query, notebook and job definition
lives in Git, every change is reviewed in a pull request, and deployments happen automatically from Git.

---

## 2. Git and GitHub

They are related but different:

| | Git | GitHub |
| --- | --- | --- |
| What it is | A version control **program** on your computer | A **website** that hosts Git repositories |
| Created by | Linus Torvalds (creator of Linux), 2005 | GitHub, Inc. (now part of Microsoft) |
| Works offline? | Yes | No |
| Adds | History, branches, merging | Pull requests, code review, issues, project boards, GitHub Actions |

**Git** stores **snapshots** of your whole project each time you commit, not just the lines that changed. It is
**distributed**: every copy of a repository has the full history, so you can work and commit without a network
connection.

**GitHub** is where the shared copy of each repository lives, so your team, your reviewer and your instructor
can all see it. Repositories can be **public** (anyone can see them) or **private** (only people you invite).

**In this course** all repos live in the GitHub organization [`dsc592f26`](https://github.com/dsc592f26):

| Repo | Purpose |
| --- | --- |
| `dsc592-course` | Course materials (public) |
| `dsc592-data` | Small datasets such as `cities.csv` (public) |
| `lab1-<your-username>`, `lab2-...` | Your individual lab repos, created for you (private) |
| `dsc592-team<N>` | Your team's project repo, from Lecture 7 (private) |

---

## 3. One-time setup

see [here](../setup/02_git_github.md)

## 4. How Git thinks: the three places your work lives

```text
 working folder ──git add──► staging area ──git commit──► local repo ──git push──► GitHub
       ▲                                                       │
       └─────────────────── git pull (fetch + merge) ◄─────────┘
```

| Place | What it is |
| --- | --- |
| **Working folder** | The files you see and edit |
| **Staging area** | The changes you've chosen to include in the next commit (`git add`) |
| **Local repository** | The history of commits on your computer (`git commit`), stored in the hidden `.git` folder |
| **Remote (GitHub)** | The shared copy, called `origin` (`git push` sends commits there, `git pull` brings them back) |

Key words:

- **Repository (repo):** a project folder tracked by Git, including its full history.
- **Commit:** a saved snapshot of the project, with a message, an author and a time.
- **Branch:** a named line of commits; technically a movable pointer to a commit.
- **Remote:** another copy of the repository, usually on GitHub. The default name is `origin`.

**Why a staging area?** It lets you choose exactly what goes into a commit. For example, you can commit your script
and leave a half-finished file for later.

---

## 5. The everyday workflow (Lab 1B)

This is the loop you'll repeat all semester: **clone → branch → edit → add → commit → push → pull request**.

```bash
# 1. Get a copy of your repo (once)
cd ~/dsc592
git clone https://github.com/dsc592f26/lab1-<your-github-username>.git
cd lab1-<your-github-username>

# 2. Make a branch for your work
git switch -c lab1              # create and switch to a new branch called lab1

# 3. Edit files, then look at what changed
git status                      # which files are new or modified?
git diff                        # what exactly changed (not yet staged)?

# 4. Stage and commit
git add shell_answers.md fetch_weather.sh .gitignore
git diff --staged               # review exactly what you are about to commit
git commit -m "Add Lab 1A shell answers and fetch script"
git log --oneline --graph       # see your history

# 5. Send your commits to GitHub
git push -u origin lab1         # -u: remember the link, so next time just `git push`

# 6. Later: get changes others pushed
git pull
```

**Writing good commit messages:** use the imperative mood ("Add", "Fix", "Update") and say what changed and why.

| Good | Bad |
| --- | --- |
| `Add fetch script for Open-Meteo` | `stuff` |
| `Fix wrong column name in Lab 1C query` | `fix` |
| `Ignore landing/ JSON files` | `final version 2` |

Commit **often**, in small steps. Your commit history is part of how your work is graded.

---

## 6. Branches

A **branch** is an independent line of work. You make changes on a branch without touching `main`, then merge
them in once they've been reviewed.

```text
 main:     A───B───────────E        (E = merge commit from the pull request)
                \         /
 lab1:           C───D───┘
```

| Command | What it does |
| --- | --- |
| `git branch` | List branches; `*` marks the one you're on |
| `git switch -c lab1` | Create a branch and switch to it |
| `git switch main` | Switch to an existing branch |
| `git merge lab1` | Merge `lab1` into the branch you're on |
| `git branch -d lab1` | Delete a branch that has been merged |
| `git branch -M main` | Rename the current branch to `main` |

You may also see `git checkout <branch>` and `git checkout -b <branch>`. These are older forms of `git switch`
and `git switch -c`, and both still work.

**How branches are used in this course:**

| Repo | Branch rule |
| --- | --- |
| `lab1-<username>` | Work on `lab1`; `main` is **protected**, so you can't push to it directly. Your work reaches `main` through a pull request, merged by the instructor after grading |
| `dsc592-team<N>` | One branch per feature (e.g. `feature/weather-ingest`, `fix/silver-dedup`); merge to `main` by pull request with **1 teammate approval** |
| `dsc592-course` | Branches `week1`, `week2`, ... are snapshots of the course code at the end of each week |

---

## 7. Pull requests

A **pull request (PR)** asks to merge one branch into another, such as `lab1` into `main`. It's where reviewers read the
changes, comment and approve before anything is merged. In this course, **every lab and every project change is
submitted as a PR**.

**Open a PR on GitHub:**

1. After `git push`, GitHub shows a yellow banner: click **Compare & pull request**.
   (Or open the **Pull requests** tab → **New pull request**.)
2. Check the direction: **base:** `main` ← **compare:** `lab1`.
3. Write a clear title (e.g. `Lab 1: Week 1 foundations`) and fill in the description template: what you did,
   anything unfinished, and the **AI use disclosure**.
4. Request a reviewer, then click **Create pull request**.

**Or from the terminal:**

```bash
gh pr create --base main --title "Lab 1: Week 1 foundations" --fill
```

**Keep pushing to update it:** every new commit you push to `lab1` appears in the same PR automatically.
**Don't merge your own lab PR.** The instructor merges after grading.

**Reviewing someone else's PR:** open the **Files changed** tab, click a line to comment, then **Review changes** →
*Comment*, *Approve* or *Request changes*. Comment on the code, not the person; be specific; suggest rather than demand.

---

## 8. Merge conflicts

A **merge conflict** happens when two branches change **the same lines** of a file in different ways. Git can't
decide which version is right, so it asks you.

You'll see something like this after `git pull` or `git merge`:

```text
CONFLICT (content): Merge conflict in cities_notes.md
Automatic merge failed; fix conflicts and then commit the result.
```

Inside the file, Git marks both versions:

```text
<<<<<<< HEAD
Miami: hot and humid, frequent afternoon storms.
=======
Miami: tropical; heat index often above 100 F.
>>>>>>> main
```

- Between `<<<<<<< HEAD` and `=======`: **your** version (the branch you're on)
- Between `=======` and `>>>>>>>`: the **incoming** version

**To resolve it:**

```bash
git status                       # lists files marked "both modified"
# 1. Open the file and edit it to the final text you want
# 2. Delete ALL three marker lines: <<<<<<<, =======, >>>>>>>
git add cities_notes.md          # mark the conflict as resolved
git commit -m "Resolve conflict in Miami description"
git push                         # the PR updates and the conflict is gone
```

VS Code shows **Accept Current / Accept Incoming / Accept Both** buttons above a conflict; those are fine to use.
The most common mistake is leaving a `=======` line in the file. You'll practice this in the Lecture 3 merge
conflict drill, with your partner's repo `conflict-drill-<pair#>`.

---

## 9. Keeping files out of Git: `.gitignore`

A `.gitignore` file lists files and folders Git should **never** track. In this course, data files and secrets
never belong in Git:

```bash
printf "landing/\n*.json\n.env\n" > .gitignore
cat .gitignore
```

```text
landing/
*.json
.env
```

| Line | Ignores |
| --- | --- |
| `landing/` | Downloaded raw data |
| `*.json` | API responses |
| `.env` | API keys and other secrets |

You can add comments to `.gitignore`, but only on **their own line** starting with `#`. A comment at the end of a
rule (`landing/  # raw data`) becomes part of the pattern and silently breaks the rule.

Commit `.gitignore` **first**, before any data exists. Once a file has been committed, adding it to `.gitignore`
doesn't remove it from history. A leaked API key stays in the history even if you delete the file later,
so treat it as compromised and get a new one.

---

## 10. Starting your own repository

Your lab and team repos are created for you. For your own side projects, there are two ways to start.

**A. Create on GitHub, then clone (easiest):**

1. On GitHub, open **Repositories** → **New**.
2. Enter a name (short and memorable) and an optional description; choose **Public** or **Private**.
3. Optionally tick **Add a README file**, choose a `.gitignore` template (e.g. *Python*) and a license.
4. Click **Create repository**, then copy the URL from the green **Code** button and:

```bash
git clone https://github.com/<your-username>/<repo-name>.git
```

**B. Start from a local folder, then connect it to an empty GitHub repo:**

```bash
cd my_project
git init                                    # make this folder a Git repo
echo "# My project" > README.md             # README.md is written in Markdown
git add .                                   # stage everything (check .gitignore first!)
git commit -m "Initial commit"
git branch -M main                          # make sure the branch is called main
git remote add origin https://github.com/<your-username>/<repo-name>.git
git push -u origin main
```

Markdown reference for READMEs: https://www.markdownguide.org/cheat-sheet/

**Forks:** on public projects you can't push to, click **Fork** to make your own copy, push to the fork, and open a
pull request back to the original. We don't use forks for course work, since you have direct access to your own repos.

---

## 11. Databricks Git folders

A **Git folder** (formerly called "Repos") is a folder in your Databricks workspace that is connected to a Git
repository. You can clone, switch branches, commit, push and pull from the Databricks UI.

1. In the workspace: **Workspace** → **Create** → **Git folder**.
2. Paste the repo URL (e.g. `https://github.com/dsc592f26/lab1-<username>.git`) and create it.
3. Use the branch button at the top to switch to `lab1`.
4. Create or edit notebooks, then click the **branch name** → review changed files → write a message →
   **Commit & Push**.
5. Back in your terminal: `git pull` to get those commits locally.

The terminal and the workspace are two views of the **same repository** on GitHub.

---

## 12. More GitHub features

| Feature | What it's for | In this course |
| --- | --- | --- |
| **Issues** | Track bugs, tasks and ideas | Optional for team task tracking |
| **Projects** (boards) | Kanban board: To do → In progress → Done | Optional for team planning |
| **GitHub Actions** | Run automated tasks on events like `push` or a PR (CI/CD) | Lectures 28–29: deploy your pipeline automatically |
| **GitHub Pages** | Host a static website from a repo | Not used |

A minimal GitHub Actions workflow lives in `.github/workflows/ci.yml`:

```yaml
name: CI
on: [push]                       # run on every push
jobs:
  check:
    runs-on: ubuntu-latest       # a fresh Linux machine
    steps:
      - uses: actions/checkout@v4   # get the repo's code
      - name: Run tests
        run: pytest              # any shell command
```

In Lecture 29, the same idea deploys your Databricks Asset Bundle whenever a PR is merged into `main`.

---

## 13. Best practices for this course

- **Commit early and often,** with clear messages. Small commits are easier to review and to undo.
- **Never work directly on `main`.** Make a branch and open a pull request.
- **Pull before you start working** (`git pull`), especially in team repos.
- **Review PRs carefully and kindly.** Reviews count toward your project grade.
- **Never commit data or secrets.** Set up `.gitignore` first.
- **Delete branches after they're merged** to keep the repo tidy (GitHub offers a button after merging).
- **Check `git status` constantly.** It almost always tells you what to do next.

---

## 14. Command reference

| Task | Command |
| --- | --- |
| Check setup | `git --version`, `git config --list`, `gh auth status` |
| Copy a repo from GitHub | `git clone <url>` |
| Start a new repo in this folder | `git init` |
| See what changed | `git status`, `git diff`, `git diff --staged` |
| Stage files | `git add <file>`, or `git add .` for everything |
| Unstage a file (keep your edits) | `git restore --staged <file>` |
| Discard your edits to a file | `git restore <file>` (cannot be undone!) |
| Commit | `git commit -m "message"` |
| See history | `git log --oneline --graph` |
| List / create / switch branches | `git branch`, `git switch -c <name>`, `git switch <name>` |
| Rename the current branch | `git branch -M <new-name>` |
| Merge a branch into the current one | `git merge <branch>` |
| Connect to GitHub | `git remote add origin <url>`, check with `git remote -v` |
| Push (first time / later) | `git push -u origin <branch>` / `git push` |
| Pull | `git pull`, or `git pull origin main` to bring in `main` |
| Open a pull request | `gh pr create --base main --fill` |

You may see `git reset <file>` used to unstage a file and `git checkout <branch>` to switch branches. These are older
forms of `git restore --staged` and `git switch`.

---

## 15. Common problems

| Message or symptom | Cause | Fix |
| --- | --- | --- |
| `Support for password authentication was removed` | Git asked for your GitHub password | `gh auth login`, then retry |
| `Repository not found` when cloning | Org invite not accepted, or wrong username in the URL | Accept the invite at https://github.com/dsc592f26; check the URL |
| `fatal: not a git repository` | You're not inside the repo folder | `cd` into the folder you cloned |
| `push declined due to repository rule violations` / `protected branch` | You tried to push to `main` | Push your branch (`git push -u origin lab1`) and open a PR |
| `Updates were rejected because the remote contains work that you do not have` | Someone pushed first | `git pull`, resolve any conflicts, then `git push` |
| `need to specify how to reconcile divergent branches` | Git's pull setting isn't chosen yet | `git config --global pull.rebase false`, then `git pull` again |
| An editor opens with a merge message | `git pull` created a merge commit | Save and close (in `vim`: type `:wq` and press Enter) |
| Commits don't show your GitHub picture | Git email doesn't match your GitHub account | Fix `git config --global user.email`, or add the email on GitHub |
| You committed a secret | It's in the history | Tell the instructor, **revoke the key**, and create a new one |

---

## 16. More resources

- GitHub Docs, [About pull requests](https://docs.github.com/en/pull-requests/get-started/about-pull-requests)
- *Pro Git* book (free): https://git-scm.com/book/en/v2
- *The Missing Semester* (MIT), "Version Control (Git)": https://missing.csail.mit.edu/2020/version-control/
- Interactive branching practice: https://learngitbranching.js.org
- Udemy free course: https://www.udemy.com/course/git-expert-4-hours/
- Course shell cheat sheet: [`linux_shell_cheatsheet.md`](linux_shell_cheatsheet.md)
