document.addEventListener('DOMContentLoaded', function() {
    const form = document.querySelector('.wpcf7-form');
    const submitButton = form.querySelector('.wpcf7-submit');
    const nameInput = form.querySelector('input[name="your-name"]');
    const emailInput = form.querySelector('input[name="your-email"]');
    const servicesCheckboxes = form.querySelectorAll('input[name="services"]');
    const budgetInput = form.querySelector('input[name="budget"]');

    // Initially disable the submit button
    submitButton.disabled = true;
    submitButton.style.opacity = '0.5';
    submitButton.style.cursor = 'not-allowed';

    // Function to check if form is valid
    function validateForm() {
        const isNameFilled = nameInput.value.trim() !== '';
        const isEmailFilled = emailInput.value.trim() !== '' && emailInput.value.includes('@');
        const isServiceSelected = Array.from(servicesCheckboxes).some(checkbox => checkbox.checked);
        const isBudgetSelected = budgetInput.value.trim() !== '';

        const isValid = isNameFilled && isEmailFilled && isServiceSelected && isBudgetSelected;

        submitButton.disabled = !isValid;
        submitButton.style.opacity = isValid ? '1' : '0.5';
        submitButton.style.cursor = isValid ? 'pointer' : 'not-allowed';
    }

    // Add event listeners for all form fields
    [nameInput, emailInput, budgetInput].forEach(input => {
        input.addEventListener('input', validateForm);
    });

    servicesCheckboxes.forEach(checkbox => {
        checkbox.addEventListener('change', validateForm);
    });

    // Add change event listener for budget dropdown
    const budgetOptions = form.querySelectorAll('.js-select-option');
    budgetOptions.forEach(option => {
        option.addEventListener('click', function() {
            budgetInput.value = this.textContent.trim();
            validateForm();
        });
    });
});