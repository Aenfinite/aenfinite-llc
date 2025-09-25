param(
    [string]$FilePath = "index.html"
)

Write-Host "Converting homepage to dynamic includes..." -ForegroundColor Cyan

$content = Get-Content $FilePath -Raw -Encoding UTF8

# Check if file exists
if (-not (Test-Path $FilePath)) {
    Write-Host "File not found: $FilePath" -ForegroundColor Red
    exit 1
}

Write-Host "Reading file content..."

# Remove hardcoded navbar section (from mainnav div to its closing)
$navbarPattern = '<div class="mainnav js-mainnav [^"]*">.*?</div>\s*</div>\s*</div>\s*</header>'
if ($content -match $navbarPattern) {
    Write-Host "Found navbar pattern, removing..."
    $content = $content -replace $navbarPattern, '<!-- Dynamic Header Include -->
		<div id="dynamic-header"></div>'
} else {
    Write-Host "Navbar pattern not found, checking if already converted..."
    if ($content -notmatch 'dynamic-header') {
        Write-Host "WARNING: No navbar found and not converted!" -ForegroundColor Yellow
    }
}

# Remove hardcoded footer content (everything after dynamic-footer div until mobile menu)
$footerStartPattern = '(<!-- Dynamic Footer Include -->\s*<div id="dynamic-footer"></div>)\s*</div>\s*<div>'
$footerEndPattern = '<div class="menu js-menu mobile">'

if ($content -match $footerStartPattern -and $content -match $footerEndPattern) {
    Write-Host "Found footer pattern, removing hardcoded content..."
    
    # Split content at the dynamic footer div
    $beforeFooter = ($content -split '<!-- Dynamic Footer Include -->')[0]
    $afterFooter = ($content -split '<div class="menu js-menu mobile">')[1]
    
    # Reconstruct with just the dynamic footer
    $content = $beforeFooter + '<!-- Dynamic Footer Include -->
		<div id="dynamic-footer"></div>
		</div>

		<div class="menu js-menu mobile">' + $afterFooter
    
    Write-Host "Footer content removed and replaced with dynamic include"
} else {
    Write-Host "Footer pattern not found or already converted"
}

# Add dynamic includes script if not present
if ($content -notmatch 'dynamic-includes\.js') {
    Write-Host "Adding dynamic includes script..."
    $content = $content -replace '    <script src="../includes/dynamic-includes.js"></script> 
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

			// Backup initialization
			if (document.readyState === 'loading') {
				document.addEventListener('DOMContentLoaded', initAdvancedCursor);
			} else {
				initAdvancedCursor();
			}
		</script></body>', '	<!-- Dynamic Includes Script -->
	<script src="includes/dynamic-includes.js"></script>
    <script src="../includes/dynamic-includes.js"></script> 
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

			// Backup initialization
			if (document.readyState === 'loading') {
				document.addEventListener('DOMContentLoaded', initAdvancedCursor);
			} else {
				initAdvancedCursor();
			}
		</script></body>'
} else {
    Write-Host "Dynamic includes script already present"
}

# Save the updated content
Set-Content -Path $FilePath -Value $content -Encoding UTF8
Write-Host "Homepage conversion completed!" -ForegroundColor Green

Write-Host ""
Write-Host "Verifying conversion:"
if ($content -match 'dynamic-header') {
    Write-Host "✓ Dynamic header include found" -ForegroundColor Green
} else {
    Write-Host "✗ Dynamic header include NOT found" -ForegroundColor Red
}

if ($content -match 'dynamic-footer') {
    Write-Host "✓ Dynamic footer include found" -ForegroundColor Green
} else {
    Write-Host "✗ Dynamic footer include NOT found" -ForegroundColor Red
}

if ($content -match 'dynamic-includes\.js') {
    Write-Host "✓ Dynamic includes script found" -ForegroundColor Green
} else {
    Write-Host "✗ Dynamic includes script NOT found" -ForegroundColor Red
}
