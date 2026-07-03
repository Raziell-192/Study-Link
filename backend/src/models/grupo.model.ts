import { pool } from '../config/database';

export interface Grupo {
  id_grupo: string;
  nombre: string;
  descripcion: string | null;
  fecha_creacion: Date;
  id_creador: string;
  id_materia: string | null;
}

export interface NuevoGrupoInput {
  nombre: string;
  descripcion?: string;
  id_creador: string;
  id_materia: string;
}

export async function crearGrupo(datos: NuevoGrupoInput): Promise<Grupo> {
  const { nombre, descripcion, id_creador, id_materia } = datos;

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    const grupoResult = await client.query(
      `INSERT INTO grupo (nombre, descripcion, id_creador, id_materia)
       VALUES ($1, $2, $3, $4)
       RETURNING *;`,
      [nombre, descripcion || null, id_creador, id_materia]
    );
    const nuevoGrupo = grupoResult.rows[0];

    await client.query(
      `INSERT INTO miembro_grupo (id_usuario, id_grupo, rol)
       VALUES ($1, $2, 'Organizador');`,
      [id_creador, nuevoGrupo.id_grupo]
    );

    await client.query('COMMIT');
    return nuevoGrupo;
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}