# Parrilladas El Establo — Landing page

Landing estática para la parrillera **Parrilladas El Establo** (Trujillo, Perú).
Construida con **Astro 7** + **Tailwind CSS 4** y animaciones con **GSAP**.

## Contenido de la página

- Hero con claim, foto de parrilla y accesos a carta y reserva.
- Platos destacados con fotografía.
- Carta completa: carnes de res, cerdo, pollo, entradas, combos, ensaladas, acompañamientos, bebidas y vinos.
- Banda de imagen con parallax.
- Sección de reservas con enlace al formulario interno.
- Página `/registro` con el formulario de captación de clientes.
- Página `/privacidad` con la política de tratamiento de datos.
- Datos del local: dirección, horarios y contacto.
- Botón flotante de WhatsApp en todas las pantallas.
- Página `/creditos` con la atribución de las fotografías.

## Quickstart

Requisitos: Node.js 22.23.4 o superior y pnpm.

```bash
pnpm install        # instalar dependencias
cp .env.example .env  # definir PUBLIC_CAPTACION_ENDPOINT cuando exista el POST
pnpm dev            # servidor de desarrollo en http://localhost:4321
pnpm test           # pruebas unitarias de los modelos (vitest)
pnpm build          # generar sitio estático en dist/
pnpm preview        # servir el build localmente
```

## Formulario de captación

`/registro` recolecta nombres, apellidos, celular, correo, fecha de nacimiento,
plato favorito y los consentimientos de datos y marketing. Al enviar, hace un
`POST` en JSON a `PUBLIC_CAPTACION_ENDPOINT` con este contrato:

```json
{
  "persona": {
    "nombres": "Ana",
    "apellidos": "Pérez",
    "telefono": "912345678",
    "email": "ana@correo.com",
    "fecha_nacimiento": "1990-05-04",
    "consentimiento_datos": true,
    "consentimiento_marketing": false
  },
  "formulario": {
    "id_plataforma_origen": "LANDING_PAGE",
    "id_publicacion_origen": null,
    "producto_favorito": "Picanha · 400 g",
    "fecha_envio": "2026-11-10T15:00:00.000Z",
    "acepta_politica_datos": true,
    "acepta_marketing": false
  },
  "origen": {
    "token_visitante": "uuid (cookie establo_vid, 365 días)",
    "token_visita": "uuid (sessionStorage establo_vsid)",
    "utm_source": "facebook",
    "utm_campaign": "carta",
    "utm_content": null,
    "fbclid": null,
    "id_publicacion": null
  }
}
```

El sitio es estático: los `token_*` son opacos y el endpoint resuelve
`visitante_web`, `visita_web`, `buyer`, `persona` y `formulario_captacion`.
Si el endpoint no está configurado, el botón queda deshabilitado y se ofrece
WhatsApp. El endpoint debe aceptar CORS desde el dominio del sitio.


## Configuración pendiente

Todo lo editable vive en `src/app/domain/models/`:

| Archivo             | Qué cambiar                                                                 |
| ------------------- | --------------------------------------------------------------------------- |
| `negocio.model.ts`  | `whatsapp` (solo dígitos con código de país), dirección y horarios.           |
| `carta.model.ts`    | Categorías, platos, combos, bebidas, vinos, precios y flag `destacado`.       |

Antes de publicar, reemplaza el placeholder `51999999999` en `whatsapp` y define
`PUBLIC_CAPTACION_ENDPOINT` en `.env`.

Los precios se tomaron de la carta original del cliente (`menu_el_cuatrero.pdf`) y
cada tamaño (por ejemplo lomo de 400 g y 300 g) es un registro independiente,
igual que en la base de datos.

Las cartas originales (imágenes) están en `public/carta/` y se enlazan desde la
sección de la carta.

## Animaciones (GSAP)

Todas las animaciones viven en `src/scripts/animations.ts` (GSAP 3 + ScrollTrigger)
y se cargan desde `src/layouts/Base.astro`:

- Introducción del hero (máscaras de texto, foto y estadísticas).
- Parallax de la foto del hero y de la banda de imagen.
- Aparición al hacer scroll de los bloques marcados con `data-reveal`.

Se usa `gsap.matchMedia('(prefers-reduced-motion: no-preference)')`: si el usuario
pide movimiento reducido, no se registra ninguna animación y el contenido queda
visible de inmediato.

## Fotografías

Las fotos de stock están en `public/img/` y provienen de Wikimedia Commons
(licencias CC0, CC BY-SA 3.0 y 4.0). La atribución completa está en la página
`/creditos` (`src/pages/creditos.astro`). Si reemplazas una imagen, actualiza esa
lista.

## Estructura

```
src/
  app/domain/models/    datos del negocio y de la carta (+ tests)
  components/           Carta.astro, WhatsAppButton.astro
  layouts/Base.astro    head, fuentes, botón flotante, carga de animaciones
  pages/index.astro     la landing completa
  pages/creditos.astro  atribución de las fotografías
  scripts/animations.ts animaciones GSAP + ScrollTrigger
  styles/global.css     tokens de color y tipografía (Tailwind 4 @theme)
public/carta/           cartas en imagen
public/img/             fotografías de stock
```

## Notas

- Sin backend ni base de datos: el formulario de reserva es un enlace externo
  (Google Forms u otro) y el canal de contacto es WhatsApp (`wa.me`).
- Despliegue: `Dockerfile` multi-stage (Node + pnpm + nginx) listo para Dokploy.
  El sitio vive en <https://elestablo.giansmd.dev>.
- Las imágenes se sirven desde `/public` sin optimizar. Si el peso importa,
  muévelas a `src/assets/` y usa el componente `<Image />` de `astro:assets`.
