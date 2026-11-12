# Arquitectura de Integración Multicanal — Parrilladas El Establo

Sistema Integral de Captación y Conversión de Prospectos: **Facebook, Instagram y Landing Page** sobre Microsoft SQL Server (`buyer`).

---

## 1. Visión General de la Integración

El sistema unifica tres canales comerciales bajo una misma arquitectura transaccional:
1. **Facebook**: Comentarios, reacciones e interacciones en la página oficial mediante Meta Graph API v27.0.
2. **Instagram**: Comentarios, likes e interacciones en medios comerciales de la cuenta profesional mediante Instagram Graph API.
3. **Landing Page y Carta Digital**: Visitas a la landing page Astro, visualizaciones de la carta digital de 120 platos y formularios de registro con intención gastronómica.

```
       [Facebook Graph API]            [Instagram Graph API]            [Landing Page Astro]
                 │                               │                                │
                 ▼                               ▼                                ▼
       dbo.interaccion_publicacion     dbo.interaccion_publicacion     dbo.visita_web / dbo.evento_web
                 │                               │                                │
                 └───────────────────────┬───────────────────────┘
                                         ▼
                                   dbo.buyer
                                         │  (Conversión por Formulario)
                                         ▼
                                    dbo.persona
                                         │
                                         ▼
                               dbo.lead_conversion
```

---

## 2. Modelo Relacional y Entidades Clave

### A. Visitante Anónimo vs Persona Identificada
- **Visitante Anónimo (`dbo.visitante_web`)**:
  - Identificado mediante un token UUID (`token_visitante`) guardado en el navegador del cliente.
  - No representa necesariamente una persona física conocida ni posee datos de contacto (email, teléfono, nombre).
  - **Regla de Oro**: No se crean registros ficticios en `dbo.persona` para navegadores anónimos.
- **Persona Identificada (`dbo.persona`)**:
  - Se genera únicamente cuando el usuario proporciona datos verificables (nombre, teléfono, correo) al completar el formulario de captación.
  - La clave natural de deduplicación es el número de teléfono celular (9 dígitos) y/o correo electrónico.

### B. Prospecto BUYER (`dbo.buyer`)
- Un prospecto BUYER representa un punto de contacto calificado en una plataforma específica (`id_plataforma_origen`).
- Posee trazabilidad de origen (`referencia_externa`):
  - Canal Meta: ID externo del comentario o usuario de Facebook/Instagram.
  - Canal Landing Page: Prefijo seguro `WEB_{token_visitante}`.
- Relación con Persona: Cuando el BUYER completa el formulario, el registro `dbo.buyer` se vincula a su `id_persona` canónica y su estado pasa a `CONVERTIDO_LEAD`.

---

## 3. Catálogo de Plataformas Unificado (`dbo.plataforma`)

| `id_plataforma` | `codigo` | `nombre` | Rol en el Sistema |
|---|---|---|---|
| 1 | `FACEBOOK` | Facebook | Interacciones oficiales Meta Page |
| 2 | `INSTAGRAM` | Instagram | Interacciones en Instagram Business Media |
| 3 | `LANDING_PAGE` | Landing Page | Prospectos web y captaciones desde la landing Astro |
| 4 | `WHATSAPP` | WhatsApp | Canal de atención directa (reservado) |

---

## 4. Deduplicación y Conteo Canónico

