-- ==============================================================================
-- PROMPT 17: CARGA DEL CATÁLOGO REAL DE LA CARTA (Parrilladas El Establo)
-- Fuente: landing/src/app/domain/models/carta.model.ts
-- Total categorías: 9 | Total productos lógicos: 120 | Total presentaciones: 146
-- Total precio acumulado: S/ 7,231.00
-- Idempotente: MERGE / verificación de unicidad
-- ==============================================================================

USE buyer;
GO

PRINT 'Iniciando carga del catálogo real de la carta...';

-- 0. Marcar productos históricos demo como inactivos en carta visible pero preservando integridad referencial
UPDATE dbo.producto_carta SET es_apto_favorito = 0, activo = 0 WHERE id_producto BETWEEN 1 AND 8;
GO

-- 1. CARGA DE PRODUCTOS LÓGICOS (120 PRODUCTOS)
SET IDENTITY_INSERT dbo.producto_carta OFF;


IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Angus · Americana y uruguaya' OR (grupo_comercial IS NULL AND N'Angus · Americana y uruguaya' IS NULL))
      AND nombre = N'Asado de tira de res'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Asado de tira de res', N'Carnes de res', 'res', N'Angus · Americana y uruguaya', NULL,
        (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'ASADO_TIRA_RES'), N'EE.UU. / Uruguay', 1, 0, NULL,
        115.00, 500.0, N'g', 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Carnes de res',
        descripcion = NULL,
        id_tipo_corte = (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'ASADO_TIRA_RES'),
        pais_origen = N'EE.UU. / Uruguay',
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 115.00,
        peso_cantidad = 500.0,
        peso_unidad = N'g',
        orden = 1,
        activo = 1
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Angus · Americana y uruguaya' OR (grupo_comercial IS NULL AND N'Angus · Americana y uruguaya' IS NULL))
      AND nombre = N'Asado de tira de res';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Angus · Americana y uruguaya' OR (grupo_comercial IS NULL AND N'Angus · Americana y uruguaya' IS NULL))
      AND nombre = N'Entraña fina'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Entraña fina', N'Carnes de res', 'res', N'Angus · Americana y uruguaya', NULL,
        (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'ENTRANA_FINA'), N'EE.UU. / Uruguay', 1, 0, NULL,
        125.00, 400.0, N'g', 2, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Carnes de res',
        descripcion = NULL,
        id_tipo_corte = (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'ENTRANA_FINA'),
        pais_origen = N'EE.UU. / Uruguay',
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 125.00,
        peso_cantidad = 400.0,
        peso_unidad = N'g',
        orden = 2,
        activo = 1
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Angus · Americana y uruguaya' OR (grupo_comercial IS NULL AND N'Angus · Americana y uruguaya' IS NULL))
      AND nombre = N'Entraña fina';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Angus · Americana y uruguaya' OR (grupo_comercial IS NULL AND N'Angus · Americana y uruguaya' IS NULL))
      AND nombre = N'Beefe angosto'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Beefe angosto', N'Carnes de res', 'res', N'Angus · Americana y uruguaya', NULL,
        (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'BIFE_ANGOSTO'), N'EE.UU. / Uruguay', 1, 0, NULL,
        100.00, 400.0, N'g', 3, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Carnes de res',
        descripcion = NULL,
        id_tipo_corte = (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'BIFE_ANGOSTO'),
        pais_origen = N'EE.UU. / Uruguay',
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 100.00,
        peso_cantidad = 400.0,
        peso_unidad = N'g',
        orden = 3,
        activo = 1
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Angus · Americana y uruguaya' OR (grupo_comercial IS NULL AND N'Angus · Americana y uruguaya' IS NULL))
      AND nombre = N'Beefe angosto';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Angus · Americana y uruguaya' OR (grupo_comercial IS NULL AND N'Angus · Americana y uruguaya' IS NULL))
      AND nombre = N'Picanha'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Picanha', N'Carnes de res', 'res', N'Angus · Americana y uruguaya', NULL,
        (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'PICANHA'), N'EE.UU. / Uruguay', 1, 1, N'/img/picanha.jpg',
        115.00, 400.0, N'g', 4, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Carnes de res',
        descripcion = NULL,
        id_tipo_corte = (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'PICANHA'),
        pais_origen = N'EE.UU. / Uruguay',
        es_apto_favorito = 1,
        destacado = 1,
        imagen = N'/img/picanha.jpg',
        precio = 115.00,
        peso_cantidad = 400.0,
        peso_unidad = N'g',
        orden = 4,
        activo = 1
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Angus · Americana y uruguaya' OR (grupo_comercial IS NULL AND N'Angus · Americana y uruguaya' IS NULL))
      AND nombre = N'Picanha';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Angus · Americana y uruguaya' OR (grupo_comercial IS NULL AND N'Angus · Americana y uruguaya' IS NULL))
      AND nombre = N'Beefe ancho'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Beefe ancho', N'Carnes de res', 'res', N'Angus · Americana y uruguaya', NULL,
        (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'BIFE_ANCHO'), N'EE.UU. / Uruguay', 1, 0, NULL,
        105.00, 400.0, N'g', 5, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Carnes de res',
        descripcion = NULL,
        id_tipo_corte = (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'BIFE_ANCHO'),
        pais_origen = N'EE.UU. / Uruguay',
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 105.00,
        peso_cantidad = 400.0,
        peso_unidad = N'g',
        orden = 5,
        activo = 1
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Angus · Americana y uruguaya' OR (grupo_comercial IS NULL AND N'Angus · Americana y uruguaya' IS NULL))
      AND nombre = N'Beefe ancho';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
      AND nombre = N'Beefe ancho'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Beefe ancho', N'Carnes de res', 'res', N'Argentina', NULL,
        (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'BIFE_ANCHO'), N'Argentina', 1, 0, NULL,
        72.00, 300.0, N'g', 6, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Carnes de res',
        descripcion = NULL,
        id_tipo_corte = (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'BIFE_ANCHO'),
        pais_origen = N'Argentina',
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 72.00,
        peso_cantidad = 300.0,
        peso_unidad = N'g',
        orden = 6,
        activo = 1
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
      AND nombre = N'Beefe ancho';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
      AND nombre = N'Picanha'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Picanha', N'Carnes de res', 'res', N'Argentina', NULL,
        (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'PICANHA'), N'Argentina', 1, 0, NULL,
        80.00, 400.0, N'g', 7, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Carnes de res',
        descripcion = NULL,
        id_tipo_corte = (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'PICANHA'),
        pais_origen = N'Argentina',
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 80.00,
        peso_cantidad = 400.0,
        peso_unidad = N'g',
        orden = 7,
        activo = 1
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
      AND nombre = N'Picanha';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
      AND nombre = N'Lomo fino'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Lomo fino', N'Carnes de res', 'res', N'Nacional', NULL,
        (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'LOMO_FINO'), N'Perú', 1, 0, NULL,
        54.00, 400.0, N'g', 8, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Carnes de res',
        descripcion = NULL,
        id_tipo_corte = (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'LOMO_FINO'),
        pais_origen = N'Perú',
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 54.00,
        peso_cantidad = 400.0,
        peso_unidad = N'g',
        orden = 8,
        activo = 1
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
      AND nombre = N'Lomo fino';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
      AND nombre = N'Beefe ancho'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Beefe ancho', N'Carnes de res', 'res', N'Nacional', NULL,
        (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'BIFE_ANCHO'), N'Perú', 1, 0, NULL,
        49.00, 300.0, N'g', 9, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Carnes de res',
        descripcion = NULL,
        id_tipo_corte = (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'BIFE_ANCHO'),
        pais_origen = N'Perú',
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 49.00,
        peso_cantidad = 300.0,
        peso_unidad = N'g',
        orden = 9,
        activo = 1
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
      AND nombre = N'Beefe ancho';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
      AND nombre = N'Beefe angosto'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Beefe angosto', N'Carnes de res', 'res', N'Nacional', NULL,
        (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'BIFE_ANGOSTO'), N'Perú', 1, 0, NULL,
        47.00, 400.0, N'g', 10, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Carnes de res',
        descripcion = NULL,
        id_tipo_corte = (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'BIFE_ANGOSTO'),
        pais_origen = N'Perú',
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 47.00,
        peso_cantidad = 400.0,
        peso_unidad = N'g',
        orden = 10,
        activo = 1
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
      AND nombre = N'Beefe angosto';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
      AND nombre = N'Beefe de chorizo'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Beefe de chorizo', N'Carnes de res', 'res', N'Nacional', NULL,
        (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'BIFE_CHORIZO'), N'Perú', 1, 0, NULL,
        52.00, 400.0, N'g', 11, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Carnes de res',
        descripcion = NULL,
        id_tipo_corte = (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'BIFE_CHORIZO'),
        pais_origen = N'Perú',
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 52.00,
        peso_cantidad = 400.0,
        peso_unidad = N'g',
        orden = 11,
        activo = 1
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
      AND nombre = N'Beefe de chorizo';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
      AND nombre = N'Picanha'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Picanha', N'Carnes de res', 'res', N'Nacional', NULL,
        (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'PICANHA'), N'Perú', 1, 0, NULL,
        65.00, 400.0, N'g', 12, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Carnes de res',
        descripcion = NULL,
        id_tipo_corte = (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'PICANHA'),
        pais_origen = N'Perú',
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 65.00,
        peso_cantidad = 400.0,
        peso_unidad = N'g',
        orden = 12,
        activo = 1
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
      AND nombre = N'Picanha';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
      AND nombre = N'Cuadril'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Cuadril', N'Carnes de res', 'res', N'Nacional', NULL,
        (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'CUADRIL'), N'Perú', 1, 0, NULL,
        45.00, 400.0, N'g', 13, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Carnes de res',
        descripcion = NULL,
        id_tipo_corte = (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'CUADRIL'),
        pais_origen = N'Perú',
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 45.00,
        peso_cantidad = 400.0,
        peso_unidad = N'g',
        orden = 13,
        activo = 1
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
      AND nombre = N'Cuadril';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
      AND nombre = N'Churrasco'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Churrasco', N'Carnes de res', 'res', N'Nacional', NULL,
        (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'CHURRASCO'), N'Perú', 1, 1, N'/img/churrasco.jpg',
        41.00, 300.0, N'g', 14, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Carnes de res',
        descripcion = NULL,
        id_tipo_corte = (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'CHURRASCO'),
        pais_origen = N'Perú',
        es_apto_favorito = 1,
        destacado = 1,
        imagen = N'/img/churrasco.jpg',
        precio = 41.00,
        peso_cantidad = 300.0,
        peso_unidad = N'g',
        orden = 14,
        activo = 1
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
      AND nombre = N'Churrasco';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
      AND nombre = N'Entraña fina'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Entraña fina', N'Carnes de res', 'res', N'Nacional', NULL,
        (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'ENTRANA_FINA'), N'Perú', 1, 0, NULL,
        62.00, 400.0, N'g', 15, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Carnes de res',
        descripcion = NULL,
        id_tipo_corte = (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'ENTRANA_FINA'),
        pais_origen = N'Perú',
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 62.00,
        peso_cantidad = 400.0,
        peso_unidad = N'g',
        orden = 15,
        activo = 1
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
      AND nombre = N'Entraña fina';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
      AND nombre = N'Asado de tira de res'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Asado de tira de res', N'Carnes de res', 'res', N'Nacional', NULL,
        (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'ASADO_TIRA_RES'), N'Perú', 1, 0, NULL,
        62.00, 700.0, N'g', 16, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Carnes de res',
        descripcion = NULL,
        id_tipo_corte = (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'ASADO_TIRA_RES'),
        pais_origen = N'Perú',
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 62.00,
        peso_cantidad = 700.0,
        peso_unidad = N'g',
        orden = 16,
        activo = 1
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
      AND nombre = N'Asado de tira de res';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
      AND nombre = N'T. Bone'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'T. Bone', N'Carnes de res', 'res', N'Nacional', NULL,
        (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'TBONE'), N'Perú', 1, 0, NULL,
        75.00, 400.0, N'g', 17, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Carnes de res',
        descripcion = NULL,
        id_tipo_corte = (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'TBONE'),
        pais_origen = N'Perú',
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 75.00,
        peso_cantidad = 400.0,
        peso_unidad = N'g',
        orden = 17,
        activo = 1
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
      AND nombre = N'T. Bone';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
      AND nombre = N'Tomahawk'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Tomahawk', N'Carnes de res', 'res', N'Nacional', NULL,
        (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'TOMAHAWK'), N'Perú', 1, 0, NULL,
        145.00, 1.0, N'kg', 18, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Carnes de res',
        descripcion = NULL,
        id_tipo_corte = (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'TOMAHAWK'),
        pais_origen = N'Perú',
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 145.00,
        peso_cantidad = 1.0,
        peso_unidad = N'kg',
        orden = 18,
        activo = 1
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
      AND nombre = N'Tomahawk';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
      AND nombre = N'Anticuchos de lomo fino en espadas'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Anticuchos de lomo fino en espadas', N'Carnes de res', 'res', N'Nacional', N'Dos espadas, acompañadas solo de papas fritas.',
        (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'ANTICUCHOS'), N'Perú', 1, 0, NULL,
        45.00, NULL, NULL, 19, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Carnes de res',
        descripcion = N'Dos espadas, acompañadas solo de papas fritas.',
        id_tipo_corte = (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'ANTICUCHOS'),
        pais_origen = N'Perú',
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 45.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 19,
        activo = 1
    WHERE id_categoria = 'res' 
      AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
      AND nombre = N'Anticuchos de lomo fino en espadas';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'cerdo' 
      AND (grupo_comercial = N'Cortes' OR (grupo_comercial IS NULL AND N'Cortes' IS NULL))
      AND nombre = N'Asado de tira de cerdo'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Asado de tira de cerdo', N'Cerdo', 'cerdo', N'Cortes', N'Dos cortes de tira de cerdo.',
        (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'ASADO_TIRA_CERDO'), NULL, 1, 0, NULL,
        58.00, 700.0, N'g', 20, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Cerdo',
        descripcion = N'Dos cortes de tira de cerdo.',
        id_tipo_corte = (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'ASADO_TIRA_CERDO'),
        pais_origen = NULL,
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 58.00,
        peso_cantidad = 700.0,
        peso_unidad = N'g',
        orden = 20,
        activo = 1
    WHERE id_categoria = 'cerdo' 
      AND (grupo_comercial = N'Cortes' OR (grupo_comercial IS NULL AND N'Cortes' IS NULL))
      AND nombre = N'Asado de tira de cerdo';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'cerdo' 
      AND (grupo_comercial = N'Cortes' OR (grupo_comercial IS NULL AND N'Cortes' IS NULL))
      AND nombre = N'Chuleta de cerdo'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Chuleta de cerdo', N'Cerdo', 'cerdo', N'Cortes', N'Dos cortes de chuleta.',
        (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'CHULETA_CERDO'), NULL, 1, 0, NULL,
        39.00, 500.0, N'g', 21, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Cerdo',
        descripcion = N'Dos cortes de chuleta.',
        id_tipo_corte = (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'CHULETA_CERDO'),
        pais_origen = NULL,
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 39.00,
        peso_cantidad = 500.0,
        peso_unidad = N'g',
        orden = 21,
        activo = 1
    WHERE id_categoria = 'cerdo' 
      AND (grupo_comercial = N'Cortes' OR (grupo_comercial IS NULL AND N'Cortes' IS NULL))
      AND nombre = N'Chuleta de cerdo';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'cerdo' 
      AND (grupo_comercial = N'Cortes' OR (grupo_comercial IS NULL AND N'Cortes' IS NULL))
      AND nombre = N'Lomo de cerdo (salomillo)'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Lomo de cerdo (salomillo)', N'Cerdo', 'cerdo', N'Cortes', NULL,
        (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'LOMO_CERDO'), NULL, 1, 0, NULL,
        53.00, 400.0, N'g', 22, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Cerdo',
        descripcion = NULL,
        id_tipo_corte = (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'LOMO_CERDO'),
        pais_origen = NULL,
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 53.00,
        peso_cantidad = 400.0,
        peso_unidad = N'g',
        orden = 22,
        activo = 1
    WHERE id_categoria = 'cerdo' 
      AND (grupo_comercial = N'Cortes' OR (grupo_comercial IS NULL AND N'Cortes' IS NULL))
      AND nombre = N'Lomo de cerdo (salomillo)';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'cerdo' 
      AND (grupo_comercial = N'Cortes' OR (grupo_comercial IS NULL AND N'Cortes' IS NULL))
      AND nombre = N'Anticuchos de lomo fino de cerdo en espadas'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Anticuchos de lomo fino de cerdo en espadas', N'Cerdo', 'cerdo', N'Cortes', N'Dos espadas, acompañadas solo de papas fritas.',
        (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'ANTICUCHOS'), NULL, 1, 0, NULL,
        42.00, NULL, NULL, 23, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Cerdo',
        descripcion = N'Dos espadas, acompañadas solo de papas fritas.',
        id_tipo_corte = (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'ANTICUCHOS'),
        pais_origen = NULL,
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 42.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 23,
        activo = 1
    WHERE id_categoria = 'cerdo' 
      AND (grupo_comercial = N'Cortes' OR (grupo_comercial IS NULL AND N'Cortes' IS NULL))
      AND nombre = N'Anticuchos de lomo fino de cerdo en espadas';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'cerdo' 
      AND (grupo_comercial = N'Costillas' OR (grupo_comercial IS NULL AND N'Costillas' IS NULL))
      AND nombre = N'Costilla de cerdo St. Louis'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Costilla de cerdo St. Louis', N'Cerdo', 'cerdo', N'Costillas', NULL,
        (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'COSTILLA_ST_LOUIS'), NULL, 1, 0, NULL,
        52.00, NULL, NULL, 24, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Cerdo',
        descripcion = NULL,
        id_tipo_corte = (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'COSTILLA_ST_LOUIS'),
        pais_origen = NULL,
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 52.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 24,
        activo = 1
    WHERE id_categoria = 'cerdo' 
      AND (grupo_comercial = N'Costillas' OR (grupo_comercial IS NULL AND N'Costillas' IS NULL))
      AND nombre = N'Costilla de cerdo St. Louis';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'cerdo' 
      AND (grupo_comercial = N'Costillas' OR (grupo_comercial IS NULL AND N'Costillas' IS NULL))
      AND nombre = N'Costilla de cerdo St. Louis en salsa BBQ'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Costilla de cerdo St. Louis en salsa BBQ', N'Cerdo', 'cerdo', N'Costillas', NULL,
        (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'COSTILLA_ST_LOUIS'), NULL, 1, 0, NULL,
        58.00, NULL, NULL, 25, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Cerdo',
        descripcion = NULL,
        id_tipo_corte = (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'COSTILLA_ST_LOUIS'),
        pais_origen = NULL,
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 58.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 25,
        activo = 1
    WHERE id_categoria = 'cerdo' 
      AND (grupo_comercial = N'Costillas' OR (grupo_comercial IS NULL AND N'Costillas' IS NULL))
      AND nombre = N'Costilla de cerdo St. Louis en salsa BBQ';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'cerdo' 
      AND (grupo_comercial = N'Costillas' OR (grupo_comercial IS NULL AND N'Costillas' IS NULL))
      AND nombre = N'Baby Ribs'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Baby Ribs', N'Cerdo', 'cerdo', N'Costillas', N'Costilla de cerdo para dos personas.',
        (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'BABY_RIBS'), NULL, 1, 0, NULL,
        76.00, 800.0, N'g', 26, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Cerdo',
        descripcion = N'Costilla de cerdo para dos personas.',
        id_tipo_corte = (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'BABY_RIBS'),
        pais_origen = NULL,
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 76.00,
        peso_cantidad = 800.0,
        peso_unidad = N'g',
        orden = 26,
        activo = 1
    WHERE id_categoria = 'cerdo' 
      AND (grupo_comercial = N'Costillas' OR (grupo_comercial IS NULL AND N'Costillas' IS NULL))
      AND nombre = N'Baby Ribs';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'cerdo' 
      AND (grupo_comercial = N'Costillas' OR (grupo_comercial IS NULL AND N'Costillas' IS NULL))
      AND nombre = N'Baby Ribs en salsa BBQ'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Baby Ribs en salsa BBQ', N'Cerdo', 'cerdo', N'Costillas', N'Costilla de cerdo para dos personas.',
        (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'BABY_RIBS'), NULL, 1, 0, NULL,
        81.00, 800.0, N'g', 27, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Cerdo',
        descripcion = N'Costilla de cerdo para dos personas.',
        id_tipo_corte = (SELECT id_tipo_corte FROM dbo.tipo_corte WHERE codigo = 'BABY_RIBS'),
        pais_origen = NULL,
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 81.00,
        peso_cantidad = 800.0,
        peso_unidad = N'g',
        orden = 27,
        activo = 1
    WHERE id_categoria = 'cerdo' 
      AND (grupo_comercial = N'Costillas' OR (grupo_comercial IS NULL AND N'Costillas' IS NULL))
      AND nombre = N'Baby Ribs en salsa BBQ';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'pollo' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'1/4 de pollo a la parrilla'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'1/4 de pollo a la parrilla', N'Pollo', 'pollo', NULL, NULL,
        NULL, NULL, 1, 0, NULL,
        30.00, NULL, NULL, 28, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Pollo',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 30.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 28,
        activo = 1
    WHERE id_categoria = 'pollo' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'1/4 de pollo a la parrilla';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'pollo' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Filete de pechuga'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Filete de pechuga', N'Pollo', 'pollo', NULL, NULL,
        NULL, NULL, 1, 0, NULL,
        38.00, 400.0, N'g', 29, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Pollo',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 38.00,
        peso_cantidad = 400.0,
        peso_unidad = N'g',
        orden = 29,
        activo = 1
    WHERE id_categoria = 'pollo' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Filete de pechuga';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'entradas' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Alitas en salsa BBQ'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Alitas en salsa BBQ', N'Entradas', 'entradas', NULL, N'Alitas bañadas en salsa BBQ.',
        NULL, NULL, 1, 0, NULL,
        30.00, 6.0, N'unidades', 30, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Entradas',
        descripcion = N'Alitas bañadas en salsa BBQ.',
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 30.00,
        peso_cantidad = 6.0,
        peso_unidad = N'unidades',
        orden = 30,
        activo = 1
    WHERE id_categoria = 'entradas' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Alitas en salsa BBQ';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'entradas' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Mollejitas a la parrilla'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Mollejitas a la parrilla', N'Entradas', 'entradas', NULL, NULL,
        NULL, NULL, 1, 0, NULL,
        30.00, 300.0, N'g', 31, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Entradas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 30.00,
        peso_cantidad = 300.0,
        peso_unidad = N'g',
        orden = 31,
        activo = 1
    WHERE id_categoria = 'entradas' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Mollejitas a la parrilla';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'entradas' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Champiñones a la parrilla'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Champiñones a la parrilla', N'Entradas', 'entradas', NULL, NULL,
        NULL, NULL, 0, 0, NULL,
        25.00, 200.0, N'g', 32, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Entradas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 25.00,
        peso_cantidad = 200.0,
        peso_unidad = N'g',
        orden = 32,
        activo = 1
    WHERE id_categoria = 'entradas' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Champiñones a la parrilla';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'entradas' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Anticuchos de corazón de res'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Anticuchos de corazón de res', N'Entradas', 'entradas', NULL, NULL,
        NULL, NULL, 1, 0, NULL,
        28.00, 2.0, N'palitos', 33, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Entradas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 28.00,
        peso_cantidad = 2.0,
        peso_unidad = N'palitos',
        orden = 33,
        activo = 1
    WHERE id_categoria = 'entradas' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Anticuchos de corazón de res';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'entradas' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Anticuchos de champiñones'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Anticuchos de champiñones', N'Entradas', 'entradas', NULL, NULL,
        NULL, NULL, 1, 0, NULL,
        28.00, 2.0, N'palitos', 34, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Entradas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 28.00,
        peso_cantidad = 2.0,
        peso_unidad = N'palitos',
        orden = 34,
        activo = 1
    WHERE id_categoria = 'entradas' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Anticuchos de champiñones';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'entradas' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Chorizo parrillero porción'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Chorizo parrillero porción', N'Entradas', 'entradas', NULL, NULL,
        NULL, NULL, 1, 0, NULL,
        30.00, 3.0, N'unidades', 35, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Entradas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 30.00,
        peso_cantidad = 3.0,
        peso_unidad = N'unidades',
        orden = 35,
        activo = 1
    WHERE id_categoria = 'entradas' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Chorizo parrillero porción';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'entradas' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Anticucho por unidad'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Anticucho por unidad', N'Entradas', 'entradas', NULL, NULL,
        NULL, NULL, 1, 0, NULL,
        14.00, NULL, NULL, 36, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Entradas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 14.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 36,
        activo = 1
    WHERE id_categoria = 'entradas' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Anticucho por unidad';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'entradas' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Chorizo parrillero por unidad'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Chorizo parrillero por unidad', N'Entradas', 'entradas', NULL, NULL,
        NULL, NULL, 1, 0, NULL,
        13.00, NULL, NULL, 37, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Entradas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 13.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 37,
        activo = 1
    WHERE id_categoria = 'entradas' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Chorizo parrillero por unidad';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'entradas' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Piqueo Cuatrero'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Piqueo Cuatrero', N'Entradas', 'entradas', NULL, N'3 alitas + 2 anticuchos + 4 mollejitas + 2 chorizos.',
        NULL, NULL, 1, 0, NULL,
        44.00, NULL, NULL, 38, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Entradas',
        descripcion = N'3 alitas + 2 anticuchos + 4 mollejitas + 2 chorizos.',
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 44.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 38,
        activo = 1
    WHERE id_categoria = 'entradas' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Piqueo Cuatrero';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'combos' 
      AND (grupo_comercial = N'Parrillas para compartir' OR (grupo_comercial IS NULL AND N'Parrillas para compartir' IS NULL))
      AND nombre = N'Mixta Grande'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Mixta Grande', N'Combos para compartir', 'combos', N'Parrillas para compartir', N'1/4 de pollo + 3 chuletas de cerdo + 2 churrascos + 1 asado de tira + 3 anticuchos de corazón + 8 mollejitas + 3 chorizos + 2 porciones de papas fritas + 2 ensaladas mixtas.',
        NULL, NULL, 1, 1, N'/img/parrilla-mixta.jpg',
        200.00, 7.0, N'personas', 39, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Combos para compartir',
        descripcion = N'1/4 de pollo + 3 chuletas de cerdo + 2 churrascos + 1 asado de tira + 3 anticuchos de corazón + 8 mollejitas + 3 chorizos + 2 porciones de papas fritas + 2 ensaladas mixtas.',
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 1,
        destacado = 1,
        imagen = N'/img/parrilla-mixta.jpg',
        precio = 200.00,
        peso_cantidad = 7.0,
        peso_unidad = N'personas',
        orden = 39,
        activo = 1
    WHERE id_categoria = 'combos' 
      AND (grupo_comercial = N'Parrillas para compartir' OR (grupo_comercial IS NULL AND N'Parrillas para compartir' IS NULL))
      AND nombre = N'Mixta Grande';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'combos' 
      AND (grupo_comercial = N'Parrillas para compartir' OR (grupo_comercial IS NULL AND N'Parrillas para compartir' IS NULL))
      AND nombre = N'Mixta Junior'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Mixta Junior', N'Combos para compartir', 'combos', N'Parrillas para compartir', N'1/4 de pollo + 2 chuletas de cerdo + 1 churrasco + 2 anticuchos de corazón + 4 mollejitas + 2 chorizos + 1 porción de papas fritas + 1 ensalada mixta.',
        NULL, NULL, 1, 0, NULL,
        160.00, 5.0, N'personas', 40, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Combos para compartir',
        descripcion = N'1/4 de pollo + 2 chuletas de cerdo + 1 churrasco + 2 anticuchos de corazón + 4 mollejitas + 2 chorizos + 1 porción de papas fritas + 1 ensalada mixta.',
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 160.00,
        peso_cantidad = 5.0,
        peso_unidad = N'personas',
        orden = 40,
        activo = 1
    WHERE id_categoria = 'combos' 
      AND (grupo_comercial = N'Parrillas para compartir' OR (grupo_comercial IS NULL AND N'Parrillas para compartir' IS NULL))
      AND nombre = N'Mixta Junior';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'combos' 
      AND (grupo_comercial = N'Combos personales' OR (grupo_comercial IS NULL AND N'Combos personales' IS NULL))
      AND nombre = N'Señor Cuatrero'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Señor Cuatrero', N'Combos para compartir', 'combos', N'Combos personales', N'300 g de lomo fino + 300 g de cuadril + 300 g de beefe, con papas y ensalada mixta.',
        NULL, NULL, 1, 0, NULL,
        130.00, 900.0, N'g', 41, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Combos para compartir',
        descripcion = N'300 g de lomo fino + 300 g de cuadril + 300 g de beefe, con papas y ensalada mixta.',
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 130.00,
        peso_cantidad = 900.0,
        peso_unidad = N'g',
        orden = 41,
        activo = 1
    WHERE id_categoria = 'combos' 
      AND (grupo_comercial = N'Combos personales' OR (grupo_comercial IS NULL AND N'Combos personales' IS NULL))
      AND nombre = N'Señor Cuatrero';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'combos' 
      AND (grupo_comercial = N'Combos personales' OR (grupo_comercial IS NULL AND N'Combos personales' IS NULL))
      AND nombre = N'Trilogía Cuatrero'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Trilogía Cuatrero', N'Combos para compartir', 'combos', N'Combos personales', N'200 g de beefe + 200 g de filete de pierna + 200 g de lomo de cerdo, con papas y ensalada mixta.',
        NULL, NULL, 1, 0, NULL,
        72.00, 600.0, N'g', 42, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Combos para compartir',
        descripcion = N'200 g de beefe + 200 g de filete de pierna + 200 g de lomo de cerdo, con papas y ensalada mixta.',
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 72.00,
        peso_cantidad = 600.0,
        peso_unidad = N'g',
        orden = 42,
        activo = 1
    WHERE id_categoria = 'combos' 
      AND (grupo_comercial = N'Combos personales' OR (grupo_comercial IS NULL AND N'Combos personales' IS NULL))
      AND nombre = N'Trilogía Cuatrero';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'combos' 
      AND (grupo_comercial = N'Combos personales' OR (grupo_comercial IS NULL AND N'Combos personales' IS NULL))
      AND nombre = N'Cuatrero'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Cuatrero', N'Combos para compartir', 'combos', N'Combos personales', N'Dos cortes de churrasco.',
        NULL, NULL, 1, 0, NULL,
        54.00, 500.0, N'g', 43, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Combos para compartir',
        descripcion = N'Dos cortes de churrasco.',
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 54.00,
        peso_cantidad = 500.0,
        peso_unidad = N'g',
        orden = 43,
        activo = 1
    WHERE id_categoria = 'combos' 
      AND (grupo_comercial = N'Combos personales' OR (grupo_comercial IS NULL AND N'Combos personales' IS NULL))
      AND nombre = N'Cuatrero';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'combos' 
      AND (grupo_comercial = N'Combos personales' OR (grupo_comercial IS NULL AND N'Combos personales' IS NULL))
      AND nombre = N'Cuatrero mix'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Cuatrero mix', N'Combos para compartir', 'combos', N'Combos personales', N'Un corte de churrasco y un corte de cerdo.',
        NULL, NULL, 1, 0, NULL,
        54.00, 500.0, N'g', 44, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Combos para compartir',
        descripcion = N'Un corte de churrasco y un corte de cerdo.',
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 1,
        destacado = 0,
        imagen = NULL,
        precio = 54.00,
        peso_cantidad = 500.0,
        peso_unidad = N'g',
        orden = 44,
        activo = 1
    WHERE id_categoria = 'combos' 
      AND (grupo_comercial = N'Combos personales' OR (grupo_comercial IS NULL AND N'Combos personales' IS NULL))
      AND nombre = N'Cuatrero mix';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'ensaladas' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Ensalada mixta clásica'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Ensalada mixta clásica', N'Ensaladas', 'ensaladas', NULL, N'Lechuga, tomate, pepinillo, zanahoria, beterraga, palta y aliño de la casa.',
        NULL, NULL, 0, 0, NULL,
        15.00, NULL, NULL, 45, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Ensaladas',
        descripcion = N'Lechuga, tomate, pepinillo, zanahoria, beterraga, palta y aliño de la casa.',
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 15.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 45,
        activo = 1
    WHERE id_categoria = 'ensaladas' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Ensalada mixta clásica';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'ensaladas' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Ensalada mixta personal'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Ensalada mixta personal', N'Ensaladas', 'ensaladas', NULL, N'Lechuga, tomate, pepinillo, zanahoria, beterraga, palta y aliño de la casa.',
        NULL, NULL, 0, 0, NULL,
        10.00, NULL, NULL, 46, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Ensaladas',
        descripcion = N'Lechuga, tomate, pepinillo, zanahoria, beterraga, palta y aliño de la casa.',
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 10.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 46,
        activo = 1
    WHERE id_categoria = 'ensaladas' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Ensalada mixta personal';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'ensaladas' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Ensalada César al estilo Cuatrero'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Ensalada César al estilo Cuatrero', N'Ensaladas', 'ensaladas', NULL, N'Lechuga romana, tocino en cuadraditos, queso parmesano rallado y fajitas de pollo con aliño de la casa.',
        NULL, NULL, 0, 0, NULL,
        26.00, NULL, NULL, 47, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Ensaladas',
        descripcion = N'Lechuga romana, tocino en cuadraditos, queso parmesano rallado y fajitas de pollo con aliño de la casa.',
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 26.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 47,
        activo = 1
    WHERE id_categoria = 'ensaladas' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Ensalada César al estilo Cuatrero';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'ensaladas' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Ensalada de palta'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Ensalada de palta', N'Ensaladas', 'ensaladas', NULL, N'Palta entera y zanahoria con aliño de la casa.',
        NULL, NULL, 0, 0, NULL,
        15.00, NULL, NULL, 48, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Ensaladas',
        descripcion = N'Palta entera y zanahoria con aliño de la casa.',
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 15.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 48,
        activo = 1
    WHERE id_categoria = 'ensaladas' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Ensalada de palta';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'acompanamientos' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Porción de papas fritas'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Porción de papas fritas', N'Acompañamientos', 'acompanamientos', NULL, NULL,
        NULL, NULL, 0, 0, NULL,
        14.00, NULL, NULL, 49, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Acompañamientos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 14.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 49,
        activo = 1
    WHERE id_categoria = 'acompanamientos' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Porción de papas fritas';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'acompanamientos' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Plato compartido de papas fritas'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Plato compartido de papas fritas', N'Acompañamientos', 'acompanamientos', NULL, NULL,
        NULL, NULL, 0, 0, NULL,
        8.00, NULL, NULL, 50, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Acompañamientos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 8.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 50,
        activo = 1
    WHERE id_categoria = 'acompanamientos' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Plato compartido de papas fritas';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'acompanamientos' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Porción de papa sancochada'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Porción de papa sancochada', N'Acompañamientos', 'acompanamientos', NULL, NULL,
        NULL, NULL, 0, 0, NULL,
        14.00, NULL, NULL, 51, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Acompañamientos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 14.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 51,
        activo = 1
    WHERE id_categoria = 'acompanamientos' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Porción de papa sancochada';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'acompanamientos' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Salsa BBQ'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Salsa BBQ', N'Acompañamientos', 'acompanamientos', NULL, NULL,
        NULL, NULL, 0, 0, NULL,
        10.00, NULL, NULL, 52, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Acompañamientos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 10.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 52,
        activo = 1
    WHERE id_categoria = 'acompanamientos' 
      AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
      AND nombre = N'Salsa BBQ';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Gaseosas' OR (grupo_comercial IS NULL AND N'Gaseosas' IS NULL))
      AND nombre = N'Gaseosa Coca Cola'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Gaseosa Coca Cola', N'Bebidas', 'bebidas', N'Gaseosas', NULL,
        NULL, NULL, 0, 0, NULL,
        8.00, 1.0, N'L', 53, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 8.00,
        peso_cantidad = 1.0,
        peso_unidad = N'L',
        orden = 53,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Gaseosas' OR (grupo_comercial IS NULL AND N'Gaseosas' IS NULL))
      AND nombre = N'Gaseosa Coca Cola';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Gaseosas' OR (grupo_comercial IS NULL AND N'Gaseosas' IS NULL))
      AND nombre = N'Gaseosa Inca Kola'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Gaseosa Inca Kola', N'Bebidas', 'bebidas', N'Gaseosas', NULL,
        NULL, NULL, 0, 0, NULL,
        8.00, 1.0, N'L', 54, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 8.00,
        peso_cantidad = 1.0,
        peso_unidad = N'L',
        orden = 54,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Gaseosas' OR (grupo_comercial IS NULL AND N'Gaseosas' IS NULL))
      AND nombre = N'Gaseosa Inca Kola';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Gaseosas' OR (grupo_comercial IS NULL AND N'Gaseosas' IS NULL))
      AND nombre = N'Gaseosa personal'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Gaseosa personal', N'Bebidas', 'bebidas', N'Gaseosas', NULL,
        NULL, NULL, 0, 0, NULL,
        3.00, 296.0, N'ml', 55, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 3.00,
        peso_cantidad = 296.0,
        peso_unidad = N'ml',
        orden = 55,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Gaseosas' OR (grupo_comercial IS NULL AND N'Gaseosas' IS NULL))
      AND nombre = N'Gaseosa personal';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Gaseosas' OR (grupo_comercial IS NULL AND N'Gaseosas' IS NULL))
      AND nombre = N'Coca Cola Zero'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Coca Cola Zero', N'Bebidas', 'bebidas', N'Gaseosas', NULL,
        NULL, NULL, 0, 0, NULL,
        4.00, 500.0, N'ml', 56, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 4.00,
        peso_cantidad = 500.0,
        peso_unidad = N'ml',
        orden = 56,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Gaseosas' OR (grupo_comercial IS NULL AND N'Gaseosas' IS NULL))
      AND nombre = N'Coca Cola Zero';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Gaseosas' OR (grupo_comercial IS NULL AND N'Gaseosas' IS NULL))
      AND nombre = N'Inca Kola Zero'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Inca Kola Zero', N'Bebidas', 'bebidas', N'Gaseosas', NULL,
        NULL, NULL, 0, 0, NULL,
        4.00, 500.0, N'ml', 57, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 4.00,
        peso_cantidad = 500.0,
        peso_unidad = N'ml',
        orden = 57,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Gaseosas' OR (grupo_comercial IS NULL AND N'Gaseosas' IS NULL))
      AND nombre = N'Inca Kola Zero';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Gaseosas' OR (grupo_comercial IS NULL AND N'Gaseosas' IS NULL))
      AND nombre = N'Agua con gas o sin gas'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Agua con gas o sin gas', N'Bebidas', 'bebidas', N'Gaseosas', NULL,
        NULL, NULL, 0, 0, NULL,
        3.00, 625.0, N'ml', 58, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 3.00,
        peso_cantidad = 625.0,
        peso_unidad = N'ml',
        orden = 58,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Gaseosas' OR (grupo_comercial IS NULL AND N'Gaseosas' IS NULL))
      AND nombre = N'Agua con gas o sin gas';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Limonadas' OR (grupo_comercial IS NULL AND N'Limonadas' IS NULL))
      AND nombre = N'Jarra de limonada clásica'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Jarra de limonada clásica', N'Bebidas', 'bebidas', N'Limonadas', NULL,
        NULL, NULL, 0, 0, NULL,
        13.00, NULL, NULL, 59, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 13.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 59,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Limonadas' OR (grupo_comercial IS NULL AND N'Limonadas' IS NULL))
      AND nombre = N'Jarra de limonada clásica';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Limonadas' OR (grupo_comercial IS NULL AND N'Limonadas' IS NULL))
      AND nombre = N'Jarra de limonada cherry'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Jarra de limonada cherry', N'Bebidas', 'bebidas', N'Limonadas', NULL,
        NULL, NULL, 0, 0, NULL,
        15.00, NULL, NULL, 60, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 15.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 60,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Limonadas' OR (grupo_comercial IS NULL AND N'Limonadas' IS NULL))
      AND nombre = N'Jarra de limonada cherry';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Limonadas' OR (grupo_comercial IS NULL AND N'Limonadas' IS NULL))
      AND nombre = N'Jarra de limonada menta'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Jarra de limonada menta', N'Bebidas', 'bebidas', N'Limonadas', NULL,
        NULL, NULL, 0, 0, NULL,
        15.00, NULL, NULL, 61, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 15.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 61,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Limonadas' OR (grupo_comercial IS NULL AND N'Limonadas' IS NULL))
      AND nombre = N'Jarra de limonada menta';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Limonadas' OR (grupo_comercial IS NULL AND N'Limonadas' IS NULL))
      AND nombre = N'Jarra de limonada africana'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Jarra de limonada africana', N'Bebidas', 'bebidas', N'Limonadas', NULL,
        NULL, NULL, 0, 0, NULL,
        15.00, NULL, NULL, 62, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 15.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 62,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Limonadas' OR (grupo_comercial IS NULL AND N'Limonadas' IS NULL))
      AND nombre = N'Jarra de limonada africana';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Limonadas' OR (grupo_comercial IS NULL AND N'Limonadas' IS NULL))
      AND nombre = N'Jarra de limonada tropical'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Jarra de limonada tropical', N'Bebidas', 'bebidas', N'Limonadas', NULL,
        NULL, NULL, 0, 0, NULL,
        15.00, NULL, NULL, 63, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 15.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 63,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Limonadas' OR (grupo_comercial IS NULL AND N'Limonadas' IS NULL))
      AND nombre = N'Jarra de limonada tropical';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Limonadas' OR (grupo_comercial IS NULL AND N'Limonadas' IS NULL))
      AND nombre = N'Jarra de limonada eléctrica'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Jarra de limonada eléctrica', N'Bebidas', 'bebidas', N'Limonadas', NULL,
        NULL, NULL, 0, 0, NULL,
        17.00, NULL, NULL, 64, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 17.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 64,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Limonadas' OR (grupo_comercial IS NULL AND N'Limonadas' IS NULL))
      AND nombre = N'Jarra de limonada eléctrica';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
      AND nombre = N'Jarra de chicha morada'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Jarra de chicha morada', N'Bebidas', 'bebidas', N'Jarras', NULL,
        NULL, NULL, 0, 0, NULL,
        15.00, NULL, NULL, 65, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 15.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 65,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
      AND nombre = N'Jarra de chicha morada';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
      AND nombre = N'Jarra de maracuyá'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Jarra de maracuyá', N'Bebidas', 'bebidas', N'Jarras', NULL,
        NULL, NULL, 0, 0, NULL,
        18.00, NULL, NULL, 66, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 18.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 66,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
      AND nombre = N'Jarra de maracuyá';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
      AND nombre = N'Jarra de naranjada'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Jarra de naranjada', N'Bebidas', 'bebidas', N'Jarras', NULL,
        NULL, NULL, 0, 0, NULL,
        18.00, NULL, NULL, 67, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 18.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 67,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
      AND nombre = N'Jarra de naranjada';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
      AND nombre = N'Jarra de jugo de piña'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Jarra de jugo de piña', N'Bebidas', 'bebidas', N'Jarras', NULL,
        NULL, NULL, 0, 0, NULL,
        18.00, NULL, NULL, 68, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 18.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 68,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
      AND nombre = N'Jarra de jugo de piña';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
      AND nombre = N'Jarra de jugo de durazno'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Jarra de jugo de durazno', N'Bebidas', 'bebidas', N'Jarras', NULL,
        NULL, NULL, 0, 0, NULL,
        18.00, NULL, NULL, 69, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 18.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 69,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
      AND nombre = N'Jarra de jugo de durazno';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
      AND nombre = N'Copa de sangría'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Copa de sangría', N'Bebidas', 'bebidas', N'Jarras', NULL,
        NULL, NULL, 0, 0, NULL,
        20.00, NULL, NULL, 70, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 20.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 70,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
      AND nombre = N'Copa de sangría';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
      AND nombre = N'Jarra de sangría de vino'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Jarra de sangría de vino', N'Bebidas', 'bebidas', N'Jarras', NULL,
        NULL, NULL, 0, 0, NULL,
        55.00, NULL, N'Jarra', 71, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 55.00,
        peso_cantidad = NULL,
        peso_unidad = N'Jarra',
        orden = 71,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
      AND nombre = N'Jarra de sangría de vino';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
      AND nombre = N'Jugo de naranja'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Jugo de naranja', N'Bebidas', 'bebidas', N'Jugos 16 oz', NULL,
        NULL, NULL, 0, 0, NULL,
        8.00, NULL, NULL, 72, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 8.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 72,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
      AND nombre = N'Jugo de naranja';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
      AND nombre = N'Jugo de chicha morada'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Jugo de chicha morada', N'Bebidas', 'bebidas', N'Jugos 16 oz', NULL,
        NULL, NULL, 0, 0, NULL,
        8.00, NULL, NULL, 73, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 8.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 73,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
      AND nombre = N'Jugo de chicha morada';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
      AND nombre = N'Jugo de limonada'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Jugo de limonada', N'Bebidas', 'bebidas', N'Jugos 16 oz', NULL,
        NULL, NULL, 0, 0, NULL,
        6.00, NULL, NULL, 74, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 6.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 74,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
      AND nombre = N'Jugo de limonada';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
      AND nombre = N'Jugo de piña'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Jugo de piña', N'Bebidas', 'bebidas', N'Jugos 16 oz', NULL,
        NULL, NULL, 0, 0, NULL,
        8.00, NULL, NULL, 75, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 8.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 75,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
      AND nombre = N'Jugo de piña';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
      AND nombre = N'Jugo de durazno'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Jugo de durazno', N'Bebidas', 'bebidas', N'Jugos 16 oz', NULL,
        NULL, NULL, 0, 0, NULL,
        8.00, NULL, NULL, 76, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 8.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 76,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
      AND nombre = N'Jugo de durazno';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
      AND nombre = N'Jugo de fresa'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Jugo de fresa', N'Bebidas', 'bebidas', N'Jugos 16 oz', NULL,
        NULL, NULL, 0, 0, NULL,
        9.00, NULL, NULL, 77, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 9.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 77,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
      AND nombre = N'Jugo de fresa';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
      AND nombre = N'Jugo de mango'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Jugo de mango', N'Bebidas', 'bebidas', N'Jugos 16 oz', NULL,
        NULL, NULL, 0, 0, NULL,
        9.00, NULL, NULL, 78, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 9.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 78,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
      AND nombre = N'Jugo de mango';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Infusiones' OR (grupo_comercial IS NULL AND N'Infusiones' IS NULL))
      AND nombre = N'Té, anís o manzanilla'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Té, anís o manzanilla', N'Bebidas', 'bebidas', N'Infusiones', NULL,
        NULL, NULL, 0, 0, NULL,
        4.00, NULL, NULL, 79, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 4.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 79,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Infusiones' OR (grupo_comercial IS NULL AND N'Infusiones' IS NULL))
      AND nombre = N'Té, anís o manzanilla';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Infusiones' OR (grupo_comercial IS NULL AND N'Infusiones' IS NULL))
      AND nombre = N'Café pasado'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Café pasado', N'Bebidas', 'bebidas', N'Infusiones', NULL,
        NULL, NULL, 0, 0, NULL,
        6.00, NULL, NULL, 80, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 6.00,
        peso_cantidad = NULL,
        peso_unidad = NULL,
        orden = 80,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Infusiones' OR (grupo_comercial IS NULL AND N'Infusiones' IS NULL))
      AND nombre = N'Café pasado';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
      AND nombre = N'Malta Cuzqueña'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Malta Cuzqueña', N'Bebidas', 'bebidas', N'Cervezas', NULL,
        NULL, NULL, 0, 0, NULL,
        10.00, 330.0, N'ml', 81, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 10.00,
        peso_cantidad = 330.0,
        peso_unidad = N'ml',
        orden = 81,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
      AND nombre = N'Malta Cuzqueña';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
      AND nombre = N'Cuzqueña Premium'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Cuzqueña Premium', N'Bebidas', 'bebidas', N'Cervezas', NULL,
        NULL, NULL, 0, 0, NULL,
        10.00, 330.0, N'ml', 82, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 10.00,
        peso_cantidad = 330.0,
        peso_unidad = N'ml',
        orden = 82,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
      AND nombre = N'Cuzqueña Premium';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
      AND nombre = N'Cuzqueña Trigo'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Cuzqueña Trigo', N'Bebidas', 'bebidas', N'Cervezas', NULL,
        NULL, NULL, 0, 0, NULL,
        10.00, 330.0, N'ml', 83, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 10.00,
        peso_cantidad = 330.0,
        peso_unidad = N'ml',
        orden = 83,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
      AND nombre = N'Cuzqueña Trigo';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
      AND nombre = N'Pilsen Callao'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Pilsen Callao', N'Bebidas', 'bebidas', N'Cervezas', NULL,
        NULL, NULL, 0, 0, NULL,
        8.00, 310.0, N'ml', 84, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 8.00,
        peso_cantidad = 310.0,
        peso_unidad = N'ml',
        orden = 84,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
      AND nombre = N'Pilsen Callao';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
      AND nombre = N'Cerveza Corona'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Cerveza Corona', N'Bebidas', 'bebidas', N'Cervezas', NULL,
        NULL, NULL, 0, 0, NULL,
        12.00, 350.0, N'ml', 85, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 12.00,
        peso_cantidad = 350.0,
        peso_unidad = N'ml',
        orden = 85,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
      AND nombre = N'Cerveza Corona';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
      AND nombre = N'Cerveza Budweiser'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Cerveza Budweiser', N'Bebidas', 'bebidas', N'Cervezas', NULL,
        NULL, NULL, 0, 0, NULL,
        12.00, 343.0, N'ml', 86, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 12.00,
        peso_cantidad = 343.0,
        peso_unidad = N'ml',
        orden = 86,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
      AND nombre = N'Cerveza Budweiser';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
      AND nombre = N'Cerveza Stella Artois'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Cerveza Stella Artois', N'Bebidas', 'bebidas', N'Cervezas', NULL,
        NULL, NULL, 0, 0, NULL,
        12.00, 343.0, N'ml', 87, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 12.00,
        peso_cantidad = 343.0,
        peso_unidad = N'ml',
        orden = 87,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
      AND nombre = N'Cerveza Stella Artois';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
      AND nombre = N'Costera Río Rojo'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Costera Río Rojo', N'Bebidas', 'bebidas', N'Cervezas', NULL,
        NULL, NULL, 0, 0, NULL,
        16.00, 330.0, N'ml', 88, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 16.00,
        peso_cantidad = 330.0,
        peso_unidad = N'ml',
        orden = 88,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
      AND nombre = N'Costera Río Rojo';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
      AND nombre = N'Costera IPA'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Costera IPA', N'Bebidas', 'bebidas', N'Cervezas', NULL,
        NULL, NULL, 0, 0, NULL,
        16.00, 330.0, N'ml', 89, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Bebidas',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 16.00,
        peso_cantidad = 330.0,
        peso_unidad = N'ml',
        orden = 89,
        activo = 1
    WHERE id_categoria = 'bebidas' 
      AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
      AND nombre = N'Costera IPA';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
      AND nombre = N'Tacama Selección Especial'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Tacama Selección Especial', N'Vinos', 'vinos', N'Perú', NULL,
        NULL, N'Perú', 0, 0, NULL,
        38.00, 750.0, N'ml', 90, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Vinos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = N'Perú',
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 38.00,
        peso_cantidad = 750.0,
        peso_unidad = N'ml',
        orden = 90,
        activo = 1
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
      AND nombre = N'Tacama Selección Especial';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
      AND nombre = N'Tacama Gran Tinto'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Tacama Gran Tinto', N'Vinos', 'vinos', N'Perú', NULL,
        NULL, N'Perú', 0, 0, NULL,
        25.00, 750.0, N'ml', 91, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Vinos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = N'Perú',
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 25.00,
        peso_cantidad = 750.0,
        peso_unidad = N'ml',
        orden = 91,
        activo = 1
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
      AND nombre = N'Tacama Gran Tinto';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
      AND nombre = N'Tacama Blanco de Blancos'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Tacama Blanco de Blancos', N'Vinos', 'vinos', N'Perú', NULL,
        NULL, N'Perú', 0, 0, NULL,
        65.00, 750.0, N'ml', 92, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Vinos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = N'Perú',
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 65.00,
        peso_cantidad = 750.0,
        peso_unidad = N'ml',
        orden = 92,
        activo = 1
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
      AND nombre = N'Tacama Blanco de Blancos';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
      AND nombre = N'Rubini Ocucaje'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Rubini Ocucaje', N'Vinos', 'vinos', N'Perú', NULL,
        NULL, N'Perú', 0, 0, NULL,
        110.00, 750.0, N'ml', 93, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Vinos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = N'Perú',
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 110.00,
        peso_cantidad = 750.0,
        peso_unidad = N'ml',
        orden = 93,
        activo = 1
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
      AND nombre = N'Rubini Ocucaje';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
      AND nombre = N'Fond de Cave'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Fond de Cave', N'Vinos', 'vinos', N'Perú', NULL,
        NULL, N'Perú', 0, 0, NULL,
        24.00, 750.0, N'ml', 94, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Vinos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = N'Perú',
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 24.00,
        peso_cantidad = 750.0,
        peso_unidad = N'ml',
        orden = 94,
        activo = 1
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
      AND nombre = N'Fond de Cave';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
      AND nombre = N'Intipalka Valle del Sol'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Intipalka Valle del Sol', N'Vinos', 'vinos', N'Perú', NULL,
        NULL, N'Perú', 0, 0, NULL,
        65.00, 750.0, N'ml', 95, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Vinos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = N'Perú',
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 65.00,
        peso_cantidad = 750.0,
        peso_unidad = N'ml',
        orden = 95,
        activo = 1
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
      AND nombre = N'Intipalka Valle del Sol';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
      AND nombre = N'Tabernero'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Tabernero', N'Vinos', 'vinos', N'Perú', NULL,
        NULL, N'Perú', 0, 0, NULL,
        24.00, 750.0, N'ml', 96, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Vinos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = N'Perú',
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 24.00,
        peso_cantidad = 750.0,
        peso_unidad = N'ml',
        orden = 96,
        activo = 1
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
      AND nombre = N'Tabernero';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
      AND nombre = N'Tabernero Gran Tinto Fina Reserva'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Tabernero Gran Tinto Fina Reserva', N'Vinos', 'vinos', N'Perú', NULL,
        NULL, N'Perú', 0, 0, NULL,
        22.00, 750.0, N'ml', 97, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Vinos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = N'Perú',
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 22.00,
        peso_cantidad = 750.0,
        peso_unidad = N'ml',
        orden = 97,
        activo = 1
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
      AND nombre = N'Tabernero Gran Tinto Fina Reserva';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
      AND nombre = N'Tabernero Blanco de Blancos'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Tabernero Blanco de Blancos', N'Vinos', 'vinos', N'Perú', NULL,
        NULL, N'Perú', 0, 0, NULL,
        40.00, 750.0, N'ml', 98, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Vinos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = N'Perú',
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 40.00,
        peso_cantidad = 750.0,
        peso_unidad = N'ml',
        orden = 98,
        activo = 1
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
      AND nombre = N'Tabernero Blanco de Blancos';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
      AND nombre = N'Escorihuela Gascón'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Escorihuela Gascón', N'Vinos', 'vinos', N'Argentina', NULL,
        NULL, N'Argentina', 0, 0, NULL,
        80.00, 750.0, N'ml', 99, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Vinos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = N'Argentina',
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 80.00,
        peso_cantidad = 750.0,
        peso_unidad = N'ml',
        orden = 99,
        activo = 1
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
      AND nombre = N'Escorihuela Gascón';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
      AND nombre = N'Nieto Senetiner'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Nieto Senetiner', N'Vinos', 'vinos', N'Argentina', NULL,
        NULL, N'Argentina', 0, 0, NULL,
        75.00, 750.0, N'ml', 100, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Vinos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = N'Argentina',
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 75.00,
        peso_cantidad = 750.0,
        peso_unidad = N'ml',
        orden = 100,
        activo = 1
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
      AND nombre = N'Nieto Senetiner';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
      AND nombre = N'Alegoría Gran Reserva'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Alegoría Gran Reserva', N'Vinos', 'vinos', N'Argentina', NULL,
        NULL, N'Argentina', 0, 0, NULL,
        130.00, 750.0, N'ml', 101, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Vinos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = N'Argentina',
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 130.00,
        peso_cantidad = 750.0,
        peso_unidad = N'ml',
        orden = 101,
        activo = 1
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
      AND nombre = N'Alegoría Gran Reserva';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
      AND nombre = N'Selección de Parcelas Reserva'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Selección de Parcelas Reserva', N'Vinos', 'vinos', N'Argentina', NULL,
        NULL, N'Argentina', 0, 0, NULL,
        100.00, 750.0, N'ml', 102, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Vinos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = N'Argentina',
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 100.00,
        peso_cantidad = 750.0,
        peso_unidad = N'ml',
        orden = 102,
        activo = 1
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
      AND nombre = N'Selección de Parcelas Reserva';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
      AND nombre = N'Navarro Correas'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Navarro Correas', N'Vinos', 'vinos', N'Argentina', NULL,
        NULL, N'Argentina', 0, 0, NULL,
        80.00, 750.0, N'ml', 103, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Vinos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = N'Argentina',
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 80.00,
        peso_cantidad = 750.0,
        peso_unidad = N'ml',
        orden = 103,
        activo = 1
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
      AND nombre = N'Navarro Correas';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
      AND nombre = N'Navarro Correas Blend'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Navarro Correas Blend', N'Vinos', 'vinos', N'Argentina', NULL,
        NULL, N'Argentina', 0, 0, NULL,
        80.00, 750.0, N'ml', 104, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Vinos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = N'Argentina',
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 80.00,
        peso_cantidad = 750.0,
        peso_unidad = N'ml',
        orden = 104,
        activo = 1
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
      AND nombre = N'Navarro Correas Blend';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
      AND nombre = N'Los Árboles'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Los Árboles', N'Vinos', 'vinos', N'Argentina', NULL,
        NULL, N'Argentina', 0, 0, NULL,
        55.00, 750.0, N'ml', 105, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Vinos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = N'Argentina',
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 55.00,
        peso_cantidad = 750.0,
        peso_unidad = N'ml',
        orden = 105,
        activo = 1
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
      AND nombre = N'Los Árboles';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
      AND nombre = N'La Celia'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'La Celia', N'Vinos', 'vinos', N'Argentina', NULL,
        NULL, N'Argentina', 0, 0, NULL,
        80.00, 750.0, N'ml', 106, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Vinos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = N'Argentina',
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 80.00,
        peso_cantidad = 750.0,
        peso_unidad = N'ml',
        orden = 106,
        activo = 1
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
      AND nombre = N'La Celia';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
      AND nombre = N'Séptima'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Séptima', N'Vinos', 'vinos', N'Argentina', NULL,
        NULL, N'Argentina', 0, 0, NULL,
        65.00, 750.0, N'ml', 107, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Vinos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = N'Argentina',
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 65.00,
        peso_cantidad = 750.0,
        peso_unidad = N'ml',
        orden = 107,
        activo = 1
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
      AND nombre = N'Séptima';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
      AND nombre = N'Errazuris Reserva'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Errazuris Reserva', N'Vinos', 'vinos', N'Chile', NULL,
        NULL, N'Chile', 0, 0, NULL,
        65.00, 750.0, N'ml', 108, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Vinos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = N'Chile',
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 65.00,
        peso_cantidad = 750.0,
        peso_unidad = N'ml',
        orden = 108,
        activo = 1
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
      AND nombre = N'Errazuris Reserva';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
      AND nombre = N'Cousiño Macul Antiguas Reservas'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Cousiño Macul Antiguas Reservas', N'Vinos', 'vinos', N'Chile', NULL,
        NULL, N'Chile', 0, 0, NULL,
        80.00, 750.0, N'ml', 109, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Vinos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = N'Chile',
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 80.00,
        peso_cantidad = 750.0,
        peso_unidad = N'ml',
        orden = 109,
        activo = 1
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
      AND nombre = N'Cousiño Macul Antiguas Reservas';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
      AND nombre = N'Cousiño Macul Don Matías Reserva'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Cousiño Macul Don Matías Reserva', N'Vinos', 'vinos', N'Chile', NULL,
        NULL, N'Chile', 0, 0, NULL,
        70.00, 750.0, N'ml', 110, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Vinos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = N'Chile',
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 70.00,
        peso_cantidad = 750.0,
        peso_unidad = N'ml',
        orden = 110,
        activo = 1
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
      AND nombre = N'Cousiño Macul Don Matías Reserva';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
      AND nombre = N'Cousiño Macul Don Luis'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Cousiño Macul Don Luis', N'Vinos', 'vinos', N'Chile', NULL,
        NULL, N'Chile', 0, 0, NULL,
        55.00, 750.0, N'ml', 111, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Vinos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = N'Chile',
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 55.00,
        peso_cantidad = 750.0,
        peso_unidad = N'ml',
        orden = 111,
        activo = 1
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
      AND nombre = N'Cousiño Macul Don Luis';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
      AND nombre = N'Marqués de Casa Concha'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Marqués de Casa Concha', N'Vinos', 'vinos', N'Chile', NULL,
        NULL, N'Chile', 0, 0, NULL,
        110.00, 750.0, N'ml', 112, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Vinos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = N'Chile',
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 110.00,
        peso_cantidad = 750.0,
        peso_unidad = N'ml',
        orden = 112,
        activo = 1
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
      AND nombre = N'Marqués de Casa Concha';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
      AND nombre = N'Casillero del Diablo Reserva Privada'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Casillero del Diablo Reserva Privada', N'Vinos', 'vinos', N'Chile', NULL,
        NULL, N'Chile', 0, 0, NULL,
        90.00, 750.0, N'ml', 113, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Vinos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = N'Chile',
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 90.00,
        peso_cantidad = 750.0,
        peso_unidad = N'ml',
        orden = 113,
        activo = 1
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
      AND nombre = N'Casillero del Diablo Reserva Privada';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
      AND nombre = N'Casillero del Diablo Reserva'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Casillero del Diablo Reserva', N'Vinos', 'vinos', N'Chile', NULL,
        NULL, N'Chile', 0, 0, NULL,
        30.00, 750.0, N'ml', 114, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Vinos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = N'Chile',
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 30.00,
        peso_cantidad = 750.0,
        peso_unidad = N'ml',
        orden = 114,
        activo = 1
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
      AND nombre = N'Casillero del Diablo Reserva';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
      AND nombre = N'Concha y Toro Frontera'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Concha y Toro Frontera', N'Vinos', 'vinos', N'Chile', NULL,
        NULL, N'Chile', 0, 0, NULL,
        40.00, 750.0, N'ml', 115, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Vinos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = N'Chile',
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 40.00,
        peso_cantidad = 750.0,
        peso_unidad = N'ml',
        orden = 115,
        activo = 1
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
      AND nombre = N'Concha y Toro Frontera';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'España' OR (grupo_comercial IS NULL AND N'España' IS NULL))
      AND nombre = N'Herederos del Marqués de Riscal'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Herederos del Marqués de Riscal', N'Vinos', 'vinos', N'España', NULL,
        NULL, N'España', 0, 0, NULL,
        75.00, 750.0, N'ml', 116, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Vinos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = N'España',
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 75.00,
        peso_cantidad = 750.0,
        peso_unidad = N'ml',
        orden = 116,
        activo = 1
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'España' OR (grupo_comercial IS NULL AND N'España' IS NULL))
      AND nombre = N'Herederos del Marqués de Riscal';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'España' OR (grupo_comercial IS NULL AND N'España' IS NULL))
      AND nombre = N'Protos Roble'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Protos Roble', N'Vinos', 'vinos', N'España', NULL,
        NULL, N'España', 0, 0, NULL,
        75.00, 750.0, N'ml', 117, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Vinos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = N'España',
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 75.00,
        peso_cantidad = 750.0,
        peso_unidad = N'ml',
        orden = 117,
        activo = 1
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'España' OR (grupo_comercial IS NULL AND N'España' IS NULL))
      AND nombre = N'Protos Roble';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Blancos' OR (grupo_comercial IS NULL AND N'Blancos' IS NULL))
      AND nombre = N'Tacama Blanco de Blancos'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Tacama Blanco de Blancos', N'Vinos', 'vinos', N'Blancos', NULL,
        NULL, NULL, 0, 0, NULL,
        65.00, 750.0, N'ml', 118, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Vinos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 65.00,
        peso_cantidad = 750.0,
        peso_unidad = N'ml',
        orden = 118,
        activo = 1
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Blancos' OR (grupo_comercial IS NULL AND N'Blancos' IS NULL))
      AND nombre = N'Tacama Blanco de Blancos';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Blancos' OR (grupo_comercial IS NULL AND N'Blancos' IS NULL))
      AND nombre = N'Tabernero Blanco de Blancos'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Tabernero Blanco de Blancos', N'Vinos', 'vinos', N'Blancos', NULL,
        NULL, NULL, 0, 0, NULL,
        40.00, 750.0, N'ml', 119, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Vinos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 40.00,
        peso_cantidad = 750.0,
        peso_unidad = N'ml',
        orden = 119,
        activo = 1
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Blancos' OR (grupo_comercial IS NULL AND N'Blancos' IS NULL))
      AND nombre = N'Tabernero Blanco de Blancos';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.producto_carta 
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Blancos' OR (grupo_comercial IS NULL AND N'Blancos' IS NULL))
      AND nombre = N'Selección de Parcelas Reserva'
)
BEGIN
    INSERT INTO dbo.producto_carta (
        nombre, categoria, id_categoria, grupo_comercial, descripcion, 
        id_tipo_corte, pais_origen, es_apto_favorito, destacado, imagen, 
        precio, peso_cantidad, peso_unidad, orden, activo
    )
    VALUES (
        N'Selección de Parcelas Reserva', N'Vinos', 'vinos', N'Blancos', NULL,
        NULL, NULL, 0, 0, NULL,
        95.00, 750.0, N'ml', 120, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.producto_carta SET
        categoria = N'Vinos',
        descripcion = NULL,
        id_tipo_corte = NULL,
        pais_origen = NULL,
        es_apto_favorito = 0,
        destacado = 0,
        imagen = NULL,
        precio = 95.00,
        peso_cantidad = 750.0,
        peso_unidad = N'ml',
        orden = 120,
        activo = 1
    WHERE id_categoria = 'vinos' 
      AND (grupo_comercial = N'Blancos' OR (grupo_comercial IS NULL AND N'Blancos' IS NULL))
      AND nombre = N'Selección de Parcelas Reserva';
END
GO
PRINT 'Productos lógicos cargados / actualizados con éxito.';
GO

-- 2. CARGA DE PRESENTACIONES (146 PRESENTACIONES)

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Angus · Americana y uruguaya' OR (grupo_comercial IS NULL AND N'Angus · Americana y uruguaya' IS NULL))
              AND nombre = N'Asado de tira de res'
        )
      AND nombre_presentacion = N'500 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Angus · Americana y uruguaya' OR (grupo_comercial IS NULL AND N'Angus · Americana y uruguaya' IS NULL))
              AND nombre = N'Asado de tira de res'
        ), N'500 g', 115.00, 500.0,
        N'g', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 115.00,
        peso_volumen_cantidad = 500.0,
        unidad_medida = N'g',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Angus · Americana y uruguaya' OR (grupo_comercial IS NULL AND N'Angus · Americana y uruguaya' IS NULL))
              AND nombre = N'Asado de tira de res'
        )
      AND nombre_presentacion = N'500 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Angus · Americana y uruguaya' OR (grupo_comercial IS NULL AND N'Angus · Americana y uruguaya' IS NULL))
              AND nombre = N'Entraña fina'
        )
      AND nombre_presentacion = N'400 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Angus · Americana y uruguaya' OR (grupo_comercial IS NULL AND N'Angus · Americana y uruguaya' IS NULL))
              AND nombre = N'Entraña fina'
        ), N'400 g', 125.00, 400.0,
        N'g', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 125.00,
        peso_volumen_cantidad = 400.0,
        unidad_medida = N'g',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Angus · Americana y uruguaya' OR (grupo_comercial IS NULL AND N'Angus · Americana y uruguaya' IS NULL))
              AND nombre = N'Entraña fina'
        )
      AND nombre_presentacion = N'400 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Angus · Americana y uruguaya' OR (grupo_comercial IS NULL AND N'Angus · Americana y uruguaya' IS NULL))
              AND nombre = N'Beefe angosto'
        )
      AND nombre_presentacion = N'400 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Angus · Americana y uruguaya' OR (grupo_comercial IS NULL AND N'Angus · Americana y uruguaya' IS NULL))
              AND nombre = N'Beefe angosto'
        ), N'400 g', 100.00, 400.0,
        N'g', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 100.00,
        peso_volumen_cantidad = 400.0,
        unidad_medida = N'g',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Angus · Americana y uruguaya' OR (grupo_comercial IS NULL AND N'Angus · Americana y uruguaya' IS NULL))
              AND nombre = N'Beefe angosto'
        )
      AND nombre_presentacion = N'400 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Angus · Americana y uruguaya' OR (grupo_comercial IS NULL AND N'Angus · Americana y uruguaya' IS NULL))
              AND nombre = N'Picanha'
        )
      AND nombre_presentacion = N'400 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Angus · Americana y uruguaya' OR (grupo_comercial IS NULL AND N'Angus · Americana y uruguaya' IS NULL))
              AND nombre = N'Picanha'
        ), N'400 g', 115.00, 400.0,
        N'g', NULL, NULL, 1,
        N'/img/picanha.jpg', 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 115.00,
        peso_volumen_cantidad = 400.0,
        unidad_medida = N'g',
        descripcion_presentacion = NULL,
        destacado = 1,
        imagen = N'/img/picanha.jpg',
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Angus · Americana y uruguaya' OR (grupo_comercial IS NULL AND N'Angus · Americana y uruguaya' IS NULL))
              AND nombre = N'Picanha'
        )
      AND nombre_presentacion = N'400 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Angus · Americana y uruguaya' OR (grupo_comercial IS NULL AND N'Angus · Americana y uruguaya' IS NULL))
              AND nombre = N'Beefe ancho'
        )
      AND nombre_presentacion = N'400 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Angus · Americana y uruguaya' OR (grupo_comercial IS NULL AND N'Angus · Americana y uruguaya' IS NULL))
              AND nombre = N'Beefe ancho'
        ), N'400 g', 105.00, 400.0,
        N'g', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 105.00,
        peso_volumen_cantidad = 400.0,
        unidad_medida = N'g',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Angus · Americana y uruguaya' OR (grupo_comercial IS NULL AND N'Angus · Americana y uruguaya' IS NULL))
              AND nombre = N'Beefe ancho'
        )
      AND nombre_presentacion = N'400 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Beefe ancho'
        )
      AND nombre_presentacion = N'300 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Beefe ancho'
        ), N'300 g', 72.00, 300.0,
        N'g', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 72.00,
        peso_volumen_cantidad = 300.0,
        unidad_medida = N'g',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Beefe ancho'
        )
      AND nombre_presentacion = N'300 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Picanha'
        )
      AND nombre_presentacion = N'400 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Picanha'
        ), N'400 g', 80.00, 400.0,
        N'g', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 80.00,
        peso_volumen_cantidad = 400.0,
        unidad_medida = N'g',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Picanha'
        )
      AND nombre_presentacion = N'400 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Lomo fino'
        )
      AND nombre_presentacion = N'400 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Lomo fino'
        ), N'400 g', 64.00, 400.0,
        N'g', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 64.00,
        peso_volumen_cantidad = 400.0,
        unidad_medida = N'g',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Lomo fino'
        )
      AND nombre_presentacion = N'400 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Lomo fino'
        )
      AND nombre_presentacion = N'300 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Lomo fino'
        ), N'300 g', 54.00, 300.0,
        N'g', NULL, NULL, 0,
        NULL, 2, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 54.00,
        peso_volumen_cantidad = 300.0,
        unidad_medida = N'g',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 2,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Lomo fino'
        )
      AND nombre_presentacion = N'300 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Beefe ancho'
        )
      AND nombre_presentacion = N'300 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Beefe ancho'
        ), N'300 g', 49.00, 300.0,
        N'g', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 49.00,
        peso_volumen_cantidad = 300.0,
        unidad_medida = N'g',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Beefe ancho'
        )
      AND nombre_presentacion = N'300 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Beefe angosto'
        )
      AND nombre_presentacion = N'400 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Beefe angosto'
        ), N'400 g', 51.00, 400.0,
        N'g', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 51.00,
        peso_volumen_cantidad = 400.0,
        unidad_medida = N'g',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Beefe angosto'
        )
      AND nombre_presentacion = N'400 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Beefe angosto'
        )
      AND nombre_presentacion = N'300 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Beefe angosto'
        ), N'300 g', 47.00, 300.0,
        N'g', NULL, NULL, 0,
        NULL, 2, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 47.00,
        peso_volumen_cantidad = 300.0,
        unidad_medida = N'g',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 2,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Beefe angosto'
        )
      AND nombre_presentacion = N'300 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Beefe de chorizo'
        )
      AND nombre_presentacion = N'400 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Beefe de chorizo'
        ), N'400 g', 52.00, 400.0,
        N'g', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 52.00,
        peso_volumen_cantidad = 400.0,
        unidad_medida = N'g',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Beefe de chorizo'
        )
      AND nombre_presentacion = N'400 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Picanha'
        )
      AND nombre_presentacion = N'400 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Picanha'
        ), N'400 g', 65.00, 400.0,
        N'g', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 65.00,
        peso_volumen_cantidad = 400.0,
        unidad_medida = N'g',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Picanha'
        )
      AND nombre_presentacion = N'400 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Cuadril'
        )
      AND nombre_presentacion = N'400 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Cuadril'
        ), N'400 g', 50.00, 400.0,
        N'g', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 50.00,
        peso_volumen_cantidad = 400.0,
        unidad_medida = N'g',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Cuadril'
        )
      AND nombre_presentacion = N'400 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Cuadril'
        )
      AND nombre_presentacion = N'300 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Cuadril'
        ), N'300 g', 45.00, 300.0,
        N'g', NULL, NULL, 0,
        NULL, 2, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 45.00,
        peso_volumen_cantidad = 300.0,
        unidad_medida = N'g',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 2,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Cuadril'
        )
      AND nombre_presentacion = N'300 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Churrasco'
        )
      AND nombre_presentacion = N'300 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Churrasco'
        ), N'300 g', 41.00, 300.0,
        N'g', NULL, NULL, 1,
        N'/img/churrasco.jpg', 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 41.00,
        peso_volumen_cantidad = 300.0,
        unidad_medida = N'g',
        descripcion_presentacion = NULL,
        destacado = 1,
        imagen = N'/img/churrasco.jpg',
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Churrasco'
        )
      AND nombre_presentacion = N'300 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Entraña fina'
        )
      AND nombre_presentacion = N'400 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Entraña fina'
        ), N'400 g', 62.00, 400.0,
        N'g', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 62.00,
        peso_volumen_cantidad = 400.0,
        unidad_medida = N'g',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Entraña fina'
        )
      AND nombre_presentacion = N'400 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Asado de tira de res'
        )
      AND nombre_presentacion = N'700 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Asado de tira de res'
        ), N'700 g', 62.00, 700.0,
        N'g', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 62.00,
        peso_volumen_cantidad = 700.0,
        unidad_medida = N'g',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Asado de tira de res'
        )
      AND nombre_presentacion = N'700 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'T. Bone'
        )
      AND nombre_presentacion = N'400 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'T. Bone'
        ), N'400 g', 75.00, 400.0,
        N'g', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 75.00,
        peso_volumen_cantidad = 400.0,
        unidad_medida = N'g',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'T. Bone'
        )
      AND nombre_presentacion = N'400 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Tomahawk'
        )
      AND nombre_presentacion = N'1.00 kg'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Tomahawk'
        ), N'1.00 kg', 145.00, 1.0,
        N'kg', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 145.00,
        peso_volumen_cantidad = 1.0,
        unidad_medida = N'kg',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Tomahawk'
        )
      AND nombre_presentacion = N'1.00 kg'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Anticuchos de lomo fino en espadas'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Anticuchos de lomo fino en espadas'
        ), N'Porción estándar', 45.00, NULL,
        NULL, NULL, N'Dos espadas, acompañadas solo de papas fritas.', 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 45.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = N'Dos espadas, acompañadas solo de papas fritas.',
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'res' 
              AND (grupo_comercial = N'Nacional' OR (grupo_comercial IS NULL AND N'Nacional' IS NULL))
              AND nombre = N'Anticuchos de lomo fino en espadas'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'cerdo' 
              AND (grupo_comercial = N'Cortes' OR (grupo_comercial IS NULL AND N'Cortes' IS NULL))
              AND nombre = N'Asado de tira de cerdo'
        )
      AND nombre_presentacion = N'700 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'cerdo' 
              AND (grupo_comercial = N'Cortes' OR (grupo_comercial IS NULL AND N'Cortes' IS NULL))
              AND nombre = N'Asado de tira de cerdo'
        ), N'700 g', 58.00, 700.0,
        N'g', NULL, N'Dos cortes de tira de cerdo.', 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 58.00,
        peso_volumen_cantidad = 700.0,
        unidad_medida = N'g',
        descripcion_presentacion = N'Dos cortes de tira de cerdo.',
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'cerdo' 
              AND (grupo_comercial = N'Cortes' OR (grupo_comercial IS NULL AND N'Cortes' IS NULL))
              AND nombre = N'Asado de tira de cerdo'
        )
      AND nombre_presentacion = N'700 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'cerdo' 
              AND (grupo_comercial = N'Cortes' OR (grupo_comercial IS NULL AND N'Cortes' IS NULL))
              AND nombre = N'Chuleta de cerdo'
        )
      AND nombre_presentacion = N'500 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'cerdo' 
              AND (grupo_comercial = N'Cortes' OR (grupo_comercial IS NULL AND N'Cortes' IS NULL))
              AND nombre = N'Chuleta de cerdo'
        ), N'500 g', 51.00, 500.0,
        N'g', NULL, N'Dos cortes de chuleta.', 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 51.00,
        peso_volumen_cantidad = 500.0,
        unidad_medida = N'g',
        descripcion_presentacion = N'Dos cortes de chuleta.',
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'cerdo' 
              AND (grupo_comercial = N'Cortes' OR (grupo_comercial IS NULL AND N'Cortes' IS NULL))
              AND nombre = N'Chuleta de cerdo'
        )
      AND nombre_presentacion = N'500 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'cerdo' 
              AND (grupo_comercial = N'Cortes' OR (grupo_comercial IS NULL AND N'Cortes' IS NULL))
              AND nombre = N'Chuleta de cerdo'
        )
      AND nombre_presentacion = N'300 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'cerdo' 
              AND (grupo_comercial = N'Cortes' OR (grupo_comercial IS NULL AND N'Cortes' IS NULL))
              AND nombre = N'Chuleta de cerdo'
        ), N'300 g', 39.00, 300.0,
        N'g', NULL, NULL, 0,
        NULL, 2, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 39.00,
        peso_volumen_cantidad = 300.0,
        unidad_medida = N'g',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 2,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'cerdo' 
              AND (grupo_comercial = N'Cortes' OR (grupo_comercial IS NULL AND N'Cortes' IS NULL))
              AND nombre = N'Chuleta de cerdo'
        )
      AND nombre_presentacion = N'300 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'cerdo' 
              AND (grupo_comercial = N'Cortes' OR (grupo_comercial IS NULL AND N'Cortes' IS NULL))
              AND nombre = N'Lomo de cerdo (salomillo)'
        )
      AND nombre_presentacion = N'400 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'cerdo' 
              AND (grupo_comercial = N'Cortes' OR (grupo_comercial IS NULL AND N'Cortes' IS NULL))
              AND nombre = N'Lomo de cerdo (salomillo)'
        ), N'400 g', 53.00, 400.0,
        N'g', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 53.00,
        peso_volumen_cantidad = 400.0,
        unidad_medida = N'g',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'cerdo' 
              AND (grupo_comercial = N'Cortes' OR (grupo_comercial IS NULL AND N'Cortes' IS NULL))
              AND nombre = N'Lomo de cerdo (salomillo)'
        )
      AND nombre_presentacion = N'400 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'cerdo' 
              AND (grupo_comercial = N'Cortes' OR (grupo_comercial IS NULL AND N'Cortes' IS NULL))
              AND nombre = N'Anticuchos de lomo fino de cerdo en espadas'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'cerdo' 
              AND (grupo_comercial = N'Cortes' OR (grupo_comercial IS NULL AND N'Cortes' IS NULL))
              AND nombre = N'Anticuchos de lomo fino de cerdo en espadas'
        ), N'Porción estándar', 42.00, NULL,
        NULL, NULL, N'Dos espadas, acompañadas solo de papas fritas.', 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 42.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = N'Dos espadas, acompañadas solo de papas fritas.',
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'cerdo' 
              AND (grupo_comercial = N'Cortes' OR (grupo_comercial IS NULL AND N'Cortes' IS NULL))
              AND nombre = N'Anticuchos de lomo fino de cerdo en espadas'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'cerdo' 
              AND (grupo_comercial = N'Costillas' OR (grupo_comercial IS NULL AND N'Costillas' IS NULL))
              AND nombre = N'Costilla de cerdo St. Louis'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'cerdo' 
              AND (grupo_comercial = N'Costillas' OR (grupo_comercial IS NULL AND N'Costillas' IS NULL))
              AND nombre = N'Costilla de cerdo St. Louis'
        ), N'Porción estándar', 52.00, NULL,
        NULL, NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 52.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'cerdo' 
              AND (grupo_comercial = N'Costillas' OR (grupo_comercial IS NULL AND N'Costillas' IS NULL))
              AND nombre = N'Costilla de cerdo St. Louis'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'cerdo' 
              AND (grupo_comercial = N'Costillas' OR (grupo_comercial IS NULL AND N'Costillas' IS NULL))
              AND nombre = N'Costilla de cerdo St. Louis en salsa BBQ'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'cerdo' 
              AND (grupo_comercial = N'Costillas' OR (grupo_comercial IS NULL AND N'Costillas' IS NULL))
              AND nombre = N'Costilla de cerdo St. Louis en salsa BBQ'
        ), N'Porción estándar', 58.00, NULL,
        NULL, NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 58.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'cerdo' 
              AND (grupo_comercial = N'Costillas' OR (grupo_comercial IS NULL AND N'Costillas' IS NULL))
              AND nombre = N'Costilla de cerdo St. Louis en salsa BBQ'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'cerdo' 
              AND (grupo_comercial = N'Costillas' OR (grupo_comercial IS NULL AND N'Costillas' IS NULL))
              AND nombre = N'Baby Ribs'
        )
      AND nombre_presentacion = N'700 a 800 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'cerdo' 
              AND (grupo_comercial = N'Costillas' OR (grupo_comercial IS NULL AND N'Costillas' IS NULL))
              AND nombre = N'Baby Ribs'
        ), N'700 a 800 g', 76.00, 800.0,
        N'g', NULL, N'Costilla de cerdo para dos personas.', 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 76.00,
        peso_volumen_cantidad = 800.0,
        unidad_medida = N'g',
        descripcion_presentacion = N'Costilla de cerdo para dos personas.',
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'cerdo' 
              AND (grupo_comercial = N'Costillas' OR (grupo_comercial IS NULL AND N'Costillas' IS NULL))
              AND nombre = N'Baby Ribs'
        )
      AND nombre_presentacion = N'700 a 800 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'cerdo' 
              AND (grupo_comercial = N'Costillas' OR (grupo_comercial IS NULL AND N'Costillas' IS NULL))
              AND nombre = N'Baby Ribs en salsa BBQ'
        )
      AND nombre_presentacion = N'700 a 800 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'cerdo' 
              AND (grupo_comercial = N'Costillas' OR (grupo_comercial IS NULL AND N'Costillas' IS NULL))
              AND nombre = N'Baby Ribs en salsa BBQ'
        ), N'700 a 800 g', 81.00, 800.0,
        N'g', NULL, N'Costilla de cerdo para dos personas.', 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 81.00,
        peso_volumen_cantidad = 800.0,
        unidad_medida = N'g',
        descripcion_presentacion = N'Costilla de cerdo para dos personas.',
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'cerdo' 
              AND (grupo_comercial = N'Costillas' OR (grupo_comercial IS NULL AND N'Costillas' IS NULL))
              AND nombre = N'Baby Ribs en salsa BBQ'
        )
      AND nombre_presentacion = N'700 a 800 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'pollo' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'1/4 de pollo a la parrilla'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'pollo' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'1/4 de pollo a la parrilla'
        ), N'Porción estándar', 30.00, NULL,
        NULL, NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 30.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'pollo' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'1/4 de pollo a la parrilla'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'pollo' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Filete de pechuga'
        )
      AND nombre_presentacion = N'400 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'pollo' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Filete de pechuga'
        ), N'400 g', 38.00, 400.0,
        N'g', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 38.00,
        peso_volumen_cantidad = 400.0,
        unidad_medida = N'g',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'pollo' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Filete de pechuga'
        )
      AND nombre_presentacion = N'400 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'entradas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Alitas en salsa BBQ'
        )
      AND nombre_presentacion = N'6 unidades'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'entradas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Alitas en salsa BBQ'
        ), N'6 unidades', 30.00, 6.0,
        N'unidades', NULL, N'Alitas bañadas en salsa BBQ.', 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 30.00,
        peso_volumen_cantidad = 6.0,
        unidad_medida = N'unidades',
        descripcion_presentacion = N'Alitas bañadas en salsa BBQ.',
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'entradas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Alitas en salsa BBQ'
        )
      AND nombre_presentacion = N'6 unidades'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'entradas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Mollejitas a la parrilla'
        )
      AND nombre_presentacion = N'300 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'entradas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Mollejitas a la parrilla'
        ), N'300 g', 30.00, 300.0,
        N'g', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 30.00,
        peso_volumen_cantidad = 300.0,
        unidad_medida = N'g',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'entradas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Mollejitas a la parrilla'
        )
      AND nombre_presentacion = N'300 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'entradas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Champiñones a la parrilla'
        )
      AND nombre_presentacion = N'200 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'entradas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Champiñones a la parrilla'
        ), N'200 g', 25.00, 200.0,
        N'g', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 25.00,
        peso_volumen_cantidad = 200.0,
        unidad_medida = N'g',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'entradas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Champiñones a la parrilla'
        )
      AND nombre_presentacion = N'200 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'entradas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Anticuchos de corazón de res'
        )
      AND nombre_presentacion = N'2 palitos'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'entradas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Anticuchos de corazón de res'
        ), N'2 palitos', 28.00, 2.0,
        N'palitos', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 28.00,
        peso_volumen_cantidad = 2.0,
        unidad_medida = N'palitos',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'entradas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Anticuchos de corazón de res'
        )
      AND nombre_presentacion = N'2 palitos'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'entradas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Anticuchos de champiñones'
        )
      AND nombre_presentacion = N'2 palitos'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'entradas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Anticuchos de champiñones'
        ), N'2 palitos', 28.00, 2.0,
        N'palitos', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 28.00,
        peso_volumen_cantidad = 2.0,
        unidad_medida = N'palitos',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'entradas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Anticuchos de champiñones'
        )
      AND nombre_presentacion = N'2 palitos'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'entradas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Chorizo parrillero porción'
        )
      AND nombre_presentacion = N'3 unidades'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'entradas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Chorizo parrillero porción'
        ), N'3 unidades', 30.00, 3.0,
        N'unidades', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 30.00,
        peso_volumen_cantidad = 3.0,
        unidad_medida = N'unidades',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'entradas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Chorizo parrillero porción'
        )
      AND nombre_presentacion = N'3 unidades'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'entradas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Anticucho por unidad'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'entradas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Anticucho por unidad'
        ), N'Porción estándar', 14.00, NULL,
        NULL, NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 14.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'entradas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Anticucho por unidad'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'entradas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Chorizo parrillero por unidad'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'entradas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Chorizo parrillero por unidad'
        ), N'Porción estándar', 13.00, NULL,
        NULL, NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 13.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'entradas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Chorizo parrillero por unidad'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'entradas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Piqueo Cuatrero'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'entradas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Piqueo Cuatrero'
        ), N'Porción estándar', 44.00, NULL,
        NULL, NULL, N'3 alitas + 2 anticuchos + 4 mollejitas + 2 chorizos.', 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 44.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = N'3 alitas + 2 anticuchos + 4 mollejitas + 2 chorizos.',
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'entradas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Piqueo Cuatrero'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'combos' 
              AND (grupo_comercial = N'Parrillas para compartir' OR (grupo_comercial IS NULL AND N'Parrillas para compartir' IS NULL))
              AND nombre = N'Mixta Grande'
        )
      AND nombre_presentacion = N'Ideal para 7 personas'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'combos' 
              AND (grupo_comercial = N'Parrillas para compartir' OR (grupo_comercial IS NULL AND N'Parrillas para compartir' IS NULL))
              AND nombre = N'Mixta Grande'
        ), N'Ideal para 7 personas', 200.00, 7.0,
        N'personas', NULL, N'1/4 de pollo + 3 chuletas de cerdo + 2 churrascos + 1 asado de tira + 3 anticuchos de corazón + 8 mollejitas + 3 chorizos + 2 porciones de papas fritas + 2 ensaladas mixtas.', 1,
        N'/img/parrilla-mixta.jpg', 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 200.00,
        peso_volumen_cantidad = 7.0,
        unidad_medida = N'personas',
        descripcion_presentacion = N'1/4 de pollo + 3 chuletas de cerdo + 2 churrascos + 1 asado de tira + 3 anticuchos de corazón + 8 mollejitas + 3 chorizos + 2 porciones de papas fritas + 2 ensaladas mixtas.',
        destacado = 1,
        imagen = N'/img/parrilla-mixta.jpg',
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'combos' 
              AND (grupo_comercial = N'Parrillas para compartir' OR (grupo_comercial IS NULL AND N'Parrillas para compartir' IS NULL))
              AND nombre = N'Mixta Grande'
        )
      AND nombre_presentacion = N'Ideal para 7 personas'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'combos' 
              AND (grupo_comercial = N'Parrillas para compartir' OR (grupo_comercial IS NULL AND N'Parrillas para compartir' IS NULL))
              AND nombre = N'Mixta Junior'
        )
      AND nombre_presentacion = N'Ideal para 5 personas'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'combos' 
              AND (grupo_comercial = N'Parrillas para compartir' OR (grupo_comercial IS NULL AND N'Parrillas para compartir' IS NULL))
              AND nombre = N'Mixta Junior'
        ), N'Ideal para 5 personas', 160.00, 5.0,
        N'personas', NULL, N'1/4 de pollo + 2 chuletas de cerdo + 1 churrasco + 2 anticuchos de corazón + 4 mollejitas + 2 chorizos + 1 porción de papas fritas + 1 ensalada mixta.', 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 160.00,
        peso_volumen_cantidad = 5.0,
        unidad_medida = N'personas',
        descripcion_presentacion = N'1/4 de pollo + 2 chuletas de cerdo + 1 churrasco + 2 anticuchos de corazón + 4 mollejitas + 2 chorizos + 1 porción de papas fritas + 1 ensalada mixta.',
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'combos' 
              AND (grupo_comercial = N'Parrillas para compartir' OR (grupo_comercial IS NULL AND N'Parrillas para compartir' IS NULL))
              AND nombre = N'Mixta Junior'
        )
      AND nombre_presentacion = N'Ideal para 5 personas'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'combos' 
              AND (grupo_comercial = N'Combos personales' OR (grupo_comercial IS NULL AND N'Combos personales' IS NULL))
              AND nombre = N'Señor Cuatrero'
        )
      AND nombre_presentacion = N'900 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'combos' 
              AND (grupo_comercial = N'Combos personales' OR (grupo_comercial IS NULL AND N'Combos personales' IS NULL))
              AND nombre = N'Señor Cuatrero'
        ), N'900 g', 130.00, 900.0,
        N'g', NULL, N'300 g de lomo fino + 300 g de cuadril + 300 g de beefe, con papas y ensalada mixta.', 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 130.00,
        peso_volumen_cantidad = 900.0,
        unidad_medida = N'g',
        descripcion_presentacion = N'300 g de lomo fino + 300 g de cuadril + 300 g de beefe, con papas y ensalada mixta.',
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'combos' 
              AND (grupo_comercial = N'Combos personales' OR (grupo_comercial IS NULL AND N'Combos personales' IS NULL))
              AND nombre = N'Señor Cuatrero'
        )
      AND nombre_presentacion = N'900 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'combos' 
              AND (grupo_comercial = N'Combos personales' OR (grupo_comercial IS NULL AND N'Combos personales' IS NULL))
              AND nombre = N'Trilogía Cuatrero'
        )
      AND nombre_presentacion = N'600 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'combos' 
              AND (grupo_comercial = N'Combos personales' OR (grupo_comercial IS NULL AND N'Combos personales' IS NULL))
              AND nombre = N'Trilogía Cuatrero'
        ), N'600 g', 72.00, 600.0,
        N'g', NULL, N'200 g de beefe + 200 g de filete de pierna + 200 g de lomo de cerdo, con papas y ensalada mixta.', 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 72.00,
        peso_volumen_cantidad = 600.0,
        unidad_medida = N'g',
        descripcion_presentacion = N'200 g de beefe + 200 g de filete de pierna + 200 g de lomo de cerdo, con papas y ensalada mixta.',
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'combos' 
              AND (grupo_comercial = N'Combos personales' OR (grupo_comercial IS NULL AND N'Combos personales' IS NULL))
              AND nombre = N'Trilogía Cuatrero'
        )
      AND nombre_presentacion = N'600 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'combos' 
              AND (grupo_comercial = N'Combos personales' OR (grupo_comercial IS NULL AND N'Combos personales' IS NULL))
              AND nombre = N'Cuatrero'
        )
      AND nombre_presentacion = N'500 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'combos' 
              AND (grupo_comercial = N'Combos personales' OR (grupo_comercial IS NULL AND N'Combos personales' IS NULL))
              AND nombre = N'Cuatrero'
        ), N'500 g', 54.00, 500.0,
        N'g', NULL, N'Dos cortes de churrasco.', 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 54.00,
        peso_volumen_cantidad = 500.0,
        unidad_medida = N'g',
        descripcion_presentacion = N'Dos cortes de churrasco.',
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'combos' 
              AND (grupo_comercial = N'Combos personales' OR (grupo_comercial IS NULL AND N'Combos personales' IS NULL))
              AND nombre = N'Cuatrero'
        )
      AND nombre_presentacion = N'500 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'combos' 
              AND (grupo_comercial = N'Combos personales' OR (grupo_comercial IS NULL AND N'Combos personales' IS NULL))
              AND nombre = N'Cuatrero mix'
        )
      AND nombre_presentacion = N'500 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'combos' 
              AND (grupo_comercial = N'Combos personales' OR (grupo_comercial IS NULL AND N'Combos personales' IS NULL))
              AND nombre = N'Cuatrero mix'
        ), N'500 g', 54.00, 500.0,
        N'g', NULL, N'Un corte de churrasco y un corte de cerdo.', 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 54.00,
        peso_volumen_cantidad = 500.0,
        unidad_medida = N'g',
        descripcion_presentacion = N'Un corte de churrasco y un corte de cerdo.',
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'combos' 
              AND (grupo_comercial = N'Combos personales' OR (grupo_comercial IS NULL AND N'Combos personales' IS NULL))
              AND nombre = N'Cuatrero mix'
        )
      AND nombre_presentacion = N'500 g'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'ensaladas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Ensalada mixta clásica'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'ensaladas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Ensalada mixta clásica'
        ), N'Porción estándar', 15.00, NULL,
        NULL, NULL, N'Lechuga, tomate, pepinillo, zanahoria, beterraga, palta y aliño de la casa.', 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 15.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = N'Lechuga, tomate, pepinillo, zanahoria, beterraga, palta y aliño de la casa.',
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'ensaladas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Ensalada mixta clásica'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'ensaladas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Ensalada mixta personal'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'ensaladas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Ensalada mixta personal'
        ), N'Porción estándar', 10.00, NULL,
        NULL, NULL, N'Lechuga, tomate, pepinillo, zanahoria, beterraga, palta y aliño de la casa.', 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 10.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = N'Lechuga, tomate, pepinillo, zanahoria, beterraga, palta y aliño de la casa.',
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'ensaladas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Ensalada mixta personal'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'ensaladas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Ensalada César al estilo Cuatrero'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'ensaladas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Ensalada César al estilo Cuatrero'
        ), N'Porción estándar', 26.00, NULL,
        NULL, NULL, N'Lechuga romana, tocino en cuadraditos, queso parmesano rallado y fajitas de pollo con aliño de la casa.', 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 26.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = N'Lechuga romana, tocino en cuadraditos, queso parmesano rallado y fajitas de pollo con aliño de la casa.',
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'ensaladas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Ensalada César al estilo Cuatrero'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'ensaladas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Ensalada de palta'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'ensaladas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Ensalada de palta'
        ), N'Porción estándar', 15.00, NULL,
        NULL, NULL, N'Palta entera y zanahoria con aliño de la casa.', 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 15.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = N'Palta entera y zanahoria con aliño de la casa.',
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'ensaladas' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Ensalada de palta'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'acompanamientos' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Porción de papas fritas'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'acompanamientos' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Porción de papas fritas'
        ), N'Porción estándar', 14.00, NULL,
        NULL, NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 14.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'acompanamientos' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Porción de papas fritas'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'acompanamientos' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Plato compartido de papas fritas'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'acompanamientos' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Plato compartido de papas fritas'
        ), N'Porción estándar', 8.00, NULL,
        NULL, NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 8.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'acompanamientos' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Plato compartido de papas fritas'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'acompanamientos' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Porción de papa sancochada'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'acompanamientos' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Porción de papa sancochada'
        ), N'Porción estándar', 14.00, NULL,
        NULL, NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 14.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'acompanamientos' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Porción de papa sancochada'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'acompanamientos' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Salsa BBQ'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'acompanamientos' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Salsa BBQ'
        ), N'Porción estándar', 10.00, NULL,
        NULL, NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 10.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'acompanamientos' 
              AND (grupo_comercial = NULL OR (grupo_comercial IS NULL AND NULL IS NULL))
              AND nombre = N'Salsa BBQ'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Gaseosas' OR (grupo_comercial IS NULL AND N'Gaseosas' IS NULL))
              AND nombre = N'Gaseosa Coca Cola'
        )
      AND nombre_presentacion = N'1 Litro'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Gaseosas' OR (grupo_comercial IS NULL AND N'Gaseosas' IS NULL))
              AND nombre = N'Gaseosa Coca Cola'
        ), N'1 Litro', 8.00, 1.0,
        N'L', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 8.00,
        peso_volumen_cantidad = 1.0,
        unidad_medida = N'L',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Gaseosas' OR (grupo_comercial IS NULL AND N'Gaseosas' IS NULL))
              AND nombre = N'Gaseosa Coca Cola'
        )
      AND nombre_presentacion = N'1 Litro'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Gaseosas' OR (grupo_comercial IS NULL AND N'Gaseosas' IS NULL))
              AND nombre = N'Gaseosa Inca Kola'
        )
      AND nombre_presentacion = N'1 Litro'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Gaseosas' OR (grupo_comercial IS NULL AND N'Gaseosas' IS NULL))
              AND nombre = N'Gaseosa Inca Kola'
        ), N'1 Litro', 8.00, 1.0,
        N'L', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 8.00,
        peso_volumen_cantidad = 1.0,
        unidad_medida = N'L',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Gaseosas' OR (grupo_comercial IS NULL AND N'Gaseosas' IS NULL))
              AND nombre = N'Gaseosa Inca Kola'
        )
      AND nombre_presentacion = N'1 Litro'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Gaseosas' OR (grupo_comercial IS NULL AND N'Gaseosas' IS NULL))
              AND nombre = N'Gaseosa personal'
        )
      AND nombre_presentacion = N'296 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Gaseosas' OR (grupo_comercial IS NULL AND N'Gaseosas' IS NULL))
              AND nombre = N'Gaseosa personal'
        ), N'296 ml', 3.00, 296.0,
        N'ml', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 3.00,
        peso_volumen_cantidad = 296.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Gaseosas' OR (grupo_comercial IS NULL AND N'Gaseosas' IS NULL))
              AND nombre = N'Gaseosa personal'
        )
      AND nombre_presentacion = N'296 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Gaseosas' OR (grupo_comercial IS NULL AND N'Gaseosas' IS NULL))
              AND nombre = N'Coca Cola Zero'
        )
      AND nombre_presentacion = N'500 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Gaseosas' OR (grupo_comercial IS NULL AND N'Gaseosas' IS NULL))
              AND nombre = N'Coca Cola Zero'
        ), N'500 ml', 4.00, 500.0,
        N'ml', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 4.00,
        peso_volumen_cantidad = 500.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Gaseosas' OR (grupo_comercial IS NULL AND N'Gaseosas' IS NULL))
              AND nombre = N'Coca Cola Zero'
        )
      AND nombre_presentacion = N'500 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Gaseosas' OR (grupo_comercial IS NULL AND N'Gaseosas' IS NULL))
              AND nombre = N'Inca Kola Zero'
        )
      AND nombre_presentacion = N'500 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Gaseosas' OR (grupo_comercial IS NULL AND N'Gaseosas' IS NULL))
              AND nombre = N'Inca Kola Zero'
        ), N'500 ml', 4.00, 500.0,
        N'ml', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 4.00,
        peso_volumen_cantidad = 500.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Gaseosas' OR (grupo_comercial IS NULL AND N'Gaseosas' IS NULL))
              AND nombre = N'Inca Kola Zero'
        )
      AND nombre_presentacion = N'500 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Gaseosas' OR (grupo_comercial IS NULL AND N'Gaseosas' IS NULL))
              AND nombre = N'Agua con gas o sin gas'
        )
      AND nombre_presentacion = N'625 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Gaseosas' OR (grupo_comercial IS NULL AND N'Gaseosas' IS NULL))
              AND nombre = N'Agua con gas o sin gas'
        ), N'625 ml', 3.00, 625.0,
        N'ml', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 3.00,
        peso_volumen_cantidad = 625.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Gaseosas' OR (grupo_comercial IS NULL AND N'Gaseosas' IS NULL))
              AND nombre = N'Agua con gas o sin gas'
        )
      AND nombre_presentacion = N'625 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Limonadas' OR (grupo_comercial IS NULL AND N'Limonadas' IS NULL))
              AND nombre = N'Jarra de limonada clásica'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Limonadas' OR (grupo_comercial IS NULL AND N'Limonadas' IS NULL))
              AND nombre = N'Jarra de limonada clásica'
        ), N'Porción estándar', 13.00, NULL,
        NULL, NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 13.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Limonadas' OR (grupo_comercial IS NULL AND N'Limonadas' IS NULL))
              AND nombre = N'Jarra de limonada clásica'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Limonadas' OR (grupo_comercial IS NULL AND N'Limonadas' IS NULL))
              AND nombre = N'Jarra de limonada cherry'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Limonadas' OR (grupo_comercial IS NULL AND N'Limonadas' IS NULL))
              AND nombre = N'Jarra de limonada cherry'
        ), N'Porción estándar', 15.00, NULL,
        NULL, NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 15.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Limonadas' OR (grupo_comercial IS NULL AND N'Limonadas' IS NULL))
              AND nombre = N'Jarra de limonada cherry'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Limonadas' OR (grupo_comercial IS NULL AND N'Limonadas' IS NULL))
              AND nombre = N'Jarra de limonada menta'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Limonadas' OR (grupo_comercial IS NULL AND N'Limonadas' IS NULL))
              AND nombre = N'Jarra de limonada menta'
        ), N'Porción estándar', 15.00, NULL,
        NULL, NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 15.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Limonadas' OR (grupo_comercial IS NULL AND N'Limonadas' IS NULL))
              AND nombre = N'Jarra de limonada menta'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Limonadas' OR (grupo_comercial IS NULL AND N'Limonadas' IS NULL))
              AND nombre = N'Jarra de limonada africana'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Limonadas' OR (grupo_comercial IS NULL AND N'Limonadas' IS NULL))
              AND nombre = N'Jarra de limonada africana'
        ), N'Porción estándar', 15.00, NULL,
        NULL, NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 15.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Limonadas' OR (grupo_comercial IS NULL AND N'Limonadas' IS NULL))
              AND nombre = N'Jarra de limonada africana'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Limonadas' OR (grupo_comercial IS NULL AND N'Limonadas' IS NULL))
              AND nombre = N'Jarra de limonada tropical'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Limonadas' OR (grupo_comercial IS NULL AND N'Limonadas' IS NULL))
              AND nombre = N'Jarra de limonada tropical'
        ), N'Porción estándar', 15.00, NULL,
        NULL, NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 15.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Limonadas' OR (grupo_comercial IS NULL AND N'Limonadas' IS NULL))
              AND nombre = N'Jarra de limonada tropical'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Limonadas' OR (grupo_comercial IS NULL AND N'Limonadas' IS NULL))
              AND nombre = N'Jarra de limonada eléctrica'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Limonadas' OR (grupo_comercial IS NULL AND N'Limonadas' IS NULL))
              AND nombre = N'Jarra de limonada eléctrica'
        ), N'Porción estándar', 17.00, NULL,
        NULL, NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 17.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Limonadas' OR (grupo_comercial IS NULL AND N'Limonadas' IS NULL))
              AND nombre = N'Jarra de limonada eléctrica'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
              AND nombre = N'Jarra de chicha morada'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
              AND nombre = N'Jarra de chicha morada'
        ), N'Porción estándar', 15.00, NULL,
        NULL, NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 15.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
              AND nombre = N'Jarra de chicha morada'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
              AND nombre = N'Jarra de maracuyá'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
              AND nombre = N'Jarra de maracuyá'
        ), N'Porción estándar', 18.00, NULL,
        NULL, NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 18.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
              AND nombre = N'Jarra de maracuyá'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
              AND nombre = N'Jarra de naranjada'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
              AND nombre = N'Jarra de naranjada'
        ), N'Porción estándar', 18.00, NULL,
        NULL, NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 18.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
              AND nombre = N'Jarra de naranjada'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
              AND nombre = N'Jarra de jugo de piña'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
              AND nombre = N'Jarra de jugo de piña'
        ), N'Porción estándar', 18.00, NULL,
        NULL, NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 18.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
              AND nombre = N'Jarra de jugo de piña'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
              AND nombre = N'Jarra de jugo de durazno'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
              AND nombre = N'Jarra de jugo de durazno'
        ), N'Porción estándar', 18.00, NULL,
        NULL, NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 18.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
              AND nombre = N'Jarra de jugo de durazno'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
              AND nombre = N'Copa de sangría'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
              AND nombre = N'Copa de sangría'
        ), N'Porción estándar', 20.00, NULL,
        NULL, NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 20.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
              AND nombre = N'Copa de sangría'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
              AND nombre = N'Jarra de sangría de vino'
        )
      AND nombre_presentacion = N'Chile Santa Helena'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
              AND nombre = N'Jarra de sangría de vino'
        ), N'Chile Santa Helena', 55.00, NULL,
        N'Jarra', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 55.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = N'Jarra',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jarras' OR (grupo_comercial IS NULL AND N'Jarras' IS NULL))
              AND nombre = N'Jarra de sangría de vino'
        )
      AND nombre_presentacion = N'Chile Santa Helena'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
              AND nombre = N'Jugo de naranja'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
              AND nombre = N'Jugo de naranja'
        ), N'Porción estándar', 8.00, NULL,
        NULL, NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 8.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
              AND nombre = N'Jugo de naranja'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
              AND nombre = N'Jugo de chicha morada'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
              AND nombre = N'Jugo de chicha morada'
        ), N'Porción estándar', 8.00, NULL,
        NULL, NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 8.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
              AND nombre = N'Jugo de chicha morada'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
              AND nombre = N'Jugo de limonada'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
              AND nombre = N'Jugo de limonada'
        ), N'Porción estándar', 6.00, NULL,
        NULL, NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 6.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
              AND nombre = N'Jugo de limonada'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
              AND nombre = N'Jugo de piña'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
              AND nombre = N'Jugo de piña'
        ), N'Porción estándar', 8.00, NULL,
        NULL, NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 8.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
              AND nombre = N'Jugo de piña'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
              AND nombre = N'Jugo de durazno'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
              AND nombre = N'Jugo de durazno'
        ), N'Porción estándar', 8.00, NULL,
        NULL, NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 8.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
              AND nombre = N'Jugo de durazno'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
              AND nombre = N'Jugo de fresa'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
              AND nombre = N'Jugo de fresa'
        ), N'Porción estándar', 9.00, NULL,
        NULL, NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 9.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
              AND nombre = N'Jugo de fresa'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
              AND nombre = N'Jugo de mango'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
              AND nombre = N'Jugo de mango'
        ), N'Porción estándar', 9.00, NULL,
        NULL, NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 9.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Jugos 16 oz' OR (grupo_comercial IS NULL AND N'Jugos 16 oz' IS NULL))
              AND nombre = N'Jugo de mango'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Infusiones' OR (grupo_comercial IS NULL AND N'Infusiones' IS NULL))
              AND nombre = N'Té, anís o manzanilla'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Infusiones' OR (grupo_comercial IS NULL AND N'Infusiones' IS NULL))
              AND nombre = N'Té, anís o manzanilla'
        ), N'Porción estándar', 4.00, NULL,
        NULL, NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 4.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Infusiones' OR (grupo_comercial IS NULL AND N'Infusiones' IS NULL))
              AND nombre = N'Té, anís o manzanilla'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Infusiones' OR (grupo_comercial IS NULL AND N'Infusiones' IS NULL))
              AND nombre = N'Café pasado'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Infusiones' OR (grupo_comercial IS NULL AND N'Infusiones' IS NULL))
              AND nombre = N'Café pasado'
        ), N'Porción estándar', 6.00, NULL,
        NULL, NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 6.00,
        peso_volumen_cantidad = NULL,
        unidad_medida = NULL,
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Infusiones' OR (grupo_comercial IS NULL AND N'Infusiones' IS NULL))
              AND nombre = N'Café pasado'
        )
      AND nombre_presentacion = N'Porción estándar'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
              AND nombre = N'Malta Cuzqueña'
        )
      AND nombre_presentacion = N'330 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
              AND nombre = N'Malta Cuzqueña'
        ), N'330 ml', 10.00, 330.0,
        N'ml', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 10.00,
        peso_volumen_cantidad = 330.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
              AND nombre = N'Malta Cuzqueña'
        )
      AND nombre_presentacion = N'330 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
              AND nombre = N'Cuzqueña Premium'
        )
      AND nombre_presentacion = N'330 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
              AND nombre = N'Cuzqueña Premium'
        ), N'330 ml', 10.00, 330.0,
        N'ml', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 10.00,
        peso_volumen_cantidad = 330.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
              AND nombre = N'Cuzqueña Premium'
        )
      AND nombre_presentacion = N'330 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
              AND nombre = N'Cuzqueña Trigo'
        )
      AND nombre_presentacion = N'330 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
              AND nombre = N'Cuzqueña Trigo'
        ), N'330 ml', 10.00, 330.0,
        N'ml', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 10.00,
        peso_volumen_cantidad = 330.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
              AND nombre = N'Cuzqueña Trigo'
        )
      AND nombre_presentacion = N'330 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
              AND nombre = N'Pilsen Callao'
        )
      AND nombre_presentacion = N'310 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
              AND nombre = N'Pilsen Callao'
        ), N'310 ml', 8.00, 310.0,
        N'ml', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 8.00,
        peso_volumen_cantidad = 310.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
              AND nombre = N'Pilsen Callao'
        )
      AND nombre_presentacion = N'310 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
              AND nombre = N'Cerveza Corona'
        )
      AND nombre_presentacion = N'350 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
              AND nombre = N'Cerveza Corona'
        ), N'350 ml', 12.00, 350.0,
        N'ml', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 12.00,
        peso_volumen_cantidad = 350.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
              AND nombre = N'Cerveza Corona'
        )
      AND nombre_presentacion = N'350 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
              AND nombre = N'Cerveza Budweiser'
        )
      AND nombre_presentacion = N'343 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
              AND nombre = N'Cerveza Budweiser'
        ), N'343 ml', 12.00, 343.0,
        N'ml', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 12.00,
        peso_volumen_cantidad = 343.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
              AND nombre = N'Cerveza Budweiser'
        )
      AND nombre_presentacion = N'343 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
              AND nombre = N'Cerveza Stella Artois'
        )
      AND nombre_presentacion = N'343 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
              AND nombre = N'Cerveza Stella Artois'
        ), N'343 ml', 12.00, 343.0,
        N'ml', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 12.00,
        peso_volumen_cantidad = 343.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
              AND nombre = N'Cerveza Stella Artois'
        )
      AND nombre_presentacion = N'343 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
              AND nombre = N'Costera Río Rojo'
        )
      AND nombre_presentacion = N'330 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
              AND nombre = N'Costera Río Rojo'
        ), N'330 ml', 16.00, 330.0,
        N'ml', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 16.00,
        peso_volumen_cantidad = 330.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
              AND nombre = N'Costera Río Rojo'
        )
      AND nombre_presentacion = N'330 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
              AND nombre = N'Costera IPA'
        )
      AND nombre_presentacion = N'330 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
              AND nombre = N'Costera IPA'
        ), N'330 ml', 16.00, 330.0,
        N'ml', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 16.00,
        peso_volumen_cantidad = 330.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'bebidas' 
              AND (grupo_comercial = N'Cervezas' OR (grupo_comercial IS NULL AND N'Cervezas' IS NULL))
              AND nombre = N'Costera IPA'
        )
      AND nombre_presentacion = N'330 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Tacama Selección Especial'
        )
      AND nombre_presentacion = N'750 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Tacama Selección Especial'
        ), N'750 ml', 65.00, 750.0,
        N'ml', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 65.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Tacama Selección Especial'
        )
      AND nombre_presentacion = N'750 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Tacama Selección Especial'
        )
      AND nombre_presentacion = N'375 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Tacama Selección Especial'
        ), N'375 ml', 38.00, 375.0,
        N'ml', NULL, NULL, 0,
        NULL, 2, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 38.00,
        peso_volumen_cantidad = 375.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 2,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Tacama Selección Especial'
        )
      AND nombre_presentacion = N'375 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Tacama Gran Tinto'
        )
      AND nombre_presentacion = N'750 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Tacama Gran Tinto'
        ), N'750 ml', 50.00, 750.0,
        N'ml', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 50.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Tacama Gran Tinto'
        )
      AND nombre_presentacion = N'750 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Tacama Gran Tinto'
        )
      AND nombre_presentacion = N'375 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Tacama Gran Tinto'
        ), N'375 ml', 25.00, 375.0,
        N'ml', NULL, NULL, 0,
        NULL, 2, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 25.00,
        peso_volumen_cantidad = 375.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 2,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Tacama Gran Tinto'
        )
      AND nombre_presentacion = N'375 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Tacama Blanco de Blancos'
        )
      AND nombre_presentacion = N'750 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Tacama Blanco de Blancos'
        ), N'750 ml', 65.00, 750.0,
        N'ml', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 65.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Tacama Blanco de Blancos'
        )
      AND nombre_presentacion = N'750 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Rubini Ocucaje'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Rubini Ocucaje'
        ), N'Cabernet Sauvignon · 750 ml', 110.00, 750.0,
        N'ml', N'Cabernet Sauvignon', NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 110.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Rubini Ocucaje'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Fond de Cave'
        )
      AND nombre_presentacion = N'Cabernet · 750 ml'
      AND (variedad_vino = N'Cabernet' OR (variedad_vino IS NULL AND N'Cabernet' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Fond de Cave'
        ), N'Cabernet · 750 ml', 45.00, 750.0,
        N'ml', N'Cabernet', NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 45.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Fond de Cave'
        )
      AND nombre_presentacion = N'Cabernet · 750 ml'
      AND (variedad_vino = N'Cabernet' OR (variedad_vino IS NULL AND N'Cabernet' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Fond de Cave'
        )
      AND nombre_presentacion = N'Cabernet · 375 ml'
      AND (variedad_vino = N'Cabernet' OR (variedad_vino IS NULL AND N'Cabernet' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Fond de Cave'
        ), N'Cabernet · 375 ml', 24.00, 375.0,
        N'ml', N'Cabernet', NULL, 0,
        NULL, 2, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 24.00,
        peso_volumen_cantidad = 375.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 2,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Fond de Cave'
        )
      AND nombre_presentacion = N'Cabernet · 375 ml'
      AND (variedad_vino = N'Cabernet' OR (variedad_vino IS NULL AND N'Cabernet' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Intipalka Valle del Sol'
        )
      AND nombre_presentacion = N'Malbec · 750 ml'
      AND (variedad_vino = N'Malbec' OR (variedad_vino IS NULL AND N'Malbec' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Intipalka Valle del Sol'
        ), N'Malbec · 750 ml', 65.00, 750.0,
        N'ml', N'Malbec', NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 65.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Intipalka Valle del Sol'
        )
      AND nombre_presentacion = N'Malbec · 750 ml'
      AND (variedad_vino = N'Malbec' OR (variedad_vino IS NULL AND N'Malbec' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Intipalka Valle del Sol'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Intipalka Valle del Sol'
        ), N'Cabernet Sauvignon · 750 ml', 65.00, 750.0,
        N'ml', N'Cabernet Sauvignon', NULL, 0,
        NULL, 2, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 65.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 2,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Intipalka Valle del Sol'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Tabernero'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Tabernero'
        ), N'Cabernet Sauvignon · 750 ml', 48.00, 750.0,
        N'ml', N'Cabernet Sauvignon', NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 48.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Tabernero'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Tabernero'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 375 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Tabernero'
        ), N'Cabernet Sauvignon · 375 ml', 24.00, 375.0,
        N'ml', N'Cabernet Sauvignon', NULL, 0,
        NULL, 2, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 24.00,
        peso_volumen_cantidad = 375.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 2,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Tabernero'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 375 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Tabernero Gran Tinto Fina Reserva'
        )
      AND nombre_presentacion = N'750 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Tabernero Gran Tinto Fina Reserva'
        ), N'750 ml', 40.00, 750.0,
        N'ml', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 40.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Tabernero Gran Tinto Fina Reserva'
        )
      AND nombre_presentacion = N'750 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Tabernero Gran Tinto Fina Reserva'
        )
      AND nombre_presentacion = N'375 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Tabernero Gran Tinto Fina Reserva'
        ), N'375 ml', 22.00, 375.0,
        N'ml', NULL, NULL, 0,
        NULL, 2, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 22.00,
        peso_volumen_cantidad = 375.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 2,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Tabernero Gran Tinto Fina Reserva'
        )
      AND nombre_presentacion = N'375 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Tabernero Blanco de Blancos'
        )
      AND nombre_presentacion = N'750 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Tabernero Blanco de Blancos'
        ), N'750 ml', 40.00, 750.0,
        N'ml', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 40.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Perú' OR (grupo_comercial IS NULL AND N'Perú' IS NULL))
              AND nombre = N'Tabernero Blanco de Blancos'
        )
      AND nombre_presentacion = N'750 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Escorihuela Gascón'
        )
      AND nombre_presentacion = N'Malbec · 750 ml'
      AND (variedad_vino = N'Malbec' OR (variedad_vino IS NULL AND N'Malbec' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Escorihuela Gascón'
        ), N'Malbec · 750 ml', 80.00, 750.0,
        N'ml', N'Malbec', NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 80.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Escorihuela Gascón'
        )
      AND nombre_presentacion = N'Malbec · 750 ml'
      AND (variedad_vino = N'Malbec' OR (variedad_vino IS NULL AND N'Malbec' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Escorihuela Gascón'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Escorihuela Gascón'
        ), N'Cabernet Sauvignon · 750 ml', 80.00, 750.0,
        N'ml', N'Cabernet Sauvignon', NULL, 0,
        NULL, 2, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 80.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 2,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Escorihuela Gascón'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Nieto Senetiner'
        )
      AND nombre_presentacion = N'Malbec · 750 ml'
      AND (variedad_vino = N'Malbec' OR (variedad_vino IS NULL AND N'Malbec' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Nieto Senetiner'
        ), N'Malbec · 750 ml', 75.00, 750.0,
        N'ml', N'Malbec', NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 75.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Nieto Senetiner'
        )
      AND nombre_presentacion = N'Malbec · 750 ml'
      AND (variedad_vino = N'Malbec' OR (variedad_vino IS NULL AND N'Malbec' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Nieto Senetiner'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Nieto Senetiner'
        ), N'Cabernet Sauvignon · 750 ml', 75.00, 750.0,
        N'ml', N'Cabernet Sauvignon', NULL, 0,
        NULL, 2, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 75.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 2,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Nieto Senetiner'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Alegoría Gran Reserva'
        )
      AND nombre_presentacion = N'Malbec · 750 ml'
      AND (variedad_vino = N'Malbec' OR (variedad_vino IS NULL AND N'Malbec' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Alegoría Gran Reserva'
        ), N'Malbec · 750 ml', 130.00, 750.0,
        N'ml', N'Malbec', NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 130.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Alegoría Gran Reserva'
        )
      AND nombre_presentacion = N'Malbec · 750 ml'
      AND (variedad_vino = N'Malbec' OR (variedad_vino IS NULL AND N'Malbec' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Alegoría Gran Reserva'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Alegoría Gran Reserva'
        ), N'Cabernet Sauvignon · 750 ml', 130.00, 750.0,
        N'ml', N'Cabernet Sauvignon', NULL, 0,
        NULL, 2, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 130.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 2,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Alegoría Gran Reserva'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Selección de Parcelas Reserva'
        )
      AND nombre_presentacion = N'Malbec · 750 ml'
      AND (variedad_vino = N'Malbec' OR (variedad_vino IS NULL AND N'Malbec' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Selección de Parcelas Reserva'
        ), N'Malbec · 750 ml', 100.00, 750.0,
        N'ml', N'Malbec', NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 100.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Selección de Parcelas Reserva'
        )
      AND nombre_presentacion = N'Malbec · 750 ml'
      AND (variedad_vino = N'Malbec' OR (variedad_vino IS NULL AND N'Malbec' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Selección de Parcelas Reserva'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Selección de Parcelas Reserva'
        ), N'Cabernet Sauvignon · 750 ml', 100.00, 750.0,
        N'ml', N'Cabernet Sauvignon', NULL, 0,
        NULL, 2, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 100.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 2,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Selección de Parcelas Reserva'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Navarro Correas'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Navarro Correas'
        ), N'Cabernet Sauvignon · 750 ml', 80.00, 750.0,
        N'ml', N'Cabernet Sauvignon', NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 80.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Navarro Correas'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Navarro Correas'
        )
      AND nombre_presentacion = N'Malbec · 750 ml'
      AND (variedad_vino = N'Malbec' OR (variedad_vino IS NULL AND N'Malbec' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Navarro Correas'
        ), N'Malbec · 750 ml', 80.00, 750.0,
        N'ml', N'Malbec', NULL, 0,
        NULL, 2, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 80.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 2,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Navarro Correas'
        )
      AND nombre_presentacion = N'Malbec · 750 ml'
      AND (variedad_vino = N'Malbec' OR (variedad_vino IS NULL AND N'Malbec' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Navarro Correas'
        )
      AND nombre_presentacion = N'Merlot · 750 ml'
      AND (variedad_vino = N'Merlot' OR (variedad_vino IS NULL AND N'Merlot' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Navarro Correas'
        ), N'Merlot · 750 ml', 80.00, 750.0,
        N'ml', N'Merlot', NULL, 0,
        NULL, 3, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 80.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 3,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Navarro Correas'
        )
      AND nombre_presentacion = N'Merlot · 750 ml'
      AND (variedad_vino = N'Merlot' OR (variedad_vino IS NULL AND N'Merlot' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Navarro Correas Blend'
        )
      AND nombre_presentacion = N'Cabernet, Malbec y Merlot · 750 ml'
      AND (variedad_vino = N'Cabernet, Malbec y Merlot' OR (variedad_vino IS NULL AND N'Cabernet, Malbec y Merlot' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Navarro Correas Blend'
        ), N'Cabernet, Malbec y Merlot · 750 ml', 80.00, 750.0,
        N'ml', N'Cabernet, Malbec y Merlot', NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 80.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Navarro Correas Blend'
        )
      AND nombre_presentacion = N'Cabernet, Malbec y Merlot · 750 ml'
      AND (variedad_vino = N'Cabernet, Malbec y Merlot' OR (variedad_vino IS NULL AND N'Cabernet, Malbec y Merlot' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Los Árboles'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Los Árboles'
        ), N'Cabernet Sauvignon · 750 ml', 55.00, 750.0,
        N'ml', N'Cabernet Sauvignon', NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 55.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Los Árboles'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Los Árboles'
        )
      AND nombre_presentacion = N'Malbec · 750 ml'
      AND (variedad_vino = N'Malbec' OR (variedad_vino IS NULL AND N'Malbec' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Los Árboles'
        ), N'Malbec · 750 ml', 55.00, 750.0,
        N'ml', N'Malbec', NULL, 0,
        NULL, 2, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 55.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 2,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Los Árboles'
        )
      AND nombre_presentacion = N'Malbec · 750 ml'
      AND (variedad_vino = N'Malbec' OR (variedad_vino IS NULL AND N'Malbec' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Los Árboles'
        )
      AND nombre_presentacion = N'Sauvignon, Malbec y Merlot · 750 ml'
      AND (variedad_vino = N'Sauvignon, Malbec y Merlot' OR (variedad_vino IS NULL AND N'Sauvignon, Malbec y Merlot' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Los Árboles'
        ), N'Sauvignon, Malbec y Merlot · 750 ml', 55.00, 750.0,
        N'ml', N'Sauvignon, Malbec y Merlot', NULL, 0,
        NULL, 3, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 55.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 3,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Los Árboles'
        )
      AND nombre_presentacion = N'Sauvignon, Malbec y Merlot · 750 ml'
      AND (variedad_vino = N'Sauvignon, Malbec y Merlot' OR (variedad_vino IS NULL AND N'Sauvignon, Malbec y Merlot' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'La Celia'
        )
      AND nombre_presentacion = N'Malbec · 750 ml'
      AND (variedad_vino = N'Malbec' OR (variedad_vino IS NULL AND N'Malbec' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'La Celia'
        ), N'Malbec · 750 ml', 80.00, 750.0,
        N'ml', N'Malbec', NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 80.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'La Celia'
        )
      AND nombre_presentacion = N'Malbec · 750 ml'
      AND (variedad_vino = N'Malbec' OR (variedad_vino IS NULL AND N'Malbec' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'La Celia'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'La Celia'
        ), N'Cabernet Sauvignon · 750 ml', 80.00, 750.0,
        N'ml', N'Cabernet Sauvignon', NULL, 0,
        NULL, 2, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 80.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 2,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'La Celia'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Séptima'
        )
      AND nombre_presentacion = N'Malbec · 750 ml'
      AND (variedad_vino = N'Malbec' OR (variedad_vino IS NULL AND N'Malbec' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Séptima'
        ), N'Malbec · 750 ml', 65.00, 750.0,
        N'ml', N'Malbec', NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 65.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Séptima'
        )
      AND nombre_presentacion = N'Malbec · 750 ml'
      AND (variedad_vino = N'Malbec' OR (variedad_vino IS NULL AND N'Malbec' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Séptima'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Séptima'
        ), N'Cabernet Sauvignon · 750 ml', 65.00, 750.0,
        N'ml', N'Cabernet Sauvignon', NULL, 0,
        NULL, 2, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 65.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 2,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Argentina' OR (grupo_comercial IS NULL AND N'Argentina' IS NULL))
              AND nombre = N'Séptima'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Errazuris Reserva'
        )
      AND nombre_presentacion = N'Carmenere · 750 ml'
      AND (variedad_vino = N'Carmenere' OR (variedad_vino IS NULL AND N'Carmenere' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Errazuris Reserva'
        ), N'Carmenere · 750 ml', 65.00, 750.0,
        N'ml', N'Carmenere', NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 65.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Errazuris Reserva'
        )
      AND nombre_presentacion = N'Carmenere · 750 ml'
      AND (variedad_vino = N'Carmenere' OR (variedad_vino IS NULL AND N'Carmenere' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Errazuris Reserva'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Errazuris Reserva'
        ), N'Cabernet Sauvignon · 750 ml', 65.00, 750.0,
        N'ml', N'Cabernet Sauvignon', NULL, 0,
        NULL, 2, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 65.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 2,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Errazuris Reserva'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Cousiño Macul Antiguas Reservas'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Cousiño Macul Antiguas Reservas'
        ), N'Cabernet Sauvignon · 750 ml', 80.00, 750.0,
        N'ml', N'Cabernet Sauvignon', NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 80.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Cousiño Macul Antiguas Reservas'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Cousiño Macul Don Matías Reserva'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Cousiño Macul Don Matías Reserva'
        ), N'Cabernet Sauvignon · 750 ml', 70.00, 750.0,
        N'ml', N'Cabernet Sauvignon', NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 70.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Cousiño Macul Don Matías Reserva'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Cousiño Macul Don Luis'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Cousiño Macul Don Luis'
        ), N'Cabernet Sauvignon · 750 ml', 55.00, 750.0,
        N'ml', N'Cabernet Sauvignon', NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 55.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Cousiño Macul Don Luis'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Marqués de Casa Concha'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Marqués de Casa Concha'
        ), N'Cabernet Sauvignon · 750 ml', 110.00, 750.0,
        N'ml', N'Cabernet Sauvignon', NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 110.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Marqués de Casa Concha'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Casillero del Diablo Reserva Privada'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Casillero del Diablo Reserva Privada'
        ), N'Cabernet Sauvignon · 750 ml', 90.00, 750.0,
        N'ml', N'Cabernet Sauvignon', NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 90.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Casillero del Diablo Reserva Privada'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Casillero del Diablo Reserva'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Casillero del Diablo Reserva'
        ), N'Cabernet Sauvignon · 750 ml', 50.00, 750.0,
        N'ml', N'Cabernet Sauvignon', NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 50.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Casillero del Diablo Reserva'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Casillero del Diablo Reserva'
        )
      AND nombre_presentacion = N'Carmenere · 750 ml'
      AND (variedad_vino = N'Carmenere' OR (variedad_vino IS NULL AND N'Carmenere' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Casillero del Diablo Reserva'
        ), N'Carmenere · 750 ml', 50.00, 750.0,
        N'ml', N'Carmenere', NULL, 0,
        NULL, 2, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 50.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 2,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Casillero del Diablo Reserva'
        )
      AND nombre_presentacion = N'Carmenere · 750 ml'
      AND (variedad_vino = N'Carmenere' OR (variedad_vino IS NULL AND N'Carmenere' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Casillero del Diablo Reserva'
        )
      AND nombre_presentacion = N'Malbec · 750 ml'
      AND (variedad_vino = N'Malbec' OR (variedad_vino IS NULL AND N'Malbec' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Casillero del Diablo Reserva'
        ), N'Malbec · 750 ml', 50.00, 750.0,
        N'ml', N'Malbec', NULL, 0,
        NULL, 3, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 50.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 3,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Casillero del Diablo Reserva'
        )
      AND nombre_presentacion = N'Malbec · 750 ml'
      AND (variedad_vino = N'Malbec' OR (variedad_vino IS NULL AND N'Malbec' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Casillero del Diablo Reserva'
        )
      AND nombre_presentacion = N'Merlot · 750 ml'
      AND (variedad_vino = N'Merlot' OR (variedad_vino IS NULL AND N'Merlot' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Casillero del Diablo Reserva'
        ), N'Merlot · 750 ml', 50.00, 750.0,
        N'ml', N'Merlot', NULL, 0,
        NULL, 4, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 50.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 4,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Casillero del Diablo Reserva'
        )
      AND nombre_presentacion = N'Merlot · 750 ml'
      AND (variedad_vino = N'Merlot' OR (variedad_vino IS NULL AND N'Merlot' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Casillero del Diablo Reserva'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 375 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Casillero del Diablo Reserva'
        ), N'Cabernet Sauvignon · 375 ml', 30.00, 375.0,
        N'ml', N'Cabernet Sauvignon', NULL, 0,
        NULL, 5, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 30.00,
        peso_volumen_cantidad = 375.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 5,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Casillero del Diablo Reserva'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 375 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Concha y Toro Frontera'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Concha y Toro Frontera'
        ), N'Cabernet Sauvignon · 750 ml', 40.00, 750.0,
        N'ml', N'Cabernet Sauvignon', NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 40.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Chile' OR (grupo_comercial IS NULL AND N'Chile' IS NULL))
              AND nombre = N'Concha y Toro Frontera'
        )
      AND nombre_presentacion = N'Cabernet Sauvignon · 750 ml'
      AND (variedad_vino = N'Cabernet Sauvignon' OR (variedad_vino IS NULL AND N'Cabernet Sauvignon' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'España' OR (grupo_comercial IS NULL AND N'España' IS NULL))
              AND nombre = N'Herederos del Marqués de Riscal'
        )
      AND nombre_presentacion = N'Tempranillo · 750 ml'
      AND (variedad_vino = N'Tempranillo' OR (variedad_vino IS NULL AND N'Tempranillo' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'España' OR (grupo_comercial IS NULL AND N'España' IS NULL))
              AND nombre = N'Herederos del Marqués de Riscal'
        ), N'Tempranillo · 750 ml', 130.00, 750.0,
        N'ml', N'Tempranillo', NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 130.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'España' OR (grupo_comercial IS NULL AND N'España' IS NULL))
              AND nombre = N'Herederos del Marqués de Riscal'
        )
      AND nombre_presentacion = N'Tempranillo · 750 ml'
      AND (variedad_vino = N'Tempranillo' OR (variedad_vino IS NULL AND N'Tempranillo' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'España' OR (grupo_comercial IS NULL AND N'España' IS NULL))
              AND nombre = N'Herederos del Marqués de Riscal'
        )
      AND nombre_presentacion = N'Tinto Reserva · 750 ml'
      AND (variedad_vino = N'Tinto Reserva' OR (variedad_vino IS NULL AND N'Tinto Reserva' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'España' OR (grupo_comercial IS NULL AND N'España' IS NULL))
              AND nombre = N'Herederos del Marqués de Riscal'
        ), N'Tinto Reserva · 750 ml', 75.00, 750.0,
        N'ml', N'Tinto Reserva', NULL, 0,
        NULL, 2, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 75.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 2,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'España' OR (grupo_comercial IS NULL AND N'España' IS NULL))
              AND nombre = N'Herederos del Marqués de Riscal'
        )
      AND nombre_presentacion = N'Tinto Reserva · 750 ml'
      AND (variedad_vino = N'Tinto Reserva' OR (variedad_vino IS NULL AND N'Tinto Reserva' IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'España' OR (grupo_comercial IS NULL AND N'España' IS NULL))
              AND nombre = N'Protos Roble'
        )
      AND nombre_presentacion = N'750 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'España' OR (grupo_comercial IS NULL AND N'España' IS NULL))
              AND nombre = N'Protos Roble'
        ), N'750 ml', 75.00, 750.0,
        N'ml', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 75.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'España' OR (grupo_comercial IS NULL AND N'España' IS NULL))
              AND nombre = N'Protos Roble'
        )
      AND nombre_presentacion = N'750 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Blancos' OR (grupo_comercial IS NULL AND N'Blancos' IS NULL))
              AND nombre = N'Tacama Blanco de Blancos'
        )
      AND nombre_presentacion = N'750 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Blancos' OR (grupo_comercial IS NULL AND N'Blancos' IS NULL))
              AND nombre = N'Tacama Blanco de Blancos'
        ), N'750 ml', 65.00, 750.0,
        N'ml', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 65.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Blancos' OR (grupo_comercial IS NULL AND N'Blancos' IS NULL))
              AND nombre = N'Tacama Blanco de Blancos'
        )
      AND nombre_presentacion = N'750 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Blancos' OR (grupo_comercial IS NULL AND N'Blancos' IS NULL))
              AND nombre = N'Tabernero Blanco de Blancos'
        )
      AND nombre_presentacion = N'750 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Blancos' OR (grupo_comercial IS NULL AND N'Blancos' IS NULL))
              AND nombre = N'Tabernero Blanco de Blancos'
        ), N'750 ml', 40.00, 750.0,
        N'ml', NULL, NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 40.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Blancos' OR (grupo_comercial IS NULL AND N'Blancos' IS NULL))
              AND nombre = N'Tabernero Blanco de Blancos'
        )
      AND nombre_presentacion = N'750 ml'
      AND (variedad_vino = NULL OR (variedad_vino IS NULL AND NULL IS NULL));
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.presentacion_producto
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Blancos' OR (grupo_comercial IS NULL AND N'Blancos' IS NULL))
              AND nombre = N'Selección de Parcelas Reserva'
        )
      AND nombre_presentacion = N'Chardonnay · 750 ml'
      AND (variedad_vino = N'Chardonnay' OR (variedad_vino IS NULL AND N'Chardonnay' IS NULL))
)
BEGIN
    INSERT INTO dbo.presentacion_producto (
        id_producto, nombre_presentacion, precio, peso_volumen_cantidad,
        unidad_medida, variedad_vino, descripcion_presentacion, destacado,
        imagen, orden, activo
    )
    VALUES (
        (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Blancos' OR (grupo_comercial IS NULL AND N'Blancos' IS NULL))
              AND nombre = N'Selección de Parcelas Reserva'
        ), N'Chardonnay · 750 ml', 95.00, 750.0,
        N'ml', N'Chardonnay', NULL, 0,
        NULL, 1, 1
    );
