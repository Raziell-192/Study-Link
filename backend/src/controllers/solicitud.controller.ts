import { Response } from 'express';
import { AuthRequest } from '../middlewares/auth.middleware';
import { crearSolicitud, listarSolicitudesPorMateria } from '../models/solicitud.model';
import { aceptarSolicitud, buscarSolicitudPorId } from '../models/solicitud.model';

export async function crear(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const { id_materia, titulo, descripcion, modalidad } = req.body;

    // Criterios de aceptación HU-04: materia, tema y modalidad son obligatorios
    if (!id_materia || !titulo || !modalidad) {
      return res.status(400).json({
        error: 'id_materia, titulo y modalidad son obligatorios.',
      });
    }

    if (!['Individual', 'Grupal'].includes(modalidad)) {
      return res.status(400).json({
        error: 'modalidad debe ser "Individual" o "Grupal".',
      });
    }

    const nuevaSolicitud = await crearSolicitud({
      id_usuario,
      id_materia,
      titulo,
      descripcion,
      modalidad,
    });

    return res.status(201).json({
      message: 'Solicitud creada exitosamente.',
      solicitud: nuevaSolicitud,
    });
  } catch (error: any) {
    // Si id_materia no existe, Postgres lanza un error de foreign key
    if (error.code === '23503') {
      return res.status(400).json({ error: 'La materia especificada no existe.' });
    }
    console.error('Error en crear() solicitud:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

export async function listarPorMateria(req: AuthRequest, res: Response) {
  try {
    const { id_materia } = req.params;
    const solicitudes = await listarSolicitudesPorMateria(id_materia);
    return res.status(200).json({ solicitudes });
  } catch (error) {
    console.error('Error en listarPorMateria():', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

export async function aceptar(req: AuthRequest, res: Response) {
  try {
    const id_tutor = req.usuario!.id_usuario;
    const { id_solicitud } = req.params;

    const solicitud = await buscarSolicitudPorId(id_solicitud);
    if (!solicitud) {
      return res.status(404).json({ error: 'Solicitud no encontrada.' });
    }

    if (solicitud.id_usuario === id_tutor) {
      return res.status(400).json({ error: 'No puedes aceptar tu propia solicitud.' });
    }

    if (solicitud.estado !== 'Abierta') {
      return res.status(409).json({ error: 'La solicitud ya no está disponible.' });
    }

    const solicitudActualizada = await aceptarSolicitud(id_solicitud, id_tutor);
    if (!solicitudActualizada) {
      // Otro tutor la aceptó justo antes (condición de carrera)
      return res.status(409).json({ error: 'La solicitud ya fue aceptada por otro tutor.' });
    }

    return res.status(200).json({
      message: 'Solicitud aceptada exitosamente.',
      solicitud: solicitudActualizada,
    });
  } catch (error) {
    console.error('Error en aceptar():', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}