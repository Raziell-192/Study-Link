import { Router } from 'express';
import { verificarToken } from '../middlewares/auth.middleware';
import { obtenerMiPerfil, actualizarMiPerfil } from '../controllers/usuario.controller';
import { listarTutoresPorMateria } from '../controllers/usuario.controller';

const router = Router();

router.get('/perfil', verificarToken, obtenerMiPerfil);
router.put('/perfil', verificarToken, actualizarMiPerfil);
router.get('/tutores/:id_materia', verificarToken, listarTutoresPorMateria);

export default router;