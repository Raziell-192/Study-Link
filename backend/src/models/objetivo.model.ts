import { pool } from '../config/database';

export interface Objetivo {
  id_objetivo: string;
  id_usuario: string;
  titulo: string;
  descripcion: string | null;
  progreso: number;
  fecha_limite: string | null;
  fecha_creacion: Date;
}

// Deriva el estado cualitativo a partir del progreso numérico (ver decisión en migración 017).
export function derivarEstado(progreso: number): string {
  if (progreso === 0) return 'No iniciado';
  if (progreso < 100) return 'En progreso';
  return 'Completado';
}

export interface NuevoObjetivoInput {
  id_usuario: string;
  titulo: string;
  descripcion?: string;
  fecha_limite?: string;
}

export async function crearObjetivo(datos: NuevoObjetivoInput): Promise<Objetivo> {
  const { id_usuario, titulo, descripcion, fecha_limite } = datos;
  const query = `
    INSERT INTO objetivo (id_usuario, titulo, descripcion, fecha_limite)
    VALUES ($1, $2, $3, $4)
    RETURNING *;
  `;
  const result = await pool.query(query, [id_usuario, titulo, descripcion || null, fecha_limite || null]);
  return result.rows[0];
}

export async function listarObjetivosPorUsuario(id_usuario: string): Promise<Objetivo[]> {
  const query = `
    SELECT * FROM objetivo WHERE id_usuario = $1 ORDER BY fecha_creacion DESC;
  `;
  const result = await pool.query(query, [id_usuario]);
  return result.rows;
}

export async function buscarObjetivoPorId(id_objetivo: string): Promise<Objetivo | null> {
  const result = await pool.query(`SELECT * FROM objetivo WHERE id_objetivo = $1;`, [id_objetivo]);
  return result.rows[0] || null;
}

export async function actualizarProgreso(id_objetivo: string, progreso: number): Promise<Objetivo | null> {
  const query = `
    UPDATE objetivo SET progreso = $2 WHERE id_objetivo = $1 RETURNING *;
  `;
  const result = await pool.query(query, [id_objetivo, progreso]);
  return result.rows[0] || null;
}