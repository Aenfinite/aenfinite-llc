# PowerShell script to fix horizontal overflow issues across all pages
# This script replaces problematic 100vw with 100% to prevent mobile horizontal scroll

Write-Host "Starting mobile responsiveness fix for horizontal overflow..." -ForegroundColor Green

# Define the root directory
$rootDir = "c:\Users\Extreme DeveOps\Documents\Aenfinite\aenfinite website\dd.nyc"

# Track statistics
$totalFiles = 0
$modifiedFiles = 0
$totalReplacements = 0

# Function to fix a single file
function Fix-HorizontalOverflow {
    param($filePath)
    
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw
        $originalContent = $content
        
        # Replace iframe 100vw with 100%
        $content = $content -replace 'style="width:\s*100vw;', 'style="width: 100%;'
        $content = $content -replace 'style="width:\s*100vw\s*;', 'style="width: 100%;'
        
        # Replace CSS 100vw with 100%
        $content = $content -replace 'width:\s*100vw\s*;', 'width: 100%;'
        $content = $content -replace 'max-width:\s*100vw\s*;', 'max-width: 100%;'
        
        # Replace full-width margin calculations that cause overflow
        $content = $content -replace 'margin-left:\s*calc\(-50vw \+ 50%\)\s*;', 'margin-left: 0;'
        
        # Count changes
        if ($content -ne $originalContent) {
            Set-Content $filePath $content -Encoding UTF8
            $script:modifiedFiles++
            
            # Count number of replacements
            $changes = ($originalContent.Length - $content.Length) / 2  # Rough estimate
            $script:totalReplacements += $changes
            
            Write-Host "Fixed: $filePath" -ForegroundColor Yellow
            return $true
        }
    }
    return $false
}

# Get all HTML files recursively
$htmlFiles = Get-ChildItem -Path $rootDir -Filter "*.html" -Recurse

Write-Host "Found $($htmlFiles.Count) HTML files to check..." -ForegroundColor Cyan

foreach ($file in $htmlFiles) {
    $script:totalFiles++
    Fix-HorizontalOverflow -filePath $file.FullName
    
    # Show progress every 50 files
    if ($script:totalFiles % 50 -eq 0) {
        Write-Host "Processed $script:totalFiles files..." -ForegroundColor Blue
    }
}

# Summary
Write-Host "`n=== Mobile Responsiveness Fix Complete ===" -ForegroundColor Green
Write-Host "Total files checked: $script:totalFiles" -ForegroundColor White
Write-Host "Files modified: $script:modifiedFiles" -ForegroundColor Yellow
Write-Host "Estimated replacements: $script:totalReplacements" -ForegroundColor Cyan

Write-Host "`nChanges made:" -ForegroundColor Green
Write-Host "- Replaced 'width: 100vw' with 'width: 100%'" -ForegroundColor White
Write-Host "- Replaced 'max-width: 100vw' with 'max-width: 100%'" -ForegroundColor White
Write-Host "- Fixed iframe width attributes from 100vw to 100%" -ForegroundColor White
Write-Host "- Removed problematic margin calculations" -ForegroundColor White

Write-Host "`nThis should eliminate horizontal scrolling issues on mobile devices!" -ForegroundColor Green
