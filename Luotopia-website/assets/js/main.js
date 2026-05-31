/**
 * Luotopia 主站 — 交互逻辑
 * - 导航栏滚动效果
 * - 移动端菜单
 * - 截图轮播
 * - 滚动渐入动画
 * - 平滑滚动
 */

document.addEventListener('DOMContentLoaded', () => {
  initNav();
  initScreenshots();
  initFadeIn();
});

// ── 导航栏 ────────────────────────────────────────────

function initNav() {
  const nav = document.getElementById('nav');
  const toggle = document.getElementById('navToggle');
  const links = document.getElementById('navLinks');
  if (!nav || !toggle || !links) return;

  // 滚动时加深导航背景
  let ticking = false;
  const updateNav = () => {
    if (window.scrollY > 32) {
      nav.classList.add('nav--scrolled');
    } else {
      nav.classList.remove('nav--scrolled');
    }
    ticking = false;
  };

  window.addEventListener('scroll', () => {
    if (!ticking) {
      requestAnimationFrame(updateNav);
      ticking = true;
    }
  });

  // 初始状态检查
  updateNav();

  // 移动端菜单开关
  toggle.addEventListener('click', () => {
    const isOpen = links.classList.toggle('open');
    toggle.setAttribute('aria-expanded', isOpen);
  });

  // 点击菜单项后关闭
  links.querySelectorAll('a').forEach(a => {
    a.addEventListener('click', () => {
      links.classList.remove('open');
      toggle.setAttribute('aria-expanded', 'false');
    });
  });

  // 点击外部关闭菜单
  document.addEventListener('click', (e) => {
    if (!nav.contains(e.target) && links.classList.contains('open')) {
      links.classList.remove('open');
      toggle.setAttribute('aria-expanded', 'false');
    }
  });
}

// ── 截图轮播 ──────────────────────────────────────────

function initScreenshots() {
  const track = document.getElementById('screenshotTrack');
  const nav = document.getElementById('screenshotNav');
  if (!track || !nav) return;

  const slides = track.querySelectorAll('.screenshot');

  // 创建导航点
  slides.forEach((_, i) => {
    const dot = document.createElement('button');
    dot.className = 'screenshots__dot';
    dot.setAttribute('aria-label', `第 ${i + 1} 张截图`);
    dot.addEventListener('click', () => {
      slides[i].scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' });
    });
    nav.appendChild(dot);
  });

  const dots = nav.querySelectorAll('.screenshots__dot');
  if (dots.length === 0) return;
  dots[0].classList.add('active');

  // 滚动时高亮当前导航点
  let scrollTicking = false;
  track.addEventListener('scroll', () => {
    if (!scrollTicking) {
      requestAnimationFrame(() => {
        updateActiveDot(track, slides, dots);
        scrollTicking = false;
      });
      scrollTicking = true;
    }
  });
}

function updateActiveDot(track, slides, dots) {
  const center = track.scrollLeft + track.offsetWidth / 2;
  let activeIdx = 0;
  let minDist = Infinity;

  slides.forEach((slide, i) => {
    const slideCenter = slide.offsetLeft + slide.offsetWidth / 2;
    const dist = Math.abs(center - slideCenter);
    if (dist < minDist) {
      minDist = dist;
      activeIdx = i;
    }
  });

  dots.forEach((dot, i) => {
    dot.classList.toggle('active', i === activeIdx);
  });
}

// ── 滚动渐入动画 ───────────────────────────────────────

function initFadeIn() {
  const elements = document.querySelectorAll('.fade-in');
  if (elements.length === 0) return;

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
        observer.unobserve(entry.target);
      }
    });
  }, {
    threshold: 0.15,
    rootMargin: '0px 0px -40px 0px'
  });

  elements.forEach(el => observer.observe(el));
}
