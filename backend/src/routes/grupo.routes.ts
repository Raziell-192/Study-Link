import { Router } from 'express';
import { verificarToken } from '../middlewares/auth.middleware';
import { crear, unirse, listar, expulsar, cambiarRol } from '../controllers/grupo.controller';

const router = Router();

router.post('/', verificarToken, crear);
router.post('/:id_grupo/unirse', verificarToken, unirse);
router.get('/:id_grupo/miembros', verificarToken, listar);
router.delete('/:id_grupo/miembros/:id_usuario', verificarToken, expulsar);
router.patch('/:id_grupo/miembros/:id_usuario/rol', verificarToken, cambiarRol);

export default router;