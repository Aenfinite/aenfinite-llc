# Update HTML Files to Use Minified Assets
# This script updates all HTML files to reference .min.js and .min.css versions

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "  Update HTML to Use Minified Assets" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Define replacements for JavaScript files
$jsReplacements = @{
    'ScrollMagic.js' = 'ScrollMagic.min.js'
    'animation.gsap.js' = 'animation.gsap.min.js'
    'demo5163.js' = 'demo5163.min.js'
    'custom-form-handler.js' = 'custom-form-handler.min.js'
    'jquery.min.js' = 'jquery.min.js'  # Already minified
    'gsap.min.js' = 'gsap.min.js'      # Already minified
    'slick.min.js' = 'slick.min.js'    # Already minified
}

# Define replacements for CSS files
$cssReplacements = @{
    'mainf1a7.css' = 'mainf1a7.min.css'
    'stylef1a7.css' = 'stylef1a7.min.css'
}

# Get all HTML files
$htmlFiles = Get-ChildItem -Path . -Filter "*.html" -Recurse -File | Where-Object { 
    $_.FullName -notmatch '\\node_modules\\|\\\.git\\|\\asset-backups' 
}

Write-Host "Found $($htmlFiles.Count) HTML files to process" -ForegroundColor Yellow
Write-Host ""

$updatedFiles = 0
$totalReplacements = 0

foreach ($file in $htmlFiles) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    $fileUpdated = $false
    $fileReplacements = 0

    # Replace JavaScript references
    foreach ($old in $jsReplacements.Keys) {
        $new = $jsReplacements[$old]
        if ($old -ne $new) {  # Only replace if different
            $pattern = [regex]::Escape($old)
            if ($content -match $pattern) {
                $content = $content -replace $pattern, $new
                $matches = [regex]::Matches($originalContent, $pattern).Count
                $fileReplacements += $matches
                $fileUpdated = $true
            }
        }
    }

    # Replace CSS references
    foreach ($old in $cssReplacements.Keys) {
        $new = $cssReplacements[$old]
        if ($old -ne $new) {  # Only replace if different
            $pattern = [regex]::Escape($old)
            if ($content -match $pattern) {
                $content = $content -replace $pattern, $new
                $matches = [regex]::Matches($originalContent, $pattern).Count
                $fileReplacements += $matches
                $fileUpdated = $true
            }
        }
    }

    # Add lazy loading optimization script before </body> if not already present
    if ($content -match '</body>' -and $content -notmatch 'lazy-load-optimization') {
        $lazyLoadScript = @"
    
    <!-- Performance Optimization Script -->
    <script src="/lazy-load-optimization.js" defer></script>
</body>
"@
        $content = $content -replace '</body>', $lazyLoadScript
        $fileUpdated = $true
        $fileReplacements++
    }

    # Save if updated
    if ($fileUpdated) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
        $updatedFiles++
        $totalReplacements += $fileReplacements
        
        $relativePath = $file.FullName.Replace((Get-Location).Path, '').TrimStart('\')
        Write-Host "✓ Updated: $relativePath ($fileReplacements changes)" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "  Update Summary" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Files scanned: $($htmlFiles.Count)" -ForegroundColor White
Write-Host "Files updated: $updatedFiles" -ForegroundColor Green
Write-Host "Total replacements: $totalReplacements" -ForegroundColor Green
Write-Host ""

if ($updatedFiles -gt 0) {
    Write-Host "✓ HTML files have been updated to use minified assets" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Test the website locally" -ForegroundColor White
    Write-Host "2. Run: git add ." -ForegroundColor White
    Write-Host "3. Run: git commit -m 'Optimize assets: Add minified versions and lazy loading'" -ForegroundColor White
    Write-Host "4. Deploy to production" -ForegroundColor White
} else {
    Write-Host "No files needed updating" -ForegroundColor Yellow
}
Write-Host ""
