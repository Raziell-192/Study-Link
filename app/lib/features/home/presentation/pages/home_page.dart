import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

/// Placeholder de HU-03 (panel principal). Cada módulo siguiente (Épica 2 en
/// adelante) cuelga su entrada de navegación aquí.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StudyLink'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().logout(),
          ),
        ],
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is! AuthAutenticado) {
            return const SizedBox.shrink();
          }
          final usuario = state.usuario;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hola, ${usuario.nombreCompleto}',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(usuario.matricula, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),
                const Text('Próximos módulos: solicitudes, grupos, biblioteca, '
                    'flashcards, calendario, chat, objetivos, calificaciones, '
                    'asistencia, logros.'),
              ],
            ),
          );
        },
      ),
    );
  }
}
