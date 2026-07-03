import { Router } from 'express';
import { verificarToken } from '../middlewares/auth.middleware';
import { crear, listarPorMateria } from '../controllers/apunte.controller';
import { crear, listarPorMateria, obtenerParaDescarga } from '../controllers/apunte.controller';

const router = Router();

router.post('/', verificarToken, crear);
router.get('/materia/:id_materia', verificarToken, listarPorMateria);
router.get('/:id_apunte/descargar', verificarToken, obtenerParaDescarga);

export default router;