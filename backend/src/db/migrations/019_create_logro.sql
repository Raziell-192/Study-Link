-- HU-30/31: Gamificación (Logros e Insignias).
-- `logro` es el catálogo (tal cual el MER) + `codigo` (no está en el MER):
-- clave interna estable para que el backend sepa qué criterio numérico corresponde
-- a cada fila sin acoplarse al id_logro (UUID) ni al texto de `nombre`.
-- Semillas basadas en AppMovil.md sección 20 (Sistema de Logros): objetivos,
-- asistencia, ayudar a otros (tutorías impartidas), compartir recursos (apuntes)
-- y completar sesiones. Los umbrales exactos no estaban definidos en la
-- documentación, así que se fijaron como decisión de equipo (ver PROGRESS.md).
CREATE TABLE IF NOT EXISTS logro (
    id_logro UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    icono VARCHAR(100)
);

-- Usuario_Logro tal cual el MER. UNIQUE(id_usuario, id_logro): un logro se obtiene una sola vez.
CREATE TABLE IF NOT EXISTS usuario_logro (
    id_usuario_logro UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_usuario UUID NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    id_logro UUID NOT NULL REFERENCES logro(id_logro) ON DELETE CASCADE,
    fecha_obtenido TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (id_usuario, id_logro)
);

CREATE INDEX IF NOT EXISTS idx_usuario_logro_usuario ON usuario_logro(id_usuario);

-- Catálogo inicial (6 logros, uno de "ayudar a otros" con 2 escalones para dar
-- sensación de progresión sin necesitar tabla de niveles todavía).
INSERT INTO logro (codigo, nombre, descripcion, icono) VALUES
    ('objetivo_1',    'Primer Paso',        'Completaste tu primer objetivo académico.', 'flag'),
    ('objetivo_5',     'Meta Cumplida',      'Completaste 5 objetivos académicos.', 'trophy'),
    ('asistencia_5',   'Asistencia Constante', 'Registraste asistencia en 5 sesiones de estudio.', 'calendar-check'),
    ('tutor_3',         'Buen Samaritano',    'Ayudaste a otros estudiantes impartiendo 3 tutorías.', 'hand-heart'),
    ('apuntes_3',       'Compartiendo Conocimiento', 'Subiste 3 apuntes a la biblioteca.', 'book-open'),
    ('sesiones_5',      'Estudiante Dedicado', 'Completaste 5 sesiones de estudio en grupo.', 'medal')
ON CONFLICT (codigo) DO NOTHING;
