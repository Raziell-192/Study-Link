import { Response } from 'express';
import { AuthRequest } from '../middlewares/auth.middleware';
import { buscarPorId, actualizarPerfil } from '../models/usuario.model';

export async function obtenerMiPerfil(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;

    const usuario = await buscarPorId(id_usuario);
    if (!usuario) {
      return res.status(404).json({ error: 'Usuario no encontrado.' });
    }

    const { contrasena: _contrasenaOculta, ...usuarioSinContrasena } = usuario;
    return res.status(200).json({ usuario: usuarioSinContrasena });
  } catch (error) {
    console.error('Error en obtenerMiPerfil():', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

export async function actualizarMiPerfil(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const { nombre_completo, carrera, semestre, foto_perfil } = req.body;

    const datosActualizar: Record<string, unknown> = {};
    if (nombre_completo !== undefined) datosActualizar.nombre_completo = nombre_completo;
    if (carrera !== undefined) datosActualizar.carrera = carrera;
    if (semestre !== undefined) datosActualizar.semestre = semestre;
    if (foto_perfil !== undefined) datosActualizar.foto_perfil = foto_perfil;

    const usuarioActualizado = await actualizarPerfil(id_usuario, datosActualizar);
    if (!usuarioActualizado) {
      return res.status(404).json({ error: 'Usuario no encontrado.' });
    }

    return res.status(200).json({
      message: 'Perfil actualizado exitosamente.',
      usuario: usuarioActualizado,
    });
  } catch (error) {
    console.error('Error en actualizarMiPerfil():', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}