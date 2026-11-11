/**
 * Lógica del Dashboard Web para el Agente Inteligente BUYER — Parrilladas El Establo.
 */

// Utilidad para obtener la clave de administración desde sessionStorage
function getAdminKey() {
  return sessionStorage.getItem("buyer_admin_key") || "";
}

function guardarAdminKey() {
  const input = document.getElementById("input-admin-key");
  const val = input.value.trim();
  if (val) {
    sessionStorage.setItem("buyer_admin_key", val);
    actualizarStatusAdminKey();
    const modalEl = document.getElementById("modalAdminKey");
    const modal = bootstrap.Modal.getInstance(modalEl);
    if (modal) modal.hide();
    mostrarAlerta("Clave administrativa almacenada para esta sesión.", "success");
  } else {
    sessionStorage.removeItem("buyer_admin_key");
    actualizarStatusAdminKey();
  }
}

function actualizarStatusAdminKey() {
  const key = getAdminKey();
  const label = document.getElementById("admin-key-status");
  if (key) {
    label.innerHTML = '<span class="text-success"><i class="bi bi-shield-check me-1"></i>Admin Activo</span>';
  } else {
    label.innerText = "Clave Admin";
  }
}

function mostrarAlerta(mensaje, tipo = "info") {
  const container = document.getElementById("alert-container");
  const alertId = "alert-" + Date.now();
  const icon = tipo === "success" ? "check-circle" : tipo === "danger" ? "exclamation-triangle" : "info-circle";
  
  container.innerHTML = `
    <div id="${alertId}" class="alert alert-${tipo} alert-dismissible fade show shadow-sm" role="alert">
      <i class="bi bi-${icon} me-2"></i>${mensaje}
      <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
  `;

  setTimeout(() => {
    const el = document.getElementById(alertId);
    if (el) {
      const bsAlert = bootstrap.Alert.getOrCreateInstance(el);
      if (bsAlert) bsAlert.close();
    }
  }, 7000);
}

