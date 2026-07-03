import { pool } from '../config/database';

export interface Apunte {
  id_apunte: string;
  id_usuario: string;
  id_materia: string;
  titulo: string;
  descripcion: string | null;
  tipo_archivo: 'PDF' | 'Imagen' | 'Enlace' | 'Presentacion';
  archivo_url: string;
  fecha_subida: Date;
}

export interface NuevoApunteInput {
  id_usuario: string;
  id_materia: string;
  titulo: string;
  descripcion?: string;
  tipo_archivo: 'PDF' | 'Imagen' | 'Enlace' | 'Presentacion';
  archivo_url: string;
}

export async function crearApunte(datos: NuevoApunteInput): Promise<Apunte> {
  const { id_usuario, id_materia, titulo, descripcion, tipo_archivo, archivo_url } = datos;

  const query = `
    INSERT INTO apunte (id_usuario, id_materia, titulo, descripcion, tipo_archivo, archivo_url)
    VALUES ($1, $2, $3, $4, $5, $6)
    RETURNING *;
  `;

  const result = await pool.query(query, [
    id_usuario,
    id_materia,
    titulo,
    descripcion || null,
    tipo_archivo,
    archivo_url,
  ]);
  return result.rows[0];
}

export async function buscarApuntePorId(id_apunte: string): Promise<Apunte | null> {
  const query = `SELECT * FROM apunte WHERE id_apunte = $1;`;
  const result = await pool.query(query, [id_apunte]);
  return result.rows[0] || null;
}

export async function listarApuntesPorMateria(id_materia: string): Promise<Apunte[]> {
  const query = `
    SELECT * FROM apunte
    WHERE id_materia = $1
    ORDER BY fecha_subida DESC;
  `;
  const result = await pool.query(query, [id_materia]);
  return result.rows;
}

// HU-12: búsqueda por texto en el título, opcionalmente acotada a una materia.
export async function buscarApuntesPorTitulo(
  texto: string,
  id_materia?: string
): Promise<Apunte[]> {
  const condiciones = ['titulo ILIKE $1'];
  const valores: any[] = [`%${texto}%`];

  if (id_materia) {
    valores.push(id_materia);
    condiciones.push(`id_materia = $${valores.length}`);
  }

  const query = `
    SELECT * FROM apunte
    WHERE ${condiciones.join(' AND ')}
    ORDER BY fecha_subida DESC;
  `;
  const result = await pool.query(query, valores);
  return result.rows;
}

export async function eliminarApunte(id_apunte: string, id_usuario: string): Promise<Apunte | null> {
  // Solo quien lo subió puede borrarlo.
  const query = `
    DELETE FROM apunte
    WHERE id_apunte = $1 AND id_usuario = $2
    RETURNING *;
  `;
  const result = await pool.query(query, [id_apunte, id_usuario]);
  return result.rows[0] || null;
}
