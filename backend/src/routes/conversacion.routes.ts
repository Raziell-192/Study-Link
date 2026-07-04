import { Router } from 'express';
import { verificarToken } from '../middlewares/auth.middleware';
import { iniciarPrivada, iniciarGrupal } from '../controllers/conversacion.controller';

const router = Router();

router.post('/privada', verificarToken, iniciarPrivada);
router.post('/grupo/:id_grupo', verificarToken, iniciarGrupal);

export default router;