# Resume builder workspace launcher

## Windows

Double-click **`open-resume-builder-workspace.bat`** or run:

```powershell
.\open-resume-builder-workspace.ps1
```

## WSL / Linux (bash)

From WSL (recommended - uses Windows Cursor and Obsidian):

```bash
chmod +x open-resume-builder-workspace.sh
./open-resume-builder-workspace.sh
```

If your Windows username is not `Avadhut`:

```bash
export WIN_USER=YourWindowsLoginName
./open-resume-builder-workspace.sh
```

On **native Linux** (not WSL), the script falls back to `xdg-open` and Linux `cursor` / `obsidian` if installed; you will likely need to edit paths at the top of `open-resume-builder-workspace.sh`.

---

**Does (Windows & WSL):**

1. Opens **two Cursor windows** (two separate workspaces): **resume-builder** (`tier-1-company-projects\resume-builder`) and **Tier 1 Companies Project** (Google Drive sync / Obsidian notes path). Each folder is opened with its own `cursor <folder>` (`cursor` on PATH, or `%LOCALAPPDATA%\Programs\cursor\Cursor.exe` on Windows).
2. Launches **Obsidian** (`%LOCALAPPDATA%\Obsidian\Obsidian.exe`).

Paths are the same style as `React-course-setup-script\react_ts_part_2.ps1`. Edit the `$resumeBuilderPath` and `$tier1CompaniesNotesPath` variables in the `.ps1` (or `RESUME` / `TIER1` in the `.sh`) if folders move.
