import { Response } from 'express';
import { AuthRequest } from '../middlewares/auth.middleware';
import {
  crearRecordatorio,
  listarRecordatoriosPendientes,
  listarRecordatoriosPorUsuario,
  marcarComoEnviado,
} from '../models/recordatorio.model';

const TIPOS_VALIDOS = ['Sesion', 'Examen', 'Tarea', 'Material', 'Objetivo', 'Evento'];

// HU-20: crear un recordatorio manual (además de los que se autogeneran al crear un evento).
export async function crear(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const { id_evento, tipo, mensaje, fecha_disparo } = req.body;

    if (!tipo || !mensaje || !fecha_disparo) {
      return res.status(400).json({
        error: 'tipo, mensaje y fecha_disparo son obligatorios.',
      });
    }

    if (!TIPOS_VALIDOS.includes(tipo)) {
      return res.status(400).json({
        error: `tipo debe ser uno de: ${TIPOS_VALIDOS.join(', ')}.`,
      });
    }

    const nuevoRecordatorio = await crearRecordatorio({
      id_usuario,
      id_evento,
      tipo,
      mensaje,
      fecha_disparo,
    });

    return res.status(201).json({
      message: 'Recordatorio creado exitosamente.',
      recordatorio: nuevoRecordatorio,
    });
  } catch (error: any) {
    if (error.code === '23503') {
      return res.status(400).json({ error: 'El evento especificado no existe.' });
    }
    console.error('Error en crear() recordatorio:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

// Endpoint que el cliente Flutter consulta periódicamente (polling) para saber
// qué recordatorios ya deben mostrarse/notificarse.
export async function listarPendientes(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const recordatorios = await listarRecordatoriosPendientes(id_usuario);
    return res.status(200).json({ recordatorios });
  } catch (error) {
    console.error('Error en listarPendientes() recordatorio:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

export async function listarTodos(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const recordatorios = await listarRecordatoriosPorUsuario(id_usuario);
    return res.status(200).json({ recordatorios });
  } catch (error) {
    console.error('Error en listarTodos() recordatorio:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

// El cliente marca el recordatorio como enviado una vez que ya lo mostró/notificó,
// para que no se vuelva a devolver en /pendientes.
export async function marcarEnviado(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const { id_recordatorio } = req.params;

    const actualizado = await marcarComoEnviado(id_recordatorio, id_usuario);
    if (!actualizado) {
      return res.status(404).json({ error: 'Recordatorio no encontrado.' });
    }

    return res.status(200).json({
      message: 'Recordatorio marcado como enviado.',
      recordatorio: actualizado,
    });
  } catch (error) {
    console.error('Error en marcarEnviado() recordatorio:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}
