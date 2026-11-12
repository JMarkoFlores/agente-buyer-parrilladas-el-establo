/* VERSION FINAL CORREGIDA - 09/11/2026
   PARRILLADAS EL ESTABLO - SOLO CAPTACION BUYER
   SQL Server 2019+ | Base nueva 'buyer' | Fechas UTC | Ejecutar una vez.
   No elimina ni altera las bases anteriores.
   Un BUYER puede ser anonimo; PERSONA solo al identificar al interesado.
   La conversion BUYER->LEAD queda registrada, pero no modelamos las fases siguientes.
*/
USE master;
GO
IF DB_ID(N'buyer') IS NOT NULL
    THROW 51000, 'La base buyer ya existe. No ejecutar nuevamente ni sobrescribir.', 1;
GO
CREATE DATABASE buyer;
GO
USE buyer;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- 1. Catalogos
CREATE TABLE dbo.plataforma (
 id_plataforma int IDENTITY(1,1) PRIMARY KEY,
 codigo varchar(20) NOT NULL UNIQUE CHECK (codigo IN ('FACEBOOK','INSTAGRAM','LANDING_PAGE','WHATSAPP')),
 nombre_pagina nvarchar(150) NOT NULL,
 url_pagina nvarchar(500) NULL,
 meta_account_id varchar(100) NULL,
 activa bit NOT NULL DEFAULT 1
);
CREATE TABLE dbo.segmento_cliente (
 id_segmento int IDENTITY(1,1) PRIMARY KEY,
 nombre nvarchar(50) NOT NULL UNIQUE,
 descripcion nvarchar(250) NULL
);
CREATE TABLE dbo.categoria_producto (
 id_categoria varchar(20) NOT NULL PRIMARY KEY,
 titulo nvarchar(100) NOT NULL,
 descripcion_nota nvarchar(500) NULL,
 orden int NOT NULL DEFAULT 0,
 activa bit NOT NULL DEFAULT 1
);
CREATE TABLE dbo.tipo_corte (
 id_tipo_corte int IDENTITY(1,1) PRIMARY KEY,
 codigo varchar(30) NOT NULL UNIQUE,
 nombre nvarchar(100) NOT NULL,
 descripcion nvarchar(250) NULL,
 activo bit NOT NULL DEFAULT 1
);
CREATE TABLE dbo.termino_coccion (
 id_termino int IDENTITY(1,1) PRIMARY KEY,
 codigo varchar(30) NOT NULL UNIQUE,
 nombre nvarchar(50) NOT NULL,
 descripcion nvarchar(250) NULL,
 orden int NOT NULL DEFAULT 0,
 activo bit NOT NULL DEFAULT 1
);
CREATE TABLE dbo.producto_carta (
 id_producto int IDENTITY(1,1) PRIMARY KEY,
 nombre nvarchar(120) NOT NULL,
 categoria varchar(30) NOT NULL,
 id_categoria varchar(20) NULL REFERENCES dbo.categoria_producto(id_categoria),
 grupo_comercial nvarchar(100) NULL,
 id_tipo_corte int NULL REFERENCES dbo.tipo_corte(id_tipo_corte),
 pais_origen nvarchar(50) NULL,
 descripcion nvarchar(500) NULL,
 estilo nvarchar(50) NULL,
 peso_cantidad decimal(9,2) NULL,
 peso_unidad varchar(20) NULL,
 precio decimal(10,2) NOT NULL CHECK (precio >= 0),
 es_apto_favorito bit NOT NULL DEFAULT 0,
 destacado bit NOT NULL DEFAULT 0,
 imagen varchar(255) NULL,
 orden int NOT NULL DEFAULT 0,
 activo bit NOT NULL DEFAULT 1
);
CREATE TABLE dbo.presentacion_producto (
 id_presentacion int IDENTITY(1,1) PRIMARY KEY,
 id_producto int NOT NULL REFERENCES dbo.producto_carta(id_producto),
 nombre_presentacion nvarchar(150) NOT NULL,
 precio decimal(10,2) NOT NULL CHECK (precio >= 0),
 peso_volumen_cantidad decimal(9,2) NULL,
 unidad_medida varchar(20) NULL,
 variedad_vino nvarchar(100) NULL,
 descripcion_presentacion nvarchar(500) NULL,
 destacado bit NOT NULL DEFAULT 0,
 imagen varchar(255) NULL,
 orden int NOT NULL DEFAULT 0,
 activo bit NOT NULL DEFAULT 1
);

