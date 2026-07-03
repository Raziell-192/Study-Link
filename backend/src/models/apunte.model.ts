import { pool } from '../config/database';

export interface Apunte {
  id_apunte: string;
  id_usuario: string;
  id_materia: string;
  titulo: string;
  archivo_url: string;
  tipo: 'PDF' | 'Imagen' | 'Enlace' | 'Presentacion';
  fecha_subida: Date;
}

export interface NuevoApunteInput {
  id_usuario: string;
  id_materia: string;
  titulo: string;
  archivo_url: string;
  tipo: 'PDF' | 'Imagen' | 'Enlace' | 'Presentacion';
}

export async function crearApunte(datos: NuevoApunteInput): Promise<Apunte> {
  const { id_usuario, id_materia, titulo, archivo_url, tipo } = datos;

  const query = `
    INSERT INTO apunte (id_usuario, id_materia, titulo, archivo_url, tipo)
    VALUES ($1, $2, $3, $4, $5)
    RETURNING *;
  `;
  const result = await pool.query(query, [id_usuario, id_materia, titulo, archivo_url, tipo]);
  return result.rows[0];
}

export interface ApunteConAutor extends Apunte {
  nombre_autor: string;
}

export async function listarApuntesPorMateria(id_materia: string): Promise<ApunteConAutor[]> {
  const query = `
    SELECT a.*, u.nombre_completo AS nombre_autor
    FROM apunte a
    JOIN usuario u ON u.id_usuario = a.id_usuario
    WHERE a.id_materia = $1
    ORDER BY a.fecha_subida DESC;
  `;
  const result = await pool.query(query, [id_materia]);
  return result.rows;
}

export async function buscarApuntePorId(id_apunte: string): Promise<Apunte | null> {
  const query = `SELECT * FROM apunte WHERE id_apunte = $1;`;
  const result = await pool.query(query, [id_apunte]);
  return result.rows[0] || null;
}