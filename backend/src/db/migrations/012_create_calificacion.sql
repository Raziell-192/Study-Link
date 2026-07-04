-- HU-26/27: Evaluación y Reputación.
-- Tabla tal cual el MER (Calificacion), sin columnas extra: AppMovil.md sección 17 menciona
-- 4 criterios (claridad, conocimiento, puntualidad, materiales), pero el MER solo define
-- una `puntuacion` global + `comentario` — se respeta el MER (igual que se hizo con HU-07),
-- los 4 criterios quedan como guía cualitativa para el comentario, no como columnas separadas.
-- UNIQUE(id_sesion, id_tutorado): un tutorado solo puede calificar una vez cada sesión.
CREATE TABLE IF NOT EXISTS calificacion (
    id_calificacion UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_sesion UUID NOT NULL REFERENCES sesion_estudio(id_sesion) ON DELETE CASCADE,
    id_tutor UUID NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    id_tutorado UUID NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    puntuacion INTEGER NOT NULL CHECK (puntuacion BETWEEN 1 AND 5),
    comentario TEXT,
    fecha TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (id_sesion, id_tutorado)
);

CREATE INDEX IF NOT EXISTS idx_calificacion_tutor ON calificacion(id_tutor);
