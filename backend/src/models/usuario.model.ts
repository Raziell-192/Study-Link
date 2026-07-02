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