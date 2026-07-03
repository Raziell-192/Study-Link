CREATE TABLE IF NOT EXISTS miembro_grupo (
    id_miembro UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_usuario UUID NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    id_grupo UUID NOT NULL REFERENCES grupo(id_grupo) ON DELETE CASCADE,
    rol VARCHAR(20) NOT NULL CHECK (rol IN ('Tutor', 'Tutorado')),
    fecha_union TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (id_usuario, id_grupo)
);