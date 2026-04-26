# Markdown File Priority App

React + Node app to review `markdown-files-report.md`, mark file/folder priority, and create backups of important items.

## Structure

- `client/` - React UI
- `server/` - Express API
- `state/settings.json` - report and backup paths
- `state/marks.json` - persistent category selections

## Categories

- `important` (gold)
- `reference`
- `archive`
- `ignore`
- `unreviewed`

## Run

Open two terminals:

```powershell
cd "Scripts/md-file-priority-app/server"
npm install
npm run dev
```

```powershell
cd "Scripts/md-file-priority-app/client"
npm install
npm run dev
```

- Client: `http://localhost:5177`
- API: `http://localhost:4177`

## Notes

- No database is used.
- State is persisted in JSON files under `state/`.
- Backup copies important items to the configured `backupOutputPath`.
