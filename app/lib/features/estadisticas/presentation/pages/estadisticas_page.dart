import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/estadistica_cubit.dart';
import '../cubit/estadistica_state.dart';

class EstadisticasPage extends StatefulWidget {
  const EstadisticasPage({super.key});

  @override
  State<EstadisticasPage> createState() => _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage> {
  @override
  void initState() {
    super.initState();
    context.read<EstadisticaCubit>().cargar();
  }

  Widget _tarjeta(BuildContext context, IconData icono, String valor, String etiqueta) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          child: Column(
            children: [
              Icon(icono, size: 32),
              const SizedBox(height: 8),
              Text(valor, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(etiqueta, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis estadísticas')),
      body: BlocConsumer<EstadisticaCubit, EstadisticaState>(
        listener: (context, state) {
          if (state is EstadisticaError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.mensaje)),
            );
          }
        },
        builder: (context, state) {
          if (state is EstadisticaCargando || state is EstadisticaInicial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is EstadisticaCargada) {
            final e = state.estadisticas;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      _tarjeta(context, Icons.schedule, '${e.horasEstudio}h', 'Horas de estudio'),
                      const SizedBox(width: 12),
                      _tarjeta(context, Icons.event_available, '${e.sesionesCompletadas}', 'Sesiones completadas'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _tarjeta(context, Icons.school, '${e.tutoriasImpartidas}', 'Tutorías impartidas'),
                      const SizedBox(width: 12),
                      _tarjeta(context, Icons.menu_book, '${e.tutoriasRecibidas}', 'Tutorías recibidas'),
                    ],
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
