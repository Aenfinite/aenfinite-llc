# Performance Optimization Guide for Aenfinite.com

This guide provides step-by-step instructions to optimize your website performance based on PageSpeed Insights diagnostics.

## Current Issues
- **Minify JavaScript**: Est. savings of 184 KiB
- **Reduce unused JavaScript**: Est. savings of 586 KiB  
- **Reduce unused CSS**: Est. savings of 93 KiB
- **Minify CSS**: Est. savings of 17 KiB
- **Minimize main-thread work**: 3.9s

## Total Potential Savings: ~880 KiB + Improved Load Time

---

## Step 1: Install Required Tools

### On Windows (Local Development)
```powershell
# Install Node.js (if not already installed)
# Download from: https://nodejs.org/

# Verify installation
node --version
npm --version
```

### On Linux Server (Production)
```bash
# Install Node.js and npm
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node --version
npm --version
```

---

## Step 2: Minify Assets

### Local Development (Windows)
```powershell
# Run the optimization script
.\optimize-assets.ps1

# This will:
# - Install terser and clean-css-cli if needed
# - Minify all JavaScript files
# - Minify all CSS files
# - Create backups in asset-backups-YYYYMMDD-HHMMSS/
# - Generate .min.js and .min.css versions
```

### Production Server (Linux)
```bash
# Install minification tools globally
sudo npm install -g terser clean-css-cli

# Minify JavaScript files
cd /var/www/aenfinite-llc

# ScrollMagic
terser wp-content/themes/aenfinite.com/static/js/ScrollMagic.js \
  -c -m --module \
  -o wp-content/themes/aenfinite.com/static/js/ScrollMagic.min.js

# animation.gsap
terser wp-content/themes/aenfinite.com/static/js/animation.gsap.js \
  -c -m --module \
  -o wp-content/themes/aenfinite.com/static/js/animation.gsap.min.js

# demo5163
terser wp-content/themes/aenfinite.com/static/js/demo5163.js \
  -c -m --module \
  -o wp-content/themes/aenfinite.com/static/js/demo5163.min.js

# custom-form-handler
terser js/custom-form-handler.js \
  -c -m --module \
  -o js/custom-form-handler.min.js

# Minify CSS files
cleancss -o wp-content/themes/aenfinite.com/static/css/mainf1a7.min.css \
  wp-content/themes/aenfinite.com/static/css/mainf1a7.css

cleancss -o wp-content/themes/aenfinite.com/stylef1a7.min.css \
  wp-content/themes/aenfinite.com/stylef1a7.css
```

---

## Step 3: Update HTML Files

### Automated Update (Windows)
```powershell
# Update all HTML files to reference minified versions
.\update-html-to-minified.ps1

# This will:
# - Find all HTML files
# - Replace .js with .min.js references
# - Replace .css with .min.css references
# - Add lazy loading script
```

### Manual Update (if needed)
Replace these patterns in all HTML files:
- `ScrollMagic.js` → `ScrollMagic.min.js`
- `animation.gsap.js` → `animation.gsap.min.js`
- `demo5163.js` → `demo5163.min.js`
- `custom-form-handler.js` → `custom-form-handler.min.js`
- `mainf1a7.css` → `mainf1a7.min.css`
- `stylef1a7.css` → `stylef1a7.min.css`

Add before `</body>` tag:
```html
<!-- Performance Optimization Script -->
<script src="/lazy-load-optimization.js" defer></script>
```

---

## Step 4: Configure Nginx for Optimal Performance

### Update Nginx Configuration
```bash
# Edit your site configuration
sudo nano /etc/nginx/sites-available/aenfinite.com

# Add the performance optimizations from nginx-performance-config.conf
# Key optimizations:
# - Gzip compression (6 level)
# - Browser caching (1 year for static assets)
# - FastCGI cache for dynamic content
# - Preload critical resources
```

### Test and Reload Nginx
```bash
# Test configuration
sudo nginx -t

# If successful, reload
sudo systemctl reload nginx
```

---

## Step 5: Implement Lazy Loading

The `lazy-load-optimization.js` script automatically:
- Lazy loads images with native browser support
- Conditionally loads ScrollMagic only when needed
- Conditionally loads Slick carousel only when needed
- Conditionally loads form handler only when needed
- Adds preconnect hints for external domains
- Defers non-critical CSS

### Mark Images for Lazy Loading
Update image tags:
```html
<!-- Before -->
<img src="image.jpg" alt="Description">

<!-- After -->
<img data-src="image.jpg" alt="Description" loading="lazy">
```

### Mark Background Images for Lazy Loading
```html
<!-- Before -->
<div style="background-image: url('bg.jpg')"></div>

<!-- After -->
<div data-bg-image="bg.jpg"></div>
```

---

## Step 6: Optimize Third-Party Scripts

