// Mass Page Generator for Aenfinite Global Services
// This script generates the hierarchical structure: Country → State/Province → City → Service

const fs = require('fs');
const path = require('path');

// Define your service structure
const SERVICES_DATA = {
    // Countries where you provide services
    countries: {
        'us': {
            name: 'United States',
            states: {
                'california': {
                    name: 'California',
                    cities: {
                        'los-angeles': { name: 'Los Angeles', population: '4M', market: 'Premium' },
                        'san-francisco': { name: 'San Francisco', population: '900K', market: 'Tech Hub' },
                        'san-diego': { name: 'San Diego', population: '1.4M', market: 'Growing' },
                        'sacramento': { name: 'Sacramento', population: '500K', market: 'Emerging' }
                    }
                },
                'new-york': {
                    name: 'New York',
                    cities: {
                        'new-york-city': { name: 'New York City', population: '8.4M', market: 'Premium' },
                        'buffalo': { name: 'Buffalo', population: '260K', market: 'Growing' },
                        'rochester': { name: 'Rochester', population: '210K', market: 'Emerging' }
                    }
                },
                'texas': {
                    name: 'Texas',
                    cities: {
                        'houston': { name: 'Houston', population: '2.3M', market: 'Premium' },
                        'dallas': { name: 'Dallas', population: '1.3M', market: 'Premium' },
                        'austin': { name: 'Austin', population: '950K', market: 'Tech Hub' }
                    }
                }
            }
        },
        'ca': {
            name: 'Canada',
            states: {
                'ontario': {
                    name: 'Ontario',
                    cities: {
                        'toronto': { name: 'Toronto', population: '2.7M', market: 'Premium' },
                        'ottawa': { name: 'Ottawa', population: '1M', market: 'Growing' }
                    }
                },
                'british-columbia': {
                    name: 'British Columbia',
                    cities: {
                        'vancouver': { name: 'Vancouver', population: '650K', market: 'Premium' }
                    }
                }
            }
        },
        'gb': {
            name: 'United Kingdom',
            states: {
                'england': {
                    name: 'England',
                    cities: {
                        'london': { name: 'London', population: '9M', market: 'Premium' },
                        'manchester': { name: 'Manchester', population: '550K', market: 'Growing' },
                        'birmingham': { name: 'Birmingham', population: '1.1M', market: 'Growing' }
                    }
                }
            }
        }
    },

    // Services you offer
    services: {
        'web-design': {
            name: 'Web Design',
            description: 'Custom website design that converts visitors into customers',
            icon: '🎨',
            pricing: 'Starting from $2,500'
        },
        'web-development': {
            name: 'Web Development',
            description: 'Full-stack web development with modern technologies',
            icon: '💻',
            pricing: 'Starting from $5,000'
        },
        'mobile-app-development': {
            name: 'Mobile App Development',
            description: 'Native and cross-platform mobile applications',
            icon: '📱',
            pricing: 'Starting from $10,000'
        },
        'ecommerce-development': {
            name: 'E-commerce Development',
            description: 'Complete online store solutions with payment integration',
            icon: '🛒',
            pricing: 'Starting from $7,500'
        },
        'seo-services': {
            name: 'SEO Services',
            description: 'Search engine optimization to boost your online visibility',
            icon: '🔍',
            pricing: 'Starting from $1,500/month'
        },
        'digital-marketing': {
            name: 'Digital Marketing',
            description: 'Comprehensive digital marketing strategies and campaigns',
            icon: '📊',
            pricing: 'Starting from $2,000/month'
        },
        'branding-design': {
            name: 'Branding & Logo Design',
            description: 'Professional brand identity and logo design services',
            icon: '✨',
            pricing: 'Starting from $1,000'
        },
        'ui-ux-design': {
            name: 'UI/UX Design',
            description: 'User interface and experience design for digital products',
            icon: '🎯',
            pricing: 'Starting from $3,000'
        }
    }
};

// Template generators
class PageGenerator {
    constructor() {
        this.baseDir = './services';
        this.generatedPages = [];
    }

