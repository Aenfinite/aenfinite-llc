$ErrorActionPreference = "Continue"

# Get all HTML files recursively
$htmlFiles = Get-ChildItem -Path . -Filter "*.html" -Recurse

foreach ($file in $htmlFiles) {
    Write-Host "Processing: $($file.FullName)"
    try {
        # Read content with current encoding
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8

        # Check if meta charset tags exist
        if ($content -notmatch '<meta\s+charset="UTF-8"') {
            # Add meta tags after <head> if they don't exist
            $content = $content -replace '(<head[^>]*>)', "`$1`n    <meta charset=`"UTF-8`">`n    <meta http-equiv=`"Content-Type`" content=`"text/html; charset=utf-8`">"
        }

        # Save with UTF-8 encoding without BOM
        $utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
        [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBomEncoding)

        Write-Host "Successfully processed: $($file.FullName)" -ForegroundColor Green
    }
    catch {
        Write-Host "Error processing $($file.FullName): $_" -ForegroundColor Red
    }
}