# PowerShell script to update navbar and footer on remaining pages (services, agency, etc.)
# This script completes the site-wide standardization

# Define paths
$rootDir = "c:\Users\Extreme DeveOps\Documents\Aenfinite\aenfinite website\dd.nyc"
$homePage = "$rootDir\index.html"

# Read homepage to extract templates
$homeContent = Get-Content $homePage -Raw -Encoding UTF8

# Extract navbar template (with aenfinite logo)
$navbarStart = $homeContent.IndexOf('<div class="mainnav js-mainnav')
$navbarEnd = $homeContent.IndexOf('</div>', $homeContent.IndexOf('</div>', $homeContent.IndexOf('</div>', $navbarStart) + 6) + 6) + 6
$standardNavbar = $homeContent.Substring($navbarStart, $navbarEnd - $navbarStart)

# Extract footer template
$footerStart = $homeContent.IndexOf('<footer')
$footerEnd = $homeContent.IndexOf('</footer>') + 9
$standardFooter = $homeContent.Substring($footerStart, $footerEnd - $footerStart)

Write-Host "Extracted templates from homepage" -ForegroundColor Green

# Get all HTML files in main directories (excluding work which we already did)
$directories = @("services", "agency", "contact", "industries", "client-testimonials", "dd-nyc-client-testimonials", "featured-work", "news", "privacy-policy")

$allFiles = @()
foreach ($dir in $directories) {
    $dirPath = Join-Path $rootDir $dir
    if (Test-Path $dirPath) {
        $files = Get-ChildItem -Path $dirPath -Recurse -Include "*.html"
        $allFiles += $files
    }
}

Write-Host "Found $($allFiles.Count) files to update" -ForegroundColor Yellow

$updated = 0
$errors = 0

foreach ($file in $allFiles) {
    try {
        Write-Host "Processing: $($file.FullName)" -ForegroundColor Cyan
        
        $content = Get-Content $file.FullName -Raw -Encoding UTF8
        $originalContent = $content
        
        # Determine depth from root to adjust paths
        $relativePath = $file.FullName.Replace($rootDir, "").Replace("\", "/")
        $depth = ($relativePath -split "/").Count - 2  # Subtract 2 for empty first element and filename
        
        # Create appropriate navbar and footer for this depth
        $currentNavbar = $standardNavbar
        $currentFooter = $standardFooter
        
        if ($depth -gt 0) {
            # Adjust paths for subdirectories
            $pathPrefix = "../" * $depth
            $currentNavbar = $currentNavbar -replace 'href="([^"]*)"(?![^<]*<)', "href=`"$pathPrefix`$1`""
            $currentNavbar = $currentNavbar -replace 'src="([^"]*)"', "src=`"$pathPrefix`$1`""
            
            $currentFooter = $currentFooter -replace 'href="([^"]*)"(?![^<]*<)', "href=`"$pathPrefix`$1`""
            $currentFooter = $currentFooter -replace 'src="([^"]*)"', "src=`"$pathPrefix`$1`""
        }
        
        # Find and replace navbar section
        if ($content -match '<div class="mainnav js-mainnav') {
            $oldNavStart = $content.IndexOf('<div class="mainnav js-mainnav')
            if ($oldNavStart -ge 0) {
                # Find the end of the mainnav div structure
                $navContent = $content.Substring($oldNavStart)
                $divCount = 0
                $inMainNav = $false
                $navEnd = $oldNavStart
                
                for ($i = 0; $i -lt $navContent.Length; $i++) {
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
                    $content = $beforeNav + $currentNavbar + $afterNav
                    Write-Host "  - Updated navbar" -ForegroundColor Green
                }
            }
        }
        
        # Find and replace footer section
        if ($content -match '<footer') {
            $footerStart = $content.IndexOf('<footer')
            $footerEnd = $content.IndexOf('</footer>') + 9
            
            if ($footerStart -ge 0 -and $footerEnd -gt $footerStart) {
                $beforeFooter = $content.Substring(0, $footerStart)
                $afterFooter = $content.Substring($footerEnd)
                $content = $beforeFooter + $currentFooter + $afterFooter
                Write-Host "  - Updated footer" -ForegroundColor Green
            }
        }
        
        # Only save if content actually changed
        if ($content -ne $originalContent) {
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8
            $updated++
            Write-Host "  - Completed successfully" -ForegroundColor Green
        } else {
            Write-Host "  - No changes needed" -ForegroundColor Yellow
        }
        
    } catch {
        Write-Host "  - Error updating $($file.FullName): $($_.Exception.Message)" -ForegroundColor Red
        $errors++
    }
}

Write-Host ""
Write-Host "=== UPDATE SUMMARY ===" -ForegroundColor Yellow
Write-Host "Files processed: $($allFiles.Count)" -ForegroundColor White
Write-Host "Successfully updated: $updated" -ForegroundColor Green
Write-Host "Errors: $errors" -ForegroundColor Red

if ($updated -gt 0) {
    Write-Host ""
    Write-Host "Site-wide standardization completed!" -ForegroundColor Green
    Write-Host "All pages now have unified navbar and footer with proper aenfinite branding." -ForegroundColor White
}
