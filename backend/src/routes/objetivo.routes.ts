import { Router } from 'express';
import { verificarToken } from '../middlewares/auth.middleware';
import { crear, listarMios, actualizar } from '../controllers/objetivo.controller';

const router = Router();

router.post('/', verificarToken, crear);
router.get('/mios', verificarToken, listarMios);
router.patch('/:id_objetivo/progreso', verificarToken, actualizar);

export default router;