### ¿Por qué Landing Page muestra 2 LEADS y BUYERS muestra 3 filas?
- **En `dbo.buyer`**:
  - Fila 51: Carlos Mendoza Rios (Landing Page - Formulario #4).
  - Fila 58: Gian Franco Samana (Landing Page - Formulario #7, primer envío).
  - Fila 64: Gian Franco Samana (Landing Page - Formulario #11, segundo envío con nuevo plato).
  - Total filas BUYER Landing = **3 registros de contacto**.
- **En `dbo.persona` y `dbo.lead_conversion`**:
  - Persona 5: Carlos Mendoza Rios (1 LEAD).
  - Persona 7: Gian Franco Samana (1 LEAD).
  - Total LEADS reales convertidos = **2 personas físicas únicas**.

---

## 5. Indicadores Estratégicos de Captación (KPIs)

### KPI 1: Costo por Anuncio (CPA / Costo por LEAD)
- **Fórmula**: `Gasto en anuncios / Número de LEADS obtenidos`
- **Tipo de Dato**: `MIXTO` (Gasto simulado académico / LEADS reales de SQL Server)
- **Numerador**: S/ 356.00 (Presupuesto académico en `dbo.gasto_anuncio_diario` etiquetado como `SIMULADO_ACADEMICO`).
- **Denominador**: 0 LEADS con procedencia atribuible comprobada a anuncios pagados.
- **Resultado Actual**: `"No calculable — Sin LEADS atribuibles a anuncios"`
- **Regla Ética**: Conforme a las directrices de integridad, no se fabrican conversiones artificiales para forzar un resultado numérico ficticio.

### KPI 2: Tasa de Interés en Menú Digital (TMD)
- **Fórmula**: `(Visitantes Carta / Visitantes Landing) × 100`
- **Tipo de Dato**: `REAL SQL SERVER` (100% transaccional)
- **Numerador**: 8 navegadores únicos que abrieron `/carta/`.
- **Denominador**: 12 navegadores únicos totales que visitaron la landing page.
- **Resultado Actual**: `66.67%` (8 / 12 × 100)
- **Interpretación**: 2 de cada 3 visitantes muestran interés gastronómico activo explorando la carta de 120 platos y 146 presentaciones.

### KPI 3: Tasa de Conversión BUYER a LEAD (B1)
- **Fórmula**: `(BUYERS únicos convertidos a LEAD / BUYERS únicos totales) × 100`
- **Tipo de Dato**: `REAL SQL SERVER` (100% transaccional multicanal)
- **Numerador**: 2 personas únicas convertidas a LEAD (Carlos Mendoza Rios + Gian Franco Samana).
- **Denominador**: 5 BUYERS únicos totales (3 prospectos activos de Facebook e Instagram + 2 LEADS únicos de Landing Page).
- **Resultado Actual**: `40.00%` (2 / 5 × 100)
- **Garantía Matemática**: Numerador <= Denominador siempre garantizado (40.00% <= 100%).

---

## 6. Aislamiento de Pruebas y Prevención de Contaminación

Para asegurar que las ejecuciones de pruebas (Pytest, Vitest, CI/CD) nunca alteren la base de datos de producción `buyer`:
1. **Fixture de Autouse en `conftest.py`**: Limpia cualquier registro transitorio generado por las pruebas que contenga correos de prueba (`@test.com`, `@example.com`) o nombres de prueba (`Valeria`), respetando rigurosamente el orden de claves foráneas.
2. **Teardown Inmediato en Endpoints de Landing**: `test_landing_endpoints.py` ejecuta limpieza contextual inmediata dentro de bloques `with client.application.app_context():`, garantizando que al finalizar los 120 tests la base conserva exactamente 6 personas, 11 buyers, 5 conversiones, 25 visitas y 28 eventos.
3. **Respaldo Nativo de Seguridad**: Se conserva el respaldo físico `backup_buyer_prompt19_initial.bak` fuera de los contenedores Docker para recuperación instantánea ante cualquier contingencia.

---

## 7. Identidad pública del autor del comentario

El nombre que muestra el sistema (`dbo.interaccion_publicacion.nombre_visible`) proviene del objeto `from` que devuelve Meta Graph API al consultar `/{post-id}/comments`.

### Por qué algunos comentarios quedan sin nombre

- Desde Graph API v20.0, Meta **omite el campo `from`** para comentarios de usuarios que no tienen rol en la aplicación. Solo lo devuelve para administradores o usuarios de prueba de la app.
- En la referencia oficial de `Comment` (v27.0) el campo `from` ya no figura entre los campos documentados.
- Cuando `from` no viene, el sincronizador guarda `id_usuario_externo = NULL` y `nombre_visible = NULL`, y **no crea un BUYER**: sin identificador externo estable no es posible deduplicar a la persona. Crear un BUYER por comentario generaría un prospecto distinto por cada comentario del mismo cliente.
- Instagram no presenta este problema porque el campo `username` sí se devuelve en `/{media-id}/comments`.

### Cómo habilitar el nombre en Facebook

1. Verificar el negocio en Meta Business Manager.
2. En Meta App Dashboard → **App Review → Permissions and Features**, solicitar **Business Asset User Profile Access** con **Advanced Access**.
3. Completar la revisión de la app (política de privacidad, términos y video de uso).
4. Confirmar el resultado con Graph API Explorer:

```text
GET /v27.0/{comment-id}?fields=from
```

Si devuelve `from: { id, name }`, la app ya tiene el acceso.

### Después de habilitarlo

No se requiere script de backfill: cada ciclo de sincronización vuelve a leer los comentarios de las publicaciones y `upsert_interaccion` actualiza `nombre_visible` cuando llega el nombre. En ese mismo ciclo se crea el BUYER que antes quedaba anónimo.

> Mientras el permiso no esté aprobado, la interfaz muestra `Usuario de Facebook (sin nombre público)` y ofrece el enlace a la publicación de origen para identificar al autor manualmente.

