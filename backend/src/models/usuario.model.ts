import { pool } from '../config/database';

export interface Usuario {
  id_usuario: string;
  matricula: string;
  nombre_completo: string;
  correo: string;
  contrasena: string;
  carrera?: string;
  semestre?: number;
  fecha_registro: Date;
  foto_perfil?: string;
  reputacion: number;
}

export interface NuevoUsuarioInput {
  matricula: string;
  nombre_completo: string;
  correo: string;
  contrasena: string;
}

export async function crearUsuario(datos: NuevoUsuarioInput): Promise<Usuario> {
  const { matricula, nombre_completo, correo, contrasena } = datos;

  const query = `
    INSERT INTO usuario (matricula, nombre_completo, correo, contrasena)
    VALUES ($1, $2, $3, $4)
    RETURNING id_usuario, matricula, nombre_completo, correo, carrera, semestre, fecha_registro, foto_perfil, reputacion;
  `;

  const result = await pool.query(query, [matricula, nombre_completo, correo, contrasena]);
  return result.rows[0];
}

export async function buscarPorMatricula(matricula: string): Promise<Usuario | null> {
  const query = `SELECT * FROM usuario WHERE matricula = $1;`;
  const result = await pool.query(query, [matricula]);
  return result.rows[0] || null;
}

export async function buscarPorCorreo(correo: string): Promise<Usuario | null> {
  const query = `SELECT * FROM usuario WHERE correo = $1;`;
  const result = await pool.query(query, [correo]);
  return result.rows[0] || null;
}

export async function buscarPorId(id_usuario: string): Promise<Usuario | null> {
  const query = `SELECT * FROM usuario WHERE id_usuario = $1;`;
  const result = await pool.query(query, [id_usuario]);
  return result.rows[0] || null;
}

export interface ActualizarPerfilInput {
  nombre_completo?: string;
  carrera?: string;
  semestre?: number;
  foto_perfil?: string;
}

export async function actualizarPerfil(
  id_usuario: string,
  datos: ActualizarPerfilInput
): Promise<Usuario | null> {
  const campos = Object.keys(datos);
  if (campos.length === 0) return buscarPorId(id_usuario);

  const setClause = campos.map((campo, i) => `${campo} = $${i + 2}`).join(', ');
  const valores = campos.map((campo) => datos[campo as keyof ActualizarPerfilInput]);

  const query = `
    UPDATE usuario SET ${setClause}
    WHERE id_usuario = $1
    RETURNING id_usuario, matricula, nombre_completo, correo, carrera, semestre, fecha_registro, foto_perfil, reputacion;
  `;

  const result = await pool.query(query, [id_usuario, ...valores]);
  return result.rows[0] || null;
}