// -----------------------------------------------------------------------------
// 1. CARGA DEL RESUMEN GENERAL (KPIs y Estado)
// -----------------------------------------------------------------------------
async function cargarResumen() {
  try {
    const res = await fetch("/api/dashboard/resumen");
    const json = await res.json();
    if (!json.success) return;

    const data = json.data;

    // Publicaciones Facebook
    const fbPubs = data.publicaciones.facebook;
    document.getElementById("kpi-fb-posts").innerText = fbPubs.total;
    document.getElementById("badge-fb-reales").innerText = `${fbPubs.reales} reales`;
    document.getElementById("badge-fb-demo").innerText = `${fbPubs.demo} demo`;

    // Publicaciones Instagram
    const igPubs = data.publicaciones.instagram;
    document.getElementById("kpi-ig-posts").innerText = igPubs.total;
    document.getElementById("badge-ig-reales").innerText = `${igPubs.reales} reales`;
    document.getElementById("badge-ig-demo").innerText = `${igPubs.demo} demo`;

    // Comentarios
    const coms = data.comentarios;
    document.getElementById("kpi-comentarios").innerText = coms.total;
    document.getElementById("badge-com-reales").innerText = `${coms.reales} reales`;
    document.getElementById("badge-com-demo").innerText = `${coms.demo} demo`;

    // BUYERS
    const buyers = data.buyers;
    document.getElementById("kpi-buyers").innerText = buyers.total;
    document.getElementById("badge-buyers-reales").innerText = `${buyers.reales} reales`;
    document.getElementById("badge-buyers-demo").innerText = `${buyers.demo} demo`;

    // Likes
    document.getElementById("kpi-likes-fb").innerText = data.reacciones_likes.facebook;
    document.getElementById("kpi-likes-ig").innerText = data.reacciones_likes.instagram;
    document.getElementById("kpi-likes-total").innerText = data.reacciones_likes.total;

    // Última sinc
    const ultima = data.ultima_sincronizacion;
    if (ultima && ultima.fecha) {
      const dt = new Date(ultima.fecha);
      document.getElementById("ultima-sync-hora").innerText = `Última sinc: ${dt.toLocaleString()}`;
    } else {
      document.getElementById("ultima-sync-hora").innerText = "Sin sincronizaciones registradas";
    }

    // Estado agentes
    const fbStatus = data.estado_agentes.facebook || {};
    const badgeFb = document.getElementById("status-badge-fb");
    if (fbStatus.conectado) {
      badgeFb.className = "badge bg-success";
      badgeFb.innerText = "Conectado";
      document.getElementById("status-desc-fb").innerText = "Meta Graph API v27.0 OK";
    } else {
      badgeFb.className = "badge bg-danger";
      badgeFb.innerText = "Desconectado";
      document.getElementById("status-desc-fb").innerText = fbStatus.mensaje || "Error de credenciales";
    }

    const igStatus = data.estado_agentes.instagram || {};
    const badgeIg = document.getElementById("status-badge-ig");
    if (igStatus.conectado) {
      badgeIg.className = "badge bg-success";
      badgeIg.innerText = "Conectado";
      document.getElementById("status-desc-ig").innerText = "Instagram Graph API v27.0 OK";
    } else {
      badgeIg.className = "badge bg-danger";
      badgeIg.innerText = "Desconectado";
      document.getElementById("status-desc-ig").innerText = igStatus.mensaje || "Error de credenciales";
    }

    const scheduler = data.estado_agentes.scheduler || {};
    const badgeScheduler = document.getElementById("badge-scheduler-nav");
    const badgeCoord = document.getElementById("status-badge-coord");
    if (scheduler.scheduler_activo) {
      badgeScheduler.className = "badge bg-success";
      badgeScheduler.innerHTML = `<i class="bi bi-clock-history me-1"></i>Scheduler: Activo (${scheduler.intervalo_minutos}m)`;
      badgeCoord.className = "badge bg-success";
      badgeCoord.innerText = "Automatizado";
      document.getElementById("status-desc-coord").innerText = `Sincroniza cada ${scheduler.intervalo_minutos} min`;
    } else {
      badgeScheduler.className = "badge bg-warning text-dark";
      badgeScheduler.innerHTML = `<i class="bi bi-pause-circle me-1"></i>Scheduler: Desactivado`;
      badgeCoord.className = "badge bg-secondary";
      badgeCoord.innerText = "Manual";
      document.getElementById("status-desc-coord").innerText = "Listo para disparos manuales";
    }

  } catch (err) {
    console.error("Error al cargar resumen:", err);
  }
}

// -----------------------------------------------------------------------------
// 2. CARGA DE PUBLICACIONES FACEBOOK
// -----------------------------------------------------------------------------
async function cargarFacebookPosts() {
  try {
    const res = await fetch("/api/facebook/publicaciones?limit=50");
    const json = await res.json();
    const tbody = document.getElementById("tbody-facebook");
    if (!json.success || !json.data || json.data.length === 0) {
      tbody.innerHTML = `<tr><td colspan="7" class="text-center py-4 text-muted">No se registraron publicaciones de Facebook.</td></tr>`;
      return;
    }

    tbody.innerHTML = json.data.map(p => {
      const fecha = p.fecha_publicacion ? new Date(p.fecha_publicacion).toLocaleString() : "-";
      const esDemo = p.origen === "DEMO";
      const badgeOrigen = esDemo 
        ? `<span class="badge badge-origin-DEMO">DEMO</span>` 
        : `<span class="badge badge-origin-META_REAL">META REAL</span>`;
      const urlLink = p.url_publicacion 
        ? `<a href="${p.url_publicacion}" target="_blank" class="btn btn-outline-primary btn-sm"><i class="bi bi-box-arrow-up-right"></i> Ver</a>` 
        : "-";

      return `
        <tr>
          <td>${badgeOrigen}</td>
          <td><code class="text-primary">${p.meta_post_id}</code></td>
          <td class="text-break" style="max-width: 320px;">${p.texto || '<span class="text-muted">(Sin texto)</span>'}</td>
          <td><small class="text-muted">${fecha}</small></td>
          <td>${urlLink}</td>
          <td><span class="badge bg-light text-dark border">Consultadas en corte</span></td>
          <td><span class="badge bg-success">${p.estado}</span></td>
        </tr>
      `;
    }).join("");
  } catch (err) {
    console.error("Error al cargar publicaciones Facebook:", err);
  }
}

