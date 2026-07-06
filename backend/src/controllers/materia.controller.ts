import { Response } from 'express';
import { AuthRequest } from '../middlewares/auth.middleware';
import { listarMaterias } from '../models/materia.model';

export async function listar(req: AuthRequest, res: Response) {
  try {
    const materias = await listarMaterias();
    return res.status(200).json({ materias });
  } catch (error) {
    console.error('Error en listar() materias:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}
