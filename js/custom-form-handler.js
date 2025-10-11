/**
 * Universal Custom Form Handler for Aenfinite Contact Forms
 * 
 * SETUP: Update the N8N webhook URL in the constructor below
 * 
 * This handler automatically:
 * - Intercepts all WordPress CF7 forms on any page
 * - Collects form data, tracking info, and page details
 * - Sends everything to N8N workflow for processing
 * - No page-specific configuration needed!
 * 
 * Just include this script on any page with contact forms
 */

class AenfiniteFormHandler {
    constructor() {
        // Hardcoded N8N webhook URL - change this once for all forms
        this.n8nWebhookUrl = 'https://n8n.aenfinite.com/webhook/aenfinite-contact-form';
        this.init();
    }

    init() {
        // Wait for DOM to be ready
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', () => {
                this.setupUniversalFormHandler();
                this.setupFormListeners();
                this.setupSelectBoxes();
                this.captureTrackingData();
            });
        } else {
            // Clean up any stuck submitting states first
            document.querySelectorAll('.wpcf7-form.submitting, form[class*="wpcf7"].submitting').forEach(form => {
                form.classList.remove('submitting');
            });
            
            this.setupUniversalFormHandler();
            this.setupFormListeners();
            this.setupSelectBoxes();
            this.captureTrackingData();
        }
    }

    // Universal form handler that works with existing WordPress CF7 forms
    setupUniversalFormHandler() {
        // Find all WordPress CF7 forms on the page
        const wpForms = document.querySelectorAll('.wpcf7-form, form[class*="wpcf7"]');
        
        wpForms.forEach(form => {
            // Clean up any stuck submitting states
            form.classList.remove('submitting');
            
            form.addEventListener('submit', (e) => {
                e.preventDefault(); // Prevent WordPress form submission
                this.handleWordPressFormSubmission(form);
            });
        });

        // Also handle custom Aenfinite forms
        const customForms = document.querySelectorAll('.aenfinite-custom-form');
        customForms.forEach(form => {
            form.addEventListener('submit', (e) => {
                e.preventDefault();
                this.handleFormSubmit(e);
            });
        });
    }

    // Handle WordPress CF7 form submissions
    async handleWordPressFormSubmission(form) {
        const submitButton = form.querySelector('input[type="submit"]');
        const responseOutput = form.querySelector('.wpcf7-response-output');
        
        // Store original button text and state
        const originalButtonText = submitButton ? submitButton.value : 'Send';
        const originalButtonDisabled = submitButton ? submitButton.disabled : false;
        
        // Show loading state and spinner
        if (submitButton) {
            submitButton.disabled = true;
            submitButton.value = 'Sending...';
            form.classList.add('submitting'); // Add submitting class for spinner visibility
            console.log('Button and spinner set to loading state');
        }
        
        // Create a function to reset button state and hide spinner
        const resetButton = () => {
            if (submitButton) {
                setTimeout(() => {
                    submitButton.disabled = originalButtonDisabled;
                    submitButton.value = originalButtonText;
                    form.classList.remove('submitting'); // Remove submitting class to hide spinner
                    console.log('Button and spinner reset to original state');
                }, 100);
            }
        };

        // Set up a failsafe timeout to reset button after 15 seconds
        const failsafeTimeout = setTimeout(() => {
            console.warn('Failsafe timeout triggered - resetting button');
            resetButton();
        }, 15000);
        
        try {
            // Collect WordPress form data
            const formData = this.collectWordPressFormData(form);
            console.log('Form data collected:', formData);
            
            // Validate required fields
            if (!this.validateForm(formData)) {
                this.showResponse(responseOutput, 'Please fill in all required fields.', 'error');
                resetButton();
                return;
            }

            // Send to CRM
            console.log('Sending to CRM...');
            const crmSuccess = await this.sendToCRM(formData);
            console.log('CRM result:', crmSuccess);
            
            // Send emails
            console.log('Sending emails...');
            const emailSuccess = await this.sendEmails(formData);
            console.log('Email result:', emailSuccess);
            
            if (crmSuccess || emailSuccess) {
                console.log('Form submission successful, showing success message');
                clearTimeout(failsafeTimeout); // Clear the failsafe since we're successful
                this.showSuccessMessage(form);
                // Don't reset button since form will be replaced with success message
                return;
            } else {
                throw new Error('Submission failed - please check your configuration');
            }
            
        } catch (error) {
            console.error('Form submission error:', error);
            clearTimeout(failsafeTimeout); // Clear the failsafe
            this.showResponse(responseOutput, error.message || 'An error occurred. Please try again later.', 'error');
            resetButton();
        }
    }

    // Collect data from WordPress CF7 forms
    collectWordPressFormData(form) {
        const data = {};
        
        // Basic form fields
        const nameInput = form.querySelector('input[name="your-name"]');
        const emailInput = form.querySelector('input[name="your-email"]');
        const projectInput = form.querySelector('input[name="text-tell-project"]');
        const budgetInput = form.querySelector('input[name="budget"]');
        
        data['your-name'] = nameInput ? nameInput.value.trim() : '';
        data['your-email'] = emailInput ? emailInput.value.trim() : '';
        data['text-tell-project'] = projectInput ? projectInput.value.trim() : '';
        data.budget = budgetInput ? budgetInput.value.trim() : '';

        // Collect selected services
        const services = [];
        const checkboxes = form.querySelectorAll('input[name="services"]:checked');
        checkboxes.forEach(checkbox => services.push(checkbox.value));
        data.services = services;

        // Collect tracking data
        const trackingFields = [
            'ip', 'ipdetails', 'urll', 'urlback', 'utm_source', 
            'utm_medium', 'utm_campaign', 'utm_term', 'utm_content'
        ];
        
        trackingFields.forEach(field => {
            const input = form.querySelector(`input[name="${field}"]`);
            data[field] = input ? input.value : '';
        });

        // Add current page info
        data.page_title = document.title;
        data.page_url = window.location.href;
        data.service_type = this.extractServiceType();

        return data;
    }

    // Setup form submission listeners
    setupFormListeners() {
        document.addEventListener('DOMContentLoaded', () => {
            const forms = document.querySelectorAll('.aenfinite-custom-form');
            forms.forEach(form => {
                form.addEventListener('submit', (e) => this.handleFormSubmit(e));
            });
        });
    }

    // Setup custom select boxes functionality
    setupSelectBoxes() {
        document.addEventListener('click', (e) => {
            if (e.target.classList.contains('js-select-holder')) {
                const selectBox = e.target.closest('.js-select');
                selectBox.classList.toggle('active');
            }

            if (e.target.classList.contains('js-select-option')) {
                const option = e.target;
                const selectBox = option.closest('.js-select');
                const input = selectBox.querySelector('.js-select-holder');
                
                input.value = option.textContent.trim();
                selectBox.classList.remove('active');
            }
        });

        // Close select boxes when clicking outside
        document.addEventListener('click', (e) => {
            if (!e.target.closest('.js-select')) {
                document.querySelectorAll('.js-select.active').forEach(select => {
                    select.classList.remove('active');
                });
            }
        });
    }

    // Capture tracking and analytics data
    captureTrackingData() {
        // Get IP address
        fetch('https://api.ipify.org?format=json')
            .then(response => response.json())
            .then(data => {
                document.querySelectorAll('input[name="ip"]').forEach(input => {
                    input.value = data.ip;
                });
            })
            .catch(error => console.log('IP detection failed:', error));

        // Get IP details
        fetch('https://ipapi.co/json/')
            .then(response => response.json())
            .then(data => {
                const ipDetails = `${data.city}, ${data.region}, ${data.country_name}`;
                document.querySelectorAll('input[name="ipdetails"]').forEach(input => {
                    input.value = ipDetails;
                });
            })
            .catch(error => console.log('IP details failed:', error));

        // Capture URL and referrer
        document.querySelectorAll('input[name="urll"]').forEach(input => {
            input.value = window.location.href;
        });

        document.querySelectorAll('input[name="urlback"]').forEach(input => {
            input.value = document.referrer;
        });

        // Capture UTM parameters
        const urlParams = new URLSearchParams(window.location.search);
        const utmParams = ['utm_id', 'utm_source', 'utm_medium', 'utm_campaign', 'utm_term', 'utm_content'];
        
        utmParams.forEach(param => {
            const value = urlParams.get(param) || '';
            document.querySelectorAll(`input[name="${param}"]`).forEach(input => {
                input.value = value;
            });
        });

        // Set timestamps
        const now = new Date();
        const dateStr = now.toLocaleDateString();
        const timeStr = now.toLocaleTimeString();

        document.querySelectorAll('input[name="datas-message"], input[name="datac-message"]').forEach(input => {
            input.value = dateStr;
        });

        document.querySelectorAll('input[name="times-message"], input[name="timec-message"]').forEach(input => {
            input.value = timeStr;
        });

        // Generate unique IDs
        const uniqueId = Date.now().toString();
        document.querySelectorAll('input[name="idd1"], input[name="idd2"]').forEach(input => {
            input.value = uniqueId;
        });
    }

    // Handle form submission
    async handleFormSubmit(e) {
        e.preventDefault();
        
        const form = e.target;
        const submitButton = form.querySelector('input[type="submit"]');
        const responseOutput = form.querySelector('.form-response-output');
        
        // Show loading state
        submitButton.disabled = true;
        submitButton.value = 'Sending...';
        
        try {
            // Collect form data
            const formData = this.collectFormData(form);
            
            // Validate required fields
            if (!this.validateForm(formData)) {
                this.showResponse(responseOutput, 'Please fill in all required fields.', 'error');
                return;
            }

            // Send to CRM
            const crmSuccess = await this.sendToCRM(formData);
            
            // Send emails
            const emailSuccess = await this.sendEmails(formData);
            
            if (crmSuccess || emailSuccess) {
                this.showSuccessMessage(form);
            } else {
                throw new Error('Submission failed');
            }
            
        } catch (error) {
            console.error('Form submission error:', error);
            this.showResponse(responseOutput, 'An error occurred. Please try again later.', 'error');
        } finally {
            // Reset button state
            submitButton.disabled = false;
            submitButton.value = 'Send';
        }
    }

    // Collect all form data
    collectFormData(form) {
        const data = {};
        
        // Basic form fields
        const inputs = form.querySelectorAll('input[type="text"], input[type="email"]');
        inputs.forEach(input => {
            data[input.name] = input.value.trim();
        });

        // Checkboxes (services)
        const services = [];
        const checkboxes = form.querySelectorAll('input[type="checkbox"]:checked');
        checkboxes.forEach(checkbox => {
            services.push(checkbox.value);
        });
        data.services = services;

        // Budget selection
        const budgetInput = form.querySelector('input[name="budget"]');
        if (budgetInput) {
            data.budget = budgetInput.value;
        }

        // Add current page info
        data.page_title = document.title;
        data.page_url = window.location.href;
        data.service_type = this.extractServiceType();

        return data;
    }

    // Extract service type from URL or page
    extractServiceType() {
        const path = window.location.pathname;
        const segments = path.split('/').filter(segment => segment);
        
        if (segments.includes('services') && segments.length > 1) {
            return segments[segments.length - 1].replace(/-/g, ' ').replace(/&/g, 'and');
        }
        
        return 'General Inquiry';
    }

    // Validate form data
    validateForm(data) {
        const required = ['your-name', 'your-email'];
        return required.every(field => data[field] && data[field].length > 0);
    }

    // Send to N8N Workflow (handles everything - CRM + Emails)
    async sendToCRM(formData) {
        return this.sendToN8N(formData);
    }

    async sendEmails(formData) {
        // N8N handles emails too, so we just return true here
        return true;
    }

    async sendToN8N(formData) {
        console.log('N8N webhook URL:', this.n8nWebhookUrl);
        
        if (!this.n8nWebhookUrl || this.n8nWebhookUrl.includes('your-n8n-instance.com')) {
            console.log('⚠️ N8N webhook URL not set - please update the URL in custom-form-handler.js');
            console.log('Form data that would be sent:', formData);
            return true; // Return true for demo purposes
        }

        try {
            // Prepare complete data package for N8N
            const n8nData = {
                // Form data
                contact: {
                    name: formData['your-name'],
                    email: formData['your-email'],
                    project_description: formData['text-tell-project'],
                    budget: formData.budget,
                    services: formData.services || []
                },
                
                // Page and service info
                page_info: {
                    service_type: formData.service_type,
                    page_title: formData.page_title,
                    page_url: formData.page_url
                },
                
                // Tracking and analytics
                tracking: {
                    ip_address: formData.ip,
                    location: formData.ipdetails,
                    referrer: formData.urlback,
                    utm_source: formData.utm_source,
                    utm_medium: formData.utm_medium,
                    utm_campaign: formData.utm_campaign,
                    utm_term: formData.utm_term,
                    utm_content: formData.utm_content
                },
                
                // Email templates (pre-generated for N8N to use)
                email_templates: {
                    admin_email: {
                        subject: `New ${formData.service_type} Inquiry from ${formData['your-name']}`,
                        html: this.generateAdminEmailHTML(formData)
                    },
                    client_email: {
                        to: formData['your-email'],
                        subject: `Thank you for contacting Aenfinite - ${formData.service_type}`,
                        html: this.generateClientEmailHTML(formData)
                    }
                },
                
                // Meta information
                meta: {
                    source: 'Aenfinite Website Contact Form',
                    timestamp: new Date().toISOString(),
                    lead_priority: this.calculateLeadPriority(formData),
                    form_version: '2.0'
                }
            };

            console.log('Sending data to N8N:', n8nData);

            // Create a timeout promise
            const timeoutPromise = new Promise((_, reject) => {
                setTimeout(() => reject(new Error('Request timeout after 10 seconds')), 10000);
            });

            // Race the fetch against the timeout
            const fetchPromise = fetch(this.n8nWebhookUrl, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(n8nData)
            });

            const response = await Promise.race([fetchPromise, timeoutPromise]);

            console.log('N8N response status:', response.status);
            console.log('N8N response ok:', response.ok);

            if (!response.ok) {
                const errorText = await response.text();
                console.error('N8N webhook error response:', errorText);
                throw new Error(`N8N webhook returned ${response.status}: ${errorText}`);
            }

            const responseData = await response.text();
            console.log('N8N response data:', responseData);

            return response.ok;
        } catch (error) {
            console.error('N8N webhook submission failed:', error);
            console.error('Error details:', {
                message: error.message,
                stack: error.stack,
                url: this.n8nWebhookUrl
            });
            return false;
        }
    }

    // Generic email sending function
    async sendEmail(emailData) {
        if (!this.emailEndpoint) {
            console.log('Email endpoint not configured');
            return true; // Return true for now if not configured
        }

        try {
            const response = await fetch(this.emailEndpoint, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(emailData)
            });

            return response.ok;
        } catch (error) {
            console.error('Email sending failed:', error);
            return false;
        }
    }

    // Generate admin notification email HTML
    generateAdminEmailHTML(formData) {
        return `
            <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 20px; color: white;">
                    <h1 style="margin: 0;">New ${formData.service_type} Inquiry</h1>
                </div>
                
                <div style="padding: 20px; background: #f9f9f9;">
                    <h2>Contact Information</h2>
                    <p><strong>Name:</strong> ${formData['your-name']}</p>
                    <p><strong>Email:</strong> ${formData['your-email']}</p>
                    <p><strong>Project Description:</strong> ${formData['text-tell-project'] || 'Not provided'}</p>
                    <p><strong>Budget:</strong> ${formData.budget || 'Not specified'}</p>
                    
                    ${formData.services && formData.services.length > 0 ? `
                        <h3>Services Interested In:</h3>
                        <ul>
                            ${formData.services.map(service => `<li>${service}</li>`).join('')}
                        </ul>
                    ` : ''}
                    
                    <h3>Page Information</h3>
                    <p><strong>Service Page:</strong> ${formData.service_type}</p>
                    <p><strong>Page Title:</strong> ${formData.page_title}</p>
                    <p><strong>URL:</strong> ${formData.page_url}</p>
                    
                    <h3>Tracking Information</h3>
                    <p><strong>IP Address:</strong> ${formData.ip || 'Unknown'}</p>
                    <p><strong>Location:</strong> ${formData.ipdetails || 'Unknown'}</p>
                    <p><strong>Referrer:</strong> ${formData.urlback || 'Direct'}</p>
                    
                    ${formData.utm_source ? `
                        <h3>Marketing Attribution</h3>
                        <p><strong>Source:</strong> ${formData.utm_source}</p>
                        <p><strong>Medium:</strong> ${formData.utm_medium || 'N/A'}</p>
                        <p><strong>Campaign:</strong> ${formData.utm_campaign || 'N/A'}</p>
                        <p><strong>Term:</strong> ${formData.utm_term || 'N/A'}</p>
                        <p><strong>Content:</strong> ${formData.utm_content || 'N/A'}</p>
                    ` : ''}
                    
                    <div style="background: #e8f4f8; padding: 15px; border-radius: 5px; margin-top: 20px;">
                        <p><strong>Submitted:</strong> ${new Date().toLocaleString()}</p>
                        <p><strong>Lead Priority:</strong> ${this.calculateLeadPriority(formData)}</p>
                    </div>
                </div>
            </div>
        `;
    }

    // Generate client confirmation email HTML (customizable per service type)
    generateClientEmailHTML(formData) {
        const serviceSpecificContent = this.getServiceSpecificContent(formData.service_type);
        
        return `
            <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 20px; color: white; text-align: center;">
                    <h1 style="margin: 0;">Thank You, ${formData['your-name']}!</h1>
                    <p style="margin: 10px 0 0 0; opacity: 0.9;">Your ${formData.service_type} inquiry has been received</p>
                </div>
                
                <div style="padding: 20px;">
                    <p>Thank you for your interest in our ${formData.service_type} services. We have received your inquiry and our team will get back to you within 24 hours.</p>
                    
                    <div style="background: #f0f8ff; padding: 15px; border-radius: 5px; margin: 20px 0; border-left: 4px solid #667eea;">
                        <h3 style="margin-top: 0; color: #333;">Your Inquiry Summary</h3>
                        <p><strong>Service:</strong> ${formData.service_type}</p>
                        <p><strong>Project:</strong> ${formData['text-tell-project'] || 'General inquiry'}</p>
                        <p><strong>Budget:</strong> ${formData.budget || 'To be discussed'}</p>
                        ${formData.services && formData.services.length > 0 ? `
                            <p><strong>Specific Services:</strong> ${formData.services.join(', ')}</p>
                        ` : ''}
                    </div>
                    
                    ${serviceSpecificContent}
                    
                    <div style="background: #f9f9f9; padding: 15px; border-radius: 5px; margin: 20px 0;">
                        <h3 style="margin-top: 0;">What Happens Next?</h3>
                        <ul style="margin: 0; padding-left: 20px;">
                            <li>Our team will review your inquiry within 2-4 hours</li>
                            <li>We'll prepare a customized proposal for your project</li>
                            <li>You'll receive a detailed consultation call within 24 hours</li>
                            <li>We'll discuss timeline, budget, and project specifications</li>
                        </ul>
                    </div>
                    
                    <p>In the meantime, feel free to:</p>
                    <ul>
                        <li>Browse our <a href="https://aenfinite.com/work" style="color: #667eea; text-decoration: none;">portfolio</a> for inspiration</li>
                        <li>Read our <a href="https://aenfinite.com/client-testimonials" style="color: #667eea; text-decoration: none;">client testimonials</a></li>
                        <li>Check out our <a href="https://aenfinite.com/services" style="color: #667eea; text-decoration: none;">other services</a></li>
                    </ul>
                    
                    <div style="text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
                        <p style="margin: 0;"><strong>Aenfinite</strong><br>
                        Professional Digital Solutions<br>
                        <a href="https://aenfinite.com/" style="color: #667eea; text-decoration: none;">www.aenfinite.com</a></p>
                        
                        <div style="margin-top: 15px;">
                            <a href="mailto:hello@aenfinite.com" style="color: #667eea; text-decoration: none; margin: 0 10px;">📧 Email</a>
                            <a href="tel:+1234567890" style="color: #667eea; text-decoration: none; margin: 0 10px;">📞 Call</a>
                        </div>
                    </div>
                </div>
            </div>
        `;
    }

    // Calculate lead priority based on form data
    calculateLeadPriority(formData) {
        let score = 0;
        
        // Budget scoring
        if (formData.budget) {
            if (formData.budget.includes('over $100,000')) score += 5;
            else if (formData.budget.includes('$50,000 to $100,000')) score += 4;
            else if (formData.budget.includes('$25,000 to $50,000')) score += 3;
            else if (formData.budget.includes('$10,000 to $25,000')) score += 2;
            else score += 1;
        }
        
        // Services selection scoring
        if (formData.services && formData.services.length > 3) score += 2;
        else if (formData.services && formData.services.length > 0) score += 1;
        
        // Project description scoring
        if (formData['text-tell-project'] && formData['text-tell-project'].length > 50) score += 1;
        
        // UTM source scoring (paid traffic = higher priority)
        if (formData.utm_source && formData.utm_source.includes('google')) score += 1;
        if (formData.utm_medium && formData.utm_medium.includes('cpc')) score += 1;
        
        if (score >= 7) return '🔥 HIGH PRIORITY';
        if (score >= 4) return '⚡ MEDIUM PRIORITY';
        return '📝 STANDARD';
    }

    // Get service-specific content for client emails
    getServiceSpecificContent(serviceType) {
        const serviceContent = {
            'AI Chatbots & Virtual Assistants': `
                <div style="background: #e8f5e8; padding: 15px; border-radius: 5px; margin: 20px 0;">
                    <h3 style="margin-top: 0;">🤖 AI Chatbots & Virtual Assistants</h3>
                    <p>Our AI solutions can help you:</p>
                    <ul>
                        <li>Automate customer support 24/7</li>
                        <li>Increase conversion rates by 30-50%</li>
                        <li>Reduce response time to under 2 seconds</li>
                        <li>Handle multiple languages and complex queries</li>
                    </ul>
                </div>
            `,
            'Web Design': `
                <div style="background: #fff3e0; padding: 15px; border-radius: 5px; margin: 20px 0;">
                    <h3 style="margin-top: 0;">🎨 Web Design Services</h3>
                    <p>Our web design process includes:</p>
                    <ul>
                        <li>Custom responsive designs for all devices</li>
                        <li>User experience (UX) optimization</li>
                        <li>SEO-friendly architecture</li>
                        <li>Performance optimization</li>
                    </ul>
                </div>
            `,
            'Digital Marketing': `
                <div style="background: #f3e5f5; padding: 15px; border-radius: 5px; margin: 20px 0;">
                    <h3 style="margin-top: 0;">📈 Digital Marketing</h3>
                    <p>Our marketing strategies deliver:</p>
                    <ul>
                        <li>Increased online visibility and traffic</li>
                        <li>Higher conversion rates and ROI</li>
                        <li>Targeted audience engagement</li>
                        <li>Data-driven campaign optimization</li>
                    </ul>
                </div>
            `
        };
        
        return serviceContent[serviceType] || `
            <div style="background: #f5f5f5; padding: 15px; border-radius: 5px; margin: 20px 0;">
                <h3 style="margin-top: 0;">🚀 ${serviceType}</h3>
                <p>We're excited to discuss how our ${serviceType} services can help grow your business and achieve your goals.</p>
            </div>
        `;
    }

    // Show success message by replacing the entire form
    showSuccessMessage(form) {
        // Find the entire formss-wrap container (includes heading and form)
        const formssWrap = form.closest('.formss-wrap');
        
        if (formssWrap) {
            // Replace the entire form wrapper with success message using heart.svg
            formssWrap.innerHTML = `
                <div class="success-container" style="text-align: center; padding: 60px 20px; position: relative; min-height: 400px; display: flex; flex-direction: column; align-items: center; justify-content: center;">
                    
                    <!-- Blue Circle with White Tick -->
                    <div class="tick-circle" style="
                        width: 80px; 
                        height: 80px; 
                        background: #227BF3; 
                        border-radius: 50%; 
                        display: flex; 
                        align-items: center; 
                        justify-content: center; 
                        margin-bottom: 25px;
                        box-shadow: 0 8px 25px rgba(34, 123, 243, 0.3);
                        transform: scale(0);
                        animation: tickAppear 0.6s ease-out 0.2s forwards;
                    ">
                        <svg width="45" height="35" viewBox="0 0 24 24" style="fill: none; stroke: white; stroke-width: 3; stroke-linecap: round; stroke-linejoin: round;">
                            <polyline points="20,6 9,17 4,12"></polyline>
                        </svg>
                    </div>
                    
                    
                    <!-- Success Message -->
                    <div class="success-text" style="color: #227BF3; font-family: 'Arial', sans-serif; opacity: 0; animation: textFadeIn 0.8s ease-out 0.6s forwards;">
                        <h2 style="margin: 0 0 20px 0; font-size: 42px; font-weight: 800; color: #227BF3; letter-spacing: -1px;">Thanks!</h2>
                        <p style="margin: 0 0 25px 0; font-size: 24px; color: #555; font-weight: 600;">We will be in touch</p>
                        <div style="font-size: 18px; color: #888; font-weight: 400; line-height: 1.5;">
                            We'll get back to you within <strong style="color: #227BF3;">24 hours</strong>
                        </div>
                    </div>
                    
                    <!-- Advanced Animations -->
                    <style>
                        @keyframes tickAppear {
                            0% { 
                                transform: scale(0) rotate(-180deg); 
                                opacity: 0; 
                            }
                            50% { 
                                transform: scale(1.2) rotate(0deg); 
                                opacity: 1; 
                            }
                            100% { 
                                transform: scale(1) rotate(0deg); 
                                opacity: 1; 
                            }
                        }
                        
                        @keyframes heartSlideUp {
                            0% { 
                                transform: translateY(30px) scale(0.8); 
                                opacity: 0; 
                            }
                            100% { 
                                transform: translateY(0) scale(1); 
                                opacity: 1; 
                            }
                        }
                        
                        @keyframes textFadeIn {
                            0% { 
                                transform: translateY(20px); 
                                opacity: 0; 
                            }
                            100% { 
                                transform: translateY(0); 
                                opacity: 1; 
                            }
                        }
                        
                        @keyframes heartPulse {
                            0% { transform: scale(1); }
                            50% { transform: scale(1.08); }
                            100% { transform: scale(1); }
                        }
                        
                        @keyframes tickPulse {
                            0% { transform: scale(1); }
                            50% { transform: scale(1.1); }
                            100% { transform: scale(1); }
                        }
                        
                        .heart-container svg {
                            animation: heartPulse 3s ease-in-out 1s infinite;
                        }
                        
                        .tick-circle {
                            animation: tickAppear 0.6s ease-out 0.2s forwards, tickPulse 2s ease-in-out 1.5s infinite;
                        }
                        
                        .success-container {
                            background: linear-gradient(135deg, rgba(34, 123, 243, 0.03) 0%, rgba(34, 123, 243, 0.08) 100%);
                            border-radius: 15px;
                        }
                    </style>
                    
                </div>
            `;
            
            // Add the animation class
            formssWrap.querySelector('div').classList.add('heart-success');
            
        } else {
            // Fallback: try to find toggle-formss or form parent
            const formContainer = form.closest('.toggle-formss') || form.parentElement;
            
            if (formContainer) {
                formContainer.innerHTML = `
                    <div style="text-align: center; padding: 60px 20px; position: relative;">
                        <div style="margin-bottom: 20px;">
                            <svg width="80" height="82" viewBox="0 0 176 178.4" style="fill: #227BF3;">
                                <path d="M0,89.2C48.3,77.2,74.7,46.5,87.9,0c13,46.5,39.9,77.2,88.2,89.4c-47.9,12-75.3,42.2-88.1,89.1C74.9,131.7,47.9,101.1,0,89.2z"/>
                            </svg>
                        </div>
                        <h2 style="margin: 0 0 10px 0; font-size: 28px; color: #227BF3;">Thanks!</h2>
                        <p style="margin: 0; font-size: 18px; color: #666;">We will be in touch</p>
                    </div>
                `;
            } else {
                // Final fallback
                const responseOutput = form.querySelector('.wpcf7-response-output');
                this.showResponse(responseOutput, 'Thank you for your message. We will get back to you soon!', 'success');
                form.reset();
            }
        }
    }

    // Show response message
    showResponse(container, message, type) {
        if (!container) return;
        
        container.innerHTML = `<div class="form-response ${type}">${message}</div>`;
        container.style.display = 'block';
        
        // Auto-hide after 10 seconds
        setTimeout(() => {
            container.style.display = 'none';
        }, 10000);
    }

    // Configuration methods
    configureN8N(webhookUrl) {
        this.n8nWebhookUrl = webhookUrl;
    }

    // Legacy methods for backward compatibility
    configureCRM(endpoint) {
        // For backward compatibility - treat as N8N webhook
        this.n8nWebhookUrl = endpoint;
    }

    configureEmail(endpoint, adminEmail) {
        // For backward compatibility - no longer needed
        console.log('Email configuration not needed - N8N handles everything');
    }

    // Set custom client email template
    setClientEmailTemplate(templateFunction) {
        this.generateClientEmailHTML = templateFunction;
    }
}

// Initialize the form handler
const aenfiniteFormHandler = new AenfiniteFormHandler();

// Export for global access and configuration
window.AenfiniteFormHandler = aenfiniteFormHandler;

// Simple configuration function for easy setup
window.configureAenfiniteForm = function(config) {
    // N8N webhook URL configuration
    if (config.n8nWebhookUrl) {
        aenfiniteFormHandler.configureN8N(config.n8nWebhookUrl);
    }
    
    // Legacy support - treat crmEndpoint as N8N webhook
    if (config.crmEndpoint) {
        aenfiniteFormHandler.configureCRM(config.crmEndpoint);
    }
    
    if (config.clientEmailTemplate) {
        aenfiniteFormHandler.setClientEmailTemplate(config.clientEmailTemplate);
    }
};

// Auto-initialization - works immediately when script is loaded
console.log('Aenfinite Universal Form Handler loaded and ready!');