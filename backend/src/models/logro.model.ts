import { pool } from '../config/database';

export interface Logro {
  id_logro: string;
  codigo: string;
  nombre: string;
  descripcion: string | null;
  icono: string | null;
}

export interface LogroConEstado extends Logro {
  obtenido: boolean;
  fecha_obtenido: Date | null;
}

// Umbrales por código de logro (ver decisión en migración 019).
// Cada entrada indica cuántas veces debe ocurrir la actividad para otorgar el logro.
const UMBRALES: Record<string, number> = {
  objetivo_1: 1,
  objetivo_5: 5,
  asistencia_5: 5,
  tutor_3: 3,
  apuntes_3: 3,
  sesiones_5: 5,
};

export interface ContadoresActividad {
  objetivos_completados: number;
  asistencias_registradas: number;
  tutorias_impartidas: number;
  apuntes_subidos: number;
  sesiones_completadas: number;
}

export async function listarCatalogo(): Promise<Logro[]> {
  const result = await pool.query(`SELECT * FROM logro ORDER BY nombre;`);
  return result.rows;
}

export async function listarLogrosConEstado(id_usuario: string): Promise<LogroConEstado[]> {
  const query = `
    SELECT l.*, ul.fecha_obtenido
    FROM logro l
    LEFT JOIN usuario_logro ul ON ul.id_logro = l.id_logro AND ul.id_usuario = $1
    ORDER BY l.nombre;
  `;
  const result = await pool.query(query, [id_usuario]);
  return result.rows.map((fila) => ({
    ...fila,
    obtenido: fila.fecha_obtenido !== null,
  }));
}

// Cuenta las actividades relevantes del usuario. Reutiliza el mismo criterio de
// "sesión completada" (fecha_fin < NOW()) que estadistica.model.ts (HU-25).
export async function contarActividad(id_usuario: string): Promise<ContadoresActividad> {
  const objetivosQuery = await pool.query(
    `SELECT COUNT(*) AS total FROM objetivo WHERE id_usuario = $1 AND progreso = 100;`,
    [id_usuario]
  );

  const asistenciaQuery = await pool.query(
    `SELECT COUNT(*) AS total FROM asistencia WHERE id_usuario = $1;`,
    [id_usuario]
  );

  const tutoriasQuery = await pool.query(
    `SELECT COUNT(*) AS total FROM solicitud_estudio WHERE id_tutor = $1;`,
    [id_usuario]
  );

  const apuntesQuery = await pool.query(
    `SELECT COUNT(*) AS total FROM apunte WHERE id_usuario = $1;`,
    [id_usuario]
  );

  const sesionesQuery = await pool.query(
    `
    SELECT COUNT(*) AS total
    FROM sesion_estudio s
    JOIN miembro_grupo mg ON mg.id_grupo = s.id_grupo
    WHERE mg.id_usuario = $1 AND s.fecha_fin < NOW();
    `,
    [id_usuario]
  );

  return {
    objetivos_completados: Number(objetivosQuery.rows[0].total),
    asistencias_registradas: Number(asistenciaQuery.rows[0].total),
    tutorias_impartidas: Number(tutoriasQuery.rows[0].total),
    apuntes_subidos: Number(apuntesQuery.rows[0].total),
    sesiones_completadas: Number(sesionesQuery.rows[0].total),
  };
}

function actividadPorCodigo(codigo: string, contadores: ContadoresActividad): number {
  switch (codigo) {
    case 'objetivo_1':
    case 'objetivo_5':
      return contadores.objetivos_completados;
    case 'asistencia_5':
      return contadores.asistencias_registradas;
    case 'tutor_3':
      return contadores.tutorias_impartidas;
    case 'apuntes_3':
      return contadores.apuntes_subidos;
    case 'sesiones_5':
      return contadores.sesiones_completadas;
    default:
      return 0;
  }
}

export async function otorgarLogro(id_usuario: string, id_logro: string): Promise<void> {
  await pool.query(
    `
    INSERT INTO usuario_logro (id_usuario, id_logro)
    VALUES ($1, $2)
    ON CONFLICT (id_usuario, id_logro) DO NOTHING;
    `,
    [id_usuario, id_logro]
  );
}

// HU-30: revisa los contadores de actividad del usuario contra los umbrales y
// otorga cualquier logro pendiente que ya se haya alcanzado. No hay job en segundo
// plano (mismo criterio que Recordatorios/Chat: sin infraestructura de tiempo real),
// así que esto se ejecuta de forma perezosa cada vez que se consulta HU-31.
export async function verificarYOtorgarLogros(id_usuario: string): Promise<Logro[]> {
  const catalogo = await listarCatalogo();
  const contadores = await contarActividad(id_usuario);

  const yaObtenidos = await pool.query(
    `SELECT id_logro FROM usuario_logro WHERE id_usuario = $1;`,
    [id_usuario]
  );
  const idsObtenidos = new Set(yaObtenidos.rows.map((f) => f.id_logro));

  const nuevos: Logro[] = [];

  for (const logro of catalogo) {
    if (idsObtenidos.has(logro.id_logro)) continue;

    const umbral = UMBRALES[logro.codigo];
    if (umbral === undefined) continue;

    const actividad = actividadPorCodigo(logro.codigo, contadores);
    if (actividad >= umbral) {
      await otorgarLogro(id_usuario, logro.id_logro);
      nuevos.push(logro);
    }
  }

  return nuevos;
}