### Google Tag Manager
Add to `<head>`:
```html
<!-- Preconnect to Google Tag Manager -->
<link rel="preconnect" href="https://www.googletagmanager.com">
<link rel="dns-prefetch" href="https://www.googletagmanager.com">

<!-- Load GTM asynchronously -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-K9VRBCFE61"></script>
```

---

## Step 7: Deploy to Production

### From Local to Server
```powershell
# Commit changes
git add .
git commit -m "Performance optimization: minified assets, lazy loading, nginx config"

# Push to repository
git push origin main
```

### On Production Server
```bash
cd /var/www/aenfinite-llc

# If you encounter ownership issues, run:
git config --global --add safe.directory /var/www/aenfinite-llc

# Pull latest changes
git pull origin main

# Ensure file permissions
sudo chown -R www-data:www-data /var/www/aenfinite-llc
sudo chmod -R 755 /var/www/aenfinite-llc

# Clear any existing cache
sudo rm -rf /var/cache/nginx/*

# Reload nginx
sudo systemctl reload nginx
```

---

## Step 8: Testing & Verification

### Test Locally First
1. Open website in browser
2. Check browser console for errors
3. Verify all images load correctly
4. Test all forms and interactive elements
5. Check sliders/carousels functionality

### Test on Production
1. Visit https://aenfinite.com
2. Open Chrome DevTools → Network tab
3. Verify `.min.js` and `.min.css` files are loading
4. Check that file sizes are reduced
5. Verify gzip compression is active (look for `Content-Encoding: gzip`)

### Run PageSpeed Insights Again
```
https://pagespeed.web.dev/
```
Test your site and verify improvements:
- JavaScript minification: ✅
- CSS minification: ✅
- Reduced unused JavaScript: ✅
- Better load times: ✅

---

## Expected Results

### Before Optimization
- Minify JavaScript: 184 KiB savings needed
- Reduce unused JS: 586 KiB savings needed
- Minify CSS: 17 KiB savings needed
- Main-thread work: 3.9s

### After Optimization
- JavaScript minified: ~184 KiB saved ✅
- Unused scripts lazy loaded: ~586 KiB reduced ✅
- CSS minified: ~17 KiB saved ✅
- Main-thread work: Reduced by 40-60% ✅
- **Total savings: ~787 KiB + improved rendering**

---

## Troubleshooting

### Issue: Scripts not loading
**Solution**: Check browser console for 404 errors. Ensure `.min.js` files exist.

### Issue: Broken functionality
**Solution**: Some scripts may have dependencies. Load jQuery before other scripts:
```html
<script src="/wp-content/themes/aenfinite.com/static/js/jquery.min.js"></script>
<script src="/wp-content/themes/aenfinite.com/static/js/gsap.min.js"></script>
<script src="/wp-content/themes/aenfinite.com/static/js/ScrollMagic.min.js"></script>
```

### Issue: Images not lazy loading
**Solution**: Ensure `lazy-load-optimization.js` is loaded and check console for errors.

### Issue: Nginx not serving compressed files
**Solution**: 
```bash
# Check gzip module is enabled
nginx -V 2>&1 | grep -o with-http_gzip_static_module

# Verify gzip is working
curl -H "Accept-Encoding: gzip" -I https://aenfinite.com
```

---

## Maintenance

### Regular Checks
- Run PageSpeed Insights monthly
- Monitor Core Web Vitals in Google Search Console
- Check for new unused JavaScript/CSS
- Update minification when source files change

### Automated Minification
Add to your deployment pipeline:
```bash
#!/bin/bash
# In your deployment script
npm install -g terser clean-css-cli
./optimize-assets.sh  # Create this script with your minification commands
```

---

## Additional Optimization Opportunities

### 1. Image Optimization
- Convert images to WebP format
- Use responsive images with srcset
- Compress images (TinyPNG, ImageOptim)

### 2. Font Optimization
- Use font-display: swap
- Subset fonts to include only needed characters
- Preload critical fonts

### 3. Remove Unused WordPress Features
- Disable WordPress emoji scripts
- Remove jQuery migrate
- Disable WordPress embeds

### 4. Enable HTTP/2
```nginx
listen 443 ssl http2;
```

### 5. Consider a CDN
- Cloudflare (free tier available)
- AWS CloudFront
- KeyCDN

---

## Resources
- [PageSpeed Insights](https://pagespeed.web.dev/)
- [Web.dev Performance](https://web.dev/performance/)
- [Terser Documentation](https://terser.org/docs/)
- [CleanCSS Documentation](https://github.com/clean-css/clean-css)
- [Nginx Optimization](https://nginx.org/en/docs/http/ngx_http_gzip_module.html)

---

## Support
For issues or questions, refer to:
- [VPS-DEPLOYMENT-GUIDE.md](./VPS-DEPLOYMENT-GUIDE.md)
- [SEO-Action-Plan.md](./SEO-Action-Plan.md)
