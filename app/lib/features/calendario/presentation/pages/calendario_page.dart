import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/models/evento_model.dart';
import '../cubit/evento_cubit.dart';
import '../cubit/evento_state.dart';
import 'crear_evento_page.dart';

class CalendarioPage extends StatefulWidget {
  const CalendarioPage({super.key});

  @override
  State<CalendarioPage> createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  final _formato = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    context.read<EventoCubit>().listarPropios();
  }

  Future<void> _abrirCrear() async {
    final creado = await Navigator.of(context).push<EventoModel>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<EventoCubit>(),
          child: const CrearEventoPage(),
        ),
      ),
    );
    if (creado != null) context.read<EventoCubit>().listarPropios();
  }

  void _confirmarEliminar(EventoModel e) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar evento'),
        content: Text('¿Eliminar "${e.titulo}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<EventoCubit>().eliminar(e.idEvento);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi calendario')),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirCrear,
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<EventoCubit, EventoState>(
        listener: (context, state) {
          if (state is EventoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.mensaje)),
            );
          }
        },
        builder: (context, state) {
          if (state is EventoCargando) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is EventosPropiosCargados) {
            if (state.eventos.isEmpty) {
              return const Center(child: Text('No tienes eventos.'));
            }
            return ListView.builder(
              itemCount: state.eventos.length,
              itemBuilder: (context, i) {
                final e = state.eventos[i];
                return ListTile(
                  leading: Icon(e.compartido ? Icons.groups_outlined : Icons.event_outlined),
                  title: Text(e.titulo),
                  subtitle: Text('${_formato.format(e.fechaInicio)} → ${_formato.format(e.fechaFin)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmarEliminar(e),
                  ),
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
