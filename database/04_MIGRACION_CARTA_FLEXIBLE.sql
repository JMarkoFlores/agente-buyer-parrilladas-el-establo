-- ==============================================================================
-- PROMPT 17: MIGRACIÓN A MODELO RELACIONAL FLEXIBLE DE CARTA
-- Base de datos: buyer
-- Idempotente, aditivo y compatible con datos existentes
-- ==============================================================================

USE buyer;
GO

-- ------------------------------------------------------------------------------
-- 1. TABLA: categoria_producto (9 Categorías reales de la carta)
-- ------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'categoria_producto' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.categoria_producto (
        id_categoria       VARCHAR(20)   NOT NULL,
        titulo             NVARCHAR(100) NOT NULL,
        descripcion_nota   NVARCHAR(500) NULL,
        orden              INT           NOT NULL DEFAULT 0,
        activa             BIT           NOT NULL DEFAULT 1,
        CONSTRAINT PK_categoria_producto PRIMARY KEY (id_categoria)
    );
    PRINT 'Tabla dbo.categoria_producto creada.';
END
GO

-- Inserción / sincronización de las 9 categorías reales
MERGE dbo.categoria_producto AS target
USING (VALUES
    ('res',             N'Carnes de res',          N'Cortes a la parrilla. Las guarniciones vienen incluidas salvo indicación del plato.', 1, 1),
    ('cerdo',           N'Cerdo',                  N'Cortes a la parrilla. Las guarniciones vienen incluidas salvo indicación del plato.', 2, 1),
    ('pollo',           N'Pollo',                  N'Cortes a la parrilla. Las guarniciones vienen incluidas.',                             3, 1),
    ('entradas',        N'Entradas',               N'Salvo el anticucho y el chorizo por unidad, las entradas vienen con papas fritas, papas sancochadas o nuestra clásica ensalada mixta.', 4, 1),
    ('combos',          N'Combos para compartir',  N'Parrillas surtidas pensadas para compartir. Las guarniciones vienen incluidas.',     5, 1),
    ('ensaladas',       N'Ensaladas',              NULL,                                                                                    6, 1),
    ('acompanamientos', N'Acompañamientos',        NULL,                                                                                    7, 1),
    ('bebidas',         N'Bebidas',                N'La limonada frozen tiene un costo adicional de S/ 5.',                                8, 1),
    ('vinos',           N'Vinos',                  N'Botellas de 750 ml salvo indicación. Se restringe el consumo de bebidas alcohólicas (Ordenanza 024-2014 MPT).', 9, 1)
) AS source (id_categoria, titulo, descripcion_nota, orden, activa)
ON (target.id_categoria = source.id_categoria)
WHEN MATCHED THEN
    UPDATE SET 
        target.titulo = source.titulo,
        target.descripcion_nota = source.descripcion_nota,
        target.orden = source.orden,
        target.activa = source.activa
WHEN NOT MATCHED THEN
    INSERT (id_categoria, titulo, descripcion_nota, orden, activa)
    VALUES (source.id_categoria, source.titulo, source.descripcion_nota, source.orden, source.activa);
GO

-- ------------------------------------------------------------------------------
-- 2. TABLA: tipo_corte (Catálogo de cortes documentados de res y cerdo)
-- ------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'tipo_corte' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.tipo_corte (
        id_tipo_corte INT           IDENTITY(1,1) NOT NULL,
        codigo        VARCHAR(30)   NOT NULL UNIQUE,
        nombre        NVARCHAR(100) NOT NULL,
        descripcion   NVARCHAR(250) NULL,
        activo        BIT           NOT NULL DEFAULT 1,
        CONSTRAINT PK_tipo_corte PRIMARY KEY (id_tipo_corte)
    );
    PRINT 'Tabla dbo.tipo_corte creada.';
END
GO

MERGE dbo.tipo_corte AS target
USING (VALUES
    ('PICANHA',            N'Picaña / Picanha',          N'Corte tradicional con cobertura de grasa característica'),
    ('LOMO_FINO',          N'Lomo Fino',                 N'Corte magro y suave'),
    ('ENTRANA_FINA',       N'Entraña Fina',              N'Corte con alto marmoleo y gran sabor'),
    ('BIFE_ANCHO',         N'Bife Ancho',                N'Ojo de bife con grasa intramuscular'),
    ('BIFE_ANGOSTO',       N'Bife Angosto',              N'Corte clásico de solomillo / bife de chorizo angosto'),
    ('BIFE_CHORIZO',       N'Bife de Chorizo',           N'Corte argentino jugoso y tierno'),
    ('CUADRIL',            N'Cuadril',                   N'Corte magro tradicional'),
    ('CHURRASCO',          N'Churrasco',                 N'Corte clásico a la brasa con hueso'),
    ('ASADO_TIRA_RES',     N'Asado de Tira de Res',      N'Costillar vacuno cortado transversalmente'),
    ('TBONE',              N'T-Bone',                    N'Corte con hueso en T que une lomo y bife'),
    ('TOMAHAWK',           N'Tomahawk',                  N'Gran corte de costilla con hueso entero expuesto'),
    ('ANTICUCHOS',         N'Anticuchos en Espadas',     N'Brochetas maceradas en especias tradicionales'),
    ('ASADO_TIRA_CERDO',   N'Asado de Tira de Cerdo',    N'Costillas transversales de cerdo'),
    ('CHULETA_CERDO',      N'Chuleta de Cerdo',          N'Corte jugoso de cerdo a la parrilla'),
    ('LOMO_CERDO',         N'Lomo de Cerdo (Solomillo)', N'Pieza magra y tierna de cerdo'),
    ('COSTILLA_ST_LOUIS',  N'Costilla de Cerdo St. Louis', N'Costillar recto con corte estilo St. Louis'),
    ('BABY_RIBS',          N'Baby Ribs',                 N'Costillitas tiernas para compartir')
) AS source (codigo, nombre, descripcion)
ON (target.codigo = source.codigo)
WHEN MATCHED THEN
    UPDATE SET target.nombre = source.nombre, target.descripcion = source.descripcion