-- 2. Campanas y publicaciones publicitarias. Publicacion != anuncio.
CREATE TABLE dbo.campana (
 id_campana int IDENTITY(1,1) PRIMARY KEY,
 id_plataforma int NOT NULL REFERENCES dbo.plataforma(id_plataforma),
 nombre nvarchar(150) NOT NULL,
 id_segmento_objetivo int NULL REFERENCES dbo.segmento_cliente(id_segmento),
 id_producto_gancho int NULL REFERENCES dbo.producto_carta(id_producto),
 fecha_inicio date NOT NULL,
 fecha_fin date NULL,
 meta_campaign_id varchar(100) NULL,
 activa bit NOT NULL DEFAULT 1,
 CONSTRAINT CK_campana_fechas CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
);
CREATE UNIQUE INDEX UX_campana_meta_campaign_id ON dbo.campana(meta_campaign_id) WHERE meta_campaign_id IS NOT NULL;
CREATE TABLE dbo.publicacion (
 id_publicacion int IDENTITY(1,1) PRIMARY KEY,
 id_plataforma int NOT NULL REFERENCES dbo.plataforma(id_plataforma),
 id_campana int NULL REFERENCES dbo.campana(id_campana),
 meta_post_id varchar(150) NOT NULL,
 texto nvarchar(2000) NULL,
 url_publicacion nvarchar(600) NULL,
 url_formulario nvarchar(600) NULL,
 fecha_publicacion datetime2(0) NOT NULL,
 estado varchar(20) NOT NULL DEFAULT 'PUBLICADA' CHECK (estado IN ('PROGRAMADA','PUBLICADA','ARCHIVADA')),
 CONSTRAINT UQ_publicacion_externa UNIQUE (id_plataforma,meta_post_id)
);
CREATE TABLE dbo.anuncio (
 id_anuncio int IDENTITY(1,1) PRIMARY KEY,
 id_campana int NOT NULL REFERENCES dbo.campana(id_campana),
 id_publicacion int NULL REFERENCES dbo.publicacion(id_publicacion),
 meta_ad_id varchar(150) NULL,
 nombre nvarchar(150) NOT NULL,
 fecha_inicio datetime2(0) NOT NULL,
 fecha_fin datetime2(0) NULL,
 CONSTRAINT CK_anuncio_fecha CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
);
CREATE UNIQUE INDEX UX_anuncio_meta_ad_id ON dbo.anuncio(meta_ad_id) WHERE meta_ad_id IS NOT NULL;
CREATE TABLE dbo.gasto_anuncio_diario (
 id_gasto bigint IDENTITY(1,1) PRIMARY KEY,
 id_anuncio int NOT NULL REFERENCES dbo.anuncio(id_anuncio),
 fecha date NOT NULL,
 monto decimal(12,2) NOT NULL CHECK (monto >= 0),
 moneda char(3) NOT NULL DEFAULT 'PEN',
 CONSTRAINT UQ_gasto_anuncio_dia UNIQUE(id_anuncio,fecha)
);
CREATE TABLE dbo.metrica_publicacion_diaria (
 id_metrica bigint IDENTITY(1,1) PRIMARY KEY,
 id_publicacion int NOT NULL REFERENCES dbo.publicacion(id_publicacion),
 fecha_corte date NOT NULL,
 total_reacciones int NULL CHECK (total_reacciones >= 0),
 total_comentarios int NULL CHECK (total_comentarios >= 0),
 total_compartidos int NULL CHECK (total_compartidos >= 0),
 alcance int NULL CHECK (alcance >= 0),
 impresiones int NULL CHECK (impresiones >= 0),
 fecha_obtencion datetime2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
 CONSTRAINT UQ_metrica_publicacion_fecha UNIQUE(id_publicacion,fecha_corte)
);

