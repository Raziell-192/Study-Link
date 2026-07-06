import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/campo_formulario.dart';
import '../cubit/calificacion_cubit.dart';
import '../cubit/calificacion_state.dart';

/// HU-26. No existe aún módulo de sesiones/UI para seleccionarlas, así que
/// por ahora se ingresan los IDs a mano (mismo criterio provisional que
/// "unirse a grupo"). Reemplazar por selector real cuando exista el módulo Sesión.
class CalificarPage extends StatefulWidget {
  const CalificarPage({super.key});

  @override
  State<CalificarPage> createState() => _CalificarPageState();
}

class _CalificarPageState extends State<CalificarPage> {
  final _formKey = GlobalKey<FormState>();
  final _idSesionCtrl = TextEditingController();
  final _idTutorCtrl = TextEditingController();
  final _comentarioCtrl = TextEditingController();
  int _puntuacion = 5;

  @override
  void dispose() {
    _idSesionCtrl.dispose();
    _idTutorCtrl.dispose();
    _comentarioCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    context.read<CalificacionCubit>().calificar(
          idSesion: _idSesionCtrl.text.trim(),
          idTutor: _idTutorCtrl.text.trim(),
          puntuacion: _puntuacion,
          comentario: _comentarioCtrl.text.trim().isEmpty ? null : _comentarioCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calificar tutor')),
      body: BlocListener<CalificacionCubit, CalificacionState>(
        listener: (context, state) {
          if (state is CalificacionEnviada) {
            Navigator.of(context).pop(state.calificacion);
          } else if (state is CalificacionError) {
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
                    controller: _idSesionCtrl,
                    etiqueta: 'ID de sesión',
                    icono: Icons.event_note_outlined,
                    validador: (v) => (v == null || v.isEmpty) ? 'Ingresa el id de la sesión.' : null,
                  ),
                  const SizedBox(height: 16),
                  CampoFormulario(
                    controller: _idTutorCtrl,
                    etiqueta: 'ID del tutor',
                    icono: Icons.person_outline,
                    validador: (v) => (v == null || v.isEmpty) ? 'Ingresa el id del tutor.' : null,
                  ),
                  const SizedBox(height: 16),
                  Text('Puntuación', style: Theme.of(context).textTheme.titleSmall),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final valor = i + 1;
                      return IconButton(
                        icon: Icon(
                          valor <= _puntuacion ? Icons.star : Icons.star_border,
                          color: Colors.amber[700],
                        ),
                        onPressed: () => setState(() => _puntuacion = valor),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  CampoFormulario(
                    controller: _comentarioCtrl,
                    etiqueta: 'Comentario (opcional)',
                    icono: Icons.comment_outlined,
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<CalificacionCubit, CalificacionState>(
                    builder: (context, state) {
                      final cargando = state is CalificacionCargando;
                      return ElevatedButton(
                        onPressed: cargando ? null : _submit,
                        child: cargando
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Enviar calificación'),
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
