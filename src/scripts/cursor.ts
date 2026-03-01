// src/scripts/cursor.ts
export function initCursor() {
    const cursor = document.querySelector('.custom-cursor') as HTMLElement;
    if (!cursor) return;

    // Don't use custom cursor on touch devices
    if (window.matchMedia('(pointer: coarse)').matches) {
        cursor.style.display = 'none';
        return;
    }

    const updateCursor = (e: MouseEvent) => {
        cursor.style.transform = `translate(${e.clientX}px, ${e.clientY}px)`;
    }

    window.addEventListener('mousemove', updateCursor);

    // Add hover effect for interactive elements
    const hoverElements = document.querySelectorAll('a, button, .hover-target');

    hoverElements.forEach(el => {
        el.addEventListener('mouseenter', () => cursor.classList.add('hovering'));
        el.addEventListener('mouseleave', () => cursor.classList.remove('hovering'));
    });

    // Hide cursor when it leaves the window
    document.addEventListener('mouseleave', () => cursor.classList.add('hidden'));
    document.addEventListener('mouseenter', () => cursor.classList.remove('hidden'));
}

document.addEventListener('DOMContentLoaded', initCursor);
// For Astro view transitions
document.addEventListener('astro:page-load', initCursor);