// -----------------------------------------------------------------------------
// 3. CARGA DE PUBLICACIONES INSTAGRAM
// -----------------------------------------------------------------------------
async function cargarInstagramPosts() {
  try {
    const res = await fetch("/api/instagram/publicaciones?limit=50");
    const json = await res.json();
    const tbody = document.getElementById("tbody-instagram");
    if (!json.success || !json.data || json.data.length === 0) {
      tbody.innerHTML = `<tr><td colspan="7" class="text-center py-4 text-muted">No se registraron publicaciones de Instagram.</td></tr>`;
      return;
    }

    tbody.innerHTML = json.data.map(p => {
      const fecha = p.fecha_publicacion ? new Date(p.fecha_publicacion).toLocaleString() : "-";
      const esDemo = p.origen === "DEMO";
      const badgeOrigen = esDemo 
        ? `<span class="badge badge-origin-DEMO">DEMO</span>` 
        : `<span class="badge badge-origin-META_REAL">META REAL</span>`;
      const urlLink = p.url_publicacion 
        ? `<a href="${p.url_publicacion}" target="_blank" class="btn btn-outline-danger btn-sm"><i class="bi bi-box-arrow-up-right"></i> Ver</a>` 
        : "-";

      return `
        <tr>
          <td>${badgeOrigen}</td>
          <td><code class="text-danger">${p.meta_post_id}</code></td>
          <td class="text-break" style="max-width: 320px;">${p.texto || '<span class="text-muted">(Sin caption)</span>'}</td>
          <td><small class="text-muted">${fecha}</small></td>
          <td>${urlLink}</td>
          <td><span class="badge bg-light text-dark border">Likes y comments activos</span></td>
          <td><span class="badge bg-success">${p.estado}</span></td>
        </tr>
      `;
    }).join("");
  } catch (err) {
    console.error("Error al cargar publicaciones Instagram:", err);
  }
}

