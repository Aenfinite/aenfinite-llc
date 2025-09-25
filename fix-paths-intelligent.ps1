# Fix Script Paths Intelligently - Final Version
# This script correctly calculates paths and fixes all dynamic-includes.js references

Write-Host "Starting intelligent script path correction..." -ForegroundColor Green

# Get all HTML files with dynamic includes
$htmlFiles = Get-ChildItem -Path "." -Include "*.html" -Recurse | Where-Object { 
    $_.Name -notlike "*temp*" -and $_.Name -notlike "*backup*" 
}

$totalFixed = 0
$correct = 0
$errors = @()

foreach ($file in $htmlFiles) {
    try {
        $content = Get-Content $file.FullName -Raw -Encoding UTF8
        
        # Skip if no dynamic includes script found
        if ($content -notmatch 'dynamic-includes\.js') {
            continue
        }
        
        # Calculate the correct path based on directory depth from root
        $relativePath = $file.FullName.Replace((Get-Location).Path, "").Replace("\", "/").TrimStart("/")
        
        # Split path and exclude filename
        $pathParts = $relativePath.Split("/") | Where-Object { $_ -ne "" }
        if ($pathParts[-1] -like "*.html") {
            $pathParts = $pathParts[0..($pathParts.Length - 2)]
        }
        
        $depth = $pathParts.Length
        
        # Determine correct script path
        $correctPath = if ($depth -eq 0) {
            "includes/dynamic-includes.js"  # Root level
        } else {
            ("../" * $depth) + "includes/dynamic-includes.js"  # Subdirectories
        }
        
        # Store original content
        $originalContent = $content
        
        # Replace ANY dynamic-includes.js path with the correct one
        $content = $content -replace 'src="[^"]*dynamic-includes\.js"', "src=""$correctPath"""
        
        # Check if content changed
        if ($content -ne $originalContent) {
            Set-Content $file.FullName -Value $content -Encoding UTF8 -NoNewline
            $totalFixed++
            Write-Host "  Fixed: $relativePath -> $correctPath" -ForegroundColor Green
        } else {
            $correct++
            Write-Host "  OK: $relativePath -> $correctPath" -ForegroundColor Gray
        }
        
    } catch {
        $errorMsg = "Error processing $($file.FullName): $($_.Exception.Message)"
        $errors += $errorMsg
        Write-Host "  Error: $errorMsg" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== INTELLIGENT PATH CORRECTION COMPLETE ===" -ForegroundColor Green
Write-Host "Files fixed: $totalFixed" -ForegroundColor Cyan
Write-Host "Already correct: $correct" -ForegroundColor Gray

if ($errors.Count -gt 0) {
    Write-Host ""
    Write-Host "Errors encountered:" -ForegroundColor Red
    foreach ($error in $errors) {
        Write-Host "  - $error" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "All dynamic includes should now load correctly!" -ForegroundColor Green
