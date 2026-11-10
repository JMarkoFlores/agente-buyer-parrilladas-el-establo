/* VERSION FINAL CORREGIDA - 09/11/2026
   DATOS DE DEMOSTRACION: maximo 10 por tabla, referencialmente consistentes.
   Ejecutar UNA SOLA VEZ sobre BD buyer recien creada, sin registros.
   Datos sintéticos, no extraídos de Meta real ni de WhatsApp real.
   Los tiempos están en UTC. */
USE buyer;
GO
SET XACT_ABORT ON;
SET NOCOUNT ON;
BEGIN TRY
 BEGIN TRANSACTION;
 IF EXISTS (SELECT 1 FROM dbo.plataforma)
     THROW 51001, 'Ya hay datos en buyer. El llenado se ejecuta solo sobre una base nueva y vacia.', 1;

 INSERT dbo.plataforma (codigo,nombre_pagina,url_pagina,meta_account_id) VALUES
 ('FACEBOOK',N'Parrilladas El Establo - Facebook',N'https://www.facebook.com/',NULL),
 ('INSTAGRAM',N'Parrilladas El Establo - Instagram',N'https://www.instagram.com/',NULL),
 ('LANDING_PAGE',N'Carta digital El Establo',N'https://ejemplo.test/menu',NULL),
 ('WHATSAPP',N'WhatsApp comercial El Establo',NULL,NULL);
 INSERT dbo.segmento_cliente(nombre,descripcion) VALUES
 (N'Familias',N'Grupos familiares'),(N'Estudiantes',N'Buscan promociones'),(N'Amigos',N'Consumo en grupo');
 INSERT dbo.producto_carta(nombre,categoria,descripcion,estilo,peso_cantidad,peso_unidad,precio) VALUES
 (N'Tira de Cerdo','COMIDA',N'Tira de cerdo a la parrilla',N'Argentina',350,'g',32),
 (N'Picaña a la Parrilla','COMIDA',N'Picaña con guarnición',N'Uruguaya',350,'g',39),
 (N'Bife Ancho','COMIDA',N'Bife ancho con guarnición',N'Argentina',350,'g',38),
 (N'Parrilla Personal','COMIDA',N'Parrilla para una persona',N'Americana',NULL,NULL,35),
 (N'Parrilla Mixta Especial','COMIDA',N'Parrilla mixta',N'Argentina',NULL,NULL,58),
 (N'Chicha Morada','BEBIDA',N'Bebida tradicional',NULL,1,'L',12),
 (N'Sangría','BEBIDA',N'Sangría de la casa',NULL,1,'L',22),
 (N'Torta de Chocolate','POSTRE',N'Porción de torta',NULL,150,'g',14);

 INSERT dbo.campana(id_plataforma,nombre,id_segmento_objetivo,id_producto_gancho,fecha_inicio,fecha_fin) VALUES
 (1,N'Promoción picaña noviembre',3,2,'2026-11-01','2026-11-30'),
 (2,N'Sangría y parrilladas',1,7,'2026-11-01','2026-11-30');
 INSERT dbo.publicacion(id_plataforma,id_campana,meta_post_id,texto,url_publicacion,url_formulario,fecha_publicacion) VALUES
 (1,1,'DEMO_FB_POST_01',N'¡Disfruta nuestra picaña! Regístrate para recibir novedades.',NULL,N'https://ejemplo.test/formulario?utm_source=facebook','2026-11-02T15:00:00'),
 (2,2,'DEMO_IG_POST_01',N'¡Conoce nuestras parrilladas! Formulario en el enlace.',NULL,N'https://ejemplo.test/formulario?utm_source=instagram','2026-11-03T16:00:00'),
 (1,1,'DEMO_FB_POST_02',N'Promoción familiar. Consulta la carta.',NULL,N'https://ejemplo.test/formulario?utm_source=facebook','2026-11-04T17:00:00');
 INSERT dbo.anuncio(id_campana,id_publicacion,meta_ad_id,nombre,fecha_inicio) VALUES
 (1,1,'DEMO_FB_AD_01',N'Anuncio Picaña','2026-11-02T15:00:00'),
 (2,2,'DEMO_IG_AD_01',N'Anuncio Sangría','2026-11-03T16:00:00');
 INSERT dbo.gasto_anuncio_diario(id_anuncio,fecha,monto) VALUES
 (1,'2026-11-04',24),(1,'2026-11-05',25),(2,'2026-11-04',20),(2,'2026-11-05',22);
 INSERT dbo.metrica_publicacion_diaria(id_publicacion,fecha_corte,total_reacciones,total_comentarios,total_compartidos,alcance,impresiones) VALUES
 (1,'2026-11-04',35,6,2,800,1200),(1,'2026-11-05',41,8,3,950,1380),
 (2,'2026-11-04',22,4,1,620,900),(2,'2026-11-05',29,5,2,750,1030);

 INSERT dbo.persona(nombres,apellidos,telefono,email,fecha_nacimiento,id_segmento,fecha_registro,fase_actual,consentimiento_datos_fecha,consentimiento_marketing_fecha) VALUES
 (N'Ana',N'Ramírez',N'+51999000001',N'ana@example.test','1999-05-10',2,'2026-11-05T10:12:00','LEAD','2026-11-05T10:12:00',NULL),
 (N'Luis',N'Torres',N'+51999000002',N'luis@example.test','1988-03-22',1,'2026-11-05T11:20:00','LEAD','2026-11-05T11:20:00','2026-11-05T11:20:00'),
 (N'María',N'Paredes',N'+51999000003',N'maria@example.test','1995-07-14',3,'2026-11-06T13:30:00','LEAD','2026-11-06T13:30:00',NULL),
 (N'Pedro',N'García',N'+51999000004',NULL,NULL,NULL,'2026-11-06T14:00:00','BUYER',NULL,NULL);
 INSERT dbo.buyer(id_persona,id_plataforma_origen,id_publicacion_origen,id_anuncio_origen,referencia_externa,fecha_primer_contacto,estado,fecha_conversion) VALUES
 (1,1,1,1,'DEMO_FB_USER_ANA','2026-11-04T10:00:00','CONVERTIDO_LEAD','2026-11-05T10:12:00'),
 (2,2,2,2,'DEMO_IG_USER_LUIS','2026-11-04T12:00:00','CONVERTIDO_LEAD','2026-11-05T11:20:00'),
 (3,4,NULL,NULL,'WHATSAPP_51999000003','2026-11-06T13:10:00','CONVERTIDO_LEAD','2026-11-06T13:30:00'),
 (NULL,3,NULL,NULL,'COOKIE_ANON_01','2026-11-05T08:00:00','BUYER',NULL),
 (4,4,NULL,NULL,'WHATSAPP_51999000004','2026-11-06T14:00:00','BUYER',NULL);
 INSERT dbo.persona_red_social(id_persona,id_plataforma,usuario,id_usuario_externo,fecha_vinculacion,metodo_vinculacion) VALUES
 (1,1,'ana.demo','DEMO_FB_USER_ANA','2026-11-05T10:12:00','FORMULARIO'),
 (2,2,'luis.demo','DEMO_IG_USER_LUIS','2026-11-05T11:20:00','FORMULARIO');
 INSERT dbo.interaccion_publicacion(id_publicacion,id_buyer,id_interaccion_externa,tipo,id_usuario_externo,nombre_visible,texto,fecha_interaccion) VALUES
 (1,1,'DEMO_COMMENT_01','COMENTARIO','DEMO_FB_USER_ANA',N'Ana R.',N'¿Cuánto cuesta la picaña?','2026-11-04T10:00:00'),
 (2,2,'DEMO_COMMENT_02','COMENTARIO','DEMO_IG_USER_LUIS',N'Luis T.',N'¿Atienden grupos familiares?','2026-11-04T12:00:00'),
 (1,NULL,'DEMO_COMMENT_03','COMENTARIO',NULL,N'Visitante',N'¿Dónde queda el local?','2026-11-05T09:15:00'),
 (3,NULL,'DEMO_COMMENT_04','COMENTARIO',NULL,N'Usuario',N'¿Tienen promociones?','2026-11-05T15:50:00');

 INSERT dbo.visitante_web(token_visitante,id_persona,dispositivo_tipo,fecha_primera_visita,fecha_ultima_visita,cantidad_visitas) VALUES
 ('11111111-1111-1111-1111-111111111111',1,'MOVIL','2026-11-04T10:05:00','2026-11-04T14:05:00',2),
 ('22222222-2222-2222-2222-222222222222',2,'ESCRITORIO','2026-11-05T10:00:00','2026-11-05T10:00:00',1),
 ('33333333-3333-3333-3333-333333333333',NULL,'MOVIL','2026-11-05T08:00:00','2026-11-05T08:00:00',1);
 INSERT dbo.visita_web(id_visitante,id_buyer,fecha_inicio,fecha_ultima_actividad,utm_source,utm_campaign,id_publicacion_origen) VALUES
 (1,1,'2026-11-04T10:05:00','2026-11-04T10:10:00','facebook','promocion_picana',1),
 (1,1,'2026-11-04T14:05:00','2026-11-04T14:08:00','facebook','promocion_picana',1),
 (2,2,'2026-11-05T10:00:00','2026-11-05T11:20:00','instagram','sangria',2),
 (3,4,'2026-11-05T08:00:00','2026-11-05T08:04:00',NULL,NULL,NULL);
 INSERT dbo.evento_web(id_visita,tipo,id_producto,fecha_evento,detalle) VALUES
 (1,'VER_MENU',2,'2026-11-04T10:06:00',N'Clic en carta'),
 (2,'CLIC_FORMULARIO',NULL,'2026-11-04T14:06:00',N'Abre formulario'),
 (3,'VER_MENU',7,'2026-11-05T10:02:00',N'Clic en carta'),
 (4,'VER_MENU',NULL,'2026-11-05T08:02:00',N'Carta completa'),
 (4,'CLIC_WHATSAPP',NULL,'2026-11-05T08:03:00',N'Botón de contacto');

 INSERT dbo.sesion_whatsapp(id_buyer,id_persona,telefono_cliente,fecha_inicio,fecha_ultimo_mensaje,estado,origen) VALUES
 (3,3,N'+51999000003','2026-11-06T13:10:00','2026-11-06T13:13:00','ABIERTA','LANDING_PAGE'),
 (5,4,N'+51999000004','2026-11-06T14:00:00','2026-11-06T14:03:00','ABIERTA','LANDING_PAGE'),
 (4,NULL,N'+51999000005','2026-11-05T08:05:00','2026-11-05T08:07:00','CERRADA','LANDING_PAGE');
 INSERT dbo.mensaje_whatsapp(id_sesion,wamid,direccion,tipo,contenido,opcion_seleccionada,fecha_mensaje,estado_entrega) VALUES
 (1,'DEMO_WAMID_01','ENTRANTE','TEXTO',N'Hola, ¿tienen parrilladas?',NULL,'2026-11-06T13:10:00',NULL),
 (1,'DEMO_WAMID_02','SALIENTE','BOTONES',N'Elige: Ver carta o Completar formulario',NULL,'2026-11-06T13:11:00','ENVIADO'),
 (1,'DEMO_WAMID_03','ENTRANTE','INTERACTIVO',N'Quiero registrarme','COMPLETAR_FORMULARIO','2026-11-06T13:13:00',NULL),
 (2,'DEMO_WAMID_04','ENTRANTE','TEXTO',N'¿Cuánto cuesta la picaña?',NULL,'2026-11-06T14:00:00',NULL),
 (2,'DEMO_WAMID_05','SALIENTE','BOTONES',N'Ver carta o Completar formulario',NULL,'2026-11-06T14:03:00','ENVIADO');

 INSERT dbo.formulario_captacion(id_persona,id_buyer,id_plataforma_origen,id_publicacion_origen,id_visita,id_sesion_whatsapp,id_producto_favorito,fecha_envio,acepta_politica_datos,acepta_marketing) VALUES
 (1,1,1,1,2,NULL,2,'2026-11-05T10:12:00',1,0),
 (2,2,2,2,3,NULL,5,'2026-11-05T11:20:00',1,1),
 (3,3,4,NULL,NULL,1,4,'2026-11-06T13:30:00',1,0);
 INSERT dbo.lead_conversion(id_buyer,id_persona,id_formulario,fecha_conversion) VALUES
 (1,1,1,'2026-11-05T10:12:00'),(2,2,2,'2026-11-05T11:20:00'),(3,3,3,'2026-11-06T13:30:00');
 INSERT dbo.historial_fases(id_persona,fase,fecha_cambio,id_buyer,id_formulario) VALUES
 (1,'LEAD','2026-11-05T10:12:00',1,1),
 (2,'LEAD','2026-11-05T11:20:00',2,2),
 (3,'LEAD','2026-11-06T13:30:00',3,3),
 (4,'BUYER','2026-11-06T14:00:00',5,NULL);
 INSERT dbo.evento_integracion(proveedor,id_evento_externo,tipo,recibido_en,procesado_en,estado) VALUES
 ('META','DEMO_COMMENT_01','COMENTARIO','2026-11-04T10:01:00','2026-11-04T10:01:10','PROCESADO'),
 ('META','DEMO_COMMENT_02','COMENTARIO','2026-11-04T12:01:00','2026-11-04T12:01:10','PROCESADO'),
 ('WHATSAPP','DEMO_WAMID_01','MENSAJE','2026-11-06T13:10:05','2026-11-06T13:10:10','PROCESADO'),
 ('LANDING','DEMO_VISITA_01','VISITA','2026-11-04T10:05:05','2026-11-04T10:05:10','PROCESADO');
 INSERT dbo.accion_agente(nombre_agente,id_buyer,id_sesion_whatsapp,accion,detalle,resultado,fecha_ejecucion) VALUES
 ('AgenteBuyer',3,1,'RESPONDER_WHATSAPP',N'Envió opciones de carta y formulario','EXITOSO','2026-11-06T13:11:00'),
 ('AgenteBuyer',5,2,'RESPONDER_WHATSAPP',N'Envió menú de opciones','EXITOSO','2026-11-06T14:03:00'),
 ('AgenteBuyer',1,NULL,'CLASIFICAR_INTERES',N'Interés por picaña','EXITOSO','2026-11-04T10:02:00');
 COMMIT TRANSACTION;
END TRY
BEGIN CATCH
 IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
 THROW;
END CATCH;
GO
-- Conteo exacto de todas las tablas (validacion).
DECLARE @sql nvarchar(max) = N'';
SELECT @sql = @sql +
    CASE WHEN LEN(@sql) > 0 THEN N' UNION ALL ' ELSE N'' END +
    N'SELECT N''' + REPLACE(name,'''','''''') +
    N''' AS tabla, COUNT_BIG(*) AS registros FROM dbo.' + QUOTENAME(name)
FROM sys.tables
WHERE schema_id = SCHEMA_ID('dbo');
SET @sql = N'SELECT tabla, registros FROM (' + @sql + N') AS x ORDER BY tabla';
EXEC sys.sp_executesql @sql;
PRINT 'Llenado terminado. Si no aparecieron errores, todos los INSERT fueron confirmados.';
GO
