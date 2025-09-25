# Simple Cursor Fix Script
# This script adds the animated cursor implementation to all pages that need it

$ErrorActionPreference = "Continue"
$rootPath = "C:\Users\Extreme DeveOps\Documents\Aenfinite\aenfinite website\dd.nyc"

# The cursor implementation to add before </head>
$cursorImplementation = @"

	<!-- Animated Cursor Implementation -->
	<style>
		* {
			cursor: none !important;
		}
		
		.cursor-container {
			position: fixed;
			top: 0;
			left: 0;
			width: 100vw;
			height: 100vh;
			pointer-events: none;
			z-index: 99999;
		}
		
		.cursor-dot {
			position: absolute;
			width: 4px;
			height: 4px;
			background: rgb(255, 255, 255);
			border-radius: 50%;
			filter: url(#goo);
			transform: translate(-50%, -50%);
		}
		
		@media (max-width: 768px) {
			.cursor-container {
				display: none;
			}
			* {
				cursor: auto !important;
			}
		}
		
		@media (pointer: coarse) {
			.cursor-container {
				display: none;
			}
			* {
				cursor: auto !important;
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
			// Check if it's a mobile device
			const isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
			const hasTouch = 'ontouchstart' in window || navigator.maxTouchPoints > 0;
			
			if (isMobile || hasTouch) {
				return; // Exit early on mobile devices
			}
			
			const cursorContainer = document.createElement('div');
			cursorContainer.className = 'cursor-container';
			document.body.appendChild(cursorContainer);
			
			const numDots = 20;
			const dots = [];
			const mousePosition = { x: 0, y: 0 };
			
			// Create dots
			for (let i = 0; i < numDots; i++) {
				const dot = document.createElement('div');
				dot.className = 'cursor-dot';
				cursorContainer.appendChild(dot);
				dots.push({
					element: dot,
					x: 0,
					y: 0,
					targetX: 0,
					targetY: 0,
					delay: i * 0.02
				});
			}
			
			// Mouse move handler
			function handleMouseMove(e) {
				mousePosition.x = e.clientX;
				mousePosition.y = e.clientY;
			}
			
			document.addEventListener('mousemove', handleMouseMove);
			
			// Animation loop
			function animate() {
				dots.forEach((dot, index) => {
					const delay = index * 0.1;
					const ease = 0.15 - (index * 0.005);
					
					dot.targetX = mousePosition.x;
					dot.targetY = mousePosition.y;
					
					dot.x += (dot.targetX - dot.x) * ease;
					dot.y += (dot.targetY - dot.y) * ease;
					
					dot.element.style.left = dot.x + 'px';
					dot.element.style.top = dot.y + 'px';
					dot.element.style.opacity = Math.max(0, 1 - index * 0.05);
					dot.element.style.transform = "translate(-50%, -50%) scale(" + Math.max(0.1, 1 - index * 0.05) + ")";
				});
				
				requestAnimationFrame(animate);
			}
			
			// Start animation
			animate();
			
			// Hide cursor when leaving window
			document.addEventListener('mouseleave', function() {
				cursorContainer.style.opacity = '0';
			});
			
			document.addEventListener('mouseenter', function() {
				cursorContainer.style.opacity = '1';
			});
			
			// Handle hover effects
			const interactiveElements = document.querySelectorAll('a, button, [role="button"], input, textarea, select, .clickable');
			
			interactiveElements.forEach(element => {
				element.addEventListener('mouseenter', function() {
					dots.forEach(dot => {
						dot.element.style.backgroundColor = 'rgb(200, 200, 200)';
						dot.element.style.transform += ' scale(1.5)';
					});
				});
				
				element.addEventListener('mouseleave', function() {
					dots.forEach(dot => {
						dot.element.style.backgroundColor = 'rgb(255, 255, 255)';
					});
				});
			});
			
			// Initialize cursor position
			const rect = document.body.getBoundingClientRect();
			mousePosition.x = rect.width / 2;
			mousePosition.y = rect.height / 2;
		});
	</script>
		
"@

# Find all index.html files and process them
Write-Host "Finding all index.html files..." -ForegroundColor Green
$allIndexFiles = Get-ChildItem -Path $rootPath -Name "index.html" -Recurse

$processedCount = 0

foreach ($file in $allIndexFiles) {
    $fullPath = Join-Path $rootPath $file
    
    # Skip certain files that are already working
    if ($file -eq "index.html" -or $file -eq "Cities\index.html" -or $file -eq "services\web-design\index.html") {
        Write-Host "Skipping: $file (already working)" -ForegroundColor Yellow
        continue
    }
    
    Write-Host "Processing: $file" -ForegroundColor Cyan
    
    try {
        # Read the file content
        $content = Get-Content -Path $fullPath -Raw -Encoding UTF8
        
        # Check if cursor implementation already exists
        if ($content -match "Animated Cursor Implementation") {
            Write-Host "  - Already has cursor implementation" -ForegroundColor Yellow
            continue
        }
        
        # Find the </head> tag and add cursor implementation before it
        if ($content -match "</head>") {
            $newContent = $content -replace "</head>", "$cursorImplementation</head>"
            Set-Content -Path $fullPath -Value $newContent -Encoding UTF8
            Write-Host "  - Cursor added successfully" -ForegroundColor Green
            $processedCount++
        } else {
            Write-Host "  - No </head> tag found" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "  - Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`nCompleted! Fixed cursor on $processedCount pages." -ForegroundColor Green
