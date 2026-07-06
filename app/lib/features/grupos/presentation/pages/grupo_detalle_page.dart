import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/grupo_cubit.dart';
import '../cubit/grupo_state.dart';

/// HU-10. Muestra miembros de un grupo y permite expulsar / cambiar rol.
/// El backend valida que solo el creador pueda hacer esas acciones; si el
/// usuario actual no lo es, simplemente recibirá un error 403 al intentar.
class GrupoDetallePage extends StatefulWidget {
  final String idGrupo;
  const GrupoDetallePage({super.key, required this.idGrupo});

  @override
  State<GrupoDetallePage> createState() => _GrupoDetallePageState();
}

class _GrupoDetallePageState extends State<GrupoDetallePage> {
  @override
  void initState() {
    super.initState();
    context.read<GrupoCubit>().listarMiembros(widget.idGrupo);
  }

  void _confirmarExpulsar(String idUsuario, String nombre) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Expulsar miembro'),
        content: Text('¿Expulsar a $nombre del grupo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<GrupoCubit>().expulsar(widget.idGrupo, idUsuario);
            },
            child: const Text('Expulsar'),
          ),
        ],
      ),
    );
  }

  void _cambiarRol(String idUsuario, String rolActual) {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Cambiar rol'),
        children: ['Organizador', 'Tutor', 'Tutorado']
            .map((r) => SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                    if (r != rolActual) {
                      context.read<GrupoCubit>().cambiarRol(widget.idGrupo, idUsuario, r);
                    }
                  },
                  child: Text(r),
                ))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Miembros del grupo')),
      body: BlocConsumer<GrupoCubit, GrupoState>(
        listener: (context, state) {
          if (state is GrupoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.mensaje)),
            );
          }
        },
        builder: (context, state) {
          if (state is GrupoCargando) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is MiembrosCargados) {
            if (state.miembros.isEmpty) {
              return const Center(child: Text('Sin miembros.'));
            }
            return ListView.builder(
              itemCount: state.miembros.length,
              itemBuilder: (context, i) {
                final m = state.miembros[i];
                return ListTile(
                  title: Text(m.nombreCompleto),
                  subtitle: Text('${m.correo} · ${m.rol}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (accion) {
                      if (accion == 'expulsar') {
                        _confirmarExpulsar(m.idUsuario, m.nombreCompleto);
                      } else if (accion == 'rol') {
                        _cambiarRol(m.idUsuario, m.rol);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'rol', child: Text('Cambiar rol')),
                      PopupMenuItem(value: 'expulsar', child: Text('Expulsar')),
                    ],
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
