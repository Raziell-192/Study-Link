import { pool } from '../config/database';

export interface Materia {
  id_materia: string;
  nombre: string;
  descripcion: string | null;
}

export async function listarMaterias(): Promise<Materia[]> {
  const query = `SELECT * FROM materia ORDER BY nombre ASC;`;
  const result = await pool.query(query);
  return result.rows;
}

export async function buscarMateriaPorId(id_materia: string): Promise<Materia | null> {
  const query = `SELECT * FROM materia WHERE id_materia = $1;`;
  const result = await pool.query(query, [id_materia]);
  return result.rows[0] || null;
}
