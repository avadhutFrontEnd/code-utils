# Path to your input markdown (must be in same folder as this script)
$inputFile = "CWM Java Course.md"

# Root directory where the structure will be created
$basePath = Join-Path (Get-Location) "JavaCourse"

# Counters & current paths
$partIndex = 0
$sectionIndex = 0
$partFolder = $null
$sectionFolder = $null

# Helper: sanitize for Windows filenames
function Get-SafeFilename([string]$name) {
    $safe = $name -replace '[<>:"/\\|?*]', '_'      # forbidden chars
    $safe = $safe -replace '[^\u0020-\u007E]', '_'  # non ASCII printable
    $safe = $safe -replace '_{2,}', '_'             # collapse __
    $safe = $safe -replace '\s{2,}', ' '            # collapse multiple spaces
    $safe = $safe.Trim('_',' ')
    return $safe
}

# Ensure base folder exists
if (-not (Test-Path $basePath)) {
    New-Item -ItemType Directory -Path $basePath | Out-Null
}

# Read markdown line by line
Get-Content $inputFile | ForEach-Object {
    $line = $_.Trim()

    # -------------------------
    # Detect PART (course title)
    # -------------------------
    if ($line -match '^\s*#\s+(.+?)(\s*:\s*)?$') {
        $partIndex++
        $sectionIndex = 0
        $partTitle = $Matches[1].Trim()
        $partFolderName = "{0:D2} - {1}" -f $partIndex, (Get-SafeFilename $partTitle)
        $partFolder = Join-Path $basePath $partFolderName

        if (-not (Test-Path $partFolder)) {
            New-Item -ItemType Directory -Path $partFolder -Force | Out-Null
            Write-Output "Created Part folder: $partFolderName"
        }
        return
    }

    # -------------------------
    # Detect SECTION (File name:)
    # Supports ALL formats:
    # **File name:** **Title**
    # **File name: Title**
    # File name: Title
    # -------------------------
    if ($line -match 'File name[:\* ]+\**(.+?)\**$') {
        $sectionIndex++
        $sectionTitle = $Matches[1].Trim()
        $sectionFolderName = "{0:D2} - {1}" -f $sectionIndex, (Get-SafeFilename $sectionTitle)
        $sectionFolder = Join-Path $partFolder $sectionFolderName

        if (-not (Test-Path $sectionFolder)) {
            New-Item -ItemType Directory -Path $sectionFolder -Force | Out-Null
            Write-Output "  Created Section folder: $sectionFolderName"
        }
        return
    }

    # -------------------------
    # Detect VIDEO / FILE LINE
    # Format: #_1-Title_here :
    # -------------------------
    if ($line -match '^\s*#_(.+?)\s*:?\s*$') {
        if (-not $sectionFolder) {
            Write-Warning "Video line found before any section: $line"
            return
        }

        $rawName = $Matches[1].Trim()
        $safeName = Get-SafeFilename $rawName
        $fileName = "$safeName.md"
        $filePath = Join-Path $sectionFolder $fileName

        $content = "#_$rawName :"
        $content | Out-File -Encoding UTF8 -FilePath $filePath -Force

        Write-Output "    Created file: $fileName"
        return
    }

}
Write-Output "`n✔ DONE — All folders and files generated under: $basePath"
