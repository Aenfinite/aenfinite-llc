# Ultimate Cursor Fix Script - Replace ALL cursor implementations with working system
# This script will systematically update every page to use the working aenfinite-cursor system

Write-Host "🎯 Starting Ultimate Cursor Fix for ALL pages..." -ForegroundColor Green

# Define the complete working cursor implementation (CSS + Script)
$workingCursorImplementation = @'
	<style>
		.aenfinite-cursor {
			position: fixed;
			top: 0;
			left: 0;
			width: 100%;
			height: 100%;
			pointer-events: none;
			z-index: 99999;
			filter: url("#goo");
		}
		
		.aenfinite-cursor span {
			position: absolute;
			width: 26px;
			height: 26px;
			border-radius: 50%;
			background-color: #227bf3;
			transform: translate(-50%, -50%);
			pointer-events: none;
		}
		
		@media (max-width: 768px) {
			.aenfinite-cursor {
				display: none;
			}
		}
	</style>

	<svg style="position: fixed; top: -1000px; left: -1000px; width: 0; height: 0;">
		<defs>
			<filter id="goo">
				<feGaussianBlur in="SourceGraphic" stdDeviation="6" result="blur" />
				<feColorMatrix in="blur" mode="matrix" values="1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  0 0 0 19 -9" result="goo" />
				<feComposite in="SourceGraphic" in2="goo" operator="atop"/>
			</filter>
		</defs>
	</svg>

	<script>
		document.addEventListener('DOMContentLoaded', function() {
			function initAdvancedCursor() {
				if (window.innerWidth <= 768) return;
				
				// Remove any existing cursors
				const existingCursors = document.querySelectorAll('.aenfinite-cursor');
				existingCursors.forEach(cursor => cursor.remove());
				
				const cursor = document.createElement('div');
				cursor.className = 'aenfinite-cursor';
				cursor.id = 'aenfinite-cursor';
				
				for (let i = 0; i < 12; i++) {
					const span = document.createElement('span');
					cursor.appendChild(span);
				}
				
				document.body.appendChild(cursor);
				
				class Dot {
					constructor(element, delay) {
						this.element = element;
						this.delay = delay;
						this.x = window.innerWidth / 2;
						this.y = window.innerHeight / 2;
						this.targetX = this.x;
						this.targetY = this.y;
						this.scale = Math.random() * 0.5 + 0.5;
						this.element.style.transform = `translate(-50%, -50%) scale(${this.scale})`;
						
						if (window.gsap && window.gsap.set) {
							gsap.set(this.element, {scale: this.scale});
						}
					}
					
					update(mouseX, mouseY) {
						this.targetX = mouseX;
						this.targetY = mouseY;
						
						const dx = this.targetX - this.x;
						const dy = this.targetY - this.y;
						
						this.x += dx * 0.1;
						this.y += dy * 0.1;
						
						if (window.gsap && window.gsap.set) {
							gsap.set(this.element, {x: this.x, y: this.y});
						}
					}
					
					updateIdle(mouseX, mouseY) {
						this.targetX = mouseX + (Math.sin(Date.now() * 0.001 + this.delay) * 20);
						this.targetY = mouseY + (Math.cos(Date.now() * 0.001 + this.delay) * 20);
						
						const dx = this.targetX - this.x;
						const dy = this.targetY - this.y;
						
						this.x += dx * 0.05;
						this.y += dy * 0.05;
						
						if (window.gsap && window.gsap.set) {
							gsap.set(this.element, {x: this.x, y: this.y});
						}
					}
				}
				
				const spans = cursor.querySelectorAll('span');
				const dots = [];
				
				spans.forEach((span, i) => {
					dots.push(new Dot(span, i * 0.1));
				});
				
				let mouseX = window.innerWidth / 2;
				let mouseY = window.innerHeight / 2;
				let lastMoveTime = Date.now();
				let isIdle = false;
				
				document.addEventListener('mousemove', (e) => {
					mouseX = e.clientX;
					mouseY = e.clientY;
					lastMoveTime = Date.now();
					isIdle = false;
				});
				
				function animate() {
					const now = Date.now();
					if (now - lastMoveTime > 1000) {
						isIdle = true;
					}
					
					dots.forEach(dot => {
						if (isIdle) {
							dot.updateIdle(mouseX, mouseY);
						} else {
							dot.update(mouseX, mouseY);
						}
					});
					
					requestAnimationFrame(animate);
				}
				
				animate();
			}
			
			// Initialize cursor
			initAdvancedCursor();
		});
	</script>
