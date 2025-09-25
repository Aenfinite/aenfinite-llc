// =========================== 
// FAQ HEART ROTATION JAVASCRIPT
// ===========================

/**
 * Initialize FAQ Heart Rotation Functionality
 * Call this function after your HTML is loaded
 */
function initializeFAQHeartRotation() {
    var faqItems = document.getElementsByClassName('faq-item');
    
    /**
     * Close all FAQ items and reset icons to closed state
     */
    function closeAllFAQ() {
        for (var j = 0; j < faqItems.length; j++) {
            var item = faqItems[j];
            var content = item.querySelector('.faq-content');
            var heartIcon = item.querySelector('.faq-heart-icon');
            
            if (content) {
                item.classList.remove('active');
                content.style.maxHeight = "0px";
                content.style.opacity = "0";
                content.style.paddingBottom = "0px";
            }
            
            // Reset all icons to closed state (heart-rotate.svg pointing down)
            if (heartIcon) {
                heartIcon.src = "/wp-content/themes/aenfinite.com/images/heart-rotate.svg";
            }
        }
    }
    
    // Loop through all FAQ items and set up functionality
    for (var i = 0; i < faqItems.length; i++) {
        var faqItem = faqItems[i];
        var faqHeader = faqItem.querySelector('.faq-header');
        var faqContent = faqItem.querySelector('.faq-content');
        
        if (faqHeader && faqContent) {
            // Set initial state based on active class
            if (faqItem.classList.contains('active')) {
                faqContent.style.maxHeight = faqContent.scrollHeight + "px";
                faqContent.style.opacity = "1";
                faqContent.style.paddingBottom = "30px";
            } else {
                faqContent.style.maxHeight = "0px";
                faqContent.style.opacity = "0";
                faqContent.style.paddingBottom = "0px";
            }
            
            // Create closure to preserve item and content references
            (function(item, content) {
                item.querySelector('.faq-header').onclick = function(e) {
                    e.preventDefault();
                    
                    var heartIcon = item.querySelector('.faq-heart-icon');
                    
                    if (item.classList.contains('active')) {
                        // Close FAQ
                        item.classList.remove('active');
                        content.style.maxHeight = "0px";
                        content.style.opacity = "0";
                        content.style.paddingBottom = "0px";
                        
                        // Switch to closed heart (heart-rotate.svg) - points to bottom with CSS rotation
                        if (heartIcon) {
                            heartIcon.src = "/wp-content/themes/aenfinite.com/images/heart-rotate.svg";
                        }
                    } else {
                        // Open FAQ (close all others first)
                        closeAllFAQ();
                        item.classList.add('active');
                        content.style.maxHeight = content.scrollHeight + "px";
                        content.style.opacity = "1";
                        content.style.paddingBottom = "30px";
                        
                        // Switch to open heart (heart.svg) - points upward normally
                        if (heartIcon) {
                            heartIcon.src = "/wp-content/themes/aenfinite.com/images/heart.svg";
                        }
                    }
                };
            })(faqItem, faqContent);
        }
    }
}

// Auto-initialize when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeFAQHeartRotation);
} else {
    initializeFAQHeartRotation();
}

// Export for manual initialization if needed
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { initializeFAQHeartRotation };
}
