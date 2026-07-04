import { Router } from 'express';
import { verificarToken } from '../middlewares/auth.middleware';
import { misEstadisticas } from '../controllers/estadistica.controller';

const router = Router();

router.get('/mias', verificarToken, misEstadisticas);

export default router;