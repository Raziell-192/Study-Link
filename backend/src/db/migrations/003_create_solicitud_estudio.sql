CREATE TABLE IF NOT EXISTS solicitud_estudio (
    id_solicitud UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_usuario UUID NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    id_materia UUID NOT NULL REFERENCES materia(id_materia) ON DELETE RESTRICT,
    id_tutor UUID REFERENCES usuario(id_usuario) ON DELETE SET NULL,
    titulo VARCHAR(150) NOT NULL,
    descripcion TEXT,
    modalidad VARCHAR(20) NOT NULL CHECK (modalidad IN ('Individual', 'Grupal')),
    fecha_creacion TIMESTAMP NOT NULL DEFAULT NOW(),
    estado VARCHAR(20) NOT NULL DEFAULT 'Abierta' CHECK (estado IN ('Abierta', 'En proceso', 'Cerrada'))
);