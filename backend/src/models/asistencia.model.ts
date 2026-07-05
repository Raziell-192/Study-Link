import { pool } from '../config/database';

export interface Asistencia {
  id_asistencia: string;
  id_sesion: string;
  id_usuario: string;
  hora_ingreso: Date;
  hora_salida: Date | null;
}

export async function registrarAsistencia(
  id_sesion: string,
  id_usuario: string,
  hora_ingreso: string,
  hora_salida?: string
): Promise<Asistencia> {
  const query = `
    INSERT INTO asistencia (id_sesion, id_usuario, hora_ingreso, hora_salida)
    VALUES ($1, $2, $3, $4)
    ON CONFLICT (id_sesion, id_usuario)
    DO UPDATE SET hora_ingreso = EXCLUDED.hora_ingreso, hora_salida = EXCLUDED.hora_salida
    RETURNING *;
  `;
  const result = await pool.query(query, [id_sesion, id_usuario, hora_ingreso, hora_salida || null]);
  return result.rows[0];
}

export interface AsistenciaConDetalle extends Asistencia {
  tema_sesion: string;
  fecha_inicio_sesion: Date;
}

export async function listarHistorialUsuario(id_usuario: string): Promise<AsistenciaConDetalle[]> {
  const query = `
    SELECT a.*, s.tema AS tema_sesion, s.fecha_inicio AS fecha_inicio_sesion
    FROM asistencia a
    JOIN sesion_estudio s ON s.id_sesion = a.id_sesion
    WHERE a.id_usuario = $1
    ORDER BY s.fecha_inicio DESC;
  `;
  const result = await pool.query(query, [id_usuario]);
  return result.rows;
}

export async function listarAsistenciaPorSesion(id_sesion: string): Promise<Asistencia[]> {
  const query = `SELECT * FROM asistencia WHERE id_sesion = $1;`;
  const result = await pool.query(query, [id_sesion]);
  return result.rows;
}