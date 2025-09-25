const fs = require('fs');
const path = require('path');

/**
 * MPC MVP - Mass Page Creator (Minimum Viable Product)
 * Simple "CSV → HTML Pages" Engine
 * 
 * Usage: node mpc-mvp.js
 */

class MPCEngine {
    constructor() {
        this.stats = {
            startTime: 0,
            totalPages: 0,
            totalSize: 0,
            errors: []
        };
    }

    // Parse CSV data into structured format
    parseCSV(csvContent) {
        const rows = csvContent.trim().split('\n');
        const headers = rows[0].split(',').map(h => h.trim());
        const dataRows = rows.slice(1).filter(row => row.trim());
        
        return dataRows.map(row => {
            const values = row.split(',').map(v => v.trim());
            const data = {};
            
            headers.forEach((header, i) => {
                data[header] = values[i] || '';
            });
            
            return data;
        });
    }

    // Replace template placeholders with actual data
    renderTemplate(template, data) {
        let html = template;
        
        Object.keys(data).forEach(key => {
            const placeholder = new RegExp(`{${key}}`, 'g');
            html = html.replace(placeholder, data[key]);
        });
        
        return html;
    }

    // Generate filename from data
    generateFilename(data) {
        const service = (data.service || 'service').toLowerCase().replace(/\s+/g, '-');
        const city = (data.city || 'city').toLowerCase().replace(/\s+/g, '-');
        const state = (data.state || 'state').toLowerCase().replace(/\s+/g, '-');
        
        return `${service}-${city}-${state}.html`;
    }

    // Main generation function
    async generatePages(csvFile, templateFile, outputDir = './generated-pages') {
        console.log('🚀 MPC MVP - Starting page generation...\n');
        this.stats.startTime = Date.now();
        
        try {
            // Read input files
            console.log('📖 Reading CSV data...');
            const csvContent = fs.readFileSync(csvFile, 'utf8');
            
            console.log('📄 Reading HTML template...');
            const template = fs.readFileSync(templateFile, 'utf8');
            
            // Parse data
            const records = this.parseCSV(csvContent);
            console.log(`📊 Found ${records.length} records to process\n`);
            
            // Create output directory
            if (!fs.existsSync(outputDir)) {
                fs.mkdirSync(outputDir, { recursive: true });
            }
            
            // Generate pages
            const results = [];
            
            for (let i = 0; i < records.length; i++) {
                const data = records[i];
                
                try {
                    // Render HTML
                    const html = this.renderTemplate(template, data);
                    const filename = this.generateFilename(data);
                    const filepath = path.join(outputDir, filename);
                    
                    // Write file
                    fs.writeFileSync(filepath, html, 'utf8');
                    
                    const size = Buffer.byteLength(html, 'utf8');
                    this.stats.totalSize += size;
                    
                    results.push({
                        filename,
                        filepath,
                        size,
                        data
                    });
                    
                    console.log(`✅ ${filename} (${Math.round(size / 1024)} KB)`);
                    
                } catch (error) {
                    console.error(`❌ Error generating page ${i + 1}:`, error.message);
                    this.stats.errors.push(`Page ${i + 1}: ${error.message}`);
                }
            }
            
            this.stats.totalPages = results.length;
            
            // Generate summary
            await this.generateSummary(results, outputDir);
            
            this.printStats();
            
            return results;
            
        } catch (error) {
            console.error('💥 Fatal error:', error.message);
            throw error;
        }
    }

    // Generate summary file
    async generateSummary(results, outputDir) {
        const summary = {
            generated_at: new Date().toISOString(),
            total_pages: results.length,
            total_size_kb: Math.round(this.stats.totalSize / 1024),
            generation_time_ms: Date.now() - this.stats.startTime,
            pages: results.map(r => ({
                filename: r.filename,
                size_kb: Math.round(r.size / 1024),
                service: r.data.service,
                city: r.data.city,
                state: r.data.state
            }))
        };
        
        const summaryPath = path.join(outputDir, 'generation-summary.json');
        fs.writeFileSync(summaryPath, JSON.stringify(summary, null, 2), 'utf8');
        
        console.log(`\n📋 Summary saved to: ${summaryPath}`);
    }

    // Print generation statistics
    printStats() {
        const duration = (Date.now() - this.stats.startTime) / 1000;
        
        console.log('\n' + '='.repeat(50));
        console.log('🎉 GENERATION COMPLETE');
        console.log('='.repeat(50));
        console.log(`📄 Pages created: ${this.stats.totalPages}`);
        console.log(`💾 Total size: ${Math.round(this.stats.totalSize / 1024)} KB`);
        console.log(`⏱️  Generation time: ${duration.toFixed(2)}s`);
        console.log(`🚀 Average: ${Math.round(this.stats.totalPages / duration)} pages/second`);
        
        if (this.stats.errors.length > 0) {
            console.log(`\n⚠️  Errors: ${this.stats.errors.length}`);
            this.stats.errors.forEach(error => console.log(`   - ${error}`));
        }
        
        console.log('='.repeat(50));
    }
}

