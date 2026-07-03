import { Request, Response } from 'express';
import bcrypt from 'bcrypt';
import { crearUsuario, buscarPorMatricula, buscarPorCorreo } from '../models/usuario.model';
import jwt from 'jsonwebtoken';

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

export async function iniciarSesion(req: Request, res: Response) {
  try {
    const { correo, contrasena } = req.body;

    if (!correo || !contrasena) {
      return res.status(400).json({ error: 'Correo y contraseña son obligatorios.' });
    }

    const usuario = await buscarPorCorreo(correo);
    if (!usuario) {
      return res.status(401).json({ error: 'Credenciales incorrectas.' });
    }

    const contrasenaValida = await bcrypt.compare(contrasena, usuario.contrasena);
    if (!contrasenaValida) {
      return res.status(401).json({ error: 'Credenciales incorrectas.' });
    }

    const token = jwt.sign(
      { id_usuario: usuario.id_usuario, correo: usuario.correo },
      process.env.JWT_SECRET as string,
      { expiresIn: '7d' }
    );

    const { contrasena: _contrasenaOculta, ...usuarioSinContrasena } = usuario;

    return res.status(200).json({
      message: 'Inicio de sesión exitoso.',
      token,
      usuario: usuarioSinContrasena,
    });
  } catch (error) {
    console.error('Error en iniciarSesion():', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
}