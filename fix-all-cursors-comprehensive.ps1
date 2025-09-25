# Comprehensive Cursor Fix Script for All Pages
# This script fixes animated cursor issues on all pages except home, Cities, and web-design which are already working

Write-Host "Starting comprehensive cursor fix for all pages..." -ForegroundColor Green

# Define the working cursor CSS styles
$cursorCSS = @'
		<!-- Advanced Cursor System -->
		<style>
			/* Advanced Cursor Styles */
			* {
				-webkit-font-smoothing: antialiased;
				-moz-osx-font-smoothing: grayscale;
			}

			body, html {
				cursor: none !important;
			}

			svg {
				display: none;
			}

			.aenfinite-cursor {
				pointer-events: none;
				position: fixed;
				display: block;
				border-radius: 0;
				transform-origin: center center;
				top: 0;
				left: 0;
				z-index: 99999;
				filter: url("#goo");
				width: 26px;
				height: 26px;
			}

			.aenfinite-cursor span {
				position: absolute;
				display: block;
				width: 26px;
				height: 26px;
				border-radius: 50%;
				background-color: #227bf3;
				transform-origin: center center;
				transform: translate(-50%, -50%);
			}

			/* On mobile devices, hide the cursor and restore default behavior */
			@media (max-width: 768px) {
				.aenfinite-cursor {
					display: none !important;
				}
				
				body, html {
					cursor: auto !important;
				}
			}
		</style>

		<!-- SVG Filter for Goo Effect -->
		<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="800">
			<defs>
			  <filter id="goo">
				<feGaussianBlur in="SourceGraphic" stdDeviation="6" result="blur" />
				<feColorMatrix in="blur" mode="matrix" values="1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  0 0 0 35 -15" result="goo" />
				<feComposite in="SourceGraphic" in2="goo" operator="atop"/>
			  </filter>
			</defs>
		</svg>

		<script>
			// Advanced Cursor Implementation
			function initAdvancedCursor() {
				// Check if mobile device
				if (window.innerWidth <= 768) {
					return; // Don't initialize cursor on mobile
				}

				// Remove any existing cursor elements
				const existingCursors = document.querySelectorAll('.aenfinite-cursor');
				existingCursors.forEach(cursor => cursor.remove());

				const cursor = document.createElement('div');
				cursor.className = 'aenfinite-cursor';
				cursor.id = 'aenfinite-cursor';
				document.body.appendChild(cursor);

				const amount = 20;
				const sineDots = Math.floor(amount * 0.3);
				const width = 26;
				const idleTimeout = 150;
				let lastFrame = 0;
				let mousePosition = {x: 0, y: 0};
				let dots = [];
				let timeoutID;
				let idle = false;

				class Dot {
					constructor(index = 0) {
						this.index = index;
						this.anglespeed = 0.05;
						this.x = 0;
						this.y = 0;
						this.scale = 1 - 0.05 * index;
						this.range = width / 2 - width / 2 * this.scale + 2;
						this.limit = width * 0.75 * this.scale;
						this.element = document.createElement("span");
						if (window.gsap && window.gsap.set) {
							gsap.set(this.element, {scale: this.scale});
						} else {
							this.element.style.transform = `scale(${this.scale})`;
						}
						cursor.appendChild(this.element);
					}

					lock() {
						this.lockX = this.x;
						this.lockY = this.y;
						this.angleX = Math.PI * 2 * Math.random();
						this.angleY = Math.PI * 2 * Math.random();
					}

					draw(delta) {
						if (!idle || this.index <= sineDots) {
							if (window.gsap && window.gsap.set) {
								gsap.set(this.element, {x: this.x, y: this.y});
							} else {
								this.element.style.transform = `translate(${this.x}px, ${this.y}px) scale(${this.scale})`;
							}
						} else {
							this.angleX += this.anglespeed;
							this.angleY += this.anglespeed;
							this.y = this.lockY + Math.sin(this.angleY) * this.range;
							this.x = this.lockX + Math.sin(this.angleX) * this.range;
							if (window.gsap && window.gsap.set) {
								gsap.set(this.element, {x: this.x, y: this.y});
							} else {
								this.element.style.transform = `translate(${this.x}px, ${this.y}px) scale(${this.scale})`;
							}
						}
					}
				}

				function startIdleTimer() {
					timeoutID = setTimeout(goInactive, idleTimeout);
					idle = false;
				}

				function resetIdleTimer() {
					clearTimeout(timeoutID);
					startIdleTimer();
				}

				function goInactive() {
					idle = true;
					for (let dot of dots) {
						dot.lock();
					}
				}

				function buildDots() {
					for (let i = 0; i < amount; i++) {
						let dot = new Dot(i);
						dots.push(dot);
					}
				}

				const onMouseMove = event => {
					mousePosition.x = event.clientX - width / 2;
					mousePosition.y = event.clientY - width / 2;
					resetIdleTimer();
				};

				const onTouchMove = (event) => {
					if (event.touches && event.touches.length > 0) {
						mousePosition.x = event.touches[0].clientX - width / 2;
						mousePosition.y = event.touches[0].clientY - width / 2;
						resetIdleTimer();
					}
				};

				const render = timestamp => {
					const delta = timestamp - lastFrame;
					positionCursor(delta);
					lastFrame = timestamp;
					requestAnimationFrame(render);
				};

				const positionCursor = delta => {
					let x = mousePosition.x;
					let y = mousePosition.y;
					dots.forEach((dot, index, dots) => {
						let nextDot = dots[index + 1] || dots[0];
						dot.x = x;
						dot.y = y;
						dot.draw(delta);
						if (!idle || index <= sineDots) {
							const dx = (nextDot.x - dot.x) * 0.35;
							const dy = (nextDot.y - dot.y) * 0.35;
							x += dx;
							y += dy;
						}
					});
				};

				// Initialize cursor system
				window.addEventListener("mousemove", onMouseMove);
				window.addEventListener("touchmove", onTouchMove);
				lastFrame = performance.now();
				buildDots();
				render();
				startIdleTimer();

				// Handle window resize
				window.addEventListener('resize', function() {
					if (window.innerWidth <= 768) {
						// Remove cursor on mobile
						const cursorEl = document.getElementById('aenfinite-cursor');
						if (cursorEl) {
							cursorEl.remove();
						}
					} else if (!document.getElementById('aenfinite-cursor')) {
						// Reinitialize cursor on desktop
						initAdvancedCursor();
					}
				});
			}

			// Initialize cursor when DOM is ready
			document.addEventListener('DOMContentLoaded', function() {
				initAdvancedCursor();
			});
		</script>

