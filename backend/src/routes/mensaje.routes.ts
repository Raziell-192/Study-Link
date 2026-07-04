import { Router } from 'express';
import { verificarToken } from '../middlewares/auth.middleware';
import { enviar, listar } from '../controllers/mensaje.controller';

const router = Router();

router.post('/', verificarToken, enviar);
router.get('/conversacion/:id_conversacion', verificarToken, listar);

export default router;