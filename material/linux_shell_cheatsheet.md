# Linux shell cheat sheet

DSC 592 · Data Engineering · Fall 2026 · Lecture 2 (Lab 1A)

These commands work in **bash** (WSL/Ubuntu, Git Bash, Databricks) and **zsh** (macOS) unless noted.
Text after `#` is a comment, and the shell ignores it.

---

## 1. Getting help

| Command | What it does |
| --- | --- |
| `man ls` | Manual page for `ls`. Use the arrow keys or space to scroll, `/word` to search, and `q` to quit |
| `ls --help` | Short help on Linux. On macOS, use `man` |

---

## 2. Navigating folders

| Command | What it does |
| --- | --- |
| `pwd` | **P**rint **w**orking **d**irectory: where am I? |
| `ls` | List files in the current folder |
| `ls -l` | Long format: permissions, owner, size, date |
| `ls -la` | Long format **plus hidden files** (names starting with `.`, e.g. `.gitignore`) |
| `ls -lh` | Long format with human-readable sizes (`4.0K`, `12M`) |
| `cd folder` | Move into `folder` |
| `cd ..` | Go up one level |
| `cd ~` or `cd` | Go to your home folder |
| `cd -` | Jump back to the previous folder |
| `mkdir name` | Make a folder |
| `mkdir -p a/b/c` | Make a folder **and any missing parents**; no error if it already exists |

**Paths:** `~` is your home folder, `.` is the current folder and `..` is the parent folder. A path that starts with `/` begins at the root of the file system.

**Reading `ls -l` output:**

```text
-rwxr--r--  1 may  staff   312 Oct  4 10:20 fetch_weather.sh
│└┬┘└┬┘└┬┘     owner group  size  modified    name
│ │  │  └ others: read only
│ │  └ group: read only
│ └ owner: read, write, execute
└ type: - file, d directory
```

The `total 8` line at the top is the disk space used, counted in blocks rather than bytes. You can ignore it.

---

## 3. Copying, moving and renaming

For `cp` and `mv`, the **last argument is always the destination**; everything before it is a source.

```bash
cp source destination
cp file1 file2 file3 destination_folder/
```

| Command | What it does |
| --- | --- |
| `cp notes.md backup/` | Copy into an existing folder (keeps the name `notes.md`) |
| `cp notes.md notes_old.md` | Make a copy with a new name |
| `cp a.md b.sh .` | Copy two files into the current folder (`.`) |
| `cp -r landing backup/` | Copy a **folder** and everything in it (`-r` = recursive) |
| `cp -i notes.md backup/` | Ask before overwriting an existing file |
| `mv old.md new.md` | **Rename** a file |
| `mv file1 file2 folder/` | **Move** files into a folder |

- With several sources, the destination must be an existing folder.
- `cp` and `mv` **overwrite without asking**. Add `-i` to be asked first.
- `rm file` deletes a file **permanently**; there is no Trash. Double-check with `ls` first.

Example from Lab 1B (run inside your cloned repo):

```bash
cp ~/dsc592/lab1/shell_answers.md ~/dsc592/lab1/fetch_weather.sh .
```

---

## 4. Looking at files

| Command | What it does |
| --- | --- |
| `cat file` | Print the whole file |
| `head -n 3 file` | First 3 lines |
| `tail -n 2 file` | Last 2 lines |
| `tail -n +2 file` | Everything **from line 2 on** (skips a header row) |
| `wc -l file` | Count lines |
| `less file` | Scroll through a big file (`q` to quit) |

```bash
wc -l cities.csv                 # 11: the header + 10 cities
tail -n +2 cities.csv | wc -l    # 10: data rows only
```

---

## 5. Printing and writing to files

`echo` prints whatever you give it. Use it to check a variable's value or to print status messages in scripts.

```bash
echo hello                          # hello
echo "Fetching weather for $CITY"   # Fetching weather for Wilmington
echo $HOME                          # /Users/may (the value of a variable)
echo landing/weather/$(date -u +%Y/%m/%d/%H)   # preview a path before using it
```

**Redirection** sends a command's output to a file instead of the screen:

| Syntax | What it does |
| --- | --- |
| `command > file` | Write output to `file`. **Replaces** what was there |
| `command >> file` | **Append** output to the end of `file` |
| `command 2> errors.txt` | Write error messages to a file |

```bash
echo "landing/" > .gitignore                    # create/overwrite: one line
echo ".env" >> .gitignore                       # add a second line
printf "landing/\n*.json\n.env\n" > .gitignore  # several lines at once
```

