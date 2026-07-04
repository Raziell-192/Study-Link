import { Response } from 'express';
import { AuthRequest } from '../middlewares/auth.middleware';
import { crearCalificacion, listarCalificacionesPorTutor } from '../models/calificacion.model';
import { buscarSesionPorId } from '../models/sesion.model';
import { esMiembro, obtenerRolEnGrupo } from '../models/grupo.model';
import { buscarPorId, actualizarReputacion } from '../models/usuario.model';

// HU-26: Calificar Tutor.
export async function calificar(req: AuthRequest, res: Response) {
  try {
    const id_tutorado = req.usuario!.id_usuario;
    const { id_sesion, id_tutor, puntuacion, comentario } = req.body;

    if (!id_sesion || !id_tutor || puntuacion === undefined) {
      return res.status(400).json({
        error: 'id_sesion, id_tutor y puntuacion son obligatorios.',
      });
    }

    const puntos = Number(puntuacion);
    if (!Number.isInteger(puntos) || puntos < 1 || puntos > 5) {
      return res.status(400).json({ error: 'puntuacion debe ser un entero entre 1 y 5.' });
    }

    if (id_tutor === id_tutorado) {
      return res.status(400).json({ error: 'No puedes calificarte a ti mismo.' });
    }

    const sesion = await buscarSesionPorId(id_sesion);
    if (!sesion) {
      return res.status(404).json({ error: 'La sesión especificada no existe.' });
    }

    // El tutorado debe pertenecer al grupo de la sesión...
    const esMiembroDelGrupo = await esMiembro(id_tutorado, sesion.id_grupo);
    if (!esMiembroDelGrupo) {
      return res.status(403).json({ error: 'No perteneces al grupo de esta sesión.' });
    }

    // ...y el id_tutor debe tener efectivamente rol de Tutor u Organizador en ese grupo.
    const rolTutor = await obtenerRolEnGrupo(id_tutor, sesion.id_grupo);
    if (!rolTutor || !['Tutor', 'Organizador'].includes(rolTutor)) {
      return res.status(400).json({ error: 'El usuario indicado no es tutor de este grupo.' });
    }

    const nuevaCalificacion = await crearCalificacion({
      id_sesion,
      id_tutor,
      id_tutorado,
      puntuacion: puntos,
      comentario,
    });

    const nuevaReputacion = await actualizarReputacion(id_tutor);

    return res.status(201).json({
      message: 'Calificación registrada exitosamente.',
      calificacion: nuevaCalificacion,
      reputacion_tutor: nuevaReputacion,
    });
  } catch (error: any) {
    if (error.code === '23505') {
      return res.status(409).json({ error: 'Ya calificaste esta sesión.' });
    }
    console.error('Error en calificar() calificacion:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

// HU-27: Consultar Reputación de un tutor (promedio + calificaciones recibidas).
export async function obtenerReputacion(req: AuthRequest, res: Response) {
  try {
    const { id_usuario } = req.params;

    const usuario = await buscarPorId(id_usuario);
    if (!usuario) {
      return res.status(404).json({ error: 'Usuario no encontrado.' });
    }

    const calificaciones = await listarCalificacionesPorTutor(id_usuario);

    return res.status(200).json({
      id_usuario: usuario.id_usuario,
      nombre_completo: usuario.nombre_completo,
      reputacion: usuario.reputacion,
      total_calificaciones: calificaciones.length,
      calificaciones,
    });
  } catch (error) {
    console.error('Error en obtenerReputacion() calificacion:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}
