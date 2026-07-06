import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/logro_cubit.dart';
import '../cubit/logro_state.dart';

class LogrosPage extends StatefulWidget {
  const LogrosPage({super.key});

  @override
  State<LogrosPage> createState() => _LogrosPageState();
}

class _LogrosPageState extends State<LogrosPage> {
  @override
  void initState() {
    super.initState();
    context.read<LogroCubit>().cargarMisLogros();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis logros')),
      body: BlocConsumer<LogroCubit, LogroState>(
        listener: (context, state) {
          if (state is LogroError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.mensaje)),
            );
          } else if (state is LogroListaCargada && state.nuevos.isNotEmpty) {
            for (final n in state.nuevos) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('¡Nuevo logro desbloqueado! ${n.nombre}')),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is LogroCargando || state is LogroInicial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LogroListaCargada) {
            if (state.logros.isEmpty) {
              return const Center(child: Text('No hay logros en el catálogo.'));
            }
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: state.logros.length,
              itemBuilder: (context, i) {
                final l = state.logros[i];
                return Opacity(
                  opacity: l.obtenido ? 1.0 : 0.35,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            l.obtenido ? Icons.emoji_events : Icons.lock_outline,
                            size: 40,
                            color: l.obtenido ? Colors.amber[700] : Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l.nombre,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          if (l.descripcion != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              l.descripcion!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
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
