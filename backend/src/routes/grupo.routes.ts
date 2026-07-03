import { Router } from 'express';
import { verificarToken } from '../middlewares/auth.middleware';
import { crear } from '../controllers/grupo.controller';

const router = Router();

router.post('/', verificarToken, crear);

export default router;