-- 3. Persona central y captacion. El identificador del canal NO equivale a persona real.
CREATE TABLE dbo.persona (
 id_persona bigint IDENTITY(1,1) PRIMARY KEY,
 nombres nvarchar(100) NOT NULL,
 apellidos nvarchar(100) NOT NULL,
 telefono varchar(20) NULL,
 email nvarchar(150) NULL,
 fecha_nacimiento date NULL,
 id_segmento int NULL REFERENCES dbo.segmento_cliente(id_segmento),
 fecha_registro datetime2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
 fase_actual varchar(10) NOT NULL DEFAULT 'LEAD' CHECK (fase_actual IN ('BUYER','LEAD')),
 consentimiento_datos_fecha datetime2(0) NULL,
 consentimiento_marketing_fecha datetime2(0) NULL,
 CONSTRAINT CK_persona_contacto CHECK (telefono IS NOT NULL OR email IS NOT NULL)
);
CREATE UNIQUE INDEX UX_persona_telefono ON dbo.persona(telefono) WHERE telefono IS NOT NULL;
CREATE UNIQUE INDEX UX_persona_email ON dbo.persona(email) WHERE email IS NOT NULL;
CREATE TABLE dbo.buyer (
 id_buyer bigint IDENTITY(1,1) PRIMARY KEY,
 id_persona bigint NULL REFERENCES dbo.persona(id_persona),
 id_plataforma_origen int NOT NULL REFERENCES dbo.plataforma(id_plataforma),
 id_publicacion_origen int NULL REFERENCES dbo.publicacion(id_publicacion),
 id_anuncio_origen int NULL REFERENCES dbo.anuncio(id_anuncio),
 referencia_externa varchar(150) NULL,
 fecha_primer_contacto datetime2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
 estado varchar(15) NOT NULL DEFAULT 'BUYER' CHECK (estado IN ('BUYER','CONVERTIDO_LEAD','DESCARTADO')),
 fecha_conversion datetime2(0) NULL,
 CONSTRAINT CK_buyer_conversion CHECK ((estado = 'CONVERTIDO_LEAD' AND id_persona IS NOT NULL AND fecha_conversion IS NOT NULL) OR (estado <> 'CONVERTIDO_LEAD' AND fecha_conversion IS NULL))
);
CREATE INDEX IX_buyer_plataforma_fecha ON dbo.buyer(id_plataforma_origen,fecha_primer_contacto);
CREATE TABLE dbo.persona_red_social (
 id_cuenta bigint IDENTITY(1,1) PRIMARY KEY,
 id_persona bigint NOT NULL REFERENCES dbo.persona(id_persona),
 id_plataforma int NOT NULL REFERENCES dbo.plataforma(id_plataforma),
 usuario varchar(150) NULL,
 id_usuario_externo varchar(150) NULL,
 fecha_vinculacion datetime2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
 metodo_vinculacion varchar(30) NOT NULL CHECK (metodo_vinculacion IN ('VERIFICACION','FORMULARIO','AUTORIZACION')),
 CONSTRAINT CK_cuenta_identificador CHECK (usuario IS NOT NULL OR id_usuario_externo IS NOT NULL)
);
CREATE UNIQUE INDEX UX_cuenta_externa ON dbo.persona_red_social(id_plataforma,id_usuario_externo) WHERE id_usuario_externo IS NOT NULL;
CREATE TABLE dbo.interaccion_publicacion (
 id_interaccion bigint IDENTITY(1,1) PRIMARY KEY,
 id_publicacion int NOT NULL REFERENCES dbo.publicacion(id_publicacion),
 id_buyer bigint NULL REFERENCES dbo.buyer(id_buyer),
 id_interaccion_externa varchar(150) NOT NULL,
 tipo varchar(15) NOT NULL CHECK (tipo IN ('COMENTARIO','RESPUESTA','REACCION')),
 id_usuario_externo varchar(150) NULL,
 nombre_visible nvarchar(150) NULL,
 texto nvarchar(2000) NULL,
 fecha_interaccion datetime2(0) NOT NULL,
 fecha_ingesta datetime2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
 CONSTRAINT UQ_interaccion_publicacion UNIQUE(id_publicacion,id_interaccion_externa)
);
-- REACCION individual solo si la API devuelve el evento permitido: no inventar IDs desde conteos.

