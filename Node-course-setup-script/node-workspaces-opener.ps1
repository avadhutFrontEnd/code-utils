$workspaces = @(
    "C:\Users\Avadhut\Desktop\git\4. Node\code",
    "C:\Users\Avadhut\Desktop\git\4. Node\NestJS",
    "C:\Users\Avadhut\Desktop\git\4. Node\Node Projects",
    "C:\Users\Avadhut\Desktop\git\4. Node\node-api"
)

$cursorCmd = Get-Command "cursor" -ErrorAction SilentlyContinue
if (-not $cursorCmd) {
    Write-Host "Cursor CLI command not found. Install/enable 'cursor' in PATH first." -ForegroundColor Red
    exit 1
}

foreach ($path in $workspaces) {
    if (-not (Test-Path -Path $path -PathType Container)) {
        Write-Host "Skipping (folder not found): $path" -ForegroundColor Yellow
        continue
    }

    Write-Host "Opening workspace folder in new window: $path"
    # IMPORTANT: pass the folder path as one quoted argument, otherwise spaces can split
    # into tokens (e.g. '4. Node\Node Projects' becoming tabs like '4', 'Node', 'Projects').
    $argLine = "-n -- `"$path`""
    Start-Process -FilePath $cursorCmd.Source -ArgumentList $argLine
    Start-Sleep -Milliseconds 700
}

Write-Host "Done: requested workspaces opened in separate Cursor windows." -ForegroundColor Green