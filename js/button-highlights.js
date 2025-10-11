// Universal Button and Checkbox Highlighting Script
// This script adds highlighting effects to all buttons and checkboxes across the website

document.addEventListener('DOMContentLoaded', function() {
	
	// CHECKBOX STYLING FOR CONTACT FORMS
	function setupCheckboxStyling() {
		const checkboxGroup = document.querySelector('.checkbox-group');
		if (checkboxGroup) {
			checkboxGroup.style.display = 'flex';
			checkboxGroup.style.flexWrap = 'wrap';
			checkboxGroup.style.gap = '10px';
			
			// Style each list item
			const listItems = checkboxGroup.querySelectorAll('.list-item');
			listItems.forEach(function(item) {
				item.style.display = 'flex';
				item.style.alignItems = 'center';
				item.style.background = '#f8f9fa';
				item.style.border = '1px solid #e0e0e0';
				item.style.borderRadius = '25px';
				item.style.padding = '8px 16px';
				item.style.cursor = 'pointer';
				item.style.transition = 'all 0.3s ease';
				item.style.boxShadow = '0 2px 4px rgba(0,0,0,0.05)';
				item.style.margin = '0';
				item.style.position = 'relative';
				item.style.transformOrigin = 'center center';
				
				// Find checkbox and label
				const checkbox = item.querySelector('input[type="checkbox"]');
				const label = item.querySelector('.list-item-label');
				
				// Make the entire item clickable
				item.addEventListener('click', function(e) {
					// If click wasn't on the checkbox itself, toggle it
					if (e.target !== checkbox) {
						checkbox.checked = !checkbox.checked;
						// Trigger change event for form processing
						const event = new Event('change', { bubbles: true });
						checkbox.dispatchEvent(event);
					}
					updateItemStyle(item, checkbox.checked);
				});
				
				// Also listen for direct checkbox changes
				if (checkbox) {
					checkbox.addEventListener('change', function() {
						updateItemStyle(item, this.checked);
					});
				}
				
				// Function to update item style based on checked state
				function updateItemStyle(item, isChecked) {
					if (isChecked) {
						item.style.background = 'linear-gradient(135deg, #227bf3, #1e6fd9)';
						item.style.borderColor = '#227bf3';
						item.style.borderWidth = '2px';
						item.style.boxShadow = '0 6px 16px rgba(34, 123, 243, 0.4), 0 0 0 3px rgba(34, 123, 243, 0.1)';
						item.style.transform = 'translateY(-2px) scale(1.02)';
						if (label) {
							label.style.color = '#ffffff';
							label.style.fontWeight = '600';
							label.style.textShadow = '0 1px 2px rgba(0,0,0,0.1)';
						}
					} else {
						item.style.background = '#f8f9fa';
						item.style.borderColor = '#e0e0e0';
						item.style.borderWidth = '1px';
						item.style.boxShadow = '0 2px 4px rgba(0,0,0,0.05)';
						item.style.transform = 'translateY(0) scale(1)';
						if (label) {
							label.style.color = '#555';
							label.style.fontWeight = '500';
							label.style.textShadow = 'none';
						}
					}
				}
				
				// Add hover effect
				item.addEventListener('mouseenter', function() {
					if (!checkbox.checked) {
						this.style.background = 'linear-gradient(135deg, #e8f4fd, #d1e9fc)';
						this.style.borderColor = '#227bf3';
						this.style.borderWidth = '2px';
						this.style.transform = 'translateY(-2px) scale(1.02)';
						this.style.boxShadow = '0 8px 20px rgba(34, 123, 243, 0.2), 0 0 0 2px rgba(34, 123, 243, 0.1)';
						
						const label = this.querySelector('.list-item-label');
						if (label) {
							label.style.color = '#227bf3';
							label.style.fontWeight = '600';
						}
					} else {
						// Enhanced hover for already selected items
						this.style.background = 'linear-gradient(135deg, #1e6fd9, #1a5bb8)';
						this.style.transform = 'translateY(-3px) scale(1.03)';
						this.style.boxShadow = '0 10px 25px rgba(34, 123, 243, 0.5), 0 0 0 3px rgba(34, 123, 243, 0.15)';
					}
				});
				
				item.addEventListener('mouseleave', function() {
					updateItemStyle(item, checkbox.checked);
				});
				
				// Style the checkbox and label
				if (checkbox) {
					checkbox.style.margin = '0 8px 0 0';
					checkbox.style.accentColor = '#227bf3';
					checkbox.style.pointerEvents = 'auto'; // Ensure checkbox is clickable
				}
				
				if (label) {
					label.style.fontSize = '14px';
					label.style.fontWeight = '500';
					label.style.color = '#555';
					label.style.cursor = 'pointer';
					label.style.margin = '0';
					label.style.whiteSpace = 'nowrap';
					label.style.pointerEvents = 'auto'; // Make label clickable
					label.style.userSelect = 'none'; // Prevent text selection
					label.style.transition = 'all 0.3s ease';
					
					// Make label clickable to toggle checkbox
					label.addEventListener('click', function(e) {
						e.preventDefault();
						e.stopPropagation();
						checkbox.checked = !checkbox.checked;
						// Trigger change event for form processing
						const event = new Event('change', { bubbles: true });
						checkbox.dispatchEvent(event);
						updateItemStyle(item, checkbox.checked);
					});
				}
				
				// Initial state
				updateItemStyle(item, checkbox.checked);
			});
		}
	}
	
	// UNIVERSAL BUTTON HIGHLIGHTING
	function setupButtonHighlighting() {
		// Find all buttons, links, and clickable elements
		const clickableElements = document.querySelectorAll('button, .btn, a[href], input[type="button"], input[type="submit"], .clickable, [role="button"]');
		
		clickableElements.forEach(function(element) {
			// Skip if it's already a checkbox item (handled above)
			if (element.closest('.checkbox-group')) return;
			
			// Store original styles
			const originalStyles = {
				background: getComputedStyle(element).background,
				borderColor: getComputedStyle(element).borderColor,
				transform: getComputedStyle(element).transform,
				boxShadow: getComputedStyle(element).boxShadow,
				color: getComputedStyle(element).color
			};
			
			// Add click event for highlighting
			element.addEventListener('click', function(e) {
				// Add highlighted state
				this.style.background = 'linear-gradient(135deg, #227bf3, #1e6fd9)';
				this.style.borderColor = '#227bf3';
				this.style.transform = 'translateY(-2px) scale(1.02)';
				this.style.boxShadow = '0 8px 20px rgba(34, 123, 243, 0.4), 0 0 0 3px rgba(34, 123, 243, 0.2)';
				this.style.color = '#ffffff';
				this.style.transition = 'all 0.3s ease';
				
				// Remove highlight after a short delay
				setTimeout(() => {
					this.style.background = originalStyles.background;
					this.style.borderColor = originalStyles.borderColor;
					this.style.transform = originalStyles.transform;
					this.style.boxShadow = originalStyles.boxShadow;
					this.style.color = originalStyles.color;
				}, 200);
			});
			
			// Add hover effect for all buttons
			element.addEventListener('mouseenter', function() {
				if (!this.dataset.clicked) {
					this.style.transition = 'all 0.3s ease';
					this.style.transform = 'translateY(-1px) scale(1.01)';
					this.style.boxShadow = '0 4px 12px rgba(34, 123, 243, 0.2)';
				}
			});
			
			element.addEventListener('mouseleave', function() {
				if (!this.dataset.clicked) {
					this.style.transform = 'translateY(0) scale(1)';
					this.style.boxShadow = originalStyles.boxShadow;
				}
			});
		});
	}
	
	// Initialize all features
	setupCheckboxStyling();
	setupButtonHighlighting();
	
	// Note: Mobile accordion now handled with pure CSS - no JavaScript needed
});
});
