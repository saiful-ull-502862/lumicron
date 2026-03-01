// src/scripts/animations.ts
import { gsap } from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import AOS from 'aos';
import 'aos/dist/aos.css';

gsap.registerPlugin(ScrollTrigger);

export function initAnimations() {
    // Initialize AOS
    AOS.init({
        duration: 800,
        once: true,
        offset: 100,
    });

    // Staggered reveal for gallery thumbnails (if any GSAP marks exist)
    const galleryItems = document.querySelectorAll('.gsap-reveal');
    if (galleryItems.length > 0) {
        gsap.fromTo(galleryItems,
            { y: 50, opacity: 0 },
            {
                y: 0,
                opacity: 1,
                duration: 0.6,
                stagger: 0.1,
                ease: 'power2.out',
                scrollTrigger: {
                    trigger: '.gsap-gallery',
                    start: 'top 80%',
                }
            }
        );
    }

    // Parallax effect for hero background
    const heroBg = document.querySelector('.hero-parallax');
    if (heroBg) {
        gsap.to(heroBg, {
            yPercent: 30,
            ease: "none",
            scrollTrigger: {
                trigger: ".hero-container",
                start: "top top",
                end: "bottom top",
                scrub: true
            }
        });
    }
}

document.addEventListener('DOMContentLoaded', initAnimations);
document.addEventListener('astro:page-load', initAnimations);