// Sample data and template for testing
const sampleCSV = `service,city,state,country,price,description
Web Design,Los Angeles,California,USA,2500,Custom website design that converts visitors into customers
SEO Services,New York City,New York,USA,1500,Professional SEO to boost your search rankings
Mobile Apps,Chicago,Illinois,USA,10000,Native iOS and Android app development
E-commerce,Miami,Florida,USA,7500,Complete online store solutions with payment processing
Digital Marketing,Houston,Texas,USA,2000,Full-service digital marketing campaigns
Branding,Phoenix,Arizona,USA,3000,Professional logo design and brand identity
Social Media,Philadelphia,Pennsylvania,USA,1200,Social media management and content creation
PPC Advertising,San Antonio,Texas,USA,2500,Google Ads and Facebook advertising campaigns
Web Hosting,San Diego,California,USA,500,Fast and secure web hosting solutions
WordPress,Dallas,Texas,USA,1800,Custom WordPress website development`;

const sampleTemplate = `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{service} in {city}, {state} - Aenfinite®</title>
    <meta name="description" content="Professional {service} services in {city}, {state}. {description} Starting at $\{price}. Contact Aenfinite for a free quote.">
    <meta name="keywords" content="{service}, {city}, {state}, web design, development, Aenfinite">
    
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            line-height: 1.6; color: #2d3748; background: #f7fafc; 
        }
        .container { max-width: 1000px; margin: 0 auto; padding: 40px 20px; }
        .content { 
            background: white; padding: 40px; border-radius: 12px; 
            box-shadow: 0 4px 6px rgba(0,0,0,0.05); 
        }
        h1 { font-size: 2.5rem; color: #1a202c; margin-bottom: 20px; }
        .breadcrumb { color: #718096; margin-bottom: 20px; font-size: 14px; }
        .breadcrumb a { color: #3182ce; text-decoration: none; }
        .description { font-size: 1.1rem; margin-bottom: 30px; color: #4a5568; }
        .pricing { 
            background: linear-gradient(135deg, #4299e1, #3182ce); 
            color: white; padding: 25px; border-radius: 10px; text-align: center; margin: 30px 0; 
        }
        .cta { 
            text-align: center; background: #1a202c; color: white; 
            padding: 30px; border-radius: 10px; margin-top: 30px; 
        }
        .cta-btn { 
            display: inline-block; background: #3182ce; color: white; 
            padding: 12px 25px; border-radius: 6px; text-decoration: none; 
            font-weight: 600; margin: 10px; 
        }
        .footer { text-align: center; margin-top: 30px; color: #718096; }
        @media (max-width: 768px) { .content { padding: 25px; } h1 { font-size: 2rem; } }
    </style>
</head>
<body>
    <div class="container">
        <div class="content">
            <nav class="breadcrumb">
                <a href="/services">Services</a> > 
                <a href="/services/{country}">{country}</a> > 
                <a href="/services/{country}/{state}">{state}</a> > 
                {city}
            </nav>
            
            <h1>{service} Services in {city}, {state}</h1>
            
            <div class="description">
                <p>Looking for professional <strong>{service}</strong> in {city}, {state}? 
                Aenfinite delivers exceptional results for {city} businesses.</p>
                
                <p>{description} Our team combines local market knowledge with proven expertise 
                to help your {city} business succeed online.</p>
                
                <h3>Why Choose Aenfinite for {service} in {city}?</h3>
                <ul>
                    <li>✅ Local {state} expertise with global standards</li>
                    <li>✅ Proven results for {city} businesses</li>
                    <li>✅ Custom solutions tailored for your needs</li>
                    <li>✅ 24/7 support and ongoing maintenance</li>
                </ul>
            </div>
            
            <div class="pricing">
                <h2>Investment</h2>
                <p style="font-size: 1.5rem; margin-top: 10px;">Starting at $\{price}</p>
                <p style="opacity: 0.9;">Custom quotes available based on your requirements</p>
            </div>
            
            <div class="cta">
                <h2>Ready to Get Started?</h2>
                <p>Let's discuss your {service} project in {city} and create something amazing.</p>
                <a href="/contact" class="cta-btn">Get Free Quote</a>
                <a href="/portfolio" class="cta-btn">View Our Work</a>
            </div>
            
            <div class="footer">
                <p>Professional {service} services by <strong>Aenfinite®</strong> | Serving {city}, {state}</p>
            </div>
        </div>
    </div>
</body>
</html>`;

// Main execution
async function main() {
    const mpc = new MPCEngine();
    
    // Create sample files if they don't exist
    if (!fs.existsSync('sample-data.csv')) {
        fs.writeFileSync('sample-data.csv', sampleCSV, 'utf8');
        console.log('📝 Created sample-data.csv');
    }
    
    if (!fs.existsSync('sample-template.html')) {
        fs.writeFileSync('sample-template.html', sampleTemplate, 'utf8');
        console.log('📝 Created sample-template.html');
    }
    
    try {
        // Run with sample data
        await mpc.generatePages(
            'sample-data.csv',
            'sample-template.html',
            './generated-pages'
        );
        
        console.log('\n🎯 Next steps:');
        console.log('1. Edit sample-data.csv with your real data');
        console.log('2. Customize sample-template.html');
        console.log('3. Run: node mpc-mvp.js');
        console.log('4. Upload generated-pages/ to your web server');
        
    } catch (error) {
        console.error('💥 Failed to generate pages:', error.message);
        process.exit(1);
    }
}

// Run if called directly
if (require.main === module) {
    main();
}

module.exports = MPCEngine;