    // Generate HTML template
    generateHTML(data) {
        return `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${data.title}</title>
    <meta name="description" content="${data.description}">
    <meta name="keywords" content="${data.keywords}">
    
    <!-- Open Graph -->
    <meta property="og:title" content="${data.title}">
    <meta property="og:description" content="${data.description}">
    <meta property="og:type" content="website">
    <meta property="og:url" content="https://dd.nyc${data.url}">
    
    <!-- Schema.org markup -->
    <script type="application/ld+json">
    ${JSON.stringify(data.schema, null, 2)}
    </script>
    
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            line-height: 1.6;
            color: #2d3748;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 40px 20px;
        }
        .content-box {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.15);
            backdrop-filter: blur(10px);
        }
        .breadcrumb {
            color: #718096;
            margin-bottom: 20px;
            font-size: 14px;
        }
        .breadcrumb a { color: #3182ce; text-decoration: none; }
        .breadcrumb a:hover { text-decoration: underline; }
        h1 {
            font-size: 2.5rem;
            color: #1a365d;
            margin-bottom: 20px;
            font-weight: 700;
        }
        .service-icon { font-size: 3rem; margin-bottom: 20px; }
        .description {
            font-size: 1.1rem;
            color: #4a5568;
            margin-bottom: 30px;
            line-height: 1.7;
        }
        .features-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin: 40px 0;
        }
        .feature-card {
            background: #f7fafc;
            padding: 25px;
            border-radius: 12px;
            border-left: 4px solid #3182ce;
        }
        .feature-card h3 { color: #2d3748; margin-bottom: 10px; }
        .pricing {
            background: linear-gradient(135deg, #4299e1 0%, #3182ce 100%);
            color: white;
            padding: 30px;
            border-radius: 15px;
            text-align: center;
            margin: 40px 0;
        }
        .cta-section {
            text-align: center;
            background: #1a365d;
            color: white;
            padding: 40px;
            border-radius: 15px;
            margin-top: 40px;
        }
        .cta-button {
            display: inline-block;
            background: #3182ce;
            color: white;
            padding: 15px 30px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
            margin-top: 20px;
            transition: background 0.3s;
        }
        .cta-button:hover { background: #2c5282; }
        .footer {
            text-align: center;
            margin-top: 40px;
            padding-top: 30px;
            border-top: 2px solid #e2e8f0;
            color: #718096;
        }
        .aenfinite-logo { color: #3182ce; font-weight: 700; }
        @media (max-width: 768px) {
            .content-box { padding: 25px; }
            h1 { font-size: 2rem; }
            .features-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="content-box">
            <nav class="breadcrumb">${data.breadcrumb}</nav>
            
            <div class="service-icon">${data.icon}</div>
            <h1>${data.h1}</h1>
            <div class="description">${data.content}</div>
            
            ${data.features ? this.generateFeatures(data.features) : ''}
            
            <div class="pricing">
                <h2>Investment</h2>
                <p style="font-size: 1.3rem; margin-top: 10px;">${data.pricing}</p>
                <p style="opacity: 0.9; margin-top: 10px;">Custom quotes available based on project requirements</p>
            </div>
            
            <div class="cta-section">
                <h2>Ready to Get Started?</h2>
                <p>Let's discuss your ${data.serviceName} project and create something amazing together.</p>
                <a href="/contact" class="cta-button">Get Free Quote</a>
                <a href="/portfolio" class="cta-button" style="margin-left: 15px; background: transparent; border: 2px solid #3182ce;">View Our Work</a>
            </div>
            
            <div class="footer">
                <p>Professional ${data.serviceName} services by <span class="aenfinite-logo">Aenfinite®</span></p>
            </div>
        </div>
    </div>
</body>
</html>`;
    }

    generateFeatures(features) {
        return `
            <div class="features-grid">
                ${features.map(feature => `
                    <div class="feature-card">
                        <h3>${feature.title}</h3>
                        <p>${feature.description}</p>
                    </div>
                `).join('')}
            </div>
        `;
    }

    // Generate service-specific pages
    generateServicePages() {
        const { countries, services } = SERVICES_DATA;

        Object.keys(countries).forEach(countryKey => {
            const country = countries[countryKey];
            
            Object.keys(country.states).forEach(stateKey => {
                const state = country.states[stateKey];
                
                Object.keys(state.cities).forEach(cityKey => {
                    const city = state.cities[cityKey];
                    
                    Object.keys(services).forEach(serviceKey => {
                        const service = services[serviceKey];
                        
                        const pageData = this.createServicePageData(
                            countryKey, country,
                            stateKey, state,
                            cityKey, city,
                            serviceKey, service
                        );
                        
                        this.createPageFile(pageData);
                    });
                });
            });
        });
    }

