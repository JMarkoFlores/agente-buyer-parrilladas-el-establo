import {
  aPayloadCaptacion,
  validarFormularioCaptacion,
  type CampoFormulario,
  type ErroresFormulario,
  type FormularioCaptacion,
} from '../app/domain/models/formulario-captacion.model';
import { API_BASE, leerOrigen, obtenerTokens } from './visitante';

const ENDPOINT = (import.meta.env.PUBLIC_CAPTACION_ENDPOINT ?? `${API_BASE}/api/landing/registros`).trim();
const CAMPOS: ReadonlyArray<CampoFormulario> = [
  'nombres',
  'apellidos',
  'telefono',
  'email',
  'fechaNacimiento',
  'idProductoFavorito',
  'aceptaPoliticaDatos',
  'aceptaMarketing',
];

function texto(datos: FormData, campo: CampoFormulario): string {
  return String(datos.get(campo) ?? '').trim();
}

function leerFormulario(form: HTMLFormElement): FormularioCaptacion {
  const datos = new FormData(form);

  return {
    nombres: texto(datos, 'nombres'),
    apellidos: texto(datos, 'apellidos'),
    telefono: texto(datos, 'telefono'),
    email: texto(datos, 'email'),
    fechaNacimiento: texto(datos, 'fechaNacimiento'),
    idProductoFavorito: texto(datos, 'idProductoFavorito'),
    aceptaPoliticaDatos: datos.get('aceptaPoliticaDatos') !== null,
    aceptaMarketing: datos.get('aceptaMarketing') !== null,
  };
}

function pintarErrores(form: HTMLFormElement, errores: ErroresFormulario): void {
  form.querySelectorAll<HTMLElement>('[data-error]').forEach((nodo) => {
    const campo = nodo.dataset.error as CampoFormulario | undefined;
    const mensaje = campo ? errores[campo] ?? '' : '';
    nodo.textContent = mensaje;
    nodo.hidden = mensaje === '';
  });

  for (const campo of CAMPOS) {
    form.querySelectorAll<HTMLElement>(`[name="${campo}"]`).forEach((control) => {
      if (errores[campo]) {
        control.setAttribute('aria-invalid', 'true');
      } else {
        control.removeAttribute('aria-invalid');
      }
    });
  }
}

function mostrarMensaje(form: HTMLFormElement, mensaje: string): void {
  const estado = form.querySelector<HTMLElement>('[data-estado]');

  if (estado) {
    estado.textContent = mensaje;
    estado.hidden = mensaje === '';
  }
}

/** Carga dinámica del catálogo de platos favoritos desde la base de datos SQL Server */
async function cargarPlatosFavoritos(form: HTMLFormElement): Promise<void> {
  const select = form.querySelector<HTMLSelectElement>('select[name="idProductoFavorito"]');
  if (!select) return;

  try {
    const respuesta = await fetch(`${API_BASE}/api/landing/platos-favoritos`);
    if (respuesta.ok) {
      const resJson = await respuesta.json();
      if (resJson?.data && Array.isArray(resJson.data) && resJson.data.length > 0) {
        select.innerHTML = '<option value="">Aún no lo sé</option>';
        for (const plato of resJson.data) {
          const opt = document.createElement('option');
          opt.value = plato.nombre;
          const detalle = plato.grupo_comercial ? ` (${plato.categoria} · ${plato.grupo_comercial})` : ` (${plato.categoria})`;
          opt.textContent = `${plato.nombre}${detalle} - desde S/ ${Number(plato.precio_desde).toFixed(2)}`;
          select.appendChild(opt);
        }
      }
    }
  } catch (error) {
    console.debug('Usando platos estáticos como respaldo:', error);
  }
}

function iniciar(): void {
  const form = document.querySelector<HTMLFormElement>('[data-formulario-captacion]');

  if (!form) {
    return;
  }

  // Cargar platos favoritos desde SQL Server
  cargarPlatosFavoritos(form);

  const boton = form.querySelector<HTMLButtonElement>('[type="submit"]');
  const aviso = form.querySelector<HTMLElement>('[data-aviso-endpoint]');
  const exito = document.querySelector<HTMLElement>('[data-exito]');

  if (!ENDPOINT && boton) {
    boton.disabled = true;
    boton.textContent = 'Formulario no disponible';
    if (aviso) {
      aviso.hidden = false;
    }
    return;
  }

  form.addEventListener('input', (evento) => {
    const control = evento.target as HTMLElement | null;
    const campo = control?.getAttribute('name') as CampoFormulario | null;

    if (!campo) {
      return;
    }

    control?.removeAttribute('aria-invalid');
    const error = form.querySelector<HTMLElement>(`[data-error="${campo}"]`);
    if (error) {
      error.textContent = '';
      error.hidden = true;
    }
  });

  form.addEventListener('submit', async (evento) => {
    evento.preventDefault();

    const trampa = form.querySelector<HTMLInputElement>('[name="website"]');
    if (trampa?.value) {
      form.hidden = true;
      if (exito) {
        exito.hidden = false;
      }
      return;
    }

    const datos = leerFormulario(form);
    const { valido, errores } = validarFormularioCaptacion(datos);

    pintarErrores(form, errores);

    if (!valido) {
      mostrarMensaje(form, 'Revisa los campos marcados.');
      form.querySelector<HTMLElement>('[aria-invalid="true"]')?.focus();
      return;
    }

    if (!boton) {
      return;
    }

    boton.disabled = true;
    const etiqueta = boton.textContent;
    boton.textContent = 'Enviando…';
    mostrarMensaje(form, '');

    try {
      const respuesta = await fetch(ENDPOINT, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(aPayloadCaptacion(datos, obtenerTokens(), leerOrigen())),
      });

      if (!respuesta.ok) {
        throw new Error(`HTTP ${respuesta.status}`);
      }

      form.hidden = true;
      if (exito) {
        exito.hidden = false;
        exito.focus();
      }
    } catch (error) {
      console.error('No se pudo enviar el formulario de captación', error);
      mostrarMensaje(
        form,
        'No pudimos registrar tus datos. Inténtalo otra vez o escríbenos por WhatsApp.',
      );
      boton.disabled = false;
      boton.textContent = etiqueta;
    }
  });
}

iniciar();
