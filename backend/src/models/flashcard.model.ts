import { pool } from '../config/database';

export interface Flashcard {
  id_flashcard: string;
  id_usuario: string;
  titulo: string;
  compartida: boolean;
  fecha_creacion: Date;
}

export interface Tarjeta {
  id_tarjeta: string;
  id_flashcard: string;
  pregunta: string;
  respuesta: string;
}

export interface NuevaTarjetaInput {
  pregunta: string;
  respuesta: string;
}

export interface NuevaFlashcardInput {
  id_usuario: string;
  titulo: string;
  compartida?: boolean;
  tarjetas: NuevaTarjetaInput[];
}

// HU-14: crea el set de flashcards y sus tarjetas en una sola transacción.
export async function crearFlashcard(datos: NuevaFlashcardInput): Promise<Flashcard & { tarjetas: Tarjeta[] }> {
  const { id_usuario, titulo, compartida, tarjetas } = datos;

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    const flashcardResult = await client.query(
      `INSERT INTO flashcard (id_usuario, titulo, compartida)
       VALUES ($1, $2, $3)
       RETURNING *;`,
      [id_usuario, titulo, Boolean(compartida)]
    );
    const nuevaFlashcard = flashcardResult.rows[0];

    const tarjetasCreadas: Tarjeta[] = [];
    for (const t of tarjetas) {
      const tarjetaResult = await client.query(
        `INSERT INTO tarjeta (id_flashcard, pregunta, respuesta)
         VALUES ($1, $2, $3)
         RETURNING *;`,
        [nuevaFlashcard.id_flashcard, t.pregunta, t.respuesta]
      );
      tarjetasCreadas.push(tarjetaResult.rows[0]);
    }

    await client.query('COMMIT');
    return { ...nuevaFlashcard, tarjetas: tarjetasCreadas };
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

export async function agregarTarjeta(id_flashcard: string, datos: NuevaTarjetaInput): Promise<Tarjeta> {
  const query = `
    INSERT INTO tarjeta (id_flashcard, pregunta, respuesta)
    VALUES ($1, $2, $3)
    RETURNING *;
  `;
  const result = await pool.query(query, [id_flashcard, datos.pregunta, datos.respuesta]);
  return result.rows[0];
}

export async function buscarFlashcardPorId(id_flashcard: string): Promise<Flashcard | null> {
  const query = `SELECT * FROM flashcard WHERE id_flashcard = $1;`;
  const result = await pool.query(query, [id_flashcard]);
  return result.rows[0] || null;
}

export async function listarTarjetasPorFlashcard(id_flashcard: string): Promise<Tarjeta[]> {
  const query = `SELECT * FROM tarjeta WHERE id_flashcard = $1 ORDER BY id_tarjeta;`;
  const result = await pool.query(query, [id_flashcard]);
  return result.rows;
}

// Mis flashcards (propias, incluye privadas).
export async function listarFlashcardsPorUsuario(id_usuario: string): Promise<Flashcard[]> {
  const query = `
    SELECT * FROM flashcard
    WHERE id_usuario = $1
    ORDER BY fecha_creacion DESC;
  `;
  const result = await pool.query(query, [id_usuario]);
  return result.rows;
}

// HU-15: explorar flashcards compartidas por otros usuarios.
export async function listarFlashcardsCompartidas(): Promise<Flashcard[]> {
  const query = `
    SELECT f.*, u.nombre_completo AS nombre_autor
    FROM flashcard f
    JOIN usuario u ON u.id_usuario = f.id_usuario
    WHERE f.compartida = TRUE
    ORDER BY f.fecha_creacion DESC;
  `;
  const result = await pool.query(query);
  return result.rows;
}

export async function actualizarCompartida(
  id_flashcard: string,
  id_usuario: string,
  compartida: boolean
): Promise<Flashcard | null> {
  const query = `
    UPDATE flashcard SET compartida = $3
    WHERE id_flashcard = $1 AND id_usuario = $2
    RETURNING *;
  `;
  const result = await pool.query(query, [id_flashcard, id_usuario, compartida]);
  return result.rows[0] || null;
}

export async function eliminarFlashcard(id_flashcard: string, id_usuario: string): Promise<Flashcard | null> {
  const query = `
    DELETE FROM flashcard
    WHERE id_flashcard = $1 AND id_usuario = $2
    RETURNING *;
  `;
  const result = await pool.query(query, [id_flashcard, id_usuario]);
  return result.rows[0] || null;
}
