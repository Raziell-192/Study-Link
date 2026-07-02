import { Request, Response } from 'express';
import bcrypt from 'bcrypt';
import { crearUsuario, buscarPorMatricula, buscarPorCorreo } from '../models/usuario.model';

const SALT_ROUNDS = 10;

export async function registrar(req: Request, res: Response) {
  try {
    const { matricula, nombre_completo, correo, contrasena } = req.body;

    // Validación básica de campos requeridos (criterio HU-01)
    if (!matricula || !nombre_completo || !correo || !contrasena) {
      return res.status(400).json({
        error: 'Todos los campos son obligatorios: matricula, nombre_completo, correo, contrasena.',
      });
    }

    // Validar que la matrícula no esté duplicada (criterio HU-01)
    const usuarioExistentePorMatricula = await buscarPorMatricula(matricula);
    if (usuarioExistentePorMatricula) {
      return res.status(409).json({ error: 'La matrícula ya está registrada.' });
    }

    // Validar que el correo no esté duplicado
    const usuarioExistentePorCorreo = await buscarPorCorreo(correo);
    if (usuarioExistentePorCorreo) {
      return res.status(409).json({ error: 'El correo ya está registrado.' });
    }

    // Hashear la contraseña antes de guardar (RNF-02: seguridad)
    const contrasenaHasheada = await bcrypt.hash(contrasena, SALT_ROUNDS);

    const nuevoUsuario = await crearUsuario({
      matricula,
      nombre_completo,
      correo,
      contrasena: contrasenaHasheada,
    });

    return res.status(201).json({
      message: 'Usuario registrado exitosamente.',
      usuario: nuevoUsuario,
    });
  } catch (error) {
    console.error('Error en registrar():', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}