import { Response } from 'express';
import { AuthRequest } from '../middlewares/auth.middleware';
import {
  crearFlashcard,
  agregarTarjeta,
  buscarFlashcardPorId,
  listarTarjetasPorFlashcard,
  listarFlashcardsPorUsuario,
  listarFlashcardsCompartidas,
  actualizarCompartida,
  eliminarFlashcard,
} from '../models/flashcard.model';

// HU-14: crear un set de flashcards con sus tarjetas.
export async function crear(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const { titulo, compartida, tarjetas } = req.body;

    if (!titulo || !Array.isArray(tarjetas) || tarjetas.length === 0) {
      return res.status(400).json({
        error: 'titulo y al menos una tarjeta (pregunta + respuesta) son obligatorios.',
      });
    }

    const tarjetaInvalida = tarjetas.find((t: any) => !t.pregunta || !t.respuesta);
    if (tarjetaInvalida) {
      return res.status(400).json({ error: 'Cada tarjeta necesita pregunta y respuesta.' });
    }

    const nuevaFlashcard = await crearFlashcard({ id_usuario, titulo, compartida, tarjetas });

    return res.status(201).json({
      message: 'Flashcard creada exitosamente.',
      flashcard: nuevaFlashcard,
    });
  } catch (error) {
    console.error('Error en crear() flashcard:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

// Agregar una tarjeta suelta a una flashcard ya existente (solo el dueño).
export async function agregarTarjetaAFlashcard(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const { id_flashcard } = req.params;
    const { pregunta, respuesta } = req.body;

    if (!pregunta || !respuesta) {
      return res.status(400).json({ error: 'pregunta y respuesta son obligatorias.' });
    }

    const flashcard = await buscarFlashcardPorId(id_flashcard);
    if (!flashcard) {
      return res.status(404).json({ error: 'Flashcard no encontrada.' });
    }
    if (flashcard.id_usuario !== id_usuario) {
      return res.status(403).json({ error: 'Solo el dueño puede agregar tarjetas.' });
    }

    const nuevaTarjeta = await agregarTarjeta(id_flashcard, { pregunta, respuesta });
    return res.status(201).json({ message: 'Tarjeta agregada.', tarjeta: nuevaTarjeta });
  } catch (error) {
    console.error('Error en agregarTarjetaAFlashcard():', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

export async function misFlashcards(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const flashcards = await listarFlashcardsPorUsuario(id_usuario);
    return res.status(200).json({ flashcards });
  } catch (error) {
    console.error('Error en misFlashcards():', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

// HU-15: explorar flashcards compartidas por otros usuarios.
export async function compartidas(req: AuthRequest, res: Response) {
  try {
    const flashcards = await listarFlashcardsCompartidas();
    return res.status(200).json({ flashcards });
  } catch (error) {
    console.error('Error en compartidas() flashcard:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

export async function obtener(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const { id_flashcard } = req.params;

    const flashcard = await buscarFlashcardPorId(id_flashcard);
    if (!flashcard) {
      return res.status(404).json({ error: 'Flashcard no encontrada.' });
    }

    // Solo el dueño o, si está compartida, cualquier usuario autenticado puede verla.
    if (!flashcard.compartida && flashcard.id_usuario !== id_usuario) {
      return res.status(403).json({ error: 'Esta flashcard es privada.' });
    }

    const tarjetas = await listarTarjetasPorFlashcard(id_flashcard);
    return res.status(200).json({ flashcard: { ...flashcard, tarjetas } });
  } catch (error) {
    console.error('Error en obtener() flashcard:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

// HU-15: alternar si una flashcard es pública o privada.
export async function compartir(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const { id_flashcard } = req.params;
    const { compartida } = req.body;

    if (typeof compartida !== 'boolean') {
      return res.status(400).json({ error: 'compartida debe ser true o false.' });
    }

    const actualizada = await actualizarCompartida(id_flashcard, id_usuario, compartida);
    if (!actualizada) {
      return res.status(404).json({
        error: 'Flashcard no encontrada o no tienes permiso para modificarla.',
      });
    }

    return res.status(200).json({ message: 'Flashcard actualizada.', flashcard: actualizada });
  } catch (error) {
    console.error('Error en compartir() flashcard:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}

export async function eliminar(req: AuthRequest, res: Response) {
  try {
    const id_usuario = req.usuario!.id_usuario;
    const { id_flashcard } = req.params;

    const eliminada = await eliminarFlashcard(id_flashcard, id_usuario);
    if (!eliminada) {
      return res.status(404).json({
        error: 'Flashcard no encontrada o no tienes permiso para eliminarla.',
      });
    }

    return res.status(200).json({ message: 'Flashcard eliminada exitosamente.' });
  } catch (error) {
    console.error('Error en eliminar() flashcard:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}
