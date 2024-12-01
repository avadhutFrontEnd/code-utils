# Prompt user to enter folder location
$folderLocation = Read-Host "Please enter the folder location containing the .vtt files"

# Iterate through each .vtt file in the folder
foreach ($file in Get-ChildItem -Path $folderLocation -Filter *.vtt) {
    # Read the contents of the .vtt file
    $vttContent = Get-Content -Path $file.FullName

    # Remove the time-stamp information and newlines, save the text-only content as a paragraph to a .txt file
    $txtContent = ($vttContent | Where-Object { $_ -notmatch '^\d+$' -and $_ -notmatch '^\d\d:\d\d:\d\d.\d\d\d --> \d\d:\d\d:\d\d.\d\d\d$' }) -join ' '
    $txtFilePath = Join-Path -Path $folderLocation -ChildPath ($file.BaseName + ".txt")
    $txtContent | Out-File -FilePath $txtFilePath -Encoding utf8
}

Write-Host "Text-only files have been saved to the same folder as the .vtt files."