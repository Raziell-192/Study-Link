import { Router } from 'express';
import { verificarToken } from '../middlewares/auth.middleware';
import { catalogo, misLogros } from '../controllers/logro.controller';

const router = Router();

router.get('/catalogo', verificarToken, catalogo);
router.get('/mios', verificarToken, misLogros);

export default router;
