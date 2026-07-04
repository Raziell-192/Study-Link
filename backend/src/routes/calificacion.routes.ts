import { Router } from 'express';
import { verificarToken } from '../middlewares/auth.middleware';
import { calificar, obtenerReputacion } from '../controllers/calificacion.controller';

const router = Router();

router.post('/', verificarToken, calificar);
router.get('/tutor/:id_usuario', verificarToken, obtenerReputacion);

export default router;