WHEN NOT MATCHED THEN
    INSERT (codigo, nombre, descripcion, activo)
    VALUES (source.codigo, source.nombre, source.descripcion, 1);
GO

-- ------------------------------------------------------------------------------
-- 3. TABLA: termino_coccion (Propuesta funcional para reservas/pedidos)
-- ------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'termino_coccion' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.termino_coccion (
        id_termino  INT           IDENTITY(1,1) NOT NULL,
        codigo      VARCHAR(30)   NOT NULL UNIQUE,
        nombre      NVARCHAR(50)  NOT NULL,
        descripcion NVARCHAR(250) NULL,
        orden       INT           NOT NULL DEFAULT 0,
        activo      BIT           NOT NULL DEFAULT 1,
        CONSTRAINT PK_termino_coccion PRIMARY KEY (id_termino)
    );
    PRINT 'Tabla dbo.termino_coccion creada.';
END
GO

MERGE dbo.termino_coccion AS target
USING (VALUES
    ('AZUL',         N'Azul o muy poco cocido', N'Sellado exteriormente, centro rojo frío (aprox. 40 °C)', 1),
    ('INGLESA',      N'A la inglesa',           N'Sellado exterior, centro rojo caliente (aprox. 50 °C)', 2),
    ('MEDIO',        N'Término medio',          N'Centro rojo suave, jugoso y tibio (aprox. 55-60 °C)', 3),
    ('TRES_CUARTOS', N'Tres cuartos',           N'Centro rosado suave con poco jugo (aprox. 65 °C)', 4),
    ('BIEN_COCIDO',  N'Bien cocido',            N'Totalmente cocido sin tonos rosados (aprox. 75 °C)', 5)
) AS source (codigo, nombre, descripcion, orden)
ON (target.codigo = source.codigo)
WHEN MATCHED THEN
    UPDATE SET target.nombre = source.nombre, target.descripcion = source.descripcion, target.orden = source.orden
WHEN NOT MATCHED THEN
    INSERT (codigo, nombre, descripcion, orden, activo)
    VALUES (source.codigo, source.nombre, source.descripcion, source.orden, 1);
GO

-- ------------------------------------------------------------------------------
-- 4. ADAPTACIÓN DE dbo.producto_carta: FLEXIBILIDAD Y RETENCIÓN DE COMPATIBILIDAD
-- ------------------------------------------------------------------------------
-- A. Eliminar restricción UNIQUE en nombre si existe (para permitir múltiples gramajes/orígenes)
DECLARE @sql_drop_uq NVARCHAR(MAX);
SELECT @sql_drop_uq = 'ALTER TABLE dbo.producto_carta DROP CONSTRAINT ' + name
FROM sys.key_constraints
WHERE parent_object_id = OBJECT_ID('dbo.producto_carta') AND type = 'UQ';

IF @sql_drop_uq IS NOT NULL
BEGIN
    EXEC sp_executesql @sql_drop_uq;
    PRINT 'Restricción UNIQUE sobre nombre en producto_carta eliminada para permitir presentaciones.';
END
GO

-- B. Eliminar restricciones CK rígidas sobre categoría y peso_unidad
DECLARE @drop_sql NVARCHAR(MAX) = N'';
SELECT @drop_sql += N'ALTER TABLE dbo.producto_carta DROP CONSTRAINT ' + QUOTENAME(name) + N'; '
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID('dbo.producto_carta')
  AND (definition LIKE '%POSTRE%' OR definition LIKE '%peso_unidad%');

IF @drop_sql <> N''
BEGIN
    EXEC sp_executesql @drop_sql;
    PRINT 'Restricciones CK rígidas eliminadas.';
END
GO

-- D. Ampliar columnas existentes en producto_carta si es necesario
ALTER TABLE dbo.producto_carta ALTER COLUMN categoria VARCHAR(30) NOT NULL;
ALTER TABLE dbo.producto_carta ALTER COLUMN peso_unidad VARCHAR(20) NULL;
GO