-- 4. Landing page: un visitante por cookie de navegador, múltiples sesiones.
CREATE TABLE dbo.visitante_web (
 id_visitante bigint IDENTITY(1,1) PRIMARY KEY,
 token_visitante uniqueidentifier NOT NULL UNIQUE DEFAULT NEWID(),
 id_persona bigint NULL REFERENCES dbo.persona(id_persona),
 dispositivo_tipo varchar(20) NULL CHECK (dispositivo_tipo IN ('MOVIL','ESCRITORIO','TABLETA','DESCONOCIDO')),
 fecha_primera_visita datetime2(0) NOT NULL,
 fecha_ultima_visita datetime2(0) NOT NULL,
 cantidad_visitas int NOT NULL DEFAULT 0 CHECK (cantidad_visitas >= 0),
 CONSTRAINT CK_visitante_fechas CHECK (fecha_ultima_visita >= fecha_primera_visita)
);
CREATE TABLE dbo.visita_web (
 id_visita bigint IDENTITY(1,1) PRIMARY KEY,
 id_visitante bigint NOT NULL REFERENCES dbo.visitante_web(id_visitante),
 id_buyer bigint NULL REFERENCES dbo.buyer(id_buyer),
 fecha_inicio datetime2(0) NOT NULL,
 fecha_ultima_actividad datetime2(0) NOT NULL,
 utm_source varchar(100) NULL,
 utm_campaign varchar(150) NULL,
 id_publicacion_origen int NULL REFERENCES dbo.publicacion(id_publicacion),
 CONSTRAINT CK_visita_fecha CHECK (fecha_ultima_actividad >= fecha_inicio)
);
CREATE TABLE dbo.evento_web (
 id_evento bigint IDENTITY(1,1) PRIMARY KEY,
 id_visita bigint NOT NULL REFERENCES dbo.visita_web(id_visita),
 tipo varchar(30) NOT NULL CHECK (tipo IN ('VER_MENU','CLIC_FORMULARIO','CLIC_WHATSAPP','ENVIO_FORMULARIO','CLIC_CARTA','VISTA_CARTA','VER_CARTA')),
 id_producto int NULL REFERENCES dbo.producto_carta(id_producto),
 fecha_evento datetime2(0) NOT NULL,
 detalle nvarchar(300) NULL
);

-- 5. WhatsApp: almacenar mensajes reales. El backend recibe webhooks y envia respuestas.
CREATE TABLE dbo.sesion_whatsapp (
 id_sesion bigint IDENTITY(1,1) PRIMARY KEY,
 id_buyer bigint NULL REFERENCES dbo.buyer(id_buyer),
 id_persona bigint NULL REFERENCES dbo.persona(id_persona),
 telefono_cliente varchar(20) NOT NULL,
 fecha_inicio datetime2(0) NOT NULL,
 fecha_ultimo_mensaje datetime2(0) NOT NULL,
 estado varchar(15) NOT NULL DEFAULT 'ABIERTA' CHECK (estado IN ('ABIERTA','CERRADA')),
 origen varchar(30) NULL,
 CONSTRAINT CK_sesion_whatsapp_fechas CHECK (fecha_ultimo_mensaje >= fecha_inicio)
);
CREATE TABLE dbo.mensaje_whatsapp (
 id_mensaje bigint IDENTITY(1,1) PRIMARY KEY,
 id_sesion bigint NOT NULL REFERENCES dbo.sesion_whatsapp(id_sesion),
 wamid varchar(200) NULL,
 direccion varchar(10) NOT NULL CHECK (direccion IN ('ENTRANTE','SALIENTE')),
 tipo varchar(20) NOT NULL CHECK (tipo IN ('TEXTO','BOTONES','INTERACTIVO','IMAGEN','OTRO')),
 contenido nvarchar(max) NULL,
 opcion_seleccionada varchar(50) NULL,
 fecha_mensaje datetime2(0) NOT NULL,
 estado_entrega varchar(20) NULL,
 CONSTRAINT CK_mensaje_contenido CHECK (contenido IS NOT NULL OR opcion_seleccionada IS NOT NULL)
);
CREATE UNIQUE INDEX UX_mensaje_wamid ON dbo.mensaje_whatsapp(wamid) WHERE wamid IS NOT NULL;

