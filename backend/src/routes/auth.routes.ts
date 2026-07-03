import { Router } from 'express';
import { registrar } from '../controllers/auth.controller';
import { registrar, iniciarSesion } from '../controllers/auth.controller';

const router = Router();

router.post('/registro', registrar);
router.post('/login', iniciarSesion);

export default router;