    createServicePageData(countryKey, country, stateKey, state, cityKey, city, serviceKey, service) {
        const url = \`/services/\${countryKey}/\${stateKey}/\${cityKey}/\${serviceKey}\`;
        
        return {
            url: url,
            title: \`\${service.name} in \${city.name}, \${state.name} - Aenfinite®\`,
            description: \`Professional \${service.name.toLowerCase()} services in \${city.name}, \${state.name}. \${service.description} Contact Aenfinite for a free consultation.\`,
            keywords: \`\${service.name}, \${city.name}, \${state.name}, \${country.name}, web design, development, digital marketing, Aenfinite\`,
            h1: \`\${service.name} Services in \${city.name}, \${state.name}\`,
            breadcrumb: \`<a href="/services">Global Services</a> > <a href="/services/\${countryKey}">\${country.name}</a> > <a href="/services/\${countryKey}/\${stateKey}">\${state.name}</a> > <a href="/services/\${countryKey}/\${stateKey}/\${cityKey}">\${city.name}</a> > \${service.name}\`,
            icon: service.icon,
            serviceName: service.name,
            pricing: service.pricing,
            content: \`
                <p>Looking for professional <strong>\${service.name.toLowerCase()}</strong> in \${city.name}, \${state.name}? Aenfinite is your trusted local partner for cutting-edge digital solutions.</p>
                
                <p>With a population of \${city.population} and a \${city.market.toLowerCase()} market, \${city.name} offers tremendous opportunities for businesses to thrive online. Our \${service.name.toLowerCase()} services are specifically tailored to help \${city.name} businesses succeed in today's competitive digital landscape.</p>
                
                <h3>Why Choose Aenfinite for \${service.name} in \${city.name}?</h3>
                <p>\${service.description} Our team combines local market knowledge with global expertise to deliver exceptional results for \${city.name} businesses.</p>
            \`,
            features: this.getServiceFeatures(serviceKey, city.name),
            schema: {
                "@context": "https://schema.org",
                "@type": "Service",
                "name": \`\${service.name} in \${city.name}\`,
                "description": service.description,
                "provider": {
                    "@type": "Organization",
                    "name": "Aenfinite",
                    "url": "https://dd.nyc"
                },
                "areaServed": {
                    "@type": "City",
                    "name": city.name,
                    "addressRegion": state.name,
                    "addressCountry": country.name
                }
            }
        };
    }

    getServiceFeatures(serviceKey, cityName) {
        const baseFeatures = {
            'web-design': [
                { title: 'Custom Design', description: \`Unique website designs tailored for \${cityName} businesses\` },
                { title: 'Mobile-First', description: 'Responsive designs that work perfectly on all devices' },
                { title: 'SEO Optimized', description: 'Built with search engine optimization in mind' },
                { title: 'Fast Loading', description: 'Optimized for speed and performance' }
            ],
            'web-development': [
                { title: 'Modern Technology', description: 'Built with the latest web technologies and frameworks' },
                { title: 'Scalable Solutions', description: 'Grows with your business needs' },
                { title: 'Security First', description: 'Enterprise-level security implementations' },
                { title: 'Ongoing Support', description: '24/7 technical support and maintenance' }
            ]
        };
        
        return baseFeatures[serviceKey] || [
            { title: 'Professional Service', description: \`High-quality \${serviceKey} solutions\` },
            { title: 'Local Expertise', description: \`Understanding of \${cityName} market dynamics\` }
        ];
    }

    createPageFile(data) {
        const filePath = path.join(this.baseDir, data.url.substring(10) + '.html'); // Remove '/services/' prefix
        const dirPath = path.dirname(filePath);
        
        // Create directory if it doesn't exist
        if (!fs.existsSync(dirPath)) {
            fs.mkdirSync(dirPath, { recursive: true });
        }
        
        // Generate HTML content
        const htmlContent = this.generateHTML(data);
        
        // Write file
        fs.writeFileSync(filePath, htmlContent);
        this.generatedPages.push(data.url);
        
        console.log(\`✅ Generated: \${data.url}\`);
    }

    // Generate sitemap
    generateSitemap() {
        const sitemapEntries = this.generatedPages.map(url => 
            \`    <url><loc>https://dd.nyc\${url}</loc><changefreq>monthly</changefreq><priority>0.8</priority></url>\`
        ).join('\\n');
        
        const sitemap = \`<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
\${sitemapEntries}
</urlset>\`;
        
        fs.writeFileSync(path.join(this.baseDir, 'sitemap.xml'), sitemap);
        console.log(\`\\n📋 Generated sitemap with \${this.generatedPages.length} pages\`);
    }

    // Run the generator
    run() {
        console.log('🚀 Starting mass page generation...');
        
        // Create base directory
        if (!fs.existsSync(this.baseDir)) {
            fs.mkdirSync(this.baseDir, { recursive: true });
        }
        
        // Generate all service pages
        this.generateServicePages();
        
        // Generate sitemap
        this.generateSitemap();
        
        console.log(\`\\n🎉 Success! Generated \${this.generatedPages.length} pages\`);
        console.log('📁 Files created in:', this.baseDir);
        console.log('\\n📊 Summary:');
        console.log(\`   Countries: \${Object.keys(SERVICES_DATA.countries).length}\`);
        console.log(\`   Services: \${Object.keys(SERVICES_DATA.services).length}\`);
        console.log(\`   Total Pages: \${this.generatedPages.length}\`);
    }
}

// Run the generator
const generator = new PageGenerator();
generator.run();
