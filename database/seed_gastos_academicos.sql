-- ==============================================================================
-- POBLADO IDEMPOTENTE DE GASTOS PUBLICITARIOS SIMULADOS (PROMPT 19)
-- Agente Inteligente Multicanal para la Captación y Conversión de BUYERS
-- Parrilladas El Establo
-- ==============================================================================
-- Finalidad EXCLUSIVA: Proporcionar el numerador para el cálculo académico del
-- KPI estratégico CPA (Costo por Adquisición de LEAD).
--
-- Restricciones:
-- - No representa gastos reales de Meta Ads (API Meta no entrega gasto sin tarjeta/crédito activo).
-- - Clasificado estrictamente como origen_dato = 'SIMULADO_ACADEMICO', es_simulado = 1.
-- - No altera métricas de publicaciones, comentarios, reacciones, visitantes ni LEADS.
-- - Idempotente: seguro para re-ejecución sin duplicar importes.
-- ==============================================================================

USE buyer;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET NOCOUNT ON;

PRINT '>> Iniciando poblado idempotente de gastos publicitarios simulados...';

-- Tabla temporal con los registros académicos presupuestados para noviembre 2026
DECLARE @GastosSimulados TABLE (
    id_anuncio INT NULL,
    id_campana INT NOT NULL,
    id_plataforma INT NOT NULL,
    fecha DATE NOT NULL,
    monto DECIMAL(12,2) NOT NULL,
    moneda CHAR(3) NOT NULL,
    observacion NVARCHAR(250) NOT NULL
);

INSERT INTO @GastosSimulados (id_anuncio, id_campana, id_plataforma, fecha, monto, moneda, observacion)
VALUES
    -- Campaña 1: Promoción picaña noviembre (Facebook)
    (NULL, 1, 1, '2026-11-08', 25.00, 'PEN', 'Presupuesto diario simulado FB - Picaña Noviembre'),
    (NULL, 1, 1, '2026-11-09', 25.00, 'PEN', 'Presupuesto diario simulado FB - Picaña Noviembre'),
    (NULL, 1, 1, '2026-11-10', 30.00, 'PEN', 'Presupuesto diario simulado FB - Picaña Noviembre'),
    (NULL, 1, 1, '2026-11-11', 30.00, 'PEN', 'Presupuesto diario simulado FB - Picaña Noviembre'),
    (NULL, 1, 1, '2026-11-12', 35.00, 'PEN', 'Presupuesto diario simulado FB - Picaña Noviembre'),

    -- Campaña 2: Sangría y parrilladas (Instagram)
    (NULL, 2, 2, '2026-11-08', 20.00, 'PEN', 'Presupuesto diario simulado IG - Sangría y Parrilladas'),
    (NULL, 2, 2, '2026-11-09', 20.00, 'PEN', 'Presupuesto diario simulado IG - Sangría y Parrilladas'),
    (NULL, 2, 2, '2026-11-10', 25.00, 'PEN', 'Presupuesto diario simulado IG - Sangría y Parrilladas'),
    (NULL, 2, 2, '2026-11-11', 25.00, 'PEN', 'Presupuesto diario simulado IG - Sangría y Parrilladas'),
    (NULL, 2, 2, '2026-11-12', 30.00, 'PEN', 'Presupuesto diario simulado IG - Sangría y Parrilladas');

-- Inserción idempotente (solo si no existe gasto para la campaña en dicha fecha)
INSERT INTO dbo.gasto_anuncio_diario (
    id_anuncio,
    id_campana,
    id_plataforma,
    fecha,
    monto,
    moneda,
    origen_dato,
    es_simulado,
    observacion,
    fecha_creacion
)
SELECT 
    s.id_anuncio,
    s.id_campana,
    s.id_plataforma,
    s.fecha,
    s.monto,
    s.moneda,
    'SIMULADO_ACADEMICO',
    1,
    s.observacion,
    SYSUTCDATETIME()
FROM @GastosSimulados s
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.gasto_anuncio_diario g
    WHERE g.id_campana = s.id_campana
      AND g.fecha = s.fecha
      AND g.origen_dato = 'SIMULADO_ACADEMICO'
);

PRINT '   Registros nuevos insertados: ' + CAST(@@ROWCOUNT AS VARCHAR);

-- Resumen de control
SELECT 
    c.nombre AS campana,
    p.codigo AS plataforma,
    COUNT(*) AS dias_con_gasto,
    SUM(g.monto) AS total_gasto_simulado,
    g.moneda
FROM dbo.gasto_anuncio_diario g
JOIN dbo.campana c ON g.id_campana = c.id_campana
JOIN dbo.plataforma p ON g.id_plataforma = p.id_plataforma
WHERE g.es_simulado = 1
GROUP BY c.nombre, p.codigo, g.moneda;

PRINT '>> Script seed_gastos_academicos.sql finalizado exitosamente.';
GO
