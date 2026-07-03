import { Response } from 'express';
import { AuthRequest } from '../middlewares/auth.middleware';
import { crearGrupo, buscarGrupoPorId, esMiembro, unirseAGrupo } from '../models/grupo.model';
import { listarMiembros, expulsarMiembro, cambiarRolMiembro } from '../models/grupo.model';

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

// Helper reutilizable: valida que quien hace la petición sea el creador del grupo
async function validarEsCreador(req: AuthRequest, id_grupo: string): Promise<{ ok: boolean; error?: string; status?: number }> {
  const grupo = await buscarGrupoPorId(id_grupo);
  if (!grupo) {
    return { ok: false, error: 'Grupo no encontrado.', status: 404 };
  }
  if (grupo.id_creador !== req.usuario!.id_usuario) {
    return { ok: false, error: 'Solo el creador del grupo puede realizar esta acción.', status: 403 };
  }
  return { ok: true };
}

export async function listar(req: AuthRequest, res: Response) {
  try {
    const { id_grupo } = req.params;
    const grupo = await buscarGrupoPorId(id_grupo);
    if (!grupo) {
      return res.status(404).json({ error: 'Grupo no encontrado.' });
    }
    const miembros = await listarMiembros(id_grupo);
    return res.status(200).json({ miembros });
  } catch (error) {
    console.error('Error en listar() miembros:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

export async function expulsar(req: AuthRequest, res: Response) {
  try {
    const { id_grupo, id_usuario } = req.params;

    const validacion = await validarEsCreador(req, id_grupo);
    if (!validacion.ok) {
      return res.status(validacion.status!).json({ error: validacion.error });
    }

    if (id_usuario === req.usuario!.id_usuario) {
      return res.status(400).json({ error: 'El creador no puede expulsarse a sí mismo.' });
    }

    const expulsado = await expulsarMiembro(id_usuario, id_grupo);
    if (!expulsado) {
      return res.status(404).json({ error: 'Ese usuario no es miembro del grupo.' });
    }

    return res.status(200).json({ message: 'Miembro expulsado exitosamente.' });
  } catch (error) {
    console.error('Error en expulsar():', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

export async function cambiarRol(req: AuthRequest, res: Response) {
  try {
    const { id_grupo, id_usuario } = req.params;
    const { rol } = req.body;

    if (!['Organizador', 'Tutor', 'Tutorado'].includes(rol)) {
      return res.status(400).json({ error: "rol debe ser 'Organizador', 'Tutor' o 'Tutorado'." });
    }

    const validacion = await validarEsCreador(req, id_grupo);
    if (!validacion.ok) {
      return res.status(validacion.status!).json({ error: validacion.error });
    }

    const actualizado = await cambiarRolMiembro(id_usuario, id_grupo, rol);
    if (!actualizado) {
      return res.status(404).json({ error: 'Ese usuario no es miembro del grupo.' });
    }

    return res.status(200).json({ message: 'Rol actualizado exitosamente.', miembro: actualizado });
  } catch (error) {
    console.error('Error en cambiarRol():', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}