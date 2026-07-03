import { Response } from 'express';
import { AuthRequest } from '../middlewares/auth.middleware';
import {
  crearApunte,
  buscarApuntePorId,
  listarApuntesPorMateria,
  buscarApuntesPorTitulo,
  eliminarApunte,
} from '../models/apunte.model';

const TIPOS_VALIDOS = ['PDF', 'Imagen', 'Enlace', 'Presentacion'];

export async function subir(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const { id_materia, titulo, descripcion, tipo_archivo, archivo_url } = req.body;

    // Criterios de aceptación HU-11: materia asociada, y el archivo ya subido
    // (PDF/imagen/etc.) referenciado por su URL en Firebase Storage.
    if (!id_materia || !titulo || !tipo_archivo || !archivo_url) {
      return res.status(400).json({
        error: 'id_materia, titulo, tipo_archivo y archivo_url son obligatorios.',
      });
    }

    if (!TIPOS_VALIDOS.includes(tipo_archivo)) {
      return res.status(400).json({
        error: `tipo_archivo debe ser uno de: ${TIPOS_VALIDOS.join(', ')}.`,
      });
    }

    const nuevoApunte = await crearApunte({
      id_usuario,
      id_materia,
      titulo,
      descripcion,
      tipo_archivo,
      archivo_url,
    });

    return res.status(201).json({
      message: 'Apunte subido exitosamente.',
      apunte: nuevoApunte,
    });
  } catch (error: any) {
    if (error.code === '23503') {
      return res.status(400).json({ error: 'La materia especificada no existe.' });
    }
    console.error('Error en subir() apunte:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

export async function listarPorMateria(req: AuthRequest, res: Response) {
  try {
    const { id_materia } = req.params;
    const apuntes = await listarApuntesPorMateria(id_materia);
    return res.status(200).json({ apuntes });
  } catch (error) {
    console.error('Error en listarPorMateria() apunte:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

// HU-12: Consultar Biblioteca — búsqueda por texto, opcionalmente filtrada por materia.
export async function buscar(req: AuthRequest, res: Response) {
  try {
    const { q, id_materia } = req.query;

    if (!q || typeof q !== 'string') {
      return res.status(400).json({ error: 'El parámetro de búsqueda "q" es obligatorio.' });
    }

    const apuntes = await buscarApuntesPorTitulo(
      q,
      typeof id_materia === 'string' ? id_materia : undefined
    );
    return res.status(200).json({ apuntes });
  } catch (error) {
    console.error('Error en buscar() apunte:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

// HU-13: Descargar Recursos — el backend no sirve el binario (vive en Firebase Storage),
// solo entrega los metadatos + archivo_url para que el cliente descargue directo.
export async function obtener(req: AuthRequest, res: Response) {
  try {
    const { id_apunte } = req.params;
    const apunte = await buscarApuntePorId(id_apunte);

    if (!apunte) {
      return res.status(404).json({ error: 'Apunte no encontrado.' });
    }

    return res.status(200).json({ apunte });
  } catch (error) {
    console.error('Error en obtener() apunte:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

export async function eliminar(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const { id_apunte } = req.params;

    const apunteEliminado = await eliminarApunte(id_apunte, id_usuario);
    if (!apunteEliminado) {
      return res.status(404).json({
        error: 'Apunte no encontrado o no tienes permiso para eliminarlo.',
      });
    }

    return res.status(200).json({ message: 'Apunte eliminado exitosamente.' });
  } catch (error) {
    console.error('Error en eliminar() apunte:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}