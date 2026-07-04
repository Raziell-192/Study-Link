-- HU-11/12/13: Biblioteca de Recursos.
-- Se agregó tipo_archivo (no está en el MER) porque AppMovil.md sección 10 exige
-- distinguir PDF / Imagen / Enlace / Presentación para poder clasificar y filtrar.
-- Se agregó descripcion (no está en el MER) para permitir búsqueda de texto en HU-12.
-- archivo_url guarda la URL ya subida a Firebase Storage por el cliente (Flutter) —
-- el backend NO maneja el archivo binario, solo referencia la URL. Ver Progreso-Studylink.md.
CREATE TABLE IF NOT EXISTS apunte (
    id_apunte UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_usuario UUID NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    id_materia UUID NOT NULL REFERENCES materia(id_materia) ON DELETE RESTRICT,
    titulo VARCHAR(150) NOT NULL,
    descripcion TEXT,
    tipo_archivo VARCHAR(20) NOT NULL CHECK (tipo_archivo IN ('PDF', 'Imagen', 'Enlace', 'Presentacion')),
    archivo_url VARCHAR(500) NOT NULL,
    fecha_subida TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_apunte_materia ON apunte(id_materia);
