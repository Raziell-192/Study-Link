CREATE TABLE IF NOT EXISTS usuario_materia (
    id_usuario_materia UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_usuario UUID NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    id_materia UUID NOT NULL REFERENCES materia(id_materia) ON DELETE CASCADE,
    nivel_conocimiento VARCHAR(20) NOT NULL CHECK (nivel_conocimiento IN ('Básico', 'Intermedio', 'Avanzado')),
    UNIQUE (id_usuario, id_materia)
);