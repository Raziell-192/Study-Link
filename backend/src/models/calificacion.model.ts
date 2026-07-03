import { pool } from '../config/database';

export interface Calificacion {
  id_calificacion: string;
  id_sesion: string;
  id_tutor: string;
  id_tutorado: string;
  puntuacion: number;
  comentario: string | null;
  fecha: Date;
}

export interface NuevaCalificacionInput {
  id_sesion: string;
  id_tutor: string;
  id_tutorado: string;
  puntuacion: number;
  comentario?: string;
}

export async function crearCalificacion(datos: NuevaCalificacionInput): Promise<Calificacion> {
  const { id_sesion, id_tutor, id_tutorado, puntuacion, comentario } = datos;

  const query = `
    INSERT INTO calificacion (id_sesion, id_tutor, id_tutorado, puntuacion, comentario)
    VALUES ($1, $2, $3, $4, $5)
    RETURNING *;
  `;

  const result = await pool.query(query, [
    id_sesion,
    id_tutor,
    id_tutorado,
    puntuacion,
    comentario || null,
  ]);
  return result.rows[0];
}

// HU-27: listado de calificaciones recibidas por un tutor, con datos del tutorado y la sesión.
export interface CalificacionConDatos extends Calificacion {
  nombre_tutorado: string;
  tema_sesion: string;
}

export async function listarCalificacionesPorTutor(id_tutor: string): Promise<CalificacionConDatos[]> {
  const query = `
    SELECT c.*, u.nombre_completo AS nombre_tutorado, s.tema AS tema_sesion
    FROM calificacion c
    JOIN usuario u ON u.id_usuario = c.id_tutorado
    JOIN sesion_estudio s ON s.id_sesion = c.id_sesion
    WHERE c.id_tutor = $1
    ORDER BY c.fecha DESC;
  `;
  const result = await pool.query(query, [id_tutor]);
  return result.rows;
}
