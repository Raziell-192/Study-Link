import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/campo_formulario.dart';
import '../../../materia/presentation/cubit/materia_cubit.dart';
import '../../../materia/presentation/widgets/selector_materia.dart';
import '../cubit/apunte_cubit.dart';
import '../cubit/apunte_state.dart';

class SubirApuntePage extends StatefulWidget {
  const SubirApuntePage({super.key});

  @override
  State<SubirApuntePage> createState() => _SubirApuntePageState();
}

class _SubirApuntePageState extends State<SubirApuntePage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  String _tipoArchivo = 'PDF';
  String? _idMateriaSeleccionada;

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    _urlCtrl.dispose();
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
    context.read<ApunteCubit>().subir(
          idMateria: _idMateriaSeleccionada!,
          titulo: _tituloCtrl.text.trim(),
          descripcion: _descripcionCtrl.text.trim().isEmpty ? null : _descripcionCtrl.text.trim(),
          tipoArchivo: _tipoArchivo,
          archivoUrl: _urlCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subir apunte')),
      body: BlocListener<ApunteCubit, ApunteState>(
        listener: (context, state) {
          if (state is ApunteSubido) {
            Navigator.of(context).pop(state.apunte);
          } else if (state is ApunteError) {
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
                    value: _tipoArchivo,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de archivo',
                      prefixIcon: Icon(Icons.insert_drive_file_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'PDF', child: Text('PDF')),
                      DropdownMenuItem(value: 'Imagen', child: Text('Imagen')),
                      DropdownMenuItem(value: 'Enlace', child: Text('Enlace')),
                      DropdownMenuItem(value: 'Presentacion', child: Text('Presentación')),
                    ],
                    onChanged: (v) => setState(() => _tipoArchivo = v ?? 'PDF'),
                  ),
                  const SizedBox(height: 16),
                  CampoFormulario(
                    controller: _urlCtrl,
                    etiqueta: 'URL del archivo',
                    icono: Icons.link,
                    tipoTeclado: TextInputType.url,
                    validador: (v) => (v == null || v.isEmpty) ? 'Ingresa la URL del archivo.' : null,
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<ApunteCubit, ApunteState>(
                    builder: (context, state) {
                      final cargando = state is ApunteCargando;
                      return ElevatedButton(
                        onPressed: cargando ? null : _submit,
                        child: cargando
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Subir apunte'),
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
