// ===== SMOOTH SCROLL =====
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
  anchor.addEventListener('click', function (e) {
    e.preventDefault();
    const target = document.querySelector(this.getAttribute('href'));
    if (target) target.scrollIntoView({ behavior: 'smooth', block: 'start' });
  });
});

// ===== NAVBAR SCROLL EFFECT =====
const navbar = document.querySelector('.navbar');
window.addEventListener('scroll', () => {
  if (window.scrollY > 50) {
    navbar.style.background = 'rgba(10,10,15,0.98)';
  } else {
    navbar.style.background = 'rgba(10,10,15,0.85)';
  }
});

// ===== SCROLL REVEAL ANIMATION =====
const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.classList.add('visible');
    }
  });
}, { threshold: 0.1 });

document.querySelectorAll('.service-card, .case-card, .about-card, .stat').forEach(el => {
  el.classList.add('fade-in');
  observer.observe(el);
});

// ===== COUNTER ANIMATION =====
function animateCounter(el, target, suffix = '') {
  let current = 0;
  const step = target / 60;
  const timer = setInterval(() => {
    current += step;
    if (current >= target) {
      current = target;
      clearInterval(timer);
    }
    el.textContent = Math.floor(current) + suffix;
  }, 16);
}

const statsObserver = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      const counters = [
        { el: entry.target.querySelectorAll('h2')[0], val: 40, suffix: '+' },
      ];
      statsObserver.unobserve(entry.target);
    }
  });
}, { threshold: 0.5 });

const statsSection = document.querySelector('.stats');
if (statsSection) statsObserver.observe(statsSection);

// ===== CURSOR GLOW EFFECT =====
const glow = document.createElement('div');
glow.style.cssText = `
  position: fixed; width: 400px; height: 400px;
  border-radius: 50%; pointer-events: none; z-index: 0;
  background: radial-gradient(circle, rgba(108,99,255,0.06) 0%, transparent 70%);
  transform: translate(-50%, -50%); transition: left 0.1s, top 0.1s;
`;
document.body.appendChild(glow);

document.addEventListener('mousemove', e => {
  glow.style.left = e.clientX + 'px';
  glow.style.top = e.clientY + 'px';
});

// ===== ADD CSS FOR FADE-IN =====
const style = document.createElement('style');
style.textContent = `
  .fade-in { opacity: 0; transform: translateY(24px); transition: opacity 0.6s ease, transform 0.6s ease; }
  .fade-in.visible { opacity: 1; transform: translateY(0); }
`;
document.head.appendChild(style);