// -----------------------------------------------------------------------------
// 4. CARGA DE COMENTARIOS Y CLASIFICACIÓN
// -----------------------------------------------------------------------------
async function cargarComentarios() {
  try {
    const plat = document.getElementById("filtro-com-plat").value;
    const intencion = document.getElementById("filtro-com-intencion").value;

    let url = "/api/dashboard/comentarios?limit=200";
    if (plat) url += `&plataforma=${encodeURIComponent(plat)}`;
    if (intencion) url += `&intencion=${encodeURIComponent(intencion)}`;

    const res = await fetch(url);
    const json = await res.json();
    const tbody = document.getElementById("tbody-comentarios");

    if (!json.success || !json.items || json.items.length === 0) {
      tbody.innerHTML = `<tr><td colspan="9" class="text-center py-4 text-muted">No se encontraron comentarios que coincidan con los filtros.</td></tr>`;
      document.getElementById("total-comentarios-badge").innerText = "0 comentarios";
      return;
    }

    document.getElementById("total-comentarios-badge").innerText = `${json.total} comentarios`;

    tbody.innerHTML = json.items.map(c => {
      const fecha = c.fecha_interaccion ? new Date(c.fecha_interaccion).toLocaleString() : "-";
      const esDemo = c.origen === "DEMO";
      const badgeOrigen = esDemo 
        ? `<span class="badge badge-origin-DEMO">DEMO</span>` 
        : `<span class="badge badge-origin-META_REAL">META REAL</span>`;
      const badgePlat = c.plataforma === "FACEBOOK" 
        ? `<span class="badge bg-primary"><i class="bi bi-facebook me-1"></i>FB</span>` 
        : `<span class="badge bg-danger"><i class="bi bi-instagram me-1"></i>IG</span>`;
      const badgeIntent = `<span class="badge badge-intent-${c.clasificacion_intencion}">${c.clasificacion_intencion}</span>`;
      const buyerInfo = c.id_buyer 
        ? `<span class="badge bg-success"><i class="bi bi-person-check-fill me-1"></i>ID ${c.id_buyer}</span>` 
        : `<span class="badge bg-light text-muted border">No asociado</span>`;

      return `
        <tr>
          <td>${badgePlat}</td>
          <td>${badgeOrigen}</td>
          <td><code class="fs-7">${c.meta_post_id ? c.meta_post_id.slice(-10) : '-'}</code></td>
          <td class="fw-semibold">${c.nombre_usuario || 'Anónimo'}</td>
          <td class="text-break" style="max-width: 300px;">"${c.texto || ''}"</td>
          <td><small class="text-muted">${fecha}</small></td>
          <td><span class="badge bg-light text-dark border fs-8">${c.tipo}</span></td>
          <td>${buyerInfo}</td>
          <td>${badgeIntent}</td>
        </tr>
      `;
    }).join("");
  } catch (err) {
    console.error("Error al cargar comentarios:", err);
  }
}

// -----------------------------------------------------------------------------
// 5. CARGA DE BUYERS
// -----------------------------------------------------------------------------
async function cargarBuyers() {
  try {
    const res = await fetch("/api/dashboard/buyers?limit=200");
    const json = await res.json();
    const tbody = document.getElementById("tbody-buyers");

    if (!json.success || !json.items || json.items.length === 0) {
      tbody.innerHTML = `<tr><td colspan="8" class="text-center py-4 text-muted">No se registraron BUYERS.</td></tr>`;
      document.getElementById("total-buyers-badge").innerText = "0 BUYERS";
      return;
    }

    document.getElementById("total-buyers-badge").innerText = `${json.total} BUYERS`;

    tbody.innerHTML = json.items.map(b => {
      const fecha = b.fecha_primer_contacto ? new Date(b.fecha_primer_contacto).toLocaleString() : "-";
      const esDemo = b.origen === "DEMO";
      const badgeOrigen = esDemo 
        ? `<span class="badge badge-origin-DEMO">DEMO</span>` 
        : `<span class="badge badge-origin-META_REAL">META REAL</span>`;
      const badgePlat = b.plataforma_codigo === "FACEBOOK" 
        ? `<span class="badge bg-primary">Facebook</span>` 
        : b.plataforma_codigo === "INSTAGRAM" 
        ? `<span class="badge bg-danger">Instagram</span>` 
        : `<span class="badge bg-secondary">${b.plataforma_codigo}</span>`;

      const estadoBadge = b.estado === "CONVERTIDO_LEAD" 
        ? `<span class="badge bg-success">CONVERTIDO_LEAD</span>` 
        : `<span class="badge bg-info text-dark">BUYER</span>`;

      return `
        <tr>
          <td><span class="badge bg-dark fs-7">#${b.id_buyer}</span></td>
          <td>${badgeOrigen}</td>
          <td>${badgePlat}</td>
          <td><code class="fs-7">${b.meta_post_id_origen ? b.meta_post_id_origen.slice(-10) : (b.id_publicacion_origen || '-')}</code></td>
          <td><code class="text-muted">${b.referencia_externa_enmascarada || '-'}</code></td>
          <td><small class="text-muted">${fecha}</small></td>
          <td>${estadoBadge}</td>
          <td><span class="badge bg-light text-dark border">${b.total_interacciones} interacciones</span></td>
        </tr>
      `;
    }).join("");
  } catch (err) {
    console.error("Error al cargar buyers:", err);
  }
}

