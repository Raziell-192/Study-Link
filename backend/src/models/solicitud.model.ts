import { pool } from '../config/database';

export interface Solicitud {
  id_solicitud: string;
  id_usuario: string;
  id_materia: string;
  id_tutor: string | null;
  titulo: string;
  descripcion: string | null;
  modalidad: 'Individual' | 'Grupal';
  fecha_creacion: Date;
  estado: 'Abierta' | 'En proceso' | 'Cerrada';
}

export interface NuevaSolicitudInput {
  id_usuario: string;
  id_materia: string;
  titulo: string;
  descripcion?: string;
  modalidad: 'Individual' | 'Grupal';
}

export async function crearSolicitud(datos: NuevaSolicitudInput): Promise<Solicitud> {
  const { id_usuario, id_materia, titulo, descripcion, modalidad } = datos;

  const query = `
    INSERT INTO solicitud_estudio (id_usuario, id_materia, titulo, descripcion, modalidad)
    VALUES ($1, $2, $3, $4, $5)
    RETURNING *;
  `;

  const result = await pool.query(query, [id_usuario, id_materia, titulo, descripcion || null, modalidad]);
  return result.rows[0];
}

export async function listarSolicitudesPorMateria(id_materia: string): Promise<Solicitud[]> {
  const query = `
    SELECT * FROM solicitud_estudio
    WHERE id_materia = $1 AND estado = 'Abierta'
    ORDER BY fecha_creacion DESC;
  `;
  const result = await pool.query(query, [id_materia]);
  return result.rows;
}

export async function buscarSolicitudPorId(id_solicitud: string): Promise<Solicitud | null> {
  const query = `SELECT * FROM solicitud_estudio WHERE id_solicitud = $1;`;
  const result = await pool.query(query, [id_solicitud]);
  return result.rows[0] || null;
}

export async function aceptarSolicitud(
  id_solicitud: string,
  id_tutor: string
): Promise<Solicitud | null> {
  const query = `
    UPDATE solicitud_estudio
    SET id_tutor = $2, estado = 'En proceso'
    WHERE id_solicitud = $1 AND estado = 'Abierta'
    RETURNING *;
  `;
  const result = await pool.query(query, [id_solicitud, id_tutor]);
  return result.rows[0] || null;
}