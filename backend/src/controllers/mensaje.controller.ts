import { Response } from 'express';
import { AuthRequest } from '../middlewares/auth.middleware';
import { enviarMensaje, listarMensajes } from '../models/mensaje.model';
import { buscarConversacionPorId } from '../models/conversacion.model';
import { esMiembro } from '../models/grupo.model';

// Verifica que el usuario autenticado tenga permiso de ver/escribir en esta conversación.
async function validarParticipante(
  id_usuario: string,
  id_conversacion: string
): Promise<{ ok: boolean; error?: string; status?: number }> {
  const conversacion = await buscarConversacionPorId(id_conversacion);
  if (!conversacion) {
    return { ok: false, error: 'Conversación no encontrada.', status: 404 };
  }

  if (conversacion.tipo === 'Privada') {
    const esParticipante =
      conversacion.id_usuario_1 === id_usuario || conversacion.id_usuario_2 === id_usuario;
    if (!esParticipante) {
      return { ok: false, error: 'No tienes acceso a esta conversación.', status: 403 };
    }
  } else {
    const perteneceAlGrupo = await esMiembro(id_usuario, conversacion.id_grupo!);
    if (!perteneceAlGrupo) {
      return { ok: false, error: 'No eres miembro del grupo de esta conversación.', status: 403 };
    }
  }

  return { ok: true };
}

export async function enviar(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const { id_conversacion, contenido } = req.body;

    if (!id_conversacion || !contenido) {
      return res.status(400).json({ error: 'id_conversacion y contenido son obligatorios.' });
    }

    const validacion = await validarParticipante(id_usuario, id_conversacion);
    if (!validacion.ok) {
      return res.status(validacion.status!).json({ error: validacion.error });
    }

    const mensaje = await enviarMensaje(id_conversacion, id_usuario, contenido);
    return res.status(201).json({ message: 'Mensaje enviado.', mensaje });
  } catch (error) {
    console.error('Error en enviar() mensaje:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

export async function listar(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const { id_conversacion } = req.params;
    const { desde } = req.query;

    const validacion = await validarParticipante(id_usuario, id_conversacion);
    if (!validacion.ok) {
      return res.status(validacion.status!).json({ error: validacion.error });
    }

    const mensajes = await listarMensajes(
      id_conversacion,
      typeof desde === 'string' ? desde : undefined
    );
    return res.status(200).json({ mensajes });
  } catch (error) {
    console.error('Error en listar() mensajes:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}