`printf` handles `\n` (newline) the same way on every system, so prefer it over `echo` for multi-line text.

---

## 6. Searching

| Command | What it does |
| --- | --- |
| `grep "text" file` | Show lines containing `text` |
| `grep -i "text" file` | Same, ignoring upper/lower case |
| `grep -c "text" file` | Count matching lines |
| `find landing -type f` | List every **file** under `landing`, including subfolders |
| `find landing -type d` | List every **folder** under `landing` |
| `find landing -name '*.json'` | Files whose name matches a pattern (keep the quotes) |

---

## 7. Pipes: combine small tools

A **pipe** `|` sends the output of one command into the next.

```bash
head -n 3 cities.csv | grep -i "new york"         # search only the first 3 lines
tail -n +2 cities.csv | sort | head -n 3           # first 3 data rows, sorted by city
find landing -name '*.json' | wc -l                # how many JSON files?
find landing -name '*.json' | sort | tail -n 1     # newest file (landing paths sort by time)
```

| Tool | What it does |
| --- | --- |
| `sort` | Sort lines alphabetically (`sort -n` numerically, `sort -r` reversed) |
| `head` / `tail` | Keep the first / last lines |
| `wc -l` | Count lines |

---

## 8. Downloading with `curl`

```bash
curl -sL -o cities.csv https://raw.githubusercontent.com/dsc592f26/dsc592-data/main/cities.csv
curl -s "https://api.open-meteo.com/v1/forecast?latitude=34.23&longitude=-77.94&current=temperature_2m"
```

| Flag | Meaning |
| --- | --- |
| `-s` | Silent: hide the progress bar |
| `-S` | Still show errors when silent (use as `-sS`) |
| `-L` | Follow redirects: if the file has moved, go to the new address |
| `-o file` | Save the response to `file` instead of printing it |
| `-O` (capital) | Save using the name from the URL. **Not the same as `-o`** |
| `-f` | Fail on HTTP errors instead of saving the error page |

**Safe default for scripts:** `curl -fsSL -o file "URL"`.

**Reading an API URL:**

```text
https://api.open-meteo.com/v1/forecast ? latitude=34.23 & longitude=-77.94 & current=temperature_2m
└──────────── endpoint ──────────────┘   └──────── parameters: key=value, joined by & ────────┘
```

Every public API documents its endpoints and parameters. For Open-Meteo, the docs page builds the URL for you.
Always put URLs in **double quotes**. In zsh (macOS), an unquoted `?` gives the error `zsh: no matches found`.

---

## 9. Variables and `$`

```bash
URL="https://api.open-meteo.com/v1/forecast?latitude=34.23&longitude=-77.94&current=temperature_2m"
curl -s "$URL"                                 # $URL is replaced by its value

DIR=landing/weather/$(date -u +%Y/%m/%d/%H)    # $( ... ) runs a command and pastes its output
mkdir -p "$DIR"                                # e.g. landing/weather/2026/10/09/14
curl -s -o "$DIR/wilmington.json" "$URL"
```

| Syntax | Meaning |
| --- | --- |
| `NAME=value` | Set a variable. **No `$`, no spaces around `=`** |
| `$NAME` | The variable's value |
| `${NAME}_suffix` | Use braces when text follows directly |
| `$(command)` | Run `command` and use its output (command substitution) |
| `"$NAME"` | Double quotes: the value is filled in. **Always quote paths** |
| `'$NAME'` | Single quotes: printed literally, with no substitution |

`date -u +%Y/%m/%d/%H` prints the current **UTC** time as `2026/10/09/14`
(`%Y` year, `%m` month, `%d` day, `%H` hour on a 24-hour clock).

**Naming convention:** ALL CAPS for environment variables (`PATH`, `HOME`, `API_KEY`). Lowercase names are safer
for variables inside scripts, so you never overwrite a system variable like `PATH` by accident.

---

## 10. Environment variables

```bash
echo $HOME $USER $PATH $SHELL        # built-in variables
export CITY="Wilmington"              # export: visible to programs you run (curl, python)
export LAT=34.23 LON=-77.94
echo "Fetching weather for $CITY"
env | grep -E '^(CITY|LAT|LON)='      # list your variables
unset CITY                            # remove it
```

- Variables last only for the current terminal window.
- To keep one permanently, add the `export` line to `~/.zshrc` (macOS) or `~/.bashrc` (Ubuntu/WSL).
- **Never hard-code or commit API keys.** Keep them in environment variables or in an untracked `.env` file
  listed in `.gitignore`. On Databricks, use secret scopes (Lecture 15).

