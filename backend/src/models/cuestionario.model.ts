import { pool } from '../config/database';

export interface Cuestionario {
  id_cuestionario: string;
  id_usuario: string;
  titulo: string;
  compartido: boolean;
  fecha_creacion: Date;
}

export type TipoPregunta = 'OpcionMultiple' | 'VerdaderoFalso' | 'RelacionConceptos' | 'RespuestaCorta';

export interface Pregunta {
  id_pregunta: string;
  id_cuestionario: string;
  pregunta: string;
  tipo: TipoPregunta;
  opciones: unknown | null;
  respuesta_correcta: string;
}

export interface NuevaPreguntaInput {
  pregunta: string;
  tipo: TipoPregunta;
  opciones?: unknown;
  respuesta_correcta: string;
}

export interface NuevoCuestionarioInput {
  id_usuario: string;
  titulo: string;
  compartido?: boolean;
  preguntas: NuevaPreguntaInput[];
}

// HU-16: crea el cuestionario y sus preguntas en una sola transacción.
export async function crearCuestionario(
  datos: NuevoCuestionarioInput
): Promise<Cuestionario & { preguntas: Pregunta[] }> {
  const { id_usuario, titulo, compartido, preguntas } = datos;

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    const cuestionarioResult = await client.query(
      `INSERT INTO cuestionario (id_usuario, titulo, compartido)
       VALUES ($1, $2, $3)
       RETURNING *;`,
      [id_usuario, titulo, Boolean(compartido)]
    );
    const nuevoCuestionario = cuestionarioResult.rows[0];

    const preguntasCreadas: Pregunta[] = [];
    for (const p of preguntas) {
      const preguntaResult = await client.query(
        `INSERT INTO pregunta (id_cuestionario, pregunta, tipo, opciones, respuesta_correcta)
         VALUES ($1, $2, $3, $4, $5)
         RETURNING *;`,
        [
          nuevoCuestionario.id_cuestionario,
          p.pregunta,
          p.tipo,
          p.opciones ? JSON.stringify(p.opciones) : null,
          p.respuesta_correcta,
        ]
      );
      preguntasCreadas.push(preguntaResult.rows[0]);
    }

    await client.query('COMMIT');
    return { ...nuevoCuestionario, preguntas: preguntasCreadas };
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

export async function buscarCuestionarioPorId(id_cuestionario: string): Promise<Cuestionario | null> {
  const query = `SELECT * FROM cuestionario WHERE id_cuestionario = $1;`;
  const result = await pool.query(query, [id_cuestionario]);
  return result.rows[0] || null;
}

export async function listarPreguntasPorCuestionario(id_cuestionario: string): Promise<Pregunta[]> {
  const query = `SELECT * FROM pregunta WHERE id_cuestionario = $1 ORDER BY id_pregunta;`;
  const result = await pool.query(query, [id_cuestionario]);
  return result.rows;
}

export async function listarCuestionariosPorUsuario(id_usuario: string): Promise<Cuestionario[]> {
  const query = `
    SELECT * FROM cuestionario
    WHERE id_usuario = $1
    ORDER BY fecha_creacion DESC;
  `;
  const result = await pool.query(query, [id_usuario]);
  return result.rows;
}

// HU-16/17: cuestionarios compartidos disponibles para resolver.
export async function listarCuestionariosCompartidos(): Promise<Cuestionario[]> {
  const query = `
    SELECT c.*, u.nombre_completo AS nombre_autor
    FROM cuestionario c
    JOIN usuario u ON u.id_usuario = c.id_usuario
    WHERE c.compartido = TRUE
    ORDER BY c.fecha_creacion DESC;
  `;
  const result = await pool.query(query);
  return result.rows;
}

export async function eliminarCuestionario(
  id_cuestionario: string,
  id_usuario: string
): Promise<Cuestionario | null> {
  const query = `
    DELETE FROM cuestionario
    WHERE id_cuestionario = $1 AND id_usuario = $2
    RETURNING *;
  `;
  const result = await pool.query(query, [id_cuestionario, id_usuario]);
  return result.rows[0] || null;
}
