import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/campo_formulario.dart';
import '../cubit/grupo_cubit.dart';
import '../cubit/grupo_state.dart';

class UnirseGrupoPage extends StatefulWidget {
  const UnirseGrupoPage({super.key});

  @override
  State<UnirseGrupoPage> createState() => _UnirseGrupoPageState();
}

class _UnirseGrupoPageState extends State<UnirseGrupoPage> {
  final _formKey = GlobalKey<FormState>();
  final _idGrupoCtrl = TextEditingController();

  @override
  void dispose() {
    _idGrupoCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    context.read<GrupoCubit>().unirse(_idGrupoCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unirme a un grupo')),
      body: BlocListener<GrupoCubit, GrupoState>(
        listener: (context, state) {
          if (state is GrupoUnido) {
            Navigator.of(context).pop(_idGrupoCtrl.text.trim());
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
                  // TODO: reemplazar por búsqueda/lista de grupos cuando exista ese endpoint.
                  CampoFormulario(
                    controller: _idGrupoCtrl,
                    etiqueta: 'ID del grupo',
                    icono: Icons.groups_outlined,
                    validador: (v) => (v == null || v.isEmpty) ? 'Ingresa el id del grupo.' : null,
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
                            : const Text('Unirme'),
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
