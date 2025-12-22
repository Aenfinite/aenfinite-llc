/**
 * Lazy Loading & Performance Optimization Script
 * Implements intelligent script loading to reduce unused JavaScript
 * Target: Reduce unused JavaScript by ~586 KiB
 */

(function() {
    'use strict';

    // Utility: Check if element exists in viewport
    function isInViewport(element) {
        if (!element) return false;
        const rect = element.getBoundingClientRect();
        return (
            rect.top >= 0 &&
            rect.left >= 0 &&
            rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
            rect.right <= (window.innerWidth || document.documentElement.clientWidth)
        );
    }

    // Utility: Dynamically load script
    function loadScript(src, callback) {
        const existingScript = document.querySelector(`script[src="${src}"]`);
        if (existingScript) {
            if (callback) callback();
            return;
        }

        const script = document.createElement('script');
        script.src = src;
        script.async = true;
        
        if (callback) {
            script.onload = callback;
        }
        
        document.body.appendChild(script);
    }

    // Utility: Dynamically load CSS
    function loadCSS(href) {
        const existingLink = document.querySelector(`link[href="${href}"]`);
        if (existingLink) return;

        const link = document.createElement('link');
        link.rel = 'stylesheet';
        link.href = href;
        document.head.appendChild(link);
    }

    // Configuration: Define which scripts are needed for which sections
    const scriptConfig = {
        // Load ScrollMagic only if there are scroll animations
        scrollMagic: {
            condition: function() {
                return document.querySelector('[data-scroll-animation]') || 
                       document.querySelector('.scroll-reveal') ||
                       document.querySelector('.parallax');
            },
            scripts: [
                '/wp-content/themes/aenfinite.com/static/js/ScrollMagic.min.js',
                '/wp-content/themes/aenfinite.com/static/js/animation.gsap.min.js'
            ]
        },
        
        // Load Slick carousel only if there are carousels
        slick: {
            condition: function() {
                return document.querySelector('.slick-slider') || 
                       document.querySelector('[data-slick]');
            },
            scripts: [
                '/wp-content/themes/aenfinite.com/static/js/slick.min.js'
            ]
        },
        
        // Load form handler only if there are forms
        formHandler: {
            condition: function() {
                return document.querySelector('form[data-custom-form]') ||
                       document.querySelector('.contact-form') ||
                       document.querySelector('#contact-form');
            },
            scripts: [
                '/js/custom-form-handler.min.js'
            ]
        }
    };

    // Defer non-critical CSS
    function deferNonCriticalCSS() {
        const nonCriticalCSS = document.querySelectorAll('link[data-defer-css]');
        nonCriticalCSS.forEach(function(link) {
            link.media = 'print';
            link.onload = function() {
                link.media = 'all';
            };
        });
    }

    // Lazy load images with native loading or IntersectionObserver fallback
    function lazyLoadImages() {
        // Use native lazy loading if supported
        if ('loading' in HTMLImageElement.prototype) {
            const images = document.querySelectorAll('img[data-src]');
            images.forEach(function(img) {
                img.src = img.dataset.src;
                img.loading = 'lazy';
                if (img.dataset.srcset) {
                    img.srcset = img.dataset.srcset;
                }
            });
        } else {
            // Fallback to IntersectionObserver
            const imageObserver = new IntersectionObserver(function(entries, observer) {
                entries.forEach(function(entry) {
                    if (entry.isIntersecting) {
                        const img = entry.target;
                        img.src = img.dataset.src;
                        if (img.dataset.srcset) {
                            img.srcset = img.dataset.srcset;
                        }
                        img.classList.remove('lazy');
                        observer.unobserve(img);
                    }
                });
            });

            const lazyImages = document.querySelectorAll('img[data-src]');
            lazyImages.forEach(function(img) {
                imageObserver.observe(img);
            });
        }
    }

    // Conditionally load scripts based on page requirements
    function loadConditionalScripts() {
        let scriptsToLoad = [];

        // Check each configuration
        for (const key in scriptConfig) {
            const config = scriptConfig[key];
            if (config.condition()) {
                scriptsToLoad = scriptsToLoad.concat(config.scripts);
            }
        }

        // Load required scripts
        scriptsToLoad.forEach(function(src) {
            loadScript(src);
        });
    }

    // Preconnect to external domains
    function addPreconnects() {
        const preconnectDomains = [
            'https://www.googletagmanager.com',
            'https://fonts.googleapis.com',
            'https://fonts.gstatic.com'
        ];

        preconnectDomains.forEach(function(domain) {
            const link = document.createElement('link');
            link.rel = 'preconnect';
            link.href = domain;
            link.crossOrigin = 'anonymous';
            document.head.appendChild(link);
        });
    }

    // Remove unused jQuery if not needed
    function optimizeJQuery() {
        // Check if any elements actually use jQuery
        const hasJQueryDependency = 
            document.querySelector('[data-toggle]') ||
            document.querySelector('.jquery-dependent') ||
            typeof $ !== 'undefined' && $('.slick-slider').length > 0;

        if (!hasJQueryDependency) {
            console.log('jQuery not needed - consider removing for better performance');
        }
    }

    // Debounce scroll events
    function debounce(func, wait) {
        let timeout;
        return function executedFunction() {
            const context = this;
            const args = arguments;
            clearTimeout(timeout);
            timeout = setTimeout(function() {
                func.apply(context, args);
            }, wait);
        };
    }

    // Lazy load background images
    function lazyLoadBackgrounds() {
        const bgObserver = new IntersectionObserver(function(entries) {
            entries.forEach(function(entry) {
                if (entry.isIntersecting) {
                    const element = entry.target;
                    const bgImage = element.dataset.bgImage;
                    if (bgImage) {
                        element.style.backgroundImage = `url(${bgImage})`;
                        element.classList.add('bg-loaded');
                        bgObserver.unobserve(element);
                    }
                }
            });
        }, {
            rootMargin: '50px'
        });

        const bgElements = document.querySelectorAll('[data-bg-image]');
        bgElements.forEach(function(el) {
            bgObserver.observe(el);
        });
    }

    // Initialize on DOM ready
    function init() {
        // Add preconnects
        addPreconnects();

        // Defer non-critical CSS
        deferNonCriticalCSS();

        // Load scripts based on page requirements
        loadConditionalScripts();

        // Lazy load images
        lazyLoadImages();

        // Lazy load backgrounds
        lazyLoadBackgrounds();

        // Optimize jQuery usage
        optimizeJQuery();

        console.log('🚀 Performance optimization initialized');
    }

    // Wait for DOM to be ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

})();
