import { Response } from 'express';
import { AuthRequest } from '../middlewares/auth.middleware';
import {
  obtenerOCrearConversacionPrivada,
  obtenerOCrearConversacionGrupal,
} from '../models/conversacion.model';
import { esMiembro } from '../models/grupo.model';

export async function iniciarPrivada(req: AuthRequest, res: Response) {
  try {
    const id_usuario_actual = req.usuario!.id_usuario;
    const { id_otro_usuario } = req.body;

    if (!id_otro_usuario) {
      return res.status(400).json({ error: 'id_otro_usuario es obligatorio.' });
    }
    if (id_otro_usuario === id_usuario_actual) {
      return res.status(400).json({ error: 'No puedes iniciar una conversación contigo mismo.' });
    }

    const conversacion = await obtenerOCrearConversacionPrivada(id_usuario_actual, id_otro_usuario);
    return res.status(200).json({ conversacion });
  } catch (error: any) {
    if (error.code === '23503') {
      return res.status(400).json({ error: 'El usuario especificado no existe.' });
    }
    console.error('Error en iniciarPrivada():', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

export async function iniciarGrupal(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const { id_grupo } = req.params;

    const esMiembroDelGrupo = await esMiembro(id_usuario, id_grupo);
    if (!esMiembroDelGrupo) {
      return res.status(403).json({ error: 'No eres miembro de este grupo.' });
    }

    const conversacion = await obtenerOCrearConversacionGrupal(id_grupo);
    return res.status(200).json({ conversacion });
  } catch (error: any) {
    if (error.code === '23503') {
      return res.status(400).json({ error: 'El grupo especificado no existe.' });
    }
    console.error('Error en iniciarGrupal():', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}