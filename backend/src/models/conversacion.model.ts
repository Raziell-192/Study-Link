import { pool } from '../config/database';

export interface Conversacion {
  id_conversacion: string;
  tipo: 'Privada' | 'Grupal';
  id_grupo: string | null;
  id_usuario_1: string | null;
  id_usuario_2: string | null;
  fecha_creacion: Date;
}

// Normaliza el par de usuarios en orden consistente para respetar el UNIQUE
// y evitar crear 2 conversaciones distintas para el mismo par (A,B) y (B,A).
function ordenarPar(idA: string, idB: string): [string, string] {
  return idA < idB ? [idA, idB] : [idB, idA];
}

export async function obtenerOCrearConversacionPrivada(
  idUsuarioActual: string,
  idOtroUsuario: string
): Promise<Conversacion> {
  const [id_usuario_1, id_usuario_2] = ordenarPar(idUsuarioActual, idOtroUsuario);

  const existente = await pool.query(
    `SELECT * FROM conversacion WHERE id_usuario_1 = $1 AND id_usuario_2 = $2;`,
    [id_usuario_1, id_usuario_2]
  );
  if (existente.rows[0]) return existente.rows[0];

  const creada = await pool.query(
    `INSERT INTO conversacion (tipo, id_usuario_1, id_usuario_2)
     VALUES ('Privada', $1, $2)
     RETURNING *;`,
    [id_usuario_1, id_usuario_2]
  );
  return creada.rows[0];
}

export async function obtenerOCrearConversacionGrupal(id_grupo: string): Promise<Conversacion> {
  const existente = await pool.query(
    `SELECT * FROM conversacion WHERE id_grupo = $1;`,
    [id_grupo]
  );
  if (existente.rows[0]) return existente.rows[0];

  const creada = await pool.query(
    `INSERT INTO conversacion (tipo, id_grupo) VALUES ('Grupal', $1) RETURNING *;`,
    [id_grupo]
  );
  return creada.rows[0];
}

export async function buscarConversacionPorId(id_conversacion: string): Promise<Conversacion | null> {
  const result = await pool.query(`SELECT * FROM conversacion WHERE id_conversacion = $1;`, [id_conversacion]);
  return result.rows[0] || null;
}