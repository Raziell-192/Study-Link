import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/campo_formulario.dart';
import '../cubit/objetivo_cubit.dart';
import '../cubit/objetivo_state.dart';

class CrearObjetivoPage extends StatefulWidget {
  const CrearObjetivoPage({super.key});

  @override
  State<CrearObjetivoPage> createState() => _CrearObjetivoPageState();
}

class _CrearObjetivoPageState extends State<CrearObjetivoPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  DateTime? _fechaLimite;

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (fecha != null) setState(() => _fechaLimite = fecha);
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    context.read<ObjetivoCubit>().crear(
          titulo: _tituloCtrl.text.trim(),
          descripcion: _descripcionCtrl.text.trim().isEmpty ? null : _descripcionCtrl.text.trim(),
          fechaLimite: _fechaLimite?.toIso8601String().split('T').first,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo objetivo')),
      body: BlocListener<ObjetivoCubit, ObjetivoState>(
        listener: (context, state) {
          if (state is ObjetivoCreado) {
            Navigator.of(context).pop(state.objetivo);
          } else if (state is ObjetivoError) {
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
                    controller: _tituloCtrl,
                    etiqueta: 'Título',
                    icono: Icons.flag_outlined,
                    validador: (v) => (v == null || v.isEmpty) ? 'Ingresa un título.' : null,
                  ),
                  const SizedBox(height: 16),
                  CampoFormulario(
                    controller: _descripcionCtrl,
                    etiqueta: 'Descripción (opcional)',
                    icono: Icons.notes_outlined,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _elegirFecha,
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(
                      _fechaLimite == null
                          ? 'Fecha límite (opcional)'
                          : _fechaLimite!.toIso8601String().split('T').first,
                    ),
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<ObjetivoCubit, ObjetivoState>(
                    builder: (context, state) {
                      final cargando = state is ObjetivoCargando;
                      return ElevatedButton(
                        onPressed: cargando ? null : _submit,
                        child: cargando
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Crear objetivo'),
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