-- E. Agregar columnas nuevas aditivas a dbo.producto_carta
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.producto_carta') AND name = 'id_categoria')
BEGIN
    ALTER TABLE dbo.producto_carta ADD id_categoria VARCHAR(20) NULL;
    ALTER TABLE dbo.producto_carta ADD CONSTRAINT FK_producto_carta_categoria 
        FOREIGN KEY (id_categoria) REFERENCES dbo.categoria_producto(id_categoria);
    PRINT 'Columna id_categoria agregada a producto_carta.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.producto_carta') AND name = 'grupo_comercial')
BEGIN
    ALTER TABLE dbo.producto_carta ADD grupo_comercial NVARCHAR(100) NULL;
    PRINT 'Columna grupo_comercial agregada a producto_carta.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.producto_carta') AND name = 'id_tipo_corte')
BEGIN
    ALTER TABLE dbo.producto_carta ADD id_tipo_corte INT NULL;
    ALTER TABLE dbo.producto_carta ADD CONSTRAINT FK_producto_carta_tipo_corte 
        FOREIGN KEY (id_tipo_corte) REFERENCES dbo.tipo_corte(id_tipo_corte);
    PRINT 'Columna id_tipo_corte agregada a producto_carta.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.producto_carta') AND name = 'pais_origen')
BEGIN
    ALTER TABLE dbo.producto_carta ADD pais_origen NVARCHAR(50) NULL;
    PRINT 'Columna pais_origen agregada a producto_carta.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.producto_carta') AND name = 'es_apto_favorito')
BEGIN
    ALTER TABLE dbo.producto_carta ADD es_apto_favorito BIT NOT NULL DEFAULT 0;
    PRINT 'Columna es_apto_favorito agregada a producto_carta.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.producto_carta') AND name = 'destacado')
BEGIN
    ALTER TABLE dbo.producto_carta ADD destacado BIT NOT NULL DEFAULT 0;
    PRINT 'Columna destacado agregada a producto_carta.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.producto_carta') AND name = 'imagen')
BEGIN
    ALTER TABLE dbo.producto_carta ADD imagen VARCHAR(255) NULL;
    PRINT 'Columna imagen agregada a producto_carta.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.producto_carta') AND name = 'orden')
BEGIN
    ALTER TABLE dbo.producto_carta ADD orden INT NOT NULL DEFAULT 0;
    PRINT 'Columna orden agregada a producto_carta.';
END
GO

-- ------------------------------------------------------------------------------
-- 5. TABLA: presentacion_producto (Presentaciones reales con gramajes y precios)
-- ------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'presentacion_producto' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.presentacion_producto (
        id_presentacion          INT            IDENTITY(1,1) NOT NULL,
        id_producto              INT            NOT NULL,
        nombre_presentacion      NVARCHAR(150)  NOT NULL,
        precio                   DECIMAL(10,2)  NOT NULL,
        peso_volumen_cantidad    DECIMAL(9,2)   NULL,
        unidad_medida            VARCHAR(20)    NULL,
        variedad_vino            NVARCHAR(100)  NULL,
        descripcion_presentacion NVARCHAR(500)  NULL,
        destacado                BIT            NOT NULL DEFAULT 0,
        imagen                   VARCHAR(255)   NULL,
        orden                    INT            NOT NULL DEFAULT 0,
        activo                   BIT            NOT NULL DEFAULT 1,
        CONSTRAINT PK_presentacion_producto PRIMARY KEY (id_presentacion),
        CONSTRAINT FK_presentacion_producto FOREIGN KEY (id_producto) REFERENCES dbo.producto_carta(id_producto),
        CONSTRAINT CK_presentacion_precio_pos CHECK (precio >= 0)
    );
    CREATE INDEX IX_presentacion_producto_id ON dbo.presentacion_producto(id_producto);
    PRINT 'Tabla dbo.presentacion_producto creada.';
END
GO

-- ------------------------------------------------------------------------------
-- 6. ACTUALIZAR RESTRICCIONES EN evento_web PARA REGISTRAR CLICS Y VISTAS DE CARTA
-- ------------------------------------------------------------------------------
DECLARE @sql_drop_ck_evento NVARCHAR(MAX);
SELECT @sql_drop_ck_evento = 'ALTER TABLE dbo.evento_web DROP CONSTRAINT ' + name
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID('dbo.evento_web') AND name LIKE '%tipo%';

IF @sql_drop_ck_evento IS NOT NULL
BEGIN
    EXEC sp_executesql @sql_drop_ck_evento;
    PRINT 'Restricción CK de evento_web.tipo eliminada para actualización.';
END
GO

ALTER TABLE dbo.evento_web ADD CONSTRAINT CK_evento_web_tipo 
    CHECK (tipo IN ('VER_MENU','CLIC_FORMULARIO','CLIC_WHATSAPP','ENVIO_FORMULARIO','CLIC_CARTA','VISTA_CARTA','VER_CARTA'));
PRINT 'Restricción CK_evento_web_tipo actualizada con CLIC_CARTA y VISTA_CARTA.';
GO
