import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/campo_formulario.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _correoCtrl = TextEditingController();
  final _contrasenaCtrl = TextEditingController();

  @override
  void dispose() {
    _correoCtrl.dispose();
    _contrasenaCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    context.read<AuthCubit>().login(
          correo: _correoCtrl.text.trim(),
          contrasena: _contrasenaCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAutenticado) {
            context.go('/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.mensaje)),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.school, size: 72),
                    const SizedBox(height: 12),
                    Text(
                      'StudyLink',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 32),
                    CampoFormulario(
                      controller: _correoCtrl,
                      etiqueta: 'Correo institucional',
                      icono: Icons.email_outlined,
                      tipoTeclado: TextInputType.emailAddress,
                      validador: (v) =>
                          (v == null || v.isEmpty) ? 'Ingresa tu correo.' : null,
                    ),
                    const SizedBox(height: 16),
                    CampoFormulario(
                      controller: _contrasenaCtrl,
                      etiqueta: 'Contraseña',
                      icono: Icons.lock_outline,
                      esPassword: true,
                      validador: (v) =>
                          (v == null || v.isEmpty) ? 'Ingresa tu contraseña.' : null,
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        final cargando = state is AuthCargando;
                        return ElevatedButton(
                          onPressed: cargando ? null : _submit,
                          child: cargando
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Iniciar sesión'),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go('/registro'),
                      child: const Text('¿No tienes cuenta? Regístrate'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
