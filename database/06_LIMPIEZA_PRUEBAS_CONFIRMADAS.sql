-- ==============================================================================
-- LIMPIEZA SEGURA DE DATOS DE PRUEBA CONFIRMADOS (PROMPT 19)
-- Agente Inteligente Multicanal para la Captación y Conversión de BUYERS
-- Parrilladas El Establo
-- ==============================================================================
-- Este script elimina EXCLUSIVAMENTE los registros sintéticos generados
-- por la suite automatizada pytest (test_landing_endpoints.py), comprobados
-- con evidencia forense (mismo payload, tokens y llamadas automatizadas).
--
-- Los registros exploratorios (Carlos Mendoza Rios) e indeterminados se
-- preservan intactos para revisión.
-- Los registros reales (Gian Franco Samana, comentarios Meta) se preservan 100%.
-- ==============================================================================

USE buyer;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET NOCOUNT ON;

BEGIN TRANSACTION;

BEGIN TRY
    PRINT '>> Iniciando eliminación de registros de prueba confirmados...';

    -- 1. Historial de Fases de Persona de Prueba (Valeria Castro Morales, ID 6)
    DELETE FROM dbo.historial_fases
    WHERE id_persona = 6;
    PRINT '   [1/8] dbo.historial_fases eliminadas: ' + CAST(@@ROWCOUNT AS VARCHAR);

    -- 2. Conversiones a LEAD de Prueba (Valeria Castro Morales, ID 6)
    DELETE FROM dbo.lead_conversion
    WHERE id_persona = 6;
    PRINT '   [2/8] dbo.lead_conversion eliminadas: ' + CAST(@@ROWCOUNT AS VARCHAR);

    -- 3. Formularios de Captación de Prueba (Valeria Castro Morales, ID 6)
    DELETE FROM dbo.formulario_captacion
    WHERE id_persona = 6;
    PRINT '   [3/8] dbo.formulario_captacion eliminados: ' + CAST(@@ROWCOUNT AS VARCHAR);

    -- 4. Eventos Web de Visitas Automatizadas de Pytest
    DELETE FROM dbo.evento_web
    WHERE id_visita IN (6, 7, 8, 9, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30);
    PRINT '   [4/8] dbo.evento_web eliminados: ' + CAST(@@ROWCOUNT AS VARCHAR);

    -- 5. Desenlazar Visitas Web de los Buyers de Prueba antes de borrar
    UPDATE dbo.visita_web
    SET id_buyer = NULL
    WHERE id_buyer IN (56, 57, 59, 60, 63);

    -- 6. Visitas Web Automatizadas de Pytest
    DELETE FROM dbo.visita_web
    WHERE id_visita IN (6, 7, 8, 9, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30);
    PRINT '   [5/8] dbo.visita_web eliminadas: ' + CAST(@@ROWCOUNT AS VARCHAR);

    -- 7. Registros BUYER Sintéticos de Pytest
    DELETE FROM dbo.buyer
    WHERE id_buyer IN (56, 57, 59, 60, 63);
    PRINT '   [6/8] dbo.buyer eliminados: ' + CAST(@@ROWCOUNT AS VARCHAR);

    -- 8. Desenlazar Visitantes Web asociados a la Persona de Prueba
    UPDATE dbo.visitante_web
    SET id_persona = NULL
    WHERE id_persona = 6;

    -- 9. Visitantes Web Huérfanos creados exclusivamente en las pruebas automatizadas
    DELETE FROM dbo.visitante_web
    WHERE id_visitante IN (5, 6, 7, 8, 10, 11, 12, 13, 14, 15, 16, 17)
      AND id_visitante NOT IN (SELECT id_visitante FROM dbo.visita_web);
    PRINT '   [7/8] dbo.visitante_web huérfanos eliminados: ' + CAST(@@ROWCOUNT AS VARCHAR);

    -- 10. Persona Sintética de Prueba (Valeria Castro Morales, ID 6)
    DELETE FROM dbo.persona
    WHERE id_persona = 6;
    PRINT '   [8/8] dbo.persona 6 eliminada: ' + CAST(@@ROWCOUNT AS VARCHAR);

    -- Control de integridad referencial final
    IF EXISTS (SELECT 1 FROM dbo.lead_conversion WHERE id_persona = 6)
        THROW 52001, 'Control fallido: Quedaron conversiones huérfanas de persona 6.', 1;

    IF EXISTS (SELECT 1 FROM dbo.formulario_captacion WHERE id_persona = 6)
        THROW 52002, 'Control fallido: Quedaron formularios huérfanos de persona 6.', 1;

    IF EXISTS (SELECT 1 FROM dbo.buyer WHERE id_buyer IN (56, 57, 59, 60, 63))
        THROW 52003, 'Control fallido: Quedaron buyers sintéticos.', 1;

    COMMIT TRANSACTION;
    PRINT '>> ÉXITO: Transacción confirmada (COMMIT). Limpieza finalizada correctamente.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    DECLARE @Err NVARCHAR(4000) = ERROR_MESSAGE();
    PRINT '>> ERROR EN LIMPIEZA: ' + @Err;
    THROW;
END CATCH;
GO
