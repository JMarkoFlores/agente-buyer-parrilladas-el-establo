import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

const mm = gsap.matchMedia();

// Sin animaciones si la persona prefiere movimiento reducido: todo queda visible.
mm.add('(prefers-reduced-motion: no-preference)', () => {
  const intro = gsap.timeline({ defaults: { ease: 'power3.out' } });

  intro
    .from('[data-hero="eyebrow"]', { y: 18, autoAlpha: 0, duration: 0.6 })
    .from('[data-hero-line]', { yPercent: 115, duration: 1, stagger: 0.1 }, '-=0.3')
    .from('[data-hero="copy"]', { y: 20, autoAlpha: 0, duration: 0.7 }, '-=0.65')
    .from('[data-hero="cta"]', { y: 16, autoAlpha: 0, duration: 0.6 }, '-=0.5')
    .from('[data-hero="stat"]', { y: 14, autoAlpha: 0, duration: 0.5, stagger: 0.07 }, '-=0.45')
    .from('[data-hero-media]', { autoAlpha: 0, scale: 1.06, duration: 1.3, ease: 'expo.out' }, 0.1);

  // Parallax suave de la foto del hero.
  gsap.to('[data-hero-photo]', {
    yPercent: 6,
    ease: 'none',
    scrollTrigger: { trigger: '[data-hero]', start: 'top top', end: 'bottom top', scrub: true },
  });

  // Aparición de bloques al entrar en pantalla.
  // Ocultamos con set() una sola vez y animamos con to(): si el batch se vuelve a evaluar
  // (refresh por fuentes/imágenes), cada pasada termina en el estado visible en vez de
  // recapturar el estado oculto como destino y dejar el bloque a medias.
  const reveals = gsap.utils.toArray<HTMLElement>('[data-reveal]');
  const lineaPliegue = window.innerHeight * 0.88;

  // Solo se oculta lo que aún está por debajo del pliegue; lo que ya está visible o quedó
  // arriba (recarga a mitad de página) permanece visible.
  reveals.forEach((el) => {
    if (el.getBoundingClientRect().top >= lineaPliegue) gsap.set(el, { y: 28, autoAlpha: 0 });
  });

  ScrollTrigger.batch(reveals, {
    start: 'top 88%',
    once: true,
    onEnter: (batch) =>
      gsap.to(batch, { y: 0, autoAlpha: 1, duration: 0.75, stagger: 0.09, ease: 'power2.out', overwrite: true }),
  });

  // Banda de imagen con parallax.
  gsap.fromTo(
    '[data-band-photo]',
    { yPercent: -8 },
    {
      yPercent: 8,
      ease: 'none',
      scrollTrigger: { trigger: '[data-band]', start: 'top bottom', end: 'bottom top', scrub: true },
    },
  );

  return () => {
    // gsap.matchMedia limpia tweens y ScrollTriggers al desactivarse.
  };
});

document.fonts.ready.then(() => ScrollTrigger.refresh());
