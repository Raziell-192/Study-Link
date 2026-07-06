import { Router } from 'express';
import { verificarToken } from '../middlewares/auth.middleware';
import { listar } from '../controllers/materia.controller';

const router = Router();

router.get('/', verificarToken, listar);

export default router;
