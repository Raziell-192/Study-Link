import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { pool } from './config/database';
import authRoutes from './routes/auth.routes';
import { verificarToken, AuthRequest } from './middlewares/auth.middleware';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Ruta de salud, para verificar que el servidor está vivo
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'StudyLink API funcionando' });
});

app.get('/db-test', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW()');
    res.json({ status: 'ok', timestamp: result.rows[0] });
  } catch (error) {
    res.status(500).json({ status: 'error', message: (error as Error).message });
  }
});

app.get('/api/perfil-test', verificarToken, (req: AuthRequest, res) => {
  res.json({ message: 'Ruta protegida accedida con éxito', usuario: req.usuario });
});

app.use('/api/auth', authRoutes);

app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});