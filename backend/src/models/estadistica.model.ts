import { pool } from '../config/database';

export interface Estadisticas {
  horas_estudio: number;
  sesiones_completadas: number;
  tutorias_impartidas: number;
  tutorias_recibidas: number;
}

export async function obtenerEstadisticas(id_usuario: string): Promise<Estadisticas> {
  // Horas de estudio + sesiones completadas: solo sesiones de grupos donde el usuario
  // es miembro, y que ya terminaron (fecha_fin en el pasado).
  const sesionesQuery = await pool.query(
    `
    SELECT
      COALESCE(SUM(EXTRACT(EPOCH FROM (s.fecha_fin - s.fecha_inicio)) / 3600), 0) AS horas,
      COUNT(*) AS completadas
    FROM sesion_estudio s
    JOIN miembro_grupo mg ON mg.id_grupo = s.id_grupo
    WHERE mg.id_usuario = $1 AND s.fecha_fin < NOW();
    `,
    [id_usuario]
  );

  // Tutorías impartidas: solicitudes donde este usuario quedó como tutor asignado.
  const impartidasQuery = await pool.query(
    `SELECT COUNT(*) AS total FROM solicitud_estudio WHERE id_tutor = $1;`,
    [id_usuario]
  );

  // Tutorías recibidas: solicitudes propias que ya fueron aceptadas por algún tutor.
  const recibidasQuery = await pool.query(
    `SELECT COUNT(*) AS total FROM solicitud_estudio WHERE id_usuario = $1 AND estado != 'Abierta';`,
    [id_usuario]
  );

  return {
    horas_estudio: Math.round(Number(sesionesQuery.rows[0].horas) * 10) / 10,
    sesiones_completadas: Number(sesionesQuery.rows[0].completadas),
    tutorias_impartidas: Number(impartidasQuery.rows[0].total),
    tutorias_recibidas: Number(recibidasQuery.rows[0].total),
  };
}