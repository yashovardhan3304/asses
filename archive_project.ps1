# PowerShell Script to Create a Clean Project ZIP (Excluding node_modules, .next, and env keys)
$ErrorActionPreference = "Stop"

$projectName = "groweasy-crm-ai-importer"
$zipPath = Join-Path (Get-Item .).Parent.FullName "$projectName-clean.zip"
$tempDir = Join-Path (Get-Item .).Parent.FullName "temp_zip_build"

Write-Host "🧹 Preparing to create clean archive..." -ForegroundColor Cyan

# Remove prior artifacts if they exist
if (Test-Path $zipPath) { 
    Remove-Item $zipPath -Force 
    Write-Host "🗑️ Removed existing ZIP file." -ForegroundColor Yellow
}
if (Test-Path $tempDir) { 
    Remove-Item $tempDir -Recurse -Force 
}

# Create temp build folder structure
New-Item -ItemType Directory -Path $tempDir | Out-Null
New-Item -ItemType Directory -Path (Join-Path $tempDir "backend") | Out-Null
New-Item -ItemType Directory -Path (Join-Path $tempDir "frontend") | Out-Null

Write-Host "📦 Copying code files (excluding node_modules and builds)..." -ForegroundColor Cyan

# 1. Copy root files
Copy-Item "docker-compose.yml" -Destination $tempDir
Copy-Item "README.md" -Destination $tempDir

# 2. Copy backend files (excluding node_modules, .env, and logs)
Get-ChildItem -Path "backend" | Where-Object { 
    $_.Name -ne "node_modules" -and $_.Name -ne ".env" -and $_.Name -ne "package-lock.json"
} | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination (Join-Path $tempDir "backend") -Recurse
}

# 3. Copy frontend files (excluding node_modules, .next, and build folders)
Get-ChildItem -Path "frontend" | Where-Object { 
    $_.Name -ne "node_modules" -and $_.Name -ne ".next" -and $_.Name -ne "package-lock.json" -and $_.Name -ne "out"
} | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination (Join-Path $tempDir "frontend") -Recurse
}

Write-Host "🗜️ Compressing files into ZIP..." -ForegroundColor Cyan

# Compress temp build folder
Compress-Archive -Path "$tempDir\*" -DestinationPath $zipPath

# Cleanup temp folder
Remove-Item $tempDir -Recurse -Force

Write-Host "🎉 SUCCESS! Clean project ZIP created at:" -ForegroundColor Green
Write-Host "$zipPath" -ForegroundColor Yellow
Write-Host "You can now upload this ZIP file directly to GitHub or send it to your evaluators!" -ForegroundColor Green
