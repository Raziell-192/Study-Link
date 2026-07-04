-- HU-21/22: Comunicación (chat privado y grupal).
-- id_usuario_1/id_usuario_2 (no están en el MER) identifican los 2 participantes
-- de una conversación Privada. Para Grupal, se reutiliza id_grupo (no está en el MER)
-- en vez de duplicar membresía — ya existe miembro_grupo para saber quién participa.
-- El CHECK obliga a que cada conversación tenga exactamente los campos de su tipo.
CREATE TABLE IF NOT EXISTS conversacion (
    id_conversacion UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('Privada', 'Grupal')),
    id_grupo UUID REFERENCES grupo(id_grupo) ON DELETE CASCADE,
    id_usuario_1 UUID REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    id_usuario_2 UUID REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT NOW(),
    CHECK (
        (tipo = 'Privada' AND id_grupo IS NULL AND id_usuario_1 IS NOT NULL AND id_usuario_2 IS NOT NULL)
        OR
        (tipo = 'Grupal' AND id_grupo IS NOT NULL AND id_usuario_1 IS NULL AND id_usuario_2 IS NULL)
    ),
    UNIQUE (id_usuario_1, id_usuario_2)
);

CREATE TABLE IF NOT EXISTS mensaje (
    id_mensaje UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_conversacion UUID NOT NULL REFERENCES conversacion(id_conversacion) ON DELETE CASCADE,
    id_usuario UUID NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    contenido TEXT NOT NULL,
    fecha_envio TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_mensaje_conversacion ON mensaje(id_conversacion, fecha_envio);