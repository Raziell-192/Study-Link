import { Router } from 'express';
import { verificarToken } from '../middlewares/auth.middleware';
import { registrar, miHistorial, porSesion } from '../controllers/asistencia.controller';

const router = Router();

router.post('/', verificarToken, registrar);
router.get('/mi-historial', verificarToken, miHistorial);
router.get('/sesion/:id_sesion', verificarToken, porSesion);

export default router;