END
ELSE
BEGIN
    UPDATE dbo.presentacion_producto SET
        precio = 95.00,
        peso_volumen_cantidad = 750.0,
        unidad_medida = N'ml',
        descripcion_presentacion = NULL,
        destacado = 0,
        imagen = NULL,
        orden = 1,
        activo = 1
    WHERE id_producto = (
            SELECT TOP 1 id_producto FROM dbo.producto_carta 
            WHERE id_categoria = 'vinos' 
              AND (grupo_comercial = N'Blancos' OR (grupo_comercial IS NULL AND N'Blancos' IS NULL))
              AND nombre = N'Selección de Parcelas Reserva'
        )
      AND nombre_presentacion = N'Chardonnay · 750 ml'
      AND (variedad_vino = N'Chardonnay' OR (variedad_vino IS NULL AND N'Chardonnay' IS NULL));
END

GO
PRINT 'Presentaciones cargadas / actualizadas con éxito.';
GO


-- 3. VALIDACIÓN Y RECONCILIACIÓN FINAL
DECLARE @total_cat INT, @total_prod INT, @total_pres INT, @suma_precios DECIMAL(10,2);
SELECT @total_cat = COUNT(*) FROM dbo.categoria_producto WHERE activa = 1;
SELECT @total_prod = COUNT(*) FROM dbo.producto_carta WHERE id_categoria IS NOT NULL AND activo = 1;
SELECT @total_pres = COUNT(*), @suma_precios = SUM(precio) FROM dbo.presentacion_producto WHERE activo = 1;

PRINT '==================================================';
PRINT 'REPORTE DE RECONCILIACIÓN CATÁLOGO REAL:';
PRINT 'Categorías activas: ' + CAST(@total_cat AS VARCHAR(10)) + ' (Esperado: 9)';
PRINT 'Productos lógicos activos: ' + CAST(@total_prod AS VARCHAR(10)) + ' (Esperado: 120)';
PRINT 'Presentaciones activas: ' + CAST(@total_pres AS VARCHAR(10)) + ' (Esperado: 146)';
PRINT 'Suma total de precios: S/ ' + CAST(@suma_precios AS VARCHAR(20)) + ' (Esperado: 7231.00)';
PRINT '==================================================';

IF (@total_cat = 9 AND @total_prod = 120 AND @total_pres = 146 AND @suma_precios = 7231.00)
    PRINT '>> RECONCILIACIÓN EXITOSA: 100% DE COINCIDENCIA CON carta.model.ts';
ELSE
    THROW 51000, 'Error: discrepancia en la reconciliación del catálogo.', 1;
GO
