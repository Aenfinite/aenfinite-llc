/**
 * Email Subscription Form Handler for Darkmode Page
 * Handles form submission and sends data to n8n webhook
 */

document.addEventListener('DOMContentLoaded', function() {
    // Get the subscription form
    const subscriptionForm = document.querySelector('#wpcf7-f1502-o1 form');
    const emailInput = document.querySelector('input[name="your-email"]');
    const submitButton = document.querySelector('.wpcf7-submit');
    const responseOutput = document.querySelector('.wpcf7-response-output');
    const successMessage = document.querySelector('.message-send-true');
    
    // n8n webhook URL - replace with your actual n8n webhook URL
    const N8N_WEBHOOK_URL = 'http://n8n.aenfinite.com:5678/webhook/email-subscription';
    
    if (subscriptionForm) {
        subscriptionForm.addEventListener('submit', async function(e) {
            e.preventDefault(); // Prevent default form submission
            
            // Get form data
            const formData = new FormData(subscriptionForm);
            const email = formData.get('your-email');
            
            // Validate email
            if (!email || !isValidEmail(email)) {
                showError('Please enter a valid email address.');
                return;
            }
            
            // Show loading state
            showLoading();
            
            try {
                // Prepare data for n8n
                const submissionData = {
                    email: email,
                    form_type: 'email_subscription',
                    page: 'darkmode',
                    timestamp: new Date().toISOString(),
                    user_agent: navigator.userAgent,
                    referrer: document.referrer,
                    url: window.location.href,
                    // Hidden field data
                    ip: await getUserIP(),
                    utm_source: getUrlParameter('utm_source'),
                    utm_medium: getUrlParameter('utm_medium'),
                    utm_campaign: getUrlParameter('utm_campaign'),
                    utm_term: getUrlParameter('utm_term'),
                    utm_content: getUrlParameter('utm_content'),
                    utm_id: getUrlParameter('utm_id')
                };
                
                // Submit to n8n
                const response = await fetch(N8N_WEBHOOK_URL, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify(submissionData)
                });
                
                if (response.ok) {
                    // Success
                    showSuccess('Thanks! We\'ll be in touch.');
                    subscriptionForm.reset();
                    
                    // Optional: Track conversion (if you have analytics)
                    if (typeof gtag !== 'undefined') {
                        gtag('event', 'email_subscription', {
                            'event_category': 'lead_generation',
                            'event_label': 'darkmode_page'
                        });
                    }
                } else {
                    throw new Error('Submission failed');
                }
                
            } catch (error) {
                console.error('Submission error:', error);
                showError('Something went wrong. Please try again.');
            } finally {
                hideLoading();
            }
        });
    }
    
    // Helper functions
    function isValidEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }
    
    function showLoading() {
        if (submitButton) {
            submitButton.disabled = true;
            submitButton.value = 'Submitting...';
            submitButton.classList.add('submitting');
        }
    }
    
    function hideLoading() {
        if (submitButton) {
            submitButton.disabled = false;
            submitButton.value = 'Submit';
            submitButton.classList.remove('submitting');
        }
    }
    
    function showSuccess(message) {
        // Hide the email input and submit button
        if (emailInput) {
            emailInput.style.display = 'none';
        }
        if (submitButton) {
            submitButton.style.display = 'none';
        }
        
        // Show success message in place of the form
        if (successMessage) {
            successMessage.querySelector('p').textContent = message;
            successMessage.style.display = 'block';
        }
        if (responseOutput) {
            responseOutput.innerHTML = `<div class="wpcf7-mail-sent-ok">${message}</div>`;
            responseOutput.setAttribute('aria-hidden', 'false');
        }
        
        // Optional: Reset after 10 seconds (you can remove this if you want permanent hiding)
        setTimeout(() => {
            if (emailInput) {
                emailInput.style.display = '';
            }
            if (submitButton) {
                submitButton.style.display = '';
            }
            if (successMessage) {
                successMessage.style.display = 'none';
            }
            if (responseOutput) {
                responseOutput.innerHTML = '';
                responseOutput.setAttribute('aria-hidden', 'true');
            }
        }, 10000); // 10 seconds - you can change this or remove entirely
    }
    
    function showError(message) {
        if (responseOutput) {
            responseOutput.innerHTML = `<div class="wpcf7-validation-errors">${message}</div>`;
            responseOutput.setAttribute('aria-hidden', 'false');
        }
        
        // Hide error message after 5 seconds
        setTimeout(() => {
            if (responseOutput) {
                responseOutput.innerHTML = '';
                responseOutput.setAttribute('aria-hidden', 'true');
            }
        }, 5000);
    }
    
    async function getUserIP() {
        try {
            const response = await fetch('https://api.ipify.org?format=json');
            const data = await response.json();
            return data.ip;
        } catch (error) {
            console.log('Could not fetch IP:', error);
            return null;
        }
    }
    
    function getUrlParameter(name) {
        const urlParams = new URLSearchParams(window.location.search);
        return urlParams.get(name);
    }
    
    // Auto-populate hidden fields with tracking data
    function populateHiddenFields() {
        const hiddenFields = {
            'datas-message': new Date().toLocaleDateString(),
            'times-message': new Date().toLocaleTimeString(),
            'datac-message': new Date().toLocaleDateString(),
            'timec-message': new Date().toLocaleTimeString(),
            'urll': window.location.href,
            'utm_source': getUrlParameter('utm_source') || '',
            'utm_medium': getUrlParameter('utm_medium') || '',
            'utm_campaign': getUrlParameter('utm_campaign') || '',
            'utm_term': getUrlParameter('utm_term') || '',
            'utm_content': getUrlParameter('utm_content') || '',
            'utm_id': getUrlParameter('utm_id') || '',
            'urlback': document.referrer || '',
            'linkcontact': 'darkmode-email-subscription'
        };
        
        // Populate hidden fields
        Object.keys(hiddenFields).forEach(fieldName => {
            const field = document.querySelector(`input[name="${fieldName}"]`);
            if (field) {
                field.value = hiddenFields[fieldName];
            }
        });
        
        // Get and populate IP address
        getUserIP().then(ip => {
            const ipField = document.querySelector('input[name="ip"]');
            if (ipField && ip) {
                ipField.value = ip;
            }
        });
    }
    
    // Initialize hidden fields
    populateHiddenFields();
    
    // Add some CSS for loading state
    const style = document.createElement('style');
    style.textContent = `
        .wpcf7-submit.submitting {
            opacity: 0.7;
            cursor: not-allowed;
        }
        
        .wpcf7-validation-errors {
            color: #ff6b6b;
            background: #ffe6e6;
            border: 1px solid #ff6b6b;
            border-radius: 4px;
            padding: 10px;
            margin: 10px 0;
        }
        
        .wpcf7-mail-sent-ok {
            color: #28a745;
            background: #e6ffe6;
            border: 1px solid #28a745;
            border-radius: 4px;
            padding: 10px;
            margin: 10px 0;
        }
        
        .message-send-true {
            display: none;
            color: #28a745;
            background: #e6ffe6;
            border: 1px solid #28a745;
            border-radius: 4px;
            padding: 15px;
            margin: 10px 0;
            text-align: center;
            font-weight: 500;
            font-size: 16px;
        }
        
        .subscribe-input:focus {
            outline: 2px solid #227bf3;
            outline-offset: 2px;
        }
    `;
    document.head.appendChild(style);
});

// Export for potential use in other scripts
window.EmailSubscriptionHandler = {
    // You can add public methods here if needed
    validateEmail: function(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }
};