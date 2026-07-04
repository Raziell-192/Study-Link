import { pool } from '../config/database';

export interface Mensaje {
  id_mensaje: string;
  id_conversacion: string;
  id_usuario: string;
  contenido: string;
  fecha_envio: Date;
}

export interface MensajeConAutor extends Mensaje {
  nombre_autor: string;
}

export async function enviarMensaje(
  id_conversacion: string,
  id_usuario: string,
  contenido: string
): Promise<Mensaje> {
  const result = await pool.query(
    `INSERT INTO mensaje (id_conversacion, id_usuario, contenido)
     VALUES ($1, $2, $3)
     RETURNING *;`,
    [id_conversacion, id_usuario, contenido]
  );
  return result.rows[0];
}

// Trae todos los mensajes, o solo los posteriores a `desde` (para polling incremental).
export async function listarMensajes(
  id_conversacion: string,
  desde?: string
): Promise<MensajeConAutor[]> {
  const condiciones = ['m.id_conversacion = $1'];
  const valores: any[] = [id_conversacion];

  if (desde) {
    valores.push(desde);
    condiciones.push(`m.fecha_envio > $${valores.length}`);
  }

  const query = `
    SELECT m.*, u.nombre_completo AS nombre_autor
    FROM mensaje m
    JOIN usuario u ON u.id_usuario = m.id_usuario
    WHERE ${condiciones.join(' AND ')}
    ORDER BY m.fecha_envio ASC;
  `;
  const result = await pool.query(query, valores);
  return result.rows;
}