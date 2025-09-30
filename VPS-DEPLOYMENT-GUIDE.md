# VPS Deployment Guide for Aenfinite Website with 404 Error Handling

## 🚀 VPS Setup Guide

### Prerequisites
- VPS with Ubuntu 20.04/22.04 LTS
- Root or sudo access
- Domain name pointed to your VPS IP

---

## 1. Initial VPS Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install essential packages
sudo apt install -y curl wget git unzip software-properties-common

# Create user for website (optional but recommended)
sudo adduser aenfinite
sudo usermod -aG sudo aenfinite
```

---

## 2. Web Server Installation

### Option A: Apache Setup
```bash
# Install Apache
sudo apt install -y apache2

# Enable Apache modules
sudo a2enmod rewrite
sudo a2enmod headers
sudo a2enmod expires
sudo a2enmod deflate

# Start and enable Apache
sudo systemctl start apache2
sudo systemctl enable apache2
```

### Option B: Nginx Setup (Recommended for performance)
```bash
# Install Nginx
sudo apt install -y nginx

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

---

## 3. SSL Certificate (Let's Encrypt)

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-apache  # For Apache
# OR
sudo apt install -y certbot python3-certbot-nginx   # For Nginx

# Get SSL certificate
sudo certbot --apache -d aenfinite.com -d www.aenfinite.com  # Apache
# OR
sudo certbot --nginx -d aenfinite.com -d www.aenfinite.com   # Nginx

# Set up auto-renewal
sudo crontab -e
# Add this line:
0 12 * * * /usr/bin/certbot renew --quiet
```

---

## 4. Website Deployment

```bash
# Create website directory
sudo mkdir -p /var/www/aenfinite.com
sudo chown -R www-data:www-data /var/www/aenfinite.com
sudo chmod -R 755 /var/www/aenfinite.com

# Upload your website files to /var/www/aenfinite.com/
# You can use SCP, SFTP, or Git
```

---

## 5. Configure 404 Error Handling

### For Apache:
1. Copy the `.htaccess` file to your website root
2. Ensure `404.html` is in the root directory
3. Apache will automatically use the ErrorDocument directive

### For Nginx:
1. Add the nginx configuration to your server block
2. Test configuration: `sudo nginx -t`
3. Reload Nginx: `sudo systemctl reload nginx`

---

## 6. Apache Virtual Host Configuration

Create: `/etc/apache2/sites-available/aenfinite.com.conf`

```apache
<VirtualHost *:80>
    ServerName aenfinite.com
    ServerAlias www.aenfinite.com
    DocumentRoot /var/www/aenfinite.com
    
    # Custom error pages
    ErrorDocument 404 /404.html
    ErrorDocument 403 /404.html
    ErrorDocument 500 /404.html
    
    # Enable .htaccess
    <Directory /var/www/aenfinite.com>
        AllowOverride All
        Require all granted
    </Directory>
    
    # Logging
    ErrorLog ${APACHE_LOG_DIR}/aenfinite.com_error.log
    CustomLog ${APACHE_LOG_DIR}/aenfinite.com_access.log combined
</VirtualHost>

# HTTPS version (after SSL setup)
<VirtualHost *:443>
    ServerName aenfinite.com
    ServerAlias www.aenfinite.com
    DocumentRoot /var/www/aenfinite.com
    
    # SSL Configuration (Certbot will add these)
    
    # Custom error pages
    ErrorDocument 404 /404.html
    ErrorDocument 403 /404.html
    ErrorDocument 500 /404.html
    
    <Directory /var/www/aenfinite.com>
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/aenfinite.com_ssl_error.log
    CustomLog ${APACHE_LOG_DIR}/aenfinite.com_ssl_access.log combined
