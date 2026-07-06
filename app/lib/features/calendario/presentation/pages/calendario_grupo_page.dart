import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/evento_cubit.dart';
import '../cubit/evento_state.dart';

/// HU-19: línea de tiempo combinada de eventos compartidos + sesiones de estudio.
class CalendarioGrupoPage extends StatefulWidget {
  final String idGrupo;
  const CalendarioGrupoPage({super.key, required this.idGrupo});

  @override
  State<CalendarioGrupoPage> createState() => _CalendarioGrupoPageState();
}

class _CalendarioGrupoPageState extends State<CalendarioGrupoPage> {
  final _formato = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    context.read<EventoCubit>().listarPorGrupo(widget.idGrupo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendario del grupo')),
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
          if (state is CalendarioGrupoCargado) {
            if (state.items.isEmpty) {
              return const Center(child: Text('Sin eventos ni sesiones programadas.'));
            }
            return ListView.builder(
              itemCount: state.items.length,
              itemBuilder: (context, i) {
                final item = state.items[i];
                final esSesion = item.origen == 'sesion';
                return ListTile(
                  leading: Icon(esSesion ? Icons.school_outlined : Icons.event_outlined),
                  title: Text(item.titulo),
                  subtitle: Text(
                    '${esSesion ? 'Sesión de estudio' : 'Evento'} · '
                    '${_formato.format(item.fechaInicio)} → ${_formato.format(item.fechaFin)}',
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
