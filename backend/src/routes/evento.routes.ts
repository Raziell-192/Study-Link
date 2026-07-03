import { Router } from 'express';
import { verificarToken } from '../middlewares/auth.middleware';
import {
  crear,
  listarPropios,
  listarPorGrupo,
  obtener,
  eliminar,
} from '../controllers/evento.controller';

const router = Router();

router.post('/', verificarToken, crear);
router.get('/', verificarToken, listarPropios);
router.get('/grupo/:id_grupo', verificarToken, listarPorGrupo);
router.get('/:id_evento', verificarToken, obtener);
router.delete('/:id_evento', verificarToken, eliminar);

export default router;
