import { Response } from 'express';
import { AuthRequest } from '../middlewares/auth.middleware';
import { registrarAsistencia, listarHistorialUsuario, listarAsistenciaPorSesion } from '../models/asistencia.model';
import { obtenerRolEnGrupo } from '../models/grupo.model';
import { pool } from '../config/database';

export async function registrar(req: AuthRequest, res: Response) {
  try {
    const id_usuario_solicitante = req.usuario!.id_usuario;
    const { id_sesion, id_usuario, hora_ingreso, hora_salida } = req.body;

    if (!id_sesion || !id_usuario || !hora_ingreso) {
      return res.status(400).json({ error: 'id_sesion, id_usuario y hora_ingreso son obligatorios.' });
    }

    // Verificar que quien registra sea Organizador/Tutor del grupo de esa sesión.
    const sesionResult = await pool.query(`SELECT id_grupo FROM sesion_estudio WHERE id_sesion = $1;`, [id_sesion]);
    const sesion = sesionResult.rows[0];
    if (!sesion) {
      return res.status(404).json({ error: 'Sesión no encontrada.' });
    }

    const rol = await obtenerRolEnGrupo(id_usuario_solicitante, sesion.id_grupo);
    if (!rol || !['Organizador', 'Tutor'].includes(rol)) {
      return res.status(403).json({ error: 'Solo el Organizador o un Tutor pueden registrar asistencia.' });
    }

    const asistencia = await registrarAsistencia(id_sesion, id_usuario, hora_ingreso, hora_salida);
    return res.status(201).json({ message: 'Asistencia registrada.', asistencia });
  } catch (error: any) {
    if (error.code === '23503') {
      return res.status(400).json({ error: 'La sesión o el usuario especificado no existe.' });
    }
    if (error.code === '23514') {
      return res.status(400).json({ error: 'hora_salida debe ser posterior a hora_ingreso.' });
    }
    console.error('Error en registrar() asistencia:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

export async function miHistorial(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const historial = await listarHistorialUsuario(id_usuario);
    return res.status(200).json({ historial });
  } catch (error) {
    console.error('Error en miHistorial():', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

export async function porSesion(req: AuthRequest, res: Response) {
  try {
    const { id_sesion } = req.params;
    const asistencias = await listarAsistenciaPorSesion(id_sesion);
    return res.status(200).json({ asistencias });
  } catch (error) {
    console.error('Error en porSesion():', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}