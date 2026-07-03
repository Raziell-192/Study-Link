import { Response } from 'express';
import { AuthRequest } from '../middlewares/auth.middleware';
import { crearGrupo } from '../models/grupo.model';

export async function crear(req: AuthRequest, res: Response) {
  try {
    const id_creador = req.usuario!.id_usuario;
    const { nombre, descripcion, id_materia } = req.body;

    // Criterios de aceptación HU-08: nombre y materia son obligatorios
    if (!nombre || !id_materia) {
      return res.status(400).json({
        error: 'nombre e id_materia son obligatorios.',
      });
    }

    const nuevoGrupo = await crearGrupo({
      nombre,
      descripcion,
      id_creador,
      id_materia,
    });

    return res.status(201).json({
      message: 'Grupo creado exitosamente.',
      grupo: nuevoGrupo,
    });
  } catch (error: any) {
    if (error.code === '23503') {
      return res.status(400).json({ error: 'La materia especificada no existe.' });
    }
    console.error('Error en crear() grupo:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}