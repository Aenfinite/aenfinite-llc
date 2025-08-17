# PowerShell script to update navbar and footer on all work pages
# This script standardizes the navbar and footer across all pages

# Define paths
$workDir = "c:\Users\Extreme DeveOps\Documents\Aenfinite\aenfinite website\dd.nyc\work"
$homePage = "c:\Users\Extreme DeveOps\Documents\Aenfinite\aenfinite website\dd.nyc\index.html"

# Read homepage to extract templates
$homeContent = Get-Content $homePage -Raw -Encoding UTF8

# Extract navbar template (with aenfinite logo)
$navbarStart = $homeContent.IndexOf('<div class="mainnav js-mainnav')
$navbarEnd = $homeContent.IndexOf('</div>', $homeContent.IndexOf('</div>', $homeContent.IndexOf('</div>', $navbarStart) + 6) + 6) + 6
$standardNavbar = $homeContent.Substring($navbarStart, $navbarEnd - $navbarStart)

# Replace relative paths in navbar template for work subdirectories
$workNavbar = $standardNavbar -replace 'href="([^"]*[^.][^.]/)([^"]*)"', 'href="../../$1$2"'
$workNavbar = $workNavbar -replace 'href="([^"]*)"(?=.*Contact)', 'href="../../$1"'

# Extract footer template
$footerStart = $homeContent.IndexOf('<footer')
$footerEnd = $homeContent.IndexOf('</footer>') + 9
$standardFooter = $homeContent.Substring($footerStart, $footerEnd - $footerStart)

# Replace relative paths in footer template for work subdirectories  
$workFooter = $standardFooter -replace 'href="([^"]*[^.][^.]/)([^"]*)"', 'href="../../$1$2"'
$workFooter = $workFooter -replace 'src="([^"]*)"', 'src="../../$1"'

Write-Host "Extracted templates from homepage" -ForegroundColor Green

# Get all HTML files in work subdirectories
$htmlFiles = Get-ChildItem -Path $workDir -Recurse -Include "*.html" | Where-Object { $_.Name -eq "index.html" }

Write-Host "Found $($htmlFiles.Count) files to update" -ForegroundColor Yellow

$updated = 0
$errors = 0

foreach ($file in $htmlFiles) {
    try {
        Write-Host "Processing: $($file.FullName)" -ForegroundColor Cyan
        
        $content = Get-Content $file.FullName -Raw -Encoding UTF8
        
        # Find and replace navbar section
        if ($content -match '<div class="mainnav js-mainnav.*?</div>\s*</div>\s*</div>') {
            # Find the exact bounds of the old navbar
            $oldNavStart = $content.IndexOf('<div class="mainnav js-mainnav')
            if ($oldNavStart -ge 0) {
                # Find the end of the mainnav div structure
                $navContent = $content.Substring($oldNavStart)
                $divCount = 0
                $inMainNav = $false
                $navEnd = $oldNavStart
                
                for ($i = 0; $i -lt $navContent.Length; $i++) {
                    $char = $navContent[$i]
                    if ($navContent.Substring($i, [Math]::Min(4, $navContent.Length - $i)) -eq '<div') {
                        $divCount++
                        if (-not $inMainNav) { $inMainNav = $true }
                    }
                    elseif ($navContent.Substring($i, [Math]::Min(6, $navContent.Length - $i)) -eq '</div>') {
                        $divCount--
                        if ($inMainNav -and $divCount -eq 0) {
                            $navEnd = $oldNavStart + $i + 6
                            break
                        }
                    }
                }
                
                if ($navEnd -gt $oldNavStart) {
                    $beforeNav = $content.Substring(0, $oldNavStart)
                    $afterNav = $content.Substring($navEnd)
                    $content = $beforeNav + $workNavbar + $afterNav
                    Write-Host "  - Updated navbar" -ForegroundColor Green
                }
            }
        }
        
        # Find and replace footer section
        if ($content -match '<footer.*?</footer>') {
            $footerStart = $content.IndexOf('<footer')
            $footerEnd = $content.IndexOf('</footer>') + 9
            
            if ($footerStart -ge 0 -and $footerEnd -gt $footerStart) {
                $beforeFooter = $content.Substring(0, $footerStart)
                $afterFooter = $content.Substring($footerEnd)
                $content = $beforeFooter + $workFooter + $afterFooter
                Write-Host "  - Updated footer" -ForegroundColor Green
            }
        }
        
        # Write the updated content back to the file
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
        $updated++
        Write-Host "  ✓ Completed successfully" -ForegroundColor Green
        
    } catch {
        Write-Host "  ✗ Error updating $($file.FullName): $($_.Exception.Message)" -ForegroundColor Red
        $errors++
    }
}

Write-Host "`n=== UPDATE SUMMARY ===" -ForegroundColor Yellow
Write-Host "Files processed: $($htmlFiles.Count)" -ForegroundColor White
Write-Host "Successfully updated: $updated" -ForegroundColor Green
Write-Host "Errors: $errors" -ForegroundColor Red

if ($updated -gt 0) {
    Write-Host "`nNavbar and footer standardization completed!" -ForegroundColor Green
    Write-Host "All pages now use the unified aenfinite logo and consistent navigation structure." -ForegroundColor White
}
