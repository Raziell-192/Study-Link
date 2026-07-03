-- HU-14/15: Flashcards. Tablas tal cual el MER (Flashcard, Tarjeta), sin columnas extra.
-- "compartida" es la única señal de visibilidad: no hay id_grupo ni id_materia en el MER
-- para Flashcard, así que "compartir" (HU-15) significa visible para cualquier usuario
-- (modo público de solo lectura), no edición colaborativa multi-usuario.
CREATE TABLE IF NOT EXISTS flashcard (
    id_flashcard UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_usuario UUID NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    titulo VARCHAR(150) NOT NULL,
    compartida BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS tarjeta (
    id_tarjeta UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_flashcard UUID NOT NULL REFERENCES flashcard(id_flashcard) ON DELETE CASCADE,
    pregunta TEXT NOT NULL,
    respuesta TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_flashcard_compartida ON flashcard(compartida);
CREATE INDEX IF NOT EXISTS idx_tarjeta_flashcard ON tarjeta(id_flashcard);
