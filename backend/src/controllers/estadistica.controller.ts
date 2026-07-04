import { Response } from 'express';
import { AuthRequest } from '../middlewares/auth.middleware';
import { obtenerEstadisticas } from '../models/estadistica.model';

export async function misEstadisticas(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const estadisticas = await obtenerEstadisticas(id_usuario);
    return res.status(200).json({ estadisticas });
  } catch (error) {
    console.error('Error en misEstadisticas():', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}