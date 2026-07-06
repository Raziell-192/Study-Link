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
                // TODO: reemplazar id fijo por selector real cuando exista módulo Materia.
                ElevatedButton.icon(
                  onPressed: () => context.push('/solicitudes/00000000-0000-0000-0000-000000000000'),
                  icon: const Icon(Icons.assignment_outlined),
                  label: const Text('Ver solicitudes de estudio'),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => context.push('/grupos/crear'),
                  icon: const Icon(Icons.group_add_outlined),
                  label: const Text('Crear grupo'),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => context.push('/grupos/unirse'),
                  icon: const Icon(Icons.login),
                  label: const Text('Unirme a un grupo'),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => context.push('/biblioteca/00000000-0000-0000-0000-000000000000'),
                  icon: const Icon(Icons.library_books_outlined),
                  label: const Text('Biblioteca de apuntes'),
                ),
                const SizedBox(height: 16),
                const Text('Próximos módulos: biblioteca, '
                    'flashcards, calendario, chat, objetivos, calificaciones, '
                    'asistencia, logros.'
                ),
                const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/estadisticas'),
                    icon: const Icon(Icons.bar_chart_outlined),
                    label: const Text('Mis estadísticas'),
                  ),
                const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/logros'),
                    icon: const Icon(Icons.emoji_events_outlined),
                    label: const Text('Mis logros'),
                  ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => context.push('/objetivos'),
                  icon: const Icon(Icons.flag_outlined),
                  label: const Text('Mis objetivos'),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => context.push('/calificar'),
                  icon: const Icon(Icons.star_outline),
                  label: const Text('Calificar tutor'),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => context.push('/calendario'),
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: const Text('Mi calendario'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}