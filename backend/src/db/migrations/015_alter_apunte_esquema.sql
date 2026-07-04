-- Alinea la tabla apunte (creada localmente con el esquema viejo de la migración 009
-- original) con el esquema final acordado con el equipo tras el merge de ramas.
ALTER TABLE apunte RENAME COLUMN tipo TO tipo_archivo;
ALTER TABLE apunte ADD COLUMN IF NOT EXISTS descripcion TEXT;
ALTER TABLE apunte ALTER COLUMN archivo_url TYPE VARCHAR(500);
CREATE INDEX IF NOT EXISTS idx_apunte_materia ON apunte(id_materia);