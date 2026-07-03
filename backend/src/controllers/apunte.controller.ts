import { Response } from 'express';
import { AuthRequest } from '../middlewares/auth.middleware';
import { crearApunte, listarApuntesPorMateria } from '../models/apunte.model';

const TIPOS_VALIDOS = ['PDF', 'Imagen', 'Enlace', 'Presentacion'];

export async function crear(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const { id_materia, titulo, archivo_url, tipo } = req.body;

    if (!id_materia || !titulo || !archivo_url || !tipo) {
      return res.status(400).json({
        error: 'id_materia, titulo, archivo_url y tipo son obligatorios.',
      });
    }

    if (!TIPOS_VALIDOS.includes(tipo)) {
      return res.status(400).json({
        error: `tipo debe ser uno de: ${TIPOS_VALIDOS.join(', ')}.`,
      });
    }

    const nuevoApunte = await crearApunte({ id_usuario, id_materia, titulo, archivo_url, tipo });

    return res.status(201).json({ message: 'Apunte subido exitosamente.', apunte: nuevoApunte });
  } catch (error: any) {
    if (error.code === '23503') {
      return res.status(400).json({ error: 'La materia especificada no existe.' });
    }
    console.error('Error en crear() apunte:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

export async function listarPorMateria(req: AuthRequest, res: Response) {
  try {
    const { id_materia } = req.params;
    const apuntes = await listarApuntesPorMateria(id_materia);
    return res.status(200).json({ apuntes });
  } catch (error) {
    console.error('Error en listarPorMateria() apuntes:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}