import { Router } from 'express';
import { verificarToken } from '../middlewares/auth.middleware';
import { crear, listarPorMateria } from '../controllers/solicitud.controller';
import { crear, listarPorMateria, aceptar } from '../controllers/solicitud.controller';

const router = Router();

router.post('/', verificarToken, crear);
router.get('/materia/:id_materia', verificarToken, listarPorMateria);
router.patch('/:id_solicitud/aceptar', verificarToken, aceptar);

export default router;