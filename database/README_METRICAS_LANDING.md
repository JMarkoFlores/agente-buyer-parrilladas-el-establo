# Métricas Oficiales de Landing Page y Carta Digital — Parrilladas El Establo

Documentación técnica y diccionario de datos de las 7 métricas oficiales del canal **Landing Page** y **Carta Digital**, calculadas como **Fuente Única de Verdad** directamente desde Microsoft SQL Server (`buyer`).

---

## 1. Resumen Ejecutivo de Métricas (Consolidadas y Reales)

| # | Métrica Oficial | Valor Actual | Tabla Origen SQL Server | Definición y Regla de Negocio |
|---|---|---|---|---|
| 1 | **Visitas Landing** | 25 | `dbo.visita_web` | Total de sesiones HTTP registradas en la landing page (`/` o `/carta/`). Una sesión agrupa la interacción continua de un navegador. |
| 2 | **Visitantes Únicos** | 12 | `dbo.visitante_web` | Cantidad de navegadores web únicos identificados mediante UUID determinista almacenado en `localStorage`. Representa visitantes anónimos distintos. |
| 3 | **Visualizaciones de Carta** | 13 | `dbo.evento_web` (`VISTA_CARTA`) | Total de eventos de carga o navegación a `/carta/` registrados. Cuenta con ventana de deduplicación idempotente de 4 segundos. |
| 4 | **Visitantes Carta** | 8 | `dbo.visitante_web` / `dbo.visita_web` / `dbo.evento_web` | Cantidad de navegadores únicos que abrieron `/carta/` al menos una vez en el período histórico. |
| 5 | **Clics a Carta** | 8 | `dbo.evento_web` (`CLIC_CARTA` + `VER_MENU`) | Interacciones comerciales explícitas donde el visitante presionó botones CTA hacia la carta digital (3 `CLIC_CARTA` + 3 `VER_MENU` demo + 2 reales). |
| 6 | **Formularios Enviados** | 3 | `dbo.formulario_captacion` | Total de envíos exitosos del formulario de registro persistidos en la base transaccional (1 de Carlos Mendoza + 2 de Gian Franco Samana). |
| 7 | **LEADS Reales** | 2 | `dbo.lead_conversion` / `dbo.persona` | Cantidad de **personas físicas únicas** (`COUNT(DISTINCT id_persona)`) convertidas exitosamente a la fase comercial LEAD. |

---

## 2. Reconciliación: Formularios Enviados (3) vs LEADS Únicos (2)

### Origen de la diferencia
- Envíos de formulario registrados (`dbo.formulario_captacion`): **3 envíos**.
  - ID Formulario 4: **Carlos Mendoza Rios** (`987654321`, `carlos.mendoza@test.com`) el `2026-11-12 03:57:22`.
  - ID Formulario 7: **Gian Franco Samana** (`964253176`, `jeanmarko25@outlook.com`) el `2026-11-12 04:29:12` (Plato favorito: Bife angosto).
  - ID Formulario 11: **Gian Franco Samana** (`964253176`, `jeanmarko25@outlook.com`) el `2026-11-12 13:47:13` (Plato favorito: Mollejitas a la parrilla).
- Personas físicas únicas convertidas (`COUNT(DISTINCT id_persona)`): **2 LEADS**.
  - **Persona 5**: Carlos Mendoza Rios.
  - **Persona 7**: Gian Franco Samana.

### Regla Canónica de Negocio
> **Regla de Deduplicación de LEADS:** Si una misma persona envía el formulario de captación más de una vez (ej. para actualizar su plato favorito o realizar una nueva consulta), cada envío se registra en `dbo.formulario_captacion` con fines de trazabilidad histórica, pero la persona se identifica por su teléfono/email canónico en `dbo.persona`. Por tanto, el número de **LEADS convertidos representa personas físicas únicas** (2 personas), garantizando que no se inflen artificialmente las cifras comerciales.

---

## 3. Consultas SQL Server Verificables en CloudBeaver

Las siguientes consultas SQL son ejecutables directamente en **CloudBeaver** (`http://localhost:8978`) o mediante `sqlcmd`:

```sql
-- 1. Visitas a la Landing (25)
SELECT COUNT(*) AS visitas_landing FROM buyer.dbo.visita_web;

-- 2. Visitantes Únicos Aproximados (12)
SELECT COUNT(*) AS visitantes_landing FROM buyer.dbo.visitante_web;

-- 3. Visualizaciones de Carta (13)
SELECT COUNT(*) AS visualizaciones_carta 
FROM buyer.dbo.evento_web 
WHERE tipo = 'VISTA_CARTA';

-- 4. Visitantes Únicos que Vieron la Carta (8)
SELECT COUNT(DISTINCT v.id_visitante) AS visitantes_carta
FROM buyer.dbo.visita_web v
INNER JOIN buyer.dbo.evento_web e ON v.id_visita = e.id_visita
WHERE e.tipo = 'VISTA_CARTA';

-- 5. Formularios Enviados (3 reales)
SELECT COUNT(*) AS formularios_reales
FROM buyer.dbo.formulario_captacion f
INNER JOIN buyer.dbo.persona p ON f.id_persona = p.id_persona
WHERE p.email NOT LIKE '%@example.test';

-- 6. LEADS Únicos Convertidos (2 reales)
SELECT COUNT(DISTINCT lc.id_persona) AS leads_unicos_reales
FROM buyer.dbo.lead_conversion lc
INNER JOIN buyer.dbo.persona p ON lc.id_persona = p.id_persona
WHERE p.email NOT LIKE '%@example.test';

-- 7. Tasa de Conversión Landing (16.67%)
-- Fórmula: (LEADS únicos / Visitantes únicos) * 100 = (2 / 12) * 100 = 16.67%
SELECT 
    CAST(ROUND((CAST(COUNT(DISTINCT lc.id_persona) AS FLOAT) / 
    CAST((SELECT COUNT(*) FROM buyer.dbo.visitante_web) AS FLOAT)) * 100.0, 2) AS NUMERIC(5,2)) AS tasa_conversion_landing
FROM buyer.dbo.lead_conversion lc
INNER JOIN buyer.dbo.persona p ON lc.id_persona = p.id_persona
WHERE p.email NOT LIKE '%@example.test';
```

---

## 4. Endpoints Backend Homologados

1. **`GET /api/dashboard/resumen`**: Retorna el bloque unificado `landing` consumido por el Dashboard General.
2. **`GET /api/landing/estadisticas`**: Retorna el desglose analítico completo con filtros por período (`hoy`, `7dias`, `30dias`, `todo`), visitas diarias y formularios recientes.
Ambos endpoints delegan en `app.services.kpi_service.KpiService.get_landing_metrics()`, garantizando consistencia absoluta (0% divergencia).
