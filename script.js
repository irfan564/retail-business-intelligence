/* ==========================================================================
   RETAIL BUSINESS INTELLIGENCE — INTERACTIVE LOGIC (script.js)
   Features:
   - Animated KPI number tickers on viewport entry (IntersectionObserver)
   - Tab switching for Advanced SQL analysis queries
   - Smooth active state navigation tracking on scroll
   - Chart Lightbox preview modal for high-res inspection
   - Code snippet copy to clipboard with toast notification
   ========================================================================== */

document.addEventListener('DOMContentLoaded', () => {

  /* ─── 1. NAVBAR SCROLL EFFECT & ACTIVE LINK HIGHLIGHT ───────────────── */
  const navbar = document.getElementById('navbar');
  const sections = document.querySelectorAll('section[id]');
  const navLinks = document.querySelectorAll('.nav-link');

  window.addEventListener('scroll', () => {
    // Navbar elevation
    if (window.scrollY > 40) {
      navbar.classList.add('scrolled');
    } else {
      navbar.classList.remove('scrolled');
    }

    // Active link highlighting
    let currentId = '';
    const scrollPos = window.scrollY + 160;

    sections.forEach(section => {
      const top = section.offsetTop;
      const height = section.offsetHeight;
      if (scrollPos >= top && scrollPos < top + height) {
        currentId = section.getAttribute('id');
      }
    });

    navLinks.forEach(link => {
      link.classList.remove('active');
      if (link.getAttribute('href') === `#${currentId}`) {
        link.classList.add('active');
      }
    });
  });

  /* ─── 2. KPI NUMBER TICKER ANIMATION ────────────────────────────────── */
  const kpiCards = document.querySelectorAll('.kpi-card');
  let animated = false;

  const animateCounters = () => {
    if (animated) return;
    animated = true;

    kpiCards.forEach(card => {
      const numberEl = card.querySelector('.kpi-number');
      if (!numberEl) return;

      const rawTarget = numberEl.getAttribute('data-target');
      if (!rawTarget) return;

      const target = parseFloat(rawTarget);
      const isRevenue = rawTarget === '13591643';
      const isOrders = rawTarget === '99441';
      const isAOV = rawTarget === '136.68';
      const isFulfillment = rawTarget === '97';
      const isLate = rawTarget === '6.8';
      const isRating = rawTarget === '4.09';

      const duration = 1800; // ms
      const startTime = performance.now();

      const updateCounter = (now) => {
        const elapsed = now - startTime;
        const progress = Math.min(elapsed / duration, 1);
        // Easing: easeOutExpo
        const ease = progress === 1 ? 1 : 1 - Math.pow(2, -10 * progress);
        const currentVal = target * ease;

        if (isRevenue) {
          // Format as $13.59M
          const millions = (currentVal / 1000000).toFixed(2);
          numberEl.textContent = `$${millions}M`;
        } else if (isOrders) {
          numberEl.textContent = Math.floor(currentVal).toLocaleString();
        } else if (isAOV) {
          numberEl.textContent = `$${currentVal.toFixed(2)}`;
        } else if (isFulfillment) {
          numberEl.textContent = `${currentVal.toFixed(1)}%`;
        } else if (isLate) {
          numberEl.textContent = `${currentVal.toFixed(1)}%`;
        } else if (isRating) {
          numberEl.textContent = `${currentVal.toFixed(2)}`;
        } else {
          numberEl.textContent = currentVal.toFixed(1);
        }

        if (progress < 1) {
          requestAnimationFrame(updateCounter);
        }
      };

      requestAnimationFrame(updateCounter);
    });
  };

  // Trigger when KPIs section is visible
  const kpiSection = document.getElementById('kpis');
  if (kpiSection) {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          animateCounters();
          observer.disconnect();
        }
      });
    }, { threshold: 0.25 });
    observer.observe(kpiSection);
  }

  /* ─── 3. SQL TABS SWITCHING ─────────────────────────────────────────── */
  const sqlTabs = document.querySelectorAll('.sql-tab');
  const sqlPanels = document.querySelectorAll('.sql-panel');

  sqlTabs.forEach(tab => {
    tab.addEventListener('click', () => {
      const targetTab = tab.getAttribute('data-tab');

      sqlTabs.forEach(t => t.classList.remove('active'));
      sqlPanels.forEach(p => p.classList.remove('active'));

      tab.classList.add('active');
      const targetPanel = document.getElementById(`panel-${targetTab}`);
      if (targetPanel) {
        targetPanel.classList.add('active');
      }
    });
  });

  /* ─── 4. CODE COPY TO CLIPBOARD BUTTONS ─────────────────────────────── */
  const codeBlocks = document.querySelectorAll('.code-block, .dax-code');

  codeBlocks.forEach(block => {
    const parent = block.parentElement;
    if (!parent) return;

    // Create copy button
    const copyBtn = document.createElement('button');
    copyBtn.className = 'copy-btn';
    copyBtn.innerHTML = '📋 Copy';
    copyBtn.setAttribute('title', 'Copy code to clipboard');

    parent.style.position = 'relative';
    copyBtn.style.position = 'absolute';
    copyBtn.style.top = '10px';
    copyBtn.style.right = '12px';
    copyBtn.style.padding = '0.3rem 0.65rem';
    copyBtn.style.fontSize = '0.75rem';
    copyBtn.style.fontWeight = '600';
    copyBtn.style.background = 'rgba(255, 255, 255, 0.08)';
    copyBtn.style.border = '1px solid rgba(255, 255, 255, 0.15)';
    copyBtn.style.borderRadius = '6px';
    copyBtn.style.color = '#cbd5e1';
    copyBtn.style.cursor = 'pointer';
    copyBtn.style.transition = 'all 0.2s ease';
    copyBtn.style.zIndex = '5';

    copyBtn.addEventListener('mouseenter', () => {
      copyBtn.style.background = 'rgba(139, 92, 246, 0.25)';
      copyBtn.style.borderColor = 'rgba(139, 92, 246, 0.5)';
      copyBtn.style.color = '#ffffff';
    });

    copyBtn.addEventListener('mouseleave', () => {
      if (copyBtn.textContent !== '✓ Copied!') {
        copyBtn.style.background = 'rgba(255, 255, 255, 0.08)';
        copyBtn.style.borderColor = 'rgba(255, 255, 255, 0.15)';
        copyBtn.style.color = '#cbd5e1';
      }
    });

    copyBtn.addEventListener('click', async () => {
      try {
        await navigator.clipboard.writeText(block.textContent.trim());
        copyBtn.innerHTML = '✓ Copied!';
        copyBtn.style.background = 'rgba(16, 185, 129, 0.25)';
        copyBtn.style.borderColor = '#10b981';
        copyBtn.style.color = '#34d399';

        setTimeout(() => {
          copyBtn.innerHTML = '📋 Copy';
          copyBtn.style.background = 'rgba(255, 255, 255, 0.08)';
          copyBtn.style.borderColor = 'rgba(255, 255, 255, 0.15)';
          copyBtn.style.color = '#cbd5e1';
        }, 2200);
      } catch (err) {
        console.error('Clipboard copy failed:', err);
      }
    });

    parent.appendChild(copyBtn);
  });

  /* ─── 5. LIGHTBOX MODAL FOR IMAGES ──────────────────────────────────── */
  const chartContainers = document.querySelectorAll('.insight-chart img');

  // Create modal element
  const modal = document.createElement('div');
  modal.id = 'img-modal';
  modal.style.cssText = `
    position: fixed;
    top: 0; left: 0; right: 0; bottom: 0;
    background: rgba(0, 0, 0, 0.88);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    display: none;
    align-items: center;
    justify-content: center;
    z-index: 2000;
    padding: 2rem;
    cursor: zoom-out;
    opacity: 0;
    transition: opacity 0.3s ease;
  `;

  const modalImg = document.createElement('img');
  modalImg.style.cssText = `
    max-width: 90vw;
    max-height: 85vh;
    border-radius: 12px;
    box-shadow: 0 25px 60px rgba(0,0,0,0.8), 0 0 0 1px rgba(255,255,255,0.1);
    transform: scale(0.95);
    transition: transform 0.3s ease;
  `;

  const closeHint = document.createElement('div');
  closeHint.style.cssText = `
    position: absolute;
    top: 24px;
    right: 28px;
    color: #cbd5e1;
    font-size: 1.75rem;
    font-weight: 300;
    cursor: pointer;
    line-height: 1;
  `;
  closeHint.innerHTML = '&times;';

  modal.appendChild(modalImg);
  modal.appendChild(closeHint);
  document.body.appendChild(modal);

  chartContainers.forEach(img => {
    img.style.cursor = 'zoom-in';
    img.addEventListener('click', () => {
      modalImg.src = img.src;
      modalImg.alt = img.alt;
      modal.style.display = 'flex';
      requestAnimationFrame(() => {
        modal.style.opacity = '1';
        modalImg.style.transform = 'scale(1)';
      });
    });
  });

  const closeModal = () => {
    modal.style.opacity = '0';
    modalImg.style.transform = 'scale(0.95)';
    setTimeout(() => {
      modal.style.display = 'none';
    }, 300);
  };

  modal.addEventListener('click', closeModal);
  closeHint.addEventListener('click', closeModal);
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && modal.style.display === 'flex') {
      closeModal();
    }
  });

  /* ─── 6. INTERACTIVE ERD NODE HIGHLIGHTING ──────────────────────────── */
  const erdNodes = document.querySelectorAll('.erd-node');
  erdNodes.forEach(node => {
    node.addEventListener('click', () => {
      const nodeName = node.querySelector('.erd-node-name')?.textContent || '';
      // Find matching row in schema table
      const rows = document.querySelectorAll('.rel-row');
      rows.forEach(r => {
        r.style.background = '';
        if (r.textContent.toLowerCase().includes(nodeName.toLowerCase().replace('_', ''))) {
          r.style.background = 'rgba(139, 92, 246, 0.2)';
          r.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
          setTimeout(() => {
            r.style.background = '';
          }, 2000);
        }
      });
    });
  });

});