-- 6. Formulario: evidencia enviada + FK a persona. Una persona puede enviar varios formularios.
CREATE TABLE dbo.formulario_captacion (
 id_formulario bigint IDENTITY(1,1) PRIMARY KEY,
 id_persona bigint NOT NULL REFERENCES dbo.persona(id_persona),
 id_buyer bigint NOT NULL REFERENCES dbo.buyer(id_buyer),
 id_plataforma_origen int NOT NULL REFERENCES dbo.plataforma(id_plataforma),
 id_publicacion_origen int NULL REFERENCES dbo.publicacion(id_publicacion),
 id_visita bigint NULL REFERENCES dbo.visita_web(id_visita),
 id_sesion_whatsapp bigint NULL REFERENCES dbo.sesion_whatsapp(id_sesion),
 id_producto_favorito int NULL REFERENCES dbo.producto_carta(id_producto),
 fecha_envio datetime2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
 acepta_politica_datos bit NOT NULL CHECK (acepta_politica_datos = 1),
 acepta_marketing bit NOT NULL DEFAULT 0,
 CONSTRAINT CK_formulario_un_origen CHECK (NOT (id_visita IS NOT NULL AND id_sesion_whatsapp IS NOT NULL))
);
CREATE TABLE dbo.lead_conversion (
 id_conversion bigint IDENTITY(1,1) PRIMARY KEY,
 id_buyer bigint NOT NULL UNIQUE REFERENCES dbo.buyer(id_buyer),
 id_persona bigint NOT NULL REFERENCES dbo.persona(id_persona),
 id_formulario bigint NOT NULL UNIQUE REFERENCES dbo.formulario_captacion(id_formulario),
 fecha_conversion datetime2(0) NOT NULL
);
CREATE TABLE dbo.historial_fases (
 id_historial bigint IDENTITY(1,1) PRIMARY KEY,
 id_persona bigint NOT NULL REFERENCES dbo.persona(id_persona),
 fase varchar(10) NOT NULL CHECK (fase IN ('BUYER','LEAD')),
 fecha_cambio datetime2(0) NOT NULL,
 id_buyer bigint NULL REFERENCES dbo.buyer(id_buyer),
 id_formulario bigint NULL REFERENCES dbo.formulario_captacion(id_formulario),
 CONSTRAINT UQ_historial_fases UNIQUE(id_persona,fase),
 CONSTRAINT CK_historial_lead CHECK (fase <> 'LEAD' OR id_formulario IS NOT NULL)
);

-- 7. Auditoria de agentes y deduplicacion de eventos (solo datos minimos)
CREATE TABLE dbo.evento_integracion (
 id_evento bigint IDENTITY(1,1) PRIMARY KEY,
 proveedor varchar(20) NOT NULL CHECK (proveedor IN ('META','WHATSAPP','LANDING')),
 id_evento_externo varchar(200) NOT NULL,
 tipo varchar(50) NOT NULL,
 recibido_en datetime2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
 procesado_en datetime2(0) NULL,
 estado varchar(15) NOT NULL DEFAULT 'RECIBIDO' CHECK (estado IN ('RECIBIDO','PROCESADO','ERROR')),
 error_resumen nvarchar(300) NULL,
 CONSTRAINT UQ_evento_integracion UNIQUE(proveedor,id_evento_externo)
);
CREATE TABLE dbo.accion_agente (
 id_accion bigint IDENTITY(1,1) PRIMARY KEY,
 nombre_agente varchar(60) NOT NULL,
 id_buyer bigint NULL REFERENCES dbo.buyer(id_buyer),
 id_sesion_whatsapp bigint NULL REFERENCES dbo.sesion_whatsapp(id_sesion),
 accion varchar(50) NOT NULL,
 detalle nvarchar(500) NULL,
 resultado varchar(20) NOT NULL CHECK (resultado IN ('EXITOSO','FALLIDO','PENDIENTE')),
 fecha_ejecucion datetime2(0) NOT NULL DEFAULT SYSUTCDATETIME()
);

-- 8. Índices principales para agente y reportes
CREATE INDEX IX_interaccion_fecha ON dbo.interaccion_publicacion(id_publicacion,fecha_interaccion);
CREATE INDEX IX_visita_visitante_fecha ON dbo.visita_web(id_visitante,fecha_inicio);
CREATE INDEX IX_evento_web_fecha ON dbo.evento_web(tipo,fecha_evento);
CREATE INDEX IX_mensaje_sesion_fecha ON dbo.mensaje_whatsapp(id_sesion,fecha_mensaje);
CREATE INDEX IX_formulario_fecha ON dbo.formulario_captacion(fecha_envio);
CREATE INDEX IX_sesion_telefono ON dbo.sesion_whatsapp(telefono_cliente,fecha_inicio DESC);
GO
PRINT 'Base buyer: 22 tablas y relaciones creadas correctamente.';
GO