---

## 11. Scripts and permissions

```bash
cat > fetch_weather.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
LAT="${1:?usage: fetch_weather.sh LAT LON}"; LON="${2:?}"
OUT="landing/weather/$(date -u +%Y/%m/%d/%H)"
mkdir -p "$OUT"
curl -s -o "$OUT/${LAT}_${LON}.json" \
  "https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}&current=temperature_2m"
echo "wrote $OUT/${LAT}_${LON}.json"
EOF

chmod u+x fetch_weather.sh       # let the owner (you) execute it; here the same as chmod 744
./fetch_weather.sh 40.71 -74.01  # run it with two arguments
```

| Piece | Meaning |
| --- | --- |
| `#!/usr/bin/env bash` | The "shebang": run this file with bash |
| `set -euo pipefail` | Stop on errors, unset variables and failed pipes |
| `$1`, `$2` | The first and second arguments |
| `${1:?message}` | Stop with `message` if argument 1 is missing |
| `cat > file <<'EOF' ... EOF` | Write the lines in between into `file` |
| `\` at the end of a line | Continue the command on the next line (no space after it!) |
| `./script.sh` | Run a script in the current folder |

**Permissions as numbers:** read = 4, write = 2, execute = 1, with one digit each for owner, group and others.
`chmod 744` gives the owner `rwx` (7), the group `r--` (4) and others `r--` (4).

---

## 12. Cron schedules (reading only)

```text
┌─ minute (0–59)
│ ┌─ hour (0–23)
│ │ ┌─ day of month (1–31)
│ │ │ ┌─ month (1–12)
│ │ │ │ ┌─ day of week (0–6, Sunday = 0)
0 * * * *      every hour, on the hour
*/15 * * * *   every 15 minutes
30 6 * * 1-5   6:30 am, Monday–Friday
```

Databricks Jobs use **Quartz** cron, which adds a seconds field and uses `?`. Hourly is `0 0 * * * ?` (Lecture 22).

---

## 13. Keyboard shortcuts

| Keys | What it does |
| --- | --- |
| **Tab** | Autocomplete file and folder names (press twice to see options) |
| **Up / Down** | Previous / next command |
| **Ctrl+R**, then type | Search your command history (press Ctrl+R again for older matches) |
| **Ctrl+C** | Stop the running command |
| **Ctrl+A / Ctrl+E** | Jump to the start / end of the line |
| **Ctrl+L** or `clear` | Clear the screen |
| `history \| grep cd` | List past commands containing `cd` |

---

## 14. bash vs zsh

| | bash | zsh |
| --- | --- | --- |
| Default on | WSL/Ubuntu, Git Bash, Databricks | macOS |
| Settings file | `~/.bashrc` | `~/.zshrc` |
| Unquoted `?` or `*` with no matching file | Passed through as text | Error: `no matches found` |

Check yours with `echo $SHELL`. Course scripts start with `#!/usr/bin/env bash`, so they run in bash either way.

---

## 15. Common mistakes

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| `zsh: no matches found` | URL not in quotes | Put the URL in `"double quotes"` |
| `curl: (6) Could not resolve host: landing` | `-O` instead of `-o`, or `-o` missing | Put `-o` (lowercase) right before the file name |
| `curl: (23) Failure writing output` | The target folder doesn't exist | `mkdir -p` the folder first |
| `Permission denied` when running a script | The file isn't executable | `chmod u+x script.sh` |
| `command not found` after setting `PATH=...` | You overwrote the system `PATH` | Open a new terminal; use lowercase names for your own variables |
| A `>` prompt appears | Unclosed quote, or a space after `\` | Press Ctrl+C and retype |
| `cd..` fails | Missing space | `cd ..` |
| A variable is empty | Spaces around `=` (`DIR = x`) | `DIR=x` |

---

## Practice

1. How many data rows are in `cities.csv`? (Exclude the header.)
2. Which city is in the 5th data row (not counting the header)? Use `head` and `tail` joined by a pipe.
3. Store a city's name, latitude and longitude in variables, build the API URL from them, and save the response
   to `landing/weather/yyyy/mm/dd/hh/<city>.json` using `$(date ...)`.
4. Run `fetch_weather.sh` for two more cities, list all JSON files under `landing`, then pipe `find` into `grep` to show only the script's files (names contain `_`).

More practice: *The Missing Semester of Your CS Education* (MIT), lectures "The Shell" and "Shell Tools and Scripting": https://missing.csail.mit.edu