// -----------------------------------------------------------------------------
// 6. CARGA DE AUDITORÍA DE AGENTES (ADMIN)
// -----------------------------------------------------------------------------
async function cargarActividadAgentes() {
  try {
    const res = await fetch("/api/agentes/actividad?limit=50");
    const json = await res.json();
    const tbody = document.getElementById("tbody-auditoria");

    if (!json.success || !json.items || json.items.length === 0) {
      tbody.innerHTML = `<tr><td colspan="5" class="text-center py-3 text-muted">Sin registros de auditoría recientes.</td></tr>`;
      return;
    }

    tbody.innerHTML = json.items.map(a => {
      const fecha = a.fecha_ejecucion ? new Date(a.fecha_ejecucion).toLocaleString() : "-";
      const badgeRes = a.resultado === "EXITOSO" 
        ? `<span class="badge bg-success">EXITOSO</span>` 
        : `<span class="badge bg-danger">${a.resultado}</span>`;

      return `
        <tr>
          <td><small class="text-muted">${fecha}</small></td>
          <td><strong>${a.nombre_agente}</strong></td>
          <td><code>${a.accion}</code></td>
          <td>${badgeRes}</td>
          <td class="text-break" style="max-width: 400px;"><small>${a.detalle || '-'}</small></td>
        </tr>
      `;
    }).join("");
  } catch (err) {
    console.error("Error al cargar auditoría:", err);
  }
}

// -----------------------------------------------------------------------------
// ACCIÓN ADMINISTRATIVA: SINCRONIZAR
// -----------------------------------------------------------------------------
async function sincronizarPlataforma(plataforma) {
  const adminKey = getAdminKey();
  if (!adminKey) {
    const modalEl = new bootstrap.Modal(document.getElementById("modalAdminKey"));
    modalEl.show();
    mostrarAlerta("Se requiere ingresar la clave ADMIN_API_KEY para ejecutar sincronizaciones.", "warning");
    return;
  }

  mostrarAlerta(`Iniciando sincronización de ${plataforma}... Por favor espere.`, "info");

  try {
    const res = await fetch("/api/agentes/sincronizar", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-Admin-Token": adminKey,
      },
      body: JSON.stringify({ plataforma: plataforma }),
    });

    const json = await res.json();

    if (res.status === 401) {
      sessionStorage.removeItem("buyer_admin_key");
      actualizarStatusAdminKey();
      mostrarAlerta("Clave ADMIN_API_KEY no válida o rechazada por el servidor.", "danger");
      return;
    }

    if (res.status === 409) {
      mostrarAlerta(json.error || "Existe otra sincronización en curso.", "warning");
      return;
    }

    if (json.success) {
      mostrarAlerta(`Sincronización de ${plataforma} completada con éxito.`, "success");
      cargarTodoElDashboard();
    } else {
      mostrarAlerta(`Fallo en la sincronización: ${json.error || 'Error desconocido'}`, "danger");
      cargarTodoElDashboard();
    }
  } catch (err) {
    console.error("Error al sincronizar:", err);
    mostrarAlerta(`Error al comunicarse con el servidor: ${err.message}`, "danger");
  }
}

// -----------------------------------------------------------------------------
// CARGA INICIAL
// -----------------------------------------------------------------------------
function cargarTodoElDashboard() {
  actualizarStatusAdminKey();
  cargarResumen();
  cargarFacebookPosts();
  cargarInstagramPosts();
  cargarComentarios();
  cargarBuyers();
  cargarActividadAgentes();
}

document.addEventListener("DOMContentLoaded", () => {
  cargarTodoElDashboard();
});
