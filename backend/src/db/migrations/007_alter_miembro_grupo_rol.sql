ALTER TABLE miembro_grupo
DROP CONSTRAINT miembro_grupo_rol_check;

ALTER TABLE miembro_grupo
ADD CONSTRAINT miembro_grupo_rol_check
CHECK (rol IN ('Organizador', 'Tutor', 'Tutorado'));