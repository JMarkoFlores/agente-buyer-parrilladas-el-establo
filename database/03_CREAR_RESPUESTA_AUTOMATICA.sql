-- ==============================================================================
-- MIGRACIÓN ADITIVA: CREACIÓN DE TABLA dbo.respuesta_automatica
-- Agente Inteligente Multicanal para la Captación y Conversión de BUYERS
-- Parrilladas El Establo
-- ==============================================================================
-- Esta migración es estrictamente no destructiva:
-- 1. No altera claves ni registros existentes de las 22 tablas.
-- 2. Asegura idempotencia con IF NOT EXISTS.
-- 3. Previene duplicados con UQ_respuesta_interaccion (unidireccional por interacción).
-- ==============================================================================

USE buyer;
GO

IF NOT EXISTS (
    SELECT * FROM sys.tables 
    WHERE name = 'respuesta_automatica' AND schema_id = SCHEMA_ID('dbo')
)
BEGIN
    PRINT 'Creando tabla dbo.respuesta_automatica...';

    CREATE TABLE dbo.respuesta_automatica (
        id_respuesta bigint IDENTITY(1,1) PRIMARY KEY,
        id_interaccion bigint NOT NULL,
        id_buyer bigint NULL,
        id_plataforma int NOT NULL,
        intencion_detectada varchar(50) NULL,
        texto_respuesta nvarchar(2000) NOT NULL,
        id_respuesta_meta varchar(150) NULL,
        estado varchar(25) NOT NULL DEFAULT 'PENDIENTE',
        tipo_envio varchar(20) NOT NULL DEFAULT 'AUTOMATICO',
        fecha_generacion datetime2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
        fecha_envio datetime2(0) NULL,
        error_detalle nvarchar(1000) NULL,

        CONSTRAINT FK_respuesta_interaccion 
            FOREIGN KEY (id_interaccion) REFERENCES dbo.interaccion_publicacion(id_interaccion),
        CONSTRAINT FK_respuesta_buyer 
            FOREIGN KEY (id_buyer) REFERENCES dbo.buyer(id_buyer),
        CONSTRAINT FK_respuesta_plataforma 
            FOREIGN KEY (id_plataforma) REFERENCES dbo.plataforma(id_plataforma),
        CONSTRAINT CK_respuesta_estado 
            CHECK (estado IN ('PENDIENTE', 'APROBADA', 'SIMULADA', 'ENVIANDO', 'ENVIADA', 'FALLIDA', 'OMITIDA', 'REQUIERE_REVISION')),
        CONSTRAINT CK_respuesta_tipo_envio 
            CHECK (tipo_envio IN ('AUTOMATICO', 'MANUAL_APROBADO', 'SIMULADO')),
        CONSTRAINT UQ_respuesta_interaccion 
            UNIQUE (id_interaccion)
    );

    CREATE INDEX IX_respuesta_estado_fecha 
        ON dbo.respuesta_automatica(estado, fecha_generacion);
    CREATE INDEX IX_respuesta_plataforma 
        ON dbo.respuesta_automatica(id_plataforma, fecha_generacion);
    CREATE INDEX IX_respuesta_buyer 
        ON dbo.respuesta_automatica(id_buyer);

    PRINT 'Tabla dbo.respuesta_automatica creada exitosamente.';
END
ELSE
BEGIN
    PRINT 'La tabla dbo.respuesta_automatica ya existe en dbo. Operación idempotente.';
END
GO
