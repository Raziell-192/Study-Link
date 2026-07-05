import { Response } from 'express';
import { AuthRequest } from '../middlewares/auth.middleware';
import { listarCatalogo, listarLogrosConEstado, verificarYOtorgarLogros } from '../models/logro.model';

// GET /api/logros/catalogo — catálogo completo de logros disponibles en la plataforma.
export async function catalogo(req: AuthRequest, res: Response) {
  try {
    const logros = await listarCatalogo();
    return res.status(200).json({ logros });
  } catch (error) {
    console.error('Error en catalogo() logros:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

// GET /api/logros/mios — HU-30 + HU-31: primero verifica y otorga cualquier logro
// pendiente que el usuario ya haya alcanzado (según su actividad hasta este momento),
// y luego devuelve el catálogo completo marcando cuáles tiene obtenidos y desde cuándo.
// `nuevos` trae solo los que se otorgaron en esta llamada, útil para que el cliente
// muestre una notificación de "¡Nuevo logro desbloqueado!".
export async function misLogros(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;

    const nuevos = await verificarYOtorgarLogros(id_usuario);
    const logros = await listarLogrosConEstado(id_usuario);

    return res.status(200).json({ logros, nuevos });
  } catch (error) {
    console.error('Error en misLogros() logros:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}
