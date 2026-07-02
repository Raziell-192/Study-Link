import { Router } from 'express';
import { verificarToken } from '../middlewares/auth.middleware';
import { obtenerMiPerfil, actualizarMiPerfil } from '../controllers/usuario.controller';

const router = Router();

router.get('/perfil', verificarToken, obtenerMiPerfil);
router.put('/perfil', verificarToken, actualizarMiPerfil);

export default router;