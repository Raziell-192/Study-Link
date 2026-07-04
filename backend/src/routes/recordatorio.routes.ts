import { Router } from 'express';
import { verificarToken } from '../middlewares/auth.middleware';
import {
  crear,
  listarPendientes,
  listarTodos,
  marcarEnviado,
} from '../controllers/recordatorio.controller';

const router = Router();

router.post('/', verificarToken, crear);
router.get('/', verificarToken, listarTodos);
router.get('/pendientes', verificarToken, listarPendientes);
router.patch('/:id_recordatorio/enviado', verificarToken, marcarEnviado);

export default router;
