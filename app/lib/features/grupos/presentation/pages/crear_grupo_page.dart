import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/campo_formulario.dart';
import '../../../materia/presentation/cubit/materia_cubit.dart';
import '../../../materia/presentation/widgets/selector_materia.dart';
import '../cubit/grupo_cubit.dart';
import '../cubit/grupo_state.dart';

class CrearGrupoPage extends StatefulWidget {
  const CrearGrupoPage({super.key});

  @override
  State<CrearGrupoPage> createState() => _CrearGrupoPageState();
}

class _CrearGrupoPageState extends State<CrearGrupoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  String? _idMateriaSeleccionada;

  @override
  void dispose() {
    _nombreCtrl.dispose();
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
    context.read<GrupoCubit>().crear(
          nombre: _nombreCtrl.text.trim(),
          descripcion: _descripcionCtrl.text.trim().isEmpty ? null : _descripcionCtrl.text.trim(),
          idMateria: _idMateriaSeleccionada!,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo grupo')),
      body: BlocListener<GrupoCubit, GrupoState>(
        listener: (context, state) {
          if (state is GrupoCreado) {
            Navigator.of(context).pop(state.grupo);
          } else if (state is GrupoError) {
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
                    controller: _nombreCtrl,
                    etiqueta: 'Nombre del grupo',
                    icono: Icons.groups_2_outlined,
                    validador: (v) => (v == null || v.isEmpty) ? 'Ingresa un nombre.' : null,
                  ),
                  const SizedBox(height: 16),
                  CampoFormulario(
                    controller: _descripcionCtrl,
                    etiqueta: 'Descripción (opcional)',
                    icono: Icons.notes_outlined,
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<GrupoCubit, GrupoState>(
                    builder: (context, state) {
                      final cargando = state is GrupoCargando;
                      return ElevatedButton(
                        onPressed: cargando ? null : _submit,
                        child: cargando
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Crear grupo'),
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
