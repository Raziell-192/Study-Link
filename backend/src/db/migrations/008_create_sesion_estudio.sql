CREATE TABLE IF NOT EXISTS sesion_estudio (
    id_sesion UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_grupo UUID NOT NULL REFERENCES grupo(id_grupo) ON DELETE CASCADE,
    id_creador UUID NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    tema VARCHAR(150) NOT NULL,
    descripcion TEXT,
    fecha_inicio TIMESTAMP NOT NULL,
    fecha_fin TIMESTAMP NOT NULL,
    modalidad VARCHAR(20) NOT NULL CHECK (modalidad IN ('Presencial', 'Virtual')),
    CHECK (fecha_fin > fecha_inicio)
);