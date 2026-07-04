import { Router } from 'express';
import { verificarToken } from '../middlewares/auth.middleware';
import {
  crear,
  agregarTarjetaAFlashcard,
  misFlashcards,
  compartidas,
  obtener,
  compartir,
  eliminar,
} from '../controllers/flashcard.controller';

const router = Router();

router.post('/', verificarToken, crear);
router.get('/', verificarToken, misFlashcards);
router.get('/compartidas', verificarToken, compartidas);
router.get('/:id_flashcard', verificarToken, obtener);
router.post('/:id_flashcard/tarjetas', verificarToken, agregarTarjetaAFlashcard);
router.patch('/:id_flashcard/compartir', verificarToken, compartir);
router.delete('/:id_flashcard', verificarToken, eliminar);

export default router;
