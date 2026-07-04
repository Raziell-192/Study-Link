-- HU-18/19: Calendario personal y compartido.
-- Se agregó id_grupo (nullable, no está en el MER) porque "compartido" por sí solo
-- no indica a QUÉ grupo se comparte el evento. Es necesario para que HU-19
-- (Visualizar Calendario Compartido) pueda filtrar eventos por grupo.
-- CHECK: si compartido = true, entonces id_grupo es obligatorio; si es personal, no.
CREATE TABLE IF NOT EXISTS evento_calendario (
    id_evento UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_usuario UUID NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    id_grupo UUID REFERENCES grupo(id_grupo) ON DELETE CASCADE,
    titulo VARCHAR(150) NOT NULL,
    descripcion TEXT,
    fecha_inicio TIMESTAMP NOT NULL,
    fecha_fin TIMESTAMP NOT NULL,
    compartido BOOLEAN NOT NULL DEFAULT FALSE,
    CHECK (fecha_fin > fecha_inicio),
    CHECK ((compartido = FALSE AND id_grupo IS NULL) OR (compartido = TRUE AND id_grupo IS NOT NULL))
);

CREATE INDEX IF NOT EXISTS idx_evento_usuario ON evento_calendario(id_usuario);
CREATE INDEX IF NOT EXISTS idx_evento_grupo ON evento_calendario(id_grupo);
