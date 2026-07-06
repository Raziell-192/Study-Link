import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/materia_model.dart';
import '../cubit/materia_cubit.dart';
import '../cubit/materia_state.dart';

/// Dropdown reutilizable de materias. Carga la lista al montarse.
/// onSeleccion entrega la MateriaModel completa (id + nombre).
class SelectorMateria extends StatefulWidget {
  final void Function(MateriaModel) onSeleccion;
  final String etiqueta;

  const SelectorMateria({
    super.key,
    required this.onSeleccion,
    this.etiqueta = 'Materia',
  });

  @override
  State<SelectorMateria> createState() => _SelectorMateriaState();
}

class _SelectorMateriaState extends State<SelectorMateria> {
  MateriaModel? _seleccionada;

  @override
  void initState() {
    super.initState();
    context.read<MateriaCubit>().listar();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MateriaCubit, MateriaState>(
      builder: (context, state) {
        if (state is MateriaCargando || state is MateriaInicial) {
          return const LinearProgressIndicator();
        }
        if (state is MateriaError) {
          return Text(state.mensaje, style: const TextStyle(color: Colors.red));
        }
        if (state is MateriaListaCargada) {
          if (state.materias.isEmpty) {
            return const Text('No hay materias registradas.');
          }
          return DropdownButtonFormField<MateriaModel>(
            value: _seleccionada,
            decoration: InputDecoration(
              labelText: widget.etiqueta,
              prefixIcon: const Icon(Icons.menu_book_outlined),
            ),
            items: state.materias
                .map((m) => DropdownMenuItem(value: m, child: Text(m.nombre)))
                .toList(),
            onChanged: (m) {
              if (m == null) return;
              setState(() => _seleccionada = m);
              widget.onSeleccion(m);
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
