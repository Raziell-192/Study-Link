CREATE TABLE IF NOT EXISTS apunte (
    id_apunte UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_usuario UUID NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    id_materia UUID NOT NULL REFERENCES materia(id_materia) ON DELETE RESTRICT,
    titulo VARCHAR(150) NOT NULL,
    archivo_url VARCHAR(255) NOT NULL,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('PDF', 'Imagen', 'Enlace', 'Presentacion')),
    fecha_subida TIMESTAMP NOT NULL DEFAULT NOW()
);