import { Router } from 'express';
import { verificarToken } from '../middlewares/auth.middleware';
import { crear, listarPorMateria } from '../controllers/solicitud.controller';

const router = Router();

router.post('/', verificarToken, crear);
router.get('/materia/:id_materia', verificarToken, listarPorMateria);

export default router;