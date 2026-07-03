import { Response } from 'express';
import { AuthRequest } from '../middlewares/auth.middleware';
import {
  crearEvento,
  buscarEventoPorId,
  listarEventosPorUsuario,
  listarEventosCompartidosPorGrupo,
  eliminarEvento,
} from '../models/evento.model';
import { esMiembro } from '../models/grupo.model';
import { listarSesionesPorGrupo } from '../models/sesion.model';
import { crearRecordatorio } from '../models/recordatorio.model';

export async function crear(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const {
      titulo,
      descripcion,
      fecha_inicio,
      fecha_fin,
      id_grupo,
      compartido,
      recordatorio_minutos_antes,
    } = req.body;

    // Criterios de aceptación HU-18: título, fechas y (opcionalmente) compartir con un grupo.
    if (!titulo || !fecha_inicio || !fecha_fin) {
      return res.status(400).json({
        error: 'titulo, fecha_inicio y fecha_fin son obligatorios.',
      });
    }

    if (new Date(fecha_fin) <= new Date(fecha_inicio)) {
      return res.status(400).json({ error: 'fecha_fin debe ser posterior a fecha_inicio.' });
    }

    const esCompartido = Boolean(compartido);

    if (esCompartido) {
      if (!id_grupo) {
        return res.status(400).json({ error: 'id_grupo es obligatorio si el evento es compartido.' });
      }
      // Solo un miembro del grupo puede compartir un evento en su calendario (HU-19).
      const perteneceAlGrupo = await esMiembro(id_usuario, id_grupo);
      if (!perteneceAlGrupo) {
        return res.status(403).json({ error: 'No perteneces a ese grupo.' });
      }
    }

    const nuevoEvento = await crearEvento({
      id_usuario,
      id_grupo: esCompartido ? id_grupo : undefined,
      titulo,
      descripcion,
      fecha_inicio,
      fecha_fin,
      compartido: esCompartido,
    });

    // HU-20: si el usuario pidió recordatorio, se genera automáticamente al crear el evento.
    if (recordatorio_minutos_antes !== undefined && recordatorio_minutos_antes !== null) {
      const minutos = Number(recordatorio_minutos_antes);
      if (!Number.isNaN(minutos) && minutos >= 0) {
        const fechaDisparo = new Date(new Date(fecha_inicio).getTime() - minutos * 60000);
        await crearRecordatorio({
          id_usuario,
          id_evento: nuevoEvento.id_evento,
          tipo: 'Evento',
          mensaje: `Recordatorio: "${titulo}" comienza pronto.`,
          fecha_disparo: fechaDisparo.toISOString(),
        });
      }
    }

    return res.status(201).json({
      message: 'Evento creado exitosamente.',
      evento: nuevoEvento,
    });
  } catch (error) {
    console.error('Error en crear() evento:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

// HU-18: consultar mi calendario personal.
export async function listarPropios(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const eventos = await listarEventosPorUsuario(id_usuario);
    return res.status(200).json({ eventos });
  } catch (error) {
    console.error('Error en listarPropios() evento:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

// HU-19: calendario compartido de un grupo = eventos compartidos + sesiones de estudio del grupo.
export async function listarPorGrupo(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const { id_grupo } = req.params;

    const perteneceAlGrupo = await esMiembro(id_usuario, id_grupo);
    if (!perteneceAlGrupo) {
      return res.status(403).json({ error: 'No perteneces a ese grupo.' });
    }

    const [eventos, sesiones] = await Promise.all([
      listarEventosCompartidosPorGrupo(id_grupo),
      listarSesionesPorGrupo(id_grupo),
    ]);

    // Se combinan ambas fuentes en una sola línea de tiempo, marcando el origen de cada item.
    const calendario = [
      ...eventos.map((e) => ({ origen: 'evento' as const, ...e })),
      ...sesiones.map((s) => ({
        origen: 'sesion' as const,
        id_evento: s.id_sesion,
        titulo: s.tema,
        descripcion: s.descripcion,
        fecha_inicio: s.fecha_inicio,
        fecha_fin: s.fecha_fin,
      })),
    ].sort((a, b) => new Date(a.fecha_inicio).getTime() - new Date(b.fecha_inicio).getTime());

    return res.status(200).json({ calendario });
  } catch (error) {
    console.error('Error en listarPorGrupo() evento:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

export async function obtener(req: AuthRequest, res: Response) {
  try {
    const { id_evento } = req.params;
    const evento = await buscarEventoPorId(id_evento);

    if (!evento) {
      return res.status(404).json({ error: 'Evento no encontrado.' });
    }

    return res.status(200).json({ evento });
  } catch (error) {
    console.error('Error en obtener() evento:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

export async function eliminar(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const { id_evento } = req.params;

    const eventoEliminado = await eliminarEvento(id_evento, id_usuario);
    if (!eventoEliminado) {
      return res.status(404).json({
        error: 'Evento no encontrado o no tienes permiso para eliminarlo.',
      });
    }

    return res.status(200).json({ message: 'Evento eliminado exitosamente.' });
  } catch (error) {
    console.error('Error en eliminar() evento:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}
