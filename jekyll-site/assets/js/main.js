// Main JavaScript for Kaleb.Engineer website
// Following Swift.org patterns for progressive enhancement

document.addEventListener('DOMContentLoaded', function() {
    // Mobile navigation toggle (for future implementation)
    initMobileNav();
    
    // Smooth scrolling for anchor links
    initSmoothScrolling();
    
    // Code syntax highlighting enhancements
    initCodeHighlighting();
});

function initMobileNav() {
    // Placeholder for mobile navigation functionality
    // Will be implemented when responsive navigation is needed
    console.log('Mobile navigation initialized');
}

function initSmoothScrolling() {
    // Add smooth scrolling to all anchor links
    const anchorLinks = document.querySelectorAll('a[href^="#"]');
    
    anchorLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            const targetId = this.getAttribute('href').substring(1);
            const targetElement = document.getElementById(targetId);
            
            if (targetElement) {
                e.preventDefault();
                targetElement.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
}

function initCodeHighlighting() {
    // Add copy buttons to code blocks
    const codeBlocks = document.querySelectorAll('pre code');
    
    codeBlocks.forEach(block => {
        const pre = block.parentElement;
        const copyButton = document.createElement('button');
        copyButton.className = 'copy-code-btn';
        copyButton.textContent = 'Copy';
        copyButton.setAttribute('aria-label', 'Copy code to clipboard');
        
        copyButton.addEventListener('click', function() {
            const code = block.textContent;
            navigator.clipboard.writeText(code).then(() => {
                copyButton.textContent = 'Copied!';
                setTimeout(() => {
                    copyButton.textContent = 'Copy';
                }, 2000);
            }).catch(err => {
                console.error('Failed to copy code: ', err);
            });
        });
        
        pre.style.position = 'relative';
        pre.appendChild(copyButton);
    });
}