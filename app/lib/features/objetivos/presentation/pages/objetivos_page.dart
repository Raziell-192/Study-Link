import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/objetivo_model.dart';
import '../cubit/objetivo_cubit.dart';
import '../cubit/objetivo_state.dart';
import 'crear_objetivo_page.dart';

class ObjetivosPage extends StatefulWidget {
  const ObjetivosPage({super.key});

  @override
  State<ObjetivosPage> createState() => _ObjetivosPageState();
}

class _ObjetivosPageState extends State<ObjetivosPage> {
  @override
  void initState() {
    super.initState();
    context.read<ObjetivoCubit>().listarMios();
  }

  Future<void> _abrirCrear() async {
    final creado = await Navigator.of(context).push<ObjetivoModel>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ObjetivoCubit>(),
          child: const CrearObjetivoPage(),
        ),
      ),
    );
    if (creado != null) context.read<ObjetivoCubit>().listarMios();
  }

  void _editarProgreso(ObjetivoModel o) {
    var valor = o.progreso.toDouble();
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(o.titulo),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${valor.round()}%'),
              Slider(
                value: valor,
                min: 0,
                max: 100,
                divisions: 20,
                label: '${valor.round()}%',
                onChanged: (v) => setStateDialog(() => valor = v),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<ObjetivoCubit>().actualizarProgreso(o.idObjetivo, valor.round());
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Completado':
        return Colors.green;
      case 'En progreso':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis objetivos')),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirCrear,
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<ObjetivoCubit, ObjetivoState>(
        listener: (context, state) {
          if (state is ObjetivoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.mensaje)),
            );
          }
        },
        builder: (context, state) {
          if (state is ObjetivoCargando) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ObjetivoListaCargada) {
            if (state.objetivos.isEmpty) {
              return const Center(child: Text('No tienes objetivos aún.'));
            }
            return ListView.builder(
              itemCount: state.objetivos.length,
              itemBuilder: (context, i) {
                final o = state.objetivos[i];
                return ListTile(
                  title: Text(o.titulo),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(o.estado, style: TextStyle(color: _colorEstado(o.estado))),
                      LinearProgressIndicator(value: o.progreso / 100),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _editarProgreso(o),
                  ),
                  isThreeLine: true,
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
