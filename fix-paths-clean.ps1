# Fix Script Paths for Dynamic Includes
# This script corrects the path to dynamic-includes.js based on directory depth

Write-Host "Starting script path correction for dynamic includes..." -ForegroundColor Green

# Get all HTML files with dynamic includes
$htmlFiles = Get-ChildItem -Path "." -Include "*.html" -Recurse | Where-Object { 
    $_.Name -notlike "*temp*" -and $_.Name -notlike "*backup*" 
}

$totalFixed = 0
$errors = @()

foreach ($file in $htmlFiles) {
    try {
        $content = Get-Content $file.FullName -Raw -Encoding UTF8
        
        # Skip if no dynamic includes script found
        if ($content -notmatch 'dynamic-includes\.js') {
            continue
        }
        
        # Calculate the correct path based on directory depth
        $relativePath = $file.FullName.Replace((Get-Location).Path, "").Replace("\", "/").TrimStart("/")
        $pathSegments = $relativePath.Split("/") | Where-Object { $_ -ne "" -and $_ -ne "index.html" }
        
        # Remove filename from segments count
        if ($pathSegments[-1] -like "*.html") {
            $pathSegments = $pathSegments[0..($pathSegments.Length - 2)]
        }
        
        $depth = $pathSegments.Length
        
        # Determine correct script path
        $correctPath = if ($depth -eq 0) {
            "includes/dynamic-includes.js"
        } else {
            "../" * $depth + "includes/dynamic-includes.js"
        }
        
        Write-Host "Processing: $relativePath (depth: $depth) -> $correctPath" -ForegroundColor Yellow
        
        # Replace all incorrect script paths
        $originalContent = $content
        
        # Common incorrect patterns to fix
        $patterns = @(
            'src="../includes/dynamic-includes.js"',
            'src="includes/dynamic-includes.js"',
            'src="../../includes/dynamic-includes.js"',
            'src="../../../includes/dynamic-includes.js"',
            'src="../../../../includes/dynamic-includes.js"'
        )
        
        foreach ($pattern in $patterns) {
            $content = $content -replace [regex]::Escape($pattern), "src=""$correctPath"""
        }
        
        # Only write if content actually changed
        if ($content -ne $originalContent) {
            Set-Content $file.FullName -Value $content -Encoding UTF8 -NoNewline
            $totalFixed++
            Write-Host "  Fixed script path" -ForegroundColor Green
        } else {
            Write-Host "  Already correct or no changes needed" -ForegroundColor Gray
        }
        
    } catch {
        $errorMsg = "Error processing $($file.FullName): $($_.Exception.Message)"
        $errors += $errorMsg
        Write-Host "  Error: $errorMsg" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== SCRIPT PATH CORRECTION COMPLETE ===" -ForegroundColor Green
Write-Host "Total files fixed: $totalFixed" -ForegroundColor Cyan

if ($errors.Count -gt 0) {
    Write-Host ""
    Write-Host "Errors encountered:" -ForegroundColor Red
    foreach ($error in $errors) {
        Write-Host "  - $error" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Script path correction finished. All dynamic includes should now load correctly!" -ForegroundColor Green
