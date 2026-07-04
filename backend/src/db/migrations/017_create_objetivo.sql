-- HU-23/24: Objetivos de Aprendizaje.
-- Tal cual el MER (Objetivo), con progreso limitado a 0-100.
-- El estado (No iniciado/En progreso/Completado/Dominado de AppMovil.md sección 15)
-- se deriva de `progreso` al leer, no se guarda como columna:
--   progreso = 0    -> No iniciado
--   1-99            -> En progreso
--   100             -> Completado
-- "Dominado" no tiene un umbral numérico claro en la documentación, así que no se
-- deriva automáticamente — queda como limitación conocida (ver PROGRESS.md).
CREATE TABLE IF NOT EXISTS objetivo (
    id_objetivo UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_usuario UUID NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    titulo VARCHAR(150) NOT NULL,
    descripcion TEXT,
    progreso INTEGER NOT NULL DEFAULT 0 CHECK (progreso BETWEEN 0 AND 100),
    fecha_limite DATE,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_objetivo_usuario ON objetivo(id_usuario);