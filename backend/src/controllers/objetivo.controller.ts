import { Response } from 'express';
import { AuthRequest } from '../middlewares/auth.middleware';
import {
  crearObjetivo,
  listarObjetivosPorUsuario,
  buscarObjetivoPorId,
  actualizarProgreso,
  derivarEstado,
} from '../models/objetivo.model';

function conEstado(objetivo: any) {
  return { ...objetivo, estado: derivarEstado(objetivo.progreso) };
}

export async function crear(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const { titulo, descripcion, fecha_limite } = req.body;

    if (!titulo) {
      return res.status(400).json({ error: 'titulo es obligatorio.' });
    }

    const nuevoObjetivo = await crearObjetivo({ id_usuario, titulo, descripcion, fecha_limite });
    return res.status(201).json({ message: 'Objetivo creado exitosamente.', objetivo: conEstado(nuevoObjetivo) });
  } catch (error) {
    console.error('Error en crear() objetivo:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

export async function listarMios(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const objetivos = await listarObjetivosPorUsuario(id_usuario);
    return res.status(200).json({ objetivos: objetivos.map(conEstado) });
  } catch (error) {
    console.error('Error en listarMios() objetivos:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

export async function actualizar(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const { id_objetivo } = req.params;
    const { progreso } = req.body;

    if (progreso === undefined || progreso < 0 || progreso > 100) {
      return res.status(400).json({ error: 'progreso debe ser un número entre 0 y 100.' });
    }

    const objetivo = await buscarObjetivoPorId(id_objetivo);
    if (!objetivo) {
      return res.status(404).json({ error: 'Objetivo no encontrado.' });
    }
    if (objetivo.id_usuario !== id_usuario) {
      return res.status(403).json({ error: 'No tienes permiso para modificar este objetivo.' });
    }

    const actualizado = await actualizarProgreso(id_objetivo, progreso);
    return res.status(200).json({ message: 'Progreso actualizado.', objetivo: conEstado(actualizado) });
  } catch (error) {
    console.error('Error en actualizar() objetivo:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}