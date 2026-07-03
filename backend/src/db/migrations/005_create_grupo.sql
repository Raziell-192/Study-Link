CREATE TABLE IF NOT EXISTS grupo (
    id_grupo UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT NOW(),
    id_creador UUID NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    id_materia UUID REFERENCES materia(id_materia) ON DELETE SET NULL
);