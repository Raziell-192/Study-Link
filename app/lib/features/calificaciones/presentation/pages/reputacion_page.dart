import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/calificacion_cubit.dart';
import '../cubit/calificacion_state.dart';

class ReputacionPage extends StatefulWidget {
  final String idUsuario;
  const ReputacionPage({super.key, required this.idUsuario});

  @override
  State<ReputacionPage> createState() => _ReputacionPageState();
}

class _ReputacionPageState extends State<ReputacionPage> {
  @override
  void initState() {
    super.initState();
    context.read<CalificacionCubit>().cargarReputacion(widget.idUsuario);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reputación')),
      body: BlocConsumer<CalificacionCubit, CalificacionState>(
        listener: (context, state) {
          if (state is CalificacionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.mensaje)),
            );
          }
        },
        builder: (context, state) {
          if (state is CalificacionCargando) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ReputacionCargada) {
            final r = state.reputacion;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Column(
                    children: [
                      Text(r.nombreCompleto, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text('${r.reputacion} (${r.totalCalificaciones})'),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 32),
                if (r.calificaciones.isEmpty) const Text('Sin calificaciones todavía.'),
                ...r.calificaciones.map((c) => ListTile(
                      leading: const Icon(Icons.star, color: Colors.amber),
                      title: Text('${c.puntuacion}/5 · ${c.nombreTutorado ?? ''}'),
                      subtitle: Text(c.comentario ?? c.temaSesion ?? ''),
                    )),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
