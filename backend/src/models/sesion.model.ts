import { pool } from '../config/database';

export interface Sesion {
  id_sesion: string;
  id_grupo: string;
  id_creador: string;
  tema: string;
  descripcion: string | null;
  fecha_inicio: Date;
  fecha_fin: Date;
  modalidad: 'Presencial' | 'Virtual';
}

export interface NuevaSesionInput {
  id_grupo: string;
  id_creador: string;
  tema: string;
  descripcion?: string;
  fecha_inicio: string;
  fecha_fin: string;
  modalidad: 'Presencial' | 'Virtual';
}

export async function crearSesion(datos: NuevaSesionInput): Promise<Sesion> {
  const { id_grupo, id_creador, tema, descripcion, fecha_inicio, fecha_fin, modalidad } = datos;

  const query = `
    INSERT INTO sesion_estudio (id_grupo, id_creador, tema, descripcion, fecha_inicio, fecha_fin, modalidad)
    VALUES ($1, $2, $3, $4, $5, $6, $7)
    RETURNING *;
  `;

  const result = await pool.query(query, [
    id_grupo, id_creador, tema, descripcion || null, fecha_inicio, fecha_fin, modalidad,
  ]);
  return result.rows[0];
}

export async function listarSesionesPorGrupo(id_grupo: string): Promise<Sesion[]> {
  const query = `
    SELECT * FROM sesion_estudio
    WHERE id_grupo = $1
    ORDER BY fecha_inicio ASC;
  `;
  const result = await pool.query(query, [id_grupo]);
  return result.rows;
}