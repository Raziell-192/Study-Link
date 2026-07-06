import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/campo_formulario.dart';
import '../../../materia/presentation/cubit/materia_cubit.dart';
import '../../../materia/presentation/widgets/selector_materia.dart';
import '../cubit/solicitud_cubit.dart';
import '../cubit/solicitud_state.dart';

class CrearSolicitudPage extends StatefulWidget {
  const CrearSolicitudPage({super.key});

  @override
  State<CrearSolicitudPage> createState() => _CrearSolicitudPageState();
}

class _CrearSolicitudPageState extends State<CrearSolicitudPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  String _modalidad = 'Individual';
  String? _idMateriaSeleccionada;

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    if (_idMateriaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una materia.')),
      );
      return;
    }
    context.read<SolicitudCubit>().crear(
          idMateria: _idMateriaSeleccionada!,
          titulo: _tituloCtrl.text.trim(),
          descripcion: _descripcionCtrl.text.trim().isEmpty ? null : _descripcionCtrl.text.trim(),
          modalidad: _modalidad,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva solicitud')),
      body: BlocListener<SolicitudCubit, SolicitudState>(
        listener: (context, state) {
          if (state is SolicitudCreada) {
            Navigator.of(context).pop(state.solicitud);
          } else if (state is SolicitudError) {
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
                  BlocProvider(
                    create: (_) => MateriaCubit(context.read()),
                    child: SelectorMateria(
                      onSeleccion: (m) => setState(() => _idMateriaSeleccionada = m.idMateria),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CampoFormulario(
                    controller: _tituloCtrl,
                    etiqueta: 'Título',
                    icono: Icons.title,
                    validador: (v) => (v == null || v.isEmpty) ? 'Ingresa un título.' : null,
                  ),
                  const SizedBox(height: 16),
                  CampoFormulario(
                    controller: _descripcionCtrl,
                    etiqueta: 'Descripción (opcional)',
                    icono: Icons.notes_outlined,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _modalidad,
                    decoration: const InputDecoration(
                      labelText: 'Modalidad',
                      prefixIcon: Icon(Icons.groups_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Individual', child: Text('Individual')),
                      DropdownMenuItem(value: 'Grupal', child: Text('Grupal')),
                    ],
                    onChanged: (v) => setState(() => _modalidad = v ?? 'Individual'),
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<SolicitudCubit, SolicitudState>(
                    builder: (context, state) {
                      final cargando = state is SolicitudCargando;
                      return ElevatedButton(
                        onPressed: cargando ? null : _submit,
                        child: cargando
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Crear solicitud'),
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
