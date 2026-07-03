import { pool } from '../config/database';

export interface Recordatorio {
  id_recordatorio: string;
  id_usuario: string;
  id_evento: string | null;
  tipo: 'Sesion' | 'Examen' | 'Tarea' | 'Material' | 'Objetivo' | 'Evento';
  mensaje: string;
  fecha_disparo: Date;
  enviado: boolean;
  fecha_creacion: Date;
}

export interface NuevoRecordatorioInput {
  id_usuario: string;
  id_evento?: string;
  tipo: Recordatorio['tipo'];
  mensaje: string;
  fecha_disparo: string;
}

export async function crearRecordatorio(datos: NuevoRecordatorioInput): Promise<Recordatorio> {
  const { id_usuario, id_evento, tipo, mensaje, fecha_disparo } = datos;

  const query = `
    INSERT INTO recordatorio (id_usuario, id_evento, tipo, mensaje, fecha_disparo)
    VALUES ($1, $2, $3, $4, $5)
    RETURNING *;
  `;

  const result = await pool.query(query, [
    id_usuario,
    id_evento || null,
    tipo,
    mensaje,
    fecha_disparo,
  ]);
  return result.rows[0];
}

export async function buscarRecordatorioPorId(id_recordatorio: string): Promise<Recordatorio | null> {
  const query = `SELECT * FROM recordatorio WHERE id_recordatorio = $1;`;
  const result = await pool.query(query, [id_recordatorio]);
  return result.rows[0] || null;
}

// HU-20: recordatorios propios cuya fecha_disparo ya llegó y aún no se marcaron como enviados.
// Este es el endpoint que el cliente Flutter consulta periódicamente (polling).
export async function listarRecordatoriosPendientes(id_usuario: string): Promise<Recordatorio[]> {
  const query = `
    SELECT * FROM recordatorio
    WHERE id_usuario = $1 AND enviado = FALSE AND fecha_disparo <= NOW()
    ORDER BY fecha_disparo ASC;
  `;
  const result = await pool.query(query, [id_usuario]);
  return result.rows;
}

export async function listarRecordatoriosPorUsuario(id_usuario: string): Promise<Recordatorio[]> {
  const query = `
    SELECT * FROM recordatorio
    WHERE id_usuario = $1
    ORDER BY fecha_disparo ASC;
  `;
  const result = await pool.query(query, [id_usuario]);
  return result.rows;
}

export async function marcarComoEnviado(
  id_recordatorio: string,
  id_usuario: string
): Promise<Recordatorio | null> {
  const query = `
    UPDATE recordatorio
    SET enviado = TRUE
    WHERE id_recordatorio = $1 AND id_usuario = $2
    RETURNING *;
  `;
  const result = await pool.query(query, [id_recordatorio, id_usuario]);
  return result.rows[0] || null;
}
