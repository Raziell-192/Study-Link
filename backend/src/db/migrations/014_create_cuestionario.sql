-- HU-16/17: Cuestionarios. Tablas basadas en el MER (Cuestionario, Pregunta).
-- Se agregó "opciones" JSONB (nullable, NO está en el MER) porque el MER solo guarda
-- pregunta + tipo + respuesta_correcta, pero para tipo 'OpcionMultiple' y
-- 'RelacionConceptos' hace falta persistir las opciones que se le muestran al usuario
-- para poder responder (respuesta_correcta sola no alcanza). Para 'VerdaderoFalso' y
-- 'RespuestaCorta', "opciones" queda NULL.
CREATE TABLE IF NOT EXISTS cuestionario (
    id_cuestionario UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_usuario UUID NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    titulo VARCHAR(150) NOT NULL,
    compartido BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS pregunta (
    id_pregunta UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_cuestionario UUID NOT NULL REFERENCES cuestionario(id_cuestionario) ON DELETE CASCADE,
    pregunta TEXT NOT NULL,
    tipo VARCHAR(30) NOT NULL CHECK (tipo IN ('OpcionMultiple', 'VerdaderoFalso', 'RelacionConceptos', 'RespuestaCorta')),
    opciones JSONB,
    respuesta_correcta TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_cuestionario_compartido ON cuestionario(compartido);
CREATE INDEX IF NOT EXISTS idx_pregunta_cuestionario ON pregunta(id_cuestionario);
