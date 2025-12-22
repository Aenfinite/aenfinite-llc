# Website Asset Optimization Script
# This script minifies JavaScript and CSS files using npm packages

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "  Aenfinite Asset Optimization" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Check if Node.js is installed
try {
    $nodeVersion = node --version
    Write-Host "✓ Node.js found: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Node.js not found. Please install Node.js from https://nodejs.org/" -ForegroundColor Red
    exit 1
}

# Check if npm is installed
try {
    $npmVersion = npm --version
    Write-Host "✓ npm found: v$npmVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ npm not found. Please install npm." -ForegroundColor Red
    exit 1
}

Write-Host ""

# Install required npm packages if not already installed
Write-Host "Checking required packages..." -ForegroundColor Yellow
$packages = @("terser", "clean-css-cli")

foreach ($package in $packages) {
    try {
        npm list -g $package 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ $package is already installed" -ForegroundColor Green
        } else {
            Write-Host "Installing $package..." -ForegroundColor Yellow
            npm install -g $package
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✓ $package installed successfully" -ForegroundColor Green
            } else {
                Write-Host "✗ Failed to install $package" -ForegroundColor Red
            }
        }
    } catch {
        Write-Host "Installing $package..." -ForegroundColor Yellow
        npm install -g $package
    }
}

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "  Starting Minification Process" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Define paths
$themePath = "wp-content/themes/aenfinite.com"
$jsPath = "$themePath/static/js"
$cssPath = "$themePath/static/css"
$rootJsPath = "js"

# JavaScript files to minify
$jsFiles = @(
    "$jsPath/ScrollMagic.js",
    "$jsPath/animation.gsap.js",
    "$jsPath/demo5163.js",
    "$rootJsPath/custom-form-handler.js"
)

# CSS files to minify
$cssFiles = @(
    "$cssPath/mainf1a7.css",
    "$themePath/stylef1a7.css"
)

# Create backup directory
$backupDir = "asset-backups-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
Write-Host "✓ Created backup directory: $backupDir" -ForegroundColor Green
Write-Host ""

# Minify JavaScript files
Write-Host "Minifying JavaScript files..." -ForegroundColor Yellow
Write-Host ""

$totalJsSaved = 0

foreach ($file in $jsFiles) {
    if (Test-Path $file) {
        $originalSize = (Get-Item $file).Length
        $fileName = Split-Path $file -Leaf
        $fileDir = Split-Path $file -Parent
        $fileBaseName = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
        $minFileName = "$fileBaseName.min.js"
        $minFilePath = Join-Path $fileDir $minFileName
        
        # Backup original
        Copy-Item $file -Destination "$backupDir/$fileName.bak" -Force
        
        Write-Host "  Processing: $file" -ForegroundColor Cyan
        
        # Minify with terser
        npx terser $file -c -m --module -o $minFilePath
        
        if (Test-Path $minFilePath) {
            $minifiedSize = (Get-Item $minFilePath).Length
            $saved = $originalSize - $minifiedSize
            $totalJsSaved += $saved
            $percentSaved = [math]::Round(($saved / $originalSize) * 100, 1)
            
            Write-Host "    Original: $([math]::Round($originalSize/1KB, 1)) KB" -ForegroundColor White
            Write-Host "    Minified: $([math]::Round($minifiedSize/1KB, 1)) KB" -ForegroundColor White
            Write-Host "    Saved: $([math]::Round($saved/1KB, 1)) KB ($percentSaved%)" -ForegroundColor Green
            Write-Host ""
        } else {
            Write-Host "    ✗ Failed to minify" -ForegroundColor Red
            Write-Host ""
        }
    } else {
        Write-Host "  ✗ File not found: $file" -ForegroundColor Red
        Write-Host ""
    }
}

# Minify CSS files
Write-Host "Minifying CSS files..." -ForegroundColor Yellow
Write-Host ""

$totalCssSaved = 0

foreach ($file in $cssFiles) {
    if (Test-Path $file) {
        $originalSize = (Get-Item $file).Length
        $fileName = Split-Path $file -Leaf
        $fileDir = Split-Path $file -Parent
        $fileBaseName = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
        $minFileName = "$fileBaseName.min.css"
        $minFilePath = Join-Path $fileDir $minFileName
        
        # Backup original
        Copy-Item $file -Destination "$backupDir/$fileName.bak" -Force
        
        Write-Host "  Processing: $file" -ForegroundColor Cyan
        
        # Minify with clean-css
        npx cleancss -o $minFilePath $file
        
        if (Test-Path $minFilePath) {
            $minifiedSize = (Get-Item $minFilePath).Length
            $saved = $originalSize - $minifiedSize
            $totalCssSaved += $saved
            $percentSaved = [math]::Round(($saved / $originalSize) * 100, 1)
            
            Write-Host "    Original: $([math]::Round($originalSize/1KB, 1)) KB" -ForegroundColor White
            Write-Host "    Minified: $([math]::Round($minifiedSize/1KB, 1)) KB" -ForegroundColor White
            Write-Host "    Saved: $([math]::Round($saved/1KB, 1)) KB ($percentSaved%)" -ForegroundColor Green
            Write-Host ""
        } else {
            Write-Host "    ✗ Failed to minify" -ForegroundColor Red
            Write-Host ""
        }
    } else {
        Write-Host "  ✗ File not found: $file" -ForegroundColor Red
        Write-Host ""
    }
}

# Summary
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "  Optimization Summary" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total JavaScript saved: $([math]::Round($totalJsSaved/1KB, 1)) KB" -ForegroundColor Green
Write-Host "Total CSS saved: $([math]::Round($totalCssSaved/1KB, 1)) KB" -ForegroundColor Green
Write-Host "Total space saved: $([math]::Round(($totalJsSaved + $totalCssSaved)/1KB, 1)) KB" -ForegroundColor Green
Write-Host ""
Write-Host "✓ Backups saved in: $backupDir" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Update HTML files to use .min.js and .min.css versions" -ForegroundColor White
Write-Host "2. Test the website thoroughly" -ForegroundColor White
Write-Host "3. Deploy to production" -ForegroundColor White
Write-Host ""
