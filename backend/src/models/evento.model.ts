import { pool } from '../config/database';

export interface Evento {
  id_evento: string;
  id_usuario: string;
  id_grupo: string | null;
  titulo: string;
  descripcion: string | null;
  fecha_inicio: Date;
  fecha_fin: Date;
  compartido: boolean;
}

export interface NuevoEventoInput {
  id_usuario: string;
  id_grupo?: string;
  titulo: string;
  descripcion?: string;
  fecha_inicio: string;
  fecha_fin: string;
  compartido: boolean;
}

export async function crearEvento(datos: NuevoEventoInput): Promise<Evento> {
  const { id_usuario, id_grupo, titulo, descripcion, fecha_inicio, fecha_fin, compartido } = datos;

  const query = `
    INSERT INTO evento_calendario (id_usuario, id_grupo, titulo, descripcion, fecha_inicio, fecha_fin, compartido)
    VALUES ($1, $2, $3, $4, $5, $6, $7)
    RETURNING *;
  `;

  const result = await pool.query(query, [
    id_usuario,
    id_grupo || null,
    titulo,
    descripcion || null,
    fecha_inicio,
    fecha_fin,
    compartido,
  ]);
  return result.rows[0];
}

export async function buscarEventoPorId(id_evento: string): Promise<Evento | null> {
  const query = `SELECT * FROM evento_calendario WHERE id_evento = $1;`;
  const result = await pool.query(query, [id_evento]);
  return result.rows[0] || null;
}

// HU-18: calendario personal (eventos propios, compartidos o no).
export async function listarEventosPorUsuario(id_usuario: string): Promise<Evento[]> {
  const query = `
    SELECT * FROM evento_calendario
    WHERE id_usuario = $1
    ORDER BY fecha_inicio ASC;
  `;
  const result = await pool.query(query, [id_usuario]);
  return result.rows;
}

// HU-19: calendario compartido de un grupo (solo eventos marcados como compartidos).
export async function listarEventosCompartidosPorGrupo(id_grupo: string): Promise<Evento[]> {
  const query = `
    SELECT * FROM evento_calendario
    WHERE id_grupo = $1 AND compartido = TRUE
    ORDER BY fecha_inicio ASC;
  `;
  const result = await pool.query(query, [id_grupo]);
  return result.rows;
}

export async function eliminarEvento(id_evento: string, id_usuario: string): Promise<Evento | null> {
  // Solo quien creó el evento puede borrarlo.
  const query = `
    DELETE FROM evento_calendario
    WHERE id_evento = $1 AND id_usuario = $2
    RETURNING *;
  `;
  const result = await pool.query(query, [id_evento, id_usuario]);
  return result.rows[0] || null;
}
