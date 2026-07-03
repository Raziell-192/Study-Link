import { Response } from 'express';
import { AuthRequest } from '../middlewares/auth.middleware';
import { crearSesion, listarSesionesPorGrupo } from '../models/sesion.model';
import { obtenerRolEnGrupo } from '../models/grupo.model';

export async function crear(req: AuthRequest, res: Response) {
  try {
    const id_creador = req.usuario!.id_usuario;
    const { id_grupo, tema, descripcion, fecha_inicio, fecha_fin, modalidad } = req.body;

    if (!id_grupo || !tema || !fecha_inicio || !fecha_fin || !modalidad) {
      return res.status(400).json({
        error: 'id_grupo, tema, fecha_inicio, fecha_fin y modalidad son obligatorios.',
      });
    }

    const rol = await obtenerRolEnGrupo(id_creador, id_grupo);
    if (!rol) {
      return res.status(403).json({ error: 'No eres miembro de este grupo.' });
    }
    if (!['Organizador', 'Tutor'].includes(rol)) {
      return res.status(403).json({ error: 'Solo el Organizador o un Tutor pueden programar sesiones.' });
    }

    if (new Date(fecha_fin) <= new Date(fecha_inicio)) {
      return res.status(400).json({ error: 'fecha_fin debe ser posterior a fecha_inicio.' });
    }

    const nuevaSesion = await crearSesion({
      id_grupo, id_creador, tema, descripcion, fecha_inicio, fecha_fin, modalidad,
    });

    return res.status(201).json({ message: 'Sesión programada exitosamente.', sesion: nuevaSesion });
  } catch (error: any) {
    if (error.code === '23503') {
      return res.status(400).json({ error: 'El grupo especificado no existe.' });
    }
    console.error('Error en crear() sesión:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

export async function listarPorGrupo(req: AuthRequest, res: Response) {
  try {
    const { id_grupo } = req.params;
    const sesiones = await listarSesionesPorGrupo(id_grupo);
    return res.status(200).json({ sesiones });
  } catch (error) {
    console.error('Error en listarPorGrupo():', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}