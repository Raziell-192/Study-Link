CREATE TABLE IF NOT EXISTS materia (
    id_materia UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(150) UNIQUE NOT NULL,
    descripcion TEXT
);