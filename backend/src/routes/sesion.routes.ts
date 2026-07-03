import { Router } from 'express';
import { verificarToken } from '../middlewares/auth.middleware';
import { crear, listarPorGrupo } from '../controllers/sesion.controller';

const router = Router();

router.post('/', verificarToken, crear);
router.get('/grupo/:id_grupo', verificarToken, listarPorGrupo);

export default router;