# PowerShell script to fix work/index.html portfolio image paths and numbering

$filePath = "c:\Users\Extreme DeveOps\Documents\Aenfinite\aenfinite\aenfinite.com\work\index.html"
$content = Get-Content $filePath -Raw

# Fix remaining image paths that are missing folder structure
$imageReplacements = @{
    # Projects that need specific folder paths
    'src="mockup-link.jpg"' = 'src="web-design-&-development/mockup-link.jpg"'
    'src="mockup-3-cover.png"' = 'src="web-design-&-development/mockup-3-cover.png"'
}

# Apply image path fixes
foreach ($oldPath in $imageReplacements.Keys) {
    $newPath = $imageReplacements[$oldPath]
    $content = $content -replace [regex]::Escape($oldPath), $newPath
    Write-Host "Fixed: $oldPath -> $newPath"
}

# Fix duplicate and incorrect data-index numbering
$indexReplacements = @{
    'data-index="07">' = 'data-index="08">'  # AlgoPros project
    'data-index="01">' = 'data-index="09">'  # Blue Vine Marketing (first occurrence after AlgoPros)
    'data-index="02">' = 'data-index="10">'  # RoboPhil (after Blue Vine)
    'data-index="03">' = 'data-index="11">'  # Next project
    'data-index="04">' = 'data-index="12">'  # Next project
    'data-index="05">' = 'data-index="13">'  # Next project
    'data-index="06">' = 'data-index="14">'  # Next project
    'data-index="07">' = 'data-index="15">'  # Next project
    'data-index="08">' = 'data-index="16">'  # Next project
    'data-index="09">' = 'data-index="17">'  # Luna Wick
    'data-index="10">' = 'data-index="18">'  # Next project
    'data-index="11">' = 'data-index="19">'  # Next project
    'data-index="12">' = 'data-index="20">'  # Next project
    'data-index="1">' = 'data-index="21">'   # Last project (fix format)
}

# Note: This approach is complex due to duplicate numbers. 
# Let me manually check and fix the specific projects instead.

Write-Host "Image path fixes completed. Manual numbering fix needed for sequential 1-21 numbering."
Write-Host "Please manually verify the data-index numbers are sequential from 01 to 21."

# Save the updated content
Set-Content -Path $filePath -Value $content -Encoding UTF8
Write-Host "File updated: $filePath"