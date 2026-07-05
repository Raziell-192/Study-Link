import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/campo_formulario.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _formKey = GlobalKey<FormState>();
  final _matriculaCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _contrasenaCtrl = TextEditingController();

  @override
  void dispose() {
    _matriculaCtrl.dispose();
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _contrasenaCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    context.read<AuthCubit>().registrar(
          matricula: _matriculaCtrl.text.trim(),
          nombreCompleto: _nombreCtrl.text.trim(),
          correo: _correoCtrl.text.trim(),
          contrasena: _contrasenaCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthRegistroExitoso) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cuenta creada. Ahora inicia sesión.')),
            );
            context.go('/login');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.mensaje)),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CampoFormulario(
                    controller: _matriculaCtrl,
                    etiqueta: 'Matrícula institucional',
                    icono: Icons.badge_outlined,
                    validador: (v) =>
                        (v == null || v.isEmpty) ? 'Ingresa tu matrícula.' : null,
                  ),
                  const SizedBox(height: 16),
                  CampoFormulario(
                    controller: _nombreCtrl,
                    etiqueta: 'Nombre completo',
                    icono: Icons.person_outline,
                    validador: (v) =>
                        (v == null || v.isEmpty) ? 'Ingresa tu nombre.' : null,
                  ),
                  const SizedBox(height: 16),
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
                    validador: (v) => (v == null || v.length < 6)
                        ? 'Mínimo 6 caracteres.'
                        : null,
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
                            : const Text('Registrarme'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
