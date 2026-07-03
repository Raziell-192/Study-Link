import { Response } from 'express';
import { AuthRequest } from '../middlewares/auth.middleware';
import { crearGrupo } from '../models/grupo.model';
import { crearGrupo, buscarGrupoPorId, esMiembro, unirseAGrupo } from '../models/grupo.model';

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

export async function unirse(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const { id_grupo } = req.params;

    const grupo = await buscarGrupoPorId(id_grupo);
    if (!grupo) {
      return res.status(404).json({ error: 'Grupo no encontrado.' });
    }

    const yaEsMiembro = await esMiembro(id_usuario, id_grupo);
    if (yaEsMiembro) {
      return res.status(409).json({ error: 'Ya eres miembro de este grupo.' });
    }

    const nuevoMiembro = await unirseAGrupo(id_usuario, id_grupo);

    return res.status(201).json({
      message: 'Te has unido al grupo exitosamente.',
      miembro: nuevoMiembro,
    });
  } catch (error) {
    console.error('Error en unirse():', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}