</VirtualHost>
```

Enable the site:
```bash
sudo a2ensite aenfinite.com.conf
sudo a2dissite 000-default.conf
sudo systemctl reload apache2
```

---

## 7. Nginx Configuration

Create: `/etc/nginx/sites-available/aenfinite.com`

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name aenfinite.com www.aenfinite.com;
    
    root /var/www/aenfinite.com;
    index index.html index.htm index.php;
    
    # Custom error pages
    error_page 404 /404.html;
    error_page 403 /404.html;
    error_page 500 502 503 504 /404.html;
    
    # Handle 404.html specifically
    location = /404.html {
        internal;
        add_header Cache-Control "no-cache, no-store, must-revalidate";
    }
    
    location / {
        try_files $uri $uri/ $uri.html =404;
    }
    
    # Static file caching
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|webp)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 10240;
    gzip_proxied expired no-cache no-store private must-revalidate;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
}
```

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/aenfinite.com /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx
```

---

## 8. Performance Optimization

### Install and Configure PHP (if needed)
```bash
sudo apt install -y php8.1-fpm php8.1-mysql php8.1-curl php8.1-gd php8.1-xml php8.1-zip
```

### Enable Compression
```bash
# For Apache (mod_deflate should be enabled)
# For Nginx (gzip is included in config above)
```

### Set up Cloudflare (Optional)
1. Sign up for Cloudflare
2. Add your domain
3. Update nameservers
4. Enable caching and compression

---

## 9. Monitoring and Maintenance

### Log Monitoring
```bash
# Apache logs
sudo tail -f /var/log/apache2/aenfinite.com_error.log
sudo tail -f /var/log/apache2/aenfinite.com_access.log

# Nginx logs
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

### Backup Script
Create: `/home/aenfinite/backup.sh`
```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
tar -czf /home/aenfinite/backups/website_backup_$DATE.tar.gz -C /var/www aenfinite.com
find /home/aenfinite/backups -name "website_backup_*.tar.gz" -mtime +7 -delete
```

Make executable and add to cron:
```bash
chmod +x /home/aenfinite/backup.sh
crontab -e
# Add: 0 2 * * * /home/aenfinite/backup.sh
```

---

## 10. Testing 404 Configuration

Test your 404 page:
```bash
# Test non-existent pages
curl -I http://aenfinite.com/non-existent-page
curl -I https://aenfinite.com/test-404

# Should return HTTP 404 status and serve your custom 404.html
```

---

## 11. File Structure on VPS

```
/var/www/aenfinite.com/
├── 404.html                    # Your custom 404 page
├── .htaccess                   # Apache configuration (if using Apache)
├── index.html                  # Homepage
├── agency/
├── services/
├── work/
├── contact/
├── wp-content/
├── js/
└── css/
```

---

## 🔧 Quick Commands Reference

```bash
# Restart web server
sudo systemctl restart apache2  # Apache
sudo systemctl restart nginx    # Nginx

# Check status
sudo systemctl status apache2
sudo systemctl status nginx

# Test configurations
sudo apache2ctl configtest     # Apache
sudo nginx -t                   # Nginx

# View recent 404 errors
sudo grep "404" /var/log/apache2/aenfinite.com_access.log | tail -10
sudo grep "404" /var/log/nginx/access.log | tail -10
```

---

## 📊 404 Error Analytics

Your 404.html page includes:
- ✅ Google Analytics tracking
- ✅ Console logging for debugging
- ✅ Error data collection
- ✅ User-friendly interface
- ✅ Search functionality
- ✅ Popular pages navigation

The 404 page will automatically:
- Track 404 events in Google Analytics
- Log detailed error information
- Provide helpful navigation options
- Maintain your brand consistency

---

## 🚀 Final Steps

1. Upload all files to `/var/www/aenfinite.com/`
2. Set proper permissions: `sudo chown -R www-data:www-data /var/www/aenfinite.com`
3. Configure your web server (Apache or Nginx)
4. Install SSL certificate
5. Test 404 functionality
6. Monitor logs for any issues

Your website will now have professional 404 error handling with fast VPS performance!