import { Response } from 'express';
import { AuthRequest } from '../middlewares/auth.middleware';
import {
  crearCuestionario,
  buscarCuestionarioPorId,
  listarPreguntasPorCuestionario,
  listarCuestionariosPorUsuario,
  listarCuestionariosCompartidos,
  eliminarCuestionario,
  TipoPregunta,
} from '../models/cuestionario.model';

const TIPOS_VALIDOS: TipoPregunta[] = [
  'OpcionMultiple',
  'VerdaderoFalso',
  'RelacionConceptos',
  'RespuestaCorta',
];

// HU-16: crear un cuestionario con sus preguntas.
export async function crear(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const { titulo, compartido, preguntas } = req.body;

    if (!titulo || !Array.isArray(preguntas) || preguntas.length === 0) {
      return res.status(400).json({
        error: 'titulo y al menos una pregunta son obligatorios.',
      });
    }

    for (const p of preguntas) {
      if (!p.pregunta || !p.tipo || !p.respuesta_correcta) {
        return res.status(400).json({
          error: 'Cada pregunta necesita pregunta, tipo y respuesta_correcta.',
        });
      }
      if (!TIPOS_VALIDOS.includes(p.tipo)) {
        return res.status(400).json({
          error: `tipo debe ser uno de: ${TIPOS_VALIDOS.join(', ')}.`,
        });
      }
    }

    const nuevoCuestionario = await crearCuestionario({ id_usuario, titulo, compartido, preguntas });

    return res.status(201).json({
      message: 'Cuestionario creado exitosamente.',
      cuestionario: nuevoCuestionario,
    });
  } catch (error) {
    console.error('Error en crear() cuestionario:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

export async function misCuestionarios(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const cuestionarios = await listarCuestionariosPorUsuario(id_usuario);
    return res.status(200).json({ cuestionarios });
  } catch (error) {
    console.error('Error en misCuestionarios():', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

export async function compartidos(req: AuthRequest, res: Response) {
  try {
    const cuestionarios = await listarCuestionariosCompartidos();
    return res.status(200).json({ cuestionarios });
  } catch (error) {
    console.error('Error en compartidos() cuestionario:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

// HU-17: obtener un cuestionario para resolverlo. Si NO eres el dueño, no se envía
// respuesta_correcta (para no hacer trampa resolviendo).
export async function obtener(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const { id_cuestionario } = req.params;

    const cuestionario = await buscarCuestionarioPorId(id_cuestionario);
    if (!cuestionario) {
      return res.status(404).json({ error: 'Cuestionario no encontrado.' });
    }

    const esDueno = cuestionario.id_usuario === id_usuario;
    if (!cuestionario.compartido && !esDueno) {
      return res.status(403).json({ error: 'Este cuestionario es privado.' });
    }

    const preguntas = await listarPreguntasPorCuestionario(id_cuestionario);
    const preguntasParaCliente = esDueno
      ? preguntas
      : preguntas.map(({ respuesta_correcta, ...resto }) => resto);

    return res.status(200).json({ cuestionario: { ...cuestionario, preguntas: preguntasParaCliente } });
  } catch (error) {
    console.error('Error en obtener() cuestionario:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

const normalizar = (texto: string) => texto.trim().toLowerCase();

// HU-17: resolver un cuestionario. Compara cada respuesta contra respuesta_correcta
// (comparación de texto normalizada: trim + minúsculas) y devuelve el puntaje.
export async function resolver(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const { id_cuestionario } = req.params;
    const { respuestas } = req.body;

    if (!Array.isArray(respuestas) || respuestas.length === 0) {
      return res.status(400).json({ error: 'respuestas debe ser un arreglo no vacío.' });
    }

    const cuestionario = await buscarCuestionarioPorId(id_cuestionario);
    if (!cuestionario) {
      return res.status(404).json({ error: 'Cuestionario no encontrado.' });
    }

    if (!cuestionario.compartido && cuestionario.id_usuario !== id_usuario) {
      return res.status(403).json({ error: 'Este cuestionario es privado.' });
    }

    const preguntas = await listarPreguntasPorCuestionario(id_cuestionario);
    const respuestasPorPregunta = new Map<string, string>(
      respuestas.map((r: any) => [r.id_pregunta, String(r.respuesta ?? '')])
    );

    let correctas = 0;
    const detalle = preguntas.map((p) => {
      const respuestaUsuario = respuestasPorPregunta.get(p.id_pregunta) ?? '';
      const esCorrecta = normalizar(respuestaUsuario) === normalizar(p.respuesta_correcta);
      if (esCorrecta) correctas++;
      return {
        id_pregunta: p.id_pregunta,
        pregunta: p.pregunta,
        respuesta_usuario: respuestaUsuario,
        correcta: esCorrecta,
        respuesta_correcta: p.respuesta_correcta,
      };
    });

    return res.status(200).json({
      total_preguntas: preguntas.length,
      correctas,
      puntaje: preguntas.length > 0 ? Math.round((correctas / preguntas.length) * 100) : 0,
      detalle,
    });
  } catch (error) {
    console.error('Error en resolver() cuestionario:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

export async function eliminar(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const { id_cuestionario } = req.params;

    const eliminado = await eliminarCuestionario(id_cuestionario, id_usuario);
    if (!eliminado) {
      return res.status(404).json({
        error: 'Cuestionario no encontrado o no tienes permiso para eliminarlo.',
      });
    }

    return res.status(200).json({ message: 'Cuestionario eliminado exitosamente.' });
  } catch (error) {
    console.error('Error en eliminar() cuestionario:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}
