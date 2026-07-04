-- HU-20: Recibir Recordatorios.
-- Tabla nueva, no está en el MER (el MER no contemplaba recordatorios como entidad).
-- Diseño acordado: el backend NO envía push notifications (eso requeriría integrar
-- Firebase Admin / FCM, sin credenciales disponibles). El backend solo guarda y expone
-- los recordatorios; el cliente Flutter los consulta periódicamente (polling) y decide
-- cómo notificar (notificación local o FCM). Ver Progreso-Studylink.md.
-- id_evento es nullable y ON DELETE CASCADE: por ahora los recordatorios se generan
-- a partir de un evento de calendario (sesión, examen, etc. modelados como Evento_Calendario).
-- tipo incluye también 'Material' y 'Objetivo' para dejar el catálogo abierto a cuando
-- existan las Épicas 4bis/8, aunque hoy solo se usan 'Sesion' y 'Evento'.
CREATE TABLE IF NOT EXISTS recordatorio (
    id_recordatorio UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_usuario UUID NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    id_evento UUID REFERENCES evento_calendario(id_evento) ON DELETE CASCADE,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('Sesion', 'Examen', 'Tarea', 'Material', 'Objetivo', 'Evento')),
    mensaje VARCHAR(255) NOT NULL,
    fecha_disparo TIMESTAMP NOT NULL,
    enviado BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_recordatorio_usuario_pendientes ON recordatorio(id_usuario, enviado, fecha_disparo);
