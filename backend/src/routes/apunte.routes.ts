import { Router } from 'express';
import { verificarToken } from '../middlewares/auth.middleware';
import {
  subir,
  listarPorMateria,
  buscar,
  obtener,
  eliminar,
} from '../controllers/apunte.controller';

const router = Router();

router.post('/', verificarToken, subir);
router.get('/buscar', verificarToken, buscar);
router.get('/materia/:id_materia', verificarToken, listarPorMateria);
router.get('/:id_apunte', verificarToken, obtener);
router.delete('/:id_apunte', verificarToken, eliminar);

export default router;