'@

# Get all HTML files
$rootPath = "c:\Users\Extreme DeveOps\Documents\Aenfinite\aenfinite website\dd.nyc"
$htmlFiles = Get-ChildItem -Path $rootPath -Filter "index.html" -Recurse

$totalFiles = $htmlFiles.Count
$processedCount = 0
$skippedCount = 0
$errorCount = 0

Write-Host "📁 Found $totalFiles HTML files to process" -ForegroundColor Cyan

foreach ($file in $htmlFiles) {
    $relativePath = $file.FullName.Replace($rootPath, "").TrimStart('\')
    
    try {
        Write-Host "🔧 Processing: $relativePath" -ForegroundColor Yellow
        
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        
        # Skip if file already has recent working implementation
        if ($content -match "initAdvancedCursor\(\)" -and $content -match "aenfinite-cursor" -and $content -match "class Dot") {
            Write-Host "  ✅ Already has complete working cursor, skipping" -ForegroundColor Green
            $skippedCount++
            continue
        }
        
        # Backup original content
        $originalContent = $content
        
        # Remove ANY existing cursor implementations
        # Remove old cursor-container CSS blocks
        $content = $content -replace '(?s)<style[^>]*>.*?\.cursor-container.*?</style>', ''
        
        # Remove old aenfinite-cursor blocks (partial implementations)
        $content = $content -replace '(?s)<style[^>]*>.*?\.aenfinite-cursor.*?</style>', ''
        
        # Remove SVG goo filters
        $content = $content -replace '(?s)<svg[^>]*>.*?<filter id="goo">.*?</svg>', ''
        
        # Remove old cursor scripts
        $content = $content -replace '(?s)<script[^>]*>.*?cursor-container.*?</script>', ''
        $content = $content -replace '(?s)<script[^>]*>.*?initAdvancedCursor.*?</script>', ''
        
        # Remove duplicate/conflicting implementations
        $content = $content -replace '(?s)<!-- Advanced Cursor System -->.*?</script>', ''
        $content = $content -replace '(?s)<!-- Custom cursor implementation -->.*?</script>', ''
        
        # Clean up extra whitespace
        $content = $content -replace '\n\s*\n\s*\n', "`n`n"
        
        # Find insertion point before </head>
        if ($content -match '(?s)(.*?)</head>') {
            $beforeHead = $matches[1].TrimEnd()
            $afterHead = $content.Substring($matches[0].Length - 7) # Keep </head> and everything after
            
            # Insert new working implementation
            $newContent = $beforeHead + "`n`n" + $workingCursorImplementation + "`n`n</head>" + $afterHead.Substring(7)
            
            # Write back to file
            Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8
            
            Write-Host "  ✅ Successfully updated with working cursor system" -ForegroundColor Green
            $processedCount++
        } else {
            Write-Host "  ⚠️ Could not find </head> tag, skipping" -ForegroundColor Yellow
            $skippedCount++
        }
        
    } catch {
        Write-Host "  ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
        $errorCount++
    }
}

# Final summary
Write-Host "`n🎉 Cursor Fix Operation Complete!" -ForegroundColor Green
Write-Host "📊 Summary:" -ForegroundColor Cyan
Write-Host "   Total files found: $totalFiles" -ForegroundColor White
Write-Host "   Files updated: $processedCount" -ForegroundColor Green
Write-Host "   Files skipped: $skippedCount" -ForegroundColor Yellow
Write-Host "   Errors encountered: $errorCount" -ForegroundColor $(if ($errorCount -eq 0) { "Green" } else { "Red" })

if ($processedCount -gt 0) {
    Write-Host "`n✨ All updated pages now have the working aenfinite-cursor system!" -ForegroundColor Green
    Write-Host "🎯 Features: GSAP animations, idle states, mobile responsive, blue dots" -ForegroundColor Cyan
}
