import { Router } from 'express';
import { verificarToken } from '../middlewares/auth.middleware';
import {
  crear,
  misCuestionarios,
  compartidos,
  obtener,
  resolver,
  eliminar,
} from '../controllers/cuestionario.controller';

const router = Router();

router.post('/', verificarToken, crear);
router.get('/', verificarToken, misCuestionarios);
router.get('/compartidos', verificarToken, compartidos);
router.get('/:id_cuestionario', verificarToken, obtener);
router.post('/:id_cuestionario/resolver', verificarToken, resolver);
router.delete('/:id_cuestionario', verificarToken, eliminar);

export default router;
