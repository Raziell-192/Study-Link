-- HU-28/29: Registro de Asistencia.
-- Tal cual el MER. El tutor registra ingreso y salida en un solo acto (decisión de equipo),
-- no hay check-in/check-out separado en tiempo real.
-- UNIQUE(id_sesion, id_usuario): un usuario solo tiene un registro de asistencia por sesión.
CREATE TABLE IF NOT EXISTS asistencia (
    id_asistencia UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_sesion UUID NOT NULL REFERENCES sesion_estudio(id_sesion) ON DELETE CASCADE,
    id_usuario UUID NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    hora_ingreso TIMESTAMP NOT NULL,
    hora_salida TIMESTAMP,
    CHECK (hora_salida IS NULL OR hora_salida > hora_ingreso),
    UNIQUE (id_sesion, id_usuario)
);

CREATE INDEX IF NOT EXISTS idx_asistencia_usuario ON asistencia(id_usuario);