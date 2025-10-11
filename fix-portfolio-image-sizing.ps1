# Portfolio Image Sizing Fix Script
# This script adds consistent image sizing CSS to all service pages with portfolio sections

# Define the CSS to add for consistent image sizing
$imageSizingCSS = @'

/* ===== PORTFOLIO IMAGE SIZING FIX ===== */
.shiftbox-image img,
.preview-media img {
	width: 100% !important;
	height: 300px !important;
	object-fit: cover !important;
	object-position: center !important;
	border-radius: 8px !important;
}

/* Responsive adjustments for smaller screens */
@media (max-width: 768px) {
	.shiftbox-image img,
	.preview-media img {
		height: 250px !important;
	}
}

@media (max-width: 480px) {
	.shiftbox-image img,
	.preview-media img {
		height: 200px !important;
	}
}
'@

# List of service pages that need the image sizing fix
$servicePages = @(
    "services\wordpress-websites\index.html",
    "services\e-commerce-websites\index.html", 
    "services\Custom-Web-Development\index.html",
    "services\software-&-platform-development\index.html",
    "services\app-development\index.html",
    "services\web-design-and-branding-for-real-estate\index.html",
    "services\ui-ux-design\index.html",
    "services\branding\index.html",
    "services\trade-show-booth-design\index.html",
    "services\conference-branding\index.html",
    "services\web-design\index.html"
)

Write-Host "Starting portfolio image sizing fix..." -ForegroundColor Green

foreach ($page in $servicePages) {
    $fullPath = Join-Path $PWD $page
    
    if (Test-Path $fullPath) {
        Write-Host "Processing: $page" -ForegroundColor Yellow
        
        # Read the file content
        $content = Get-Content $fullPath -Raw
        
        # Check if the fix is already applied
        if ($content -match "PORTFOLIO IMAGE SIZING FIX") {
            Write-Host "  - Already has image sizing fix, skipping..." -ForegroundColor Cyan
            continue
        }
        
        # Find the first closing </style> tag and add our CSS before it
        if ($content -match '(\s*)\}(\s*)</style>') {
            $replacement = "`$1}`$2$imageSizingCSS`$2</style>"
            $updatedContent = $content -replace '(\s*)\}(\s*)</style>', $replacement, 1
            
            # Write back to file
            $updatedContent | Out-File -FilePath $fullPath -Encoding UTF8
            Write-Host "  - Image sizing CSS added successfully!" -ForegroundColor Green
        } else {
            Write-Host "  - Could not find suitable </style> tag, skipping..." -ForegroundColor Red
        }
    } else {
        Write-Host "File not found: $page" -ForegroundColor Red
    }
}

Write-Host "`nImage sizing fix completed!" -ForegroundColor Green
Write-Host "All portfolio images should now have consistent dimensions:" -ForegroundColor White
Write-Host "  - Desktop: 300px height" -ForegroundColor White  
Write-Host "  - Tablet: 250px height" -ForegroundColor White
Write-Host "  - Mobile: 200px height" -ForegroundColor White
Write-Host "  - All with object-fit: cover for proper scaling" -ForegroundColor White