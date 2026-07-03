import { Router } from 'express';
import { verificarToken } from '../middlewares/auth.middleware';
import { crear } from '../controllers/grupo.controller';
import { crear, unirse } from '../controllers/grupo.controller';

const router = Router();

router.post('/', verificarToken, crear);
router.post('/:id_grupo/unirse', verificarToken, unirse);

export default router;