'@

# Function to fix cursor on a specific page
function Fix-CursorOnPage {
    param(
        [string]$FilePath
    )
    
    try {
        Write-Host "Processing: $FilePath" -ForegroundColor Yellow
        
        # Read the file content
        $content = Get-Content -Path $FilePath -Raw -Encoding UTF8
        
        if (-not $content) {
            Write-Host "  - Skipping: Empty or unreadable file" -ForegroundColor Red
            return
        }
        
        # Check if file has </head> tag
        if ($content -notmatch '</head>') {
            Write-Host "  - Skipping: No </head> tag found" -ForegroundColor Red
            return
        }
        
        # Remove any existing cursor implementations
        # Remove duplicate cursor CSS and JS that might be at the bottom
        $content = $content -replace '<!-- Universal Button and Checkbox Highlighting Script -->.*?</script></body>', '</body>'
        $content = $content -replace '<!-- Advanced Cursor System -->.*?</script></body>', '</body>'
        
        # Remove any existing cursor CSS in head section
        $content = $content -replace '<!-- Advanced Cursor System -->.*?</style>', ''
        $content = $content -replace '<!-- SVG Filter for.*?</svg>', ''
        
        # Remove any existing cursor JavaScript
        $content = $content -replace 'function initAdvancedCursor\(\).*?}\);', ''
        
        # Add the working cursor implementation right before </head>
        $content = $content -replace '</head>', "$cursorCSS`r`n</head>"
        
        # Write the fixed content back to file
        Set-Content -Path $FilePath -Value $content -Encoding UTF8 -NoNewline
        Write-Host "  ✓ Fixed cursor implementation" -ForegroundColor Green
        
    } catch {
        Write-Host "  - Error processing file: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Get all HTML files but exclude the working ones
$workingPages = @(
    "index.html",
    "Cities\index.html", 
    "services\web-design\index.html"
)

Write-Host "Finding all HTML files..." -ForegroundColor Cyan

# Find all index.html files recursively
$allHtmlFiles = Get-ChildItem -Path "." -Name "index.html" -Recurse | Where-Object {
    $relativePath = $_
    $isWorking = $false
    foreach ($workingPage in $workingPages) {
        if ($relativePath -like "*$workingPage" -or $relativePath -eq $workingPage) {
            $isWorking = $true
            break
        }
    }
    -not $isWorking
}

Write-Host "Found $($allHtmlFiles.Count) pages to fix" -ForegroundColor Cyan

# Process each file
$fixedCount = 0
foreach ($htmlFile in $allHtmlFiles) {
    $fullPath = Resolve-Path $htmlFile -ErrorAction SilentlyContinue
    if ($fullPath) {
        Fix-CursorOnPage -FilePath $fullPath
        $fixedCount++
    }
}

Write-Host "`nCompleted! Fixed cursor on $fixedCount pages." -ForegroundColor Green
Write-Host "Pages that were already working (skipped): home page, Cities page, services/web-design page" -ForegroundColor Cyan
Write-Host "`nAll pages should now have working animated cursors! 🎯" -ForegroundColor Magenta
