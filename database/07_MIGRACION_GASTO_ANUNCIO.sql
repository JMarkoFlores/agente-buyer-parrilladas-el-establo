-- ==============================================================================
-- MIGRACIÓN ADITIVA: EXTENSIÓN DE TABLA GASTOS PARA KPI CPA ACADÉMICO (PROMPT 19)
-- Agente Inteligente Multicanal para la Captación y Conversión de BUYERS
-- Parrilladas El Establo
-- ==============================================================================
-- Reutiliza dbo.gasto_anuncio_diario agregando trazabilidad de simulación académica:
-- - origen_dato: 'SIMULADO_ACADEMICO' | 'META_ADS_REAL'
-- - es_simulado: 1 para académico, 0 para real
-- - id_campana, id_plataforma y observacion
--
-- Crea la vista canónica dbo.gasto_anuncio para compatibilidad arquitectónica.
-- Operación estrictamente idempotente y no destructiva.
-- ==============================================================================

USE buyer;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET NOCOUNT ON;

-- 1. Flexibilizar id_anuncio para permitir presupuestos a nivel de campaña/plataforma
IF EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('dbo.gasto_anuncio_diario') 
      AND name = 'id_anuncio' 
      AND is_nullable = 0
)
BEGIN
    PRINT '>> Permitiendo NULL en dbo.gasto_anuncio_diario.id_anuncio...';
    -- Primero verificar si existe la restricción UNIQUE anterior
    IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'UQ_gasto_anuncio_dia')
    BEGIN
        ALTER TABLE dbo.gasto_anuncio_diario DROP CONSTRAINT UQ_gasto_anuncio_dia;
    END;
    
    ALTER TABLE dbo.gasto_anuncio_diario ALTER COLUMN id_anuncio INT NULL;
END
GO

-- 2. Agregar columna id_campana
IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('dbo.gasto_anuncio_diario') AND name = 'id_campana'
)
BEGIN
    PRINT '>> Agregando columna id_campana a dbo.gasto_anuncio_diario...';
    ALTER TABLE dbo.gasto_anuncio_diario 
    ADD id_campana INT NULL CONSTRAINT FK_gasto_campana REFERENCES dbo.campana(id_campana);
END
GO

-- 3. Agregar columna id_plataforma
IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('dbo.gasto_anuncio_diario') AND name = 'id_plataforma'
)
BEGIN
    PRINT '>> Agregando columna id_plataforma a dbo.gasto_anuncio_diario...';
    ALTER TABLE dbo.gasto_anuncio_diario 
    ADD id_plataforma INT NULL CONSTRAINT FK_gasto_plataforma REFERENCES dbo.plataforma(id_plataforma);
END
GO

-- 4. Agregar columna origen_dato
IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('dbo.gasto_anuncio_diario') AND name = 'origen_dato'
)
BEGIN
    PRINT '>> Agregando columna origen_dato a dbo.gasto_anuncio_diario...';
    ALTER TABLE dbo.gasto_anuncio_diario 
    ADD origen_dato VARCHAR(30) NOT NULL CONSTRAINT DF_gasto_origen DEFAULT 'SIMULADO_ACADEMICO';
END
GO

-- 5. Agregar columna es_simulado
IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('dbo.gasto_anuncio_diario') AND name = 'es_simulado'
)
BEGIN
    PRINT '>> Agregando columna es_simulado a dbo.gasto_anuncio_diario...';
    ALTER TABLE dbo.gasto_anuncio_diario 
    ADD es_simulado BIT NOT NULL CONSTRAINT DF_gasto_simulado DEFAULT 1;
END
GO

-- 6. Agregar columna observacion
IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('dbo.gasto_anuncio_diario') AND name = 'observacion'
)
BEGIN
    PRINT '>> Agregando columna observacion a dbo.gasto_anuncio_diario...';
    ALTER TABLE dbo.gasto_anuncio_diario 
    ADD observacion NVARCHAR(250) NULL;
END
GO

-- 7. Agregar columna fecha_creacion
IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('dbo.gasto_anuncio_diario') AND name = 'fecha_creacion'
)
BEGIN
    PRINT '>> Agregando columna fecha_creacion a dbo.gasto_anuncio_diario...';
    ALTER TABLE dbo.gasto_anuncio_diario 
    ADD fecha_creacion DATETIME2(0) NOT NULL CONSTRAINT DF_gasto_fecha_crea DEFAULT SYSUTCDATETIME();
END
GO

-- 8. Actualizar registros existentes para asegurar consistencia
UPDATE dbo.gasto_anuncio_diario
SET origen_dato = 'SIMULADO_ACADEMICO',
    es_simulado = 1,
    observacion = 'Gasto inicial de demostración académica'
WHERE observacion IS NULL;
GO

-- 9. Crear Vista Unificada dbo.gasto_anuncio
CREATE OR ALTER VIEW dbo.gasto_anuncio AS
SELECT 
    g.id_gasto,
    g.id_anuncio,
    COALESCE(g.id_campana, a.id_campana) AS id_campana,
    COALESCE(g.id_plataforma, c.id_plataforma, 1) AS id_plataforma,
    g.fecha,
    g.monto,
    g.moneda,
    g.origen_dato,
    g.es_simulado,
    g.observacion,
    g.fecha_creacion
FROM dbo.gasto_anuncio_diario g
LEFT JOIN dbo.anuncio a ON g.id_anuncio = a.id_anuncio
LEFT JOIN dbo.campana c ON COALESCE(g.id_campana, a.id_campana) = c.id_campana;
GO

PRINT '>> Migración aditiva dbo.gasto_anuncio completada con éxito.';
GO
