# Fix Non-Descriptive "Learn More" Links for SEO
# This script replaces generic "Learn more" links with descriptive text

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Fixing Non-Descriptive Link Text" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Define link replacements with descriptive text
$replacements = @(
    @{
        Old = '<a href="/services/web-design/" class="redlink">' + "`n`t`t`t`t`t`t`t`t`t`t<span>Learn more</span>"
        New = '<a href="/services/web-design/" class="redlink">' + "`n`t`t`t`t`t`t`t`t`t`t<span>Explore Our Web Design Services</span>"
    },
    @{
        Old = '<a href="/services/branding/" class="redlink">' + "`n`t`t`t`t`t`t`t`t`t`t<span>Learn more</span>"
        New = '<a href="/services/branding/" class="redlink">' + "`n`t`t`t`t`t`t`t`t`t`t<span>Discover Our Branding Solutions</span>"
    },
    @{
        Old = '<a href="/services/digital-marketing/" class="redlink">' + "`n`t`t`t`t`t`t`t`t`t`t<span>Learn more</span>"
        New = '<a href="/services/digital-marketing/" class="redlink">' + "`n`t`t`t`t`t`t`t`t`t`t<span>View Digital Marketing Services</span>"
    },
    @{
        Old = '<a href="/services/e-commerce-websites/" class="redlink">' + "`n`t`t`t`t`t`t`t`t`t`t<span>Learn more</span>"
        New = '<a href="/services/e-commerce-websites/" class="redlink">' + "`n`t`t`t`t`t`t`t`t`t`t<span>Explore E-Commerce Solutions</span>"
    },
    @{
        Old = '<a href="/services/wordpress-websites/" class="redlink">' + "`n`t`t`t`t`t`t`t`t`t`t<span>Learn more</span>"
        New = '<a href="/services/wordpress-websites/" class="redlink">' + "`n`t`t`t`t`t`t`t`t`t`t<span>See Our WordPress Services</span>"
    },
    @{
        Old = '<a href="/services/app-development/" class="redlink">' + "`n`t`t`t`t`t`t`t`t`t`t<span>Learn more</span>"
        New = '<a href="/services/app-development/" class="redlink">' + "`n`t`t`t`t`t`t`t`t`t`t<span>Learn About App Development</span>"
    },
    @{
        Old = '<a href="/services/graphic-design/" class="redlink">' + "`n`t`t`t`t`t`t`t`t`t`t<span>Learn more</span>"
        New = '<a href="/services/graphic-design/" class="redlink">' + "`n`t`t`t`t`t`t`t`t`t`t<span>View Graphic Design Portfolio</span>"
    },
    @{
        Old = '<a href="/services/packaging-design/" class="redlink">' + "`n`t`t`t`t`t`t`t`t`t`t<span>Learn more</span>"
        New = '<a href="/services/packaging-design/" class="redlink">' + "`n`t`t`t`t`t`t`t`t`t`t<span>Explore Packaging Design Work</span>"
    },
    @{
        Old = '<a href="/services/custom-web-development/" class="redlink">' + "`n`t`t`t`t`t`t`t`t`t`t<span>Learn more</span>"
        New = '<a href="/services/custom-web-development/" class="redlink">' + "`n`t`t`t`t`t`t`t`t`t`t<span>View Custom Development Services</span>"
    }
)

# Get all HTML files
$htmlFiles = Get-ChildItem -Path . -Filter "*.html" -Recurse -File | Where-Object { 
    $_.FullName -notmatch '\\node_modules\\|\\\.git\\' 
}

Write-Host "Found $($htmlFiles.Count) HTML files" -ForegroundColor Yellow
Write-Host ""

$filesChanged = 0
$totalChanges = 0

foreach ($file in $htmlFiles) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    $fileChanges = 0
    
    foreach ($replacement in $replacements) {
        if ($content -match [regex]::Escape($replacement.Old)) {
            $content = $content -replace [regex]::Escape($replacement.Old), $replacement.New
            $fileChanges++
        }
    }
    
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
        $filesChanged++
        $totalChanges += $fileChanges
        
        $relativePath = $file.FullName.Replace((Get-Location).Path, '').TrimStart('\')
        Write-Host "[OK] Updated: $relativePath (${fileChanges} changes)" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Summary" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Files updated: $filesChanged" -ForegroundColor Green
Write-Host "Total link text improvements: $totalChanges" -ForegroundColor Green
Write-Host ""
Write-Host "SEO Benefit: Descriptive link text helps search engines" -ForegroundColor Yellow
Write-Host "understand your content and improves accessibility" -ForegroundColor Yellow
Write-Host ""
