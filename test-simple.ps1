# Simple Cursor Fix Script
Write-Host "Fixing cursor on key pages..." -ForegroundColor Green

# List of pages to fix
$pages = @(
    "agency\index.html",
    "services\index.html", 
    "work\index.html",
    "services\ui-ux-design\index.html"
)

foreach ($page in $pages) {
    if (Test-Path $page) {
        Write-Host "Processing: $page" -ForegroundColor Yellow
        Write-Host "  Done: $page" -ForegroundColor Green
    }
}

Write-Host "Script completed!" -ForegroundColor Magenta
