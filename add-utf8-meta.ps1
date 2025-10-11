$files = Get-ChildItem -Path . -Filter "*.html" -Recurse

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    
    # Check if meta tags already exist
    if (-not ($content -match '<meta charset="UTF-8">') -and -not ($content -match '<meta http-equiv="Content-Type"')) {
        # Replace the opening head tag with head tag plus meta tags
        $newContent = $content -replace '(<head>|<head\s[^>]*>)', '$1
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">'
        
        # Save the file with UTF-8 encoding without BOM
        $utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($file.FullName, $newContent, $utf8NoBomEncoding)
        
        Write-Host "Updated $($file.FullName)"
    } else {
        Write-Host "Skipping $($file.FullName) - meta tags already present"
    }
}