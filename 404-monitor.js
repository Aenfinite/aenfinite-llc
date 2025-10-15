// 404 Error Monitoring Script
document.addEventListener('DOMContentLoaded', function() {
    // Log 404 errors to analytics
    if (document.title.includes('404') || document.body.textContent.includes('404')) {
        const referrer = document.referrer;
        const currentPath = window.location.pathname;
        
        // Send to analytics or logging service
        console.log(`404 Error detected: ${currentPath} - Referred from: ${referrer}`);
        
        // You can implement your own logging service here
        if (typeof gtag !== 'undefined') {
            gtag('event', '404_error', {
                'event_category': 'Error',
                'event_label': currentPath,
                'referrer': referrer
            });
        }
    }
});