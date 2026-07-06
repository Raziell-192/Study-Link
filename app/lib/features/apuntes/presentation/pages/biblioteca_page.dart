import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/apunte_model.dart';
import '../cubit/apunte_cubit.dart';
import '../cubit/apunte_state.dart';
import 'subir_apunte_page.dart';

class BibliotecaPage extends StatefulWidget {
  final String idMateria;
  const BibliotecaPage({super.key, required this.idMateria});

  @override
  State<BibliotecaPage> createState() => _BibliotecaPageState();
}

class _BibliotecaPageState extends State<BibliotecaPage> {
  final _busquedaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ApunteCubit>().listarPorMateria(widget.idMateria);
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  void _buscar() {
    final q = _busquedaCtrl.text.trim();
    if (q.isEmpty) {
      context.read<ApunteCubit>().listarPorMateria(widget.idMateria);
    } else {
      context.read<ApunteCubit>().buscar(q, idMateria: widget.idMateria);
    }
  }

  Future<void> _descargar(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el archivo.')),
        );
      }
    }
  }

  void _confirmarEliminar(ApunteModel a) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar apunte'),
        content: Text('¿Eliminar "${a.titulo}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ApunteCubit>().eliminar(a.idApunte, widget.idMateria);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _abrirSubir() async {
    final subido = await Navigator.of(context).push<ApunteModel>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ApunteCubit>(),
          child: const SubirApuntePage(),
        ),
      ),
    );
    if (subido != null) {
      context.read<ApunteCubit>().listarPorMateria(widget.idMateria);
    }
  }

  IconData _iconoPorTipo(String tipo) {
    switch (tipo) {
      case 'PDF':
        return Icons.picture_as_pdf_outlined;
      case 'Imagen':
        return Icons.image_outlined;
      case 'Presentacion':
        return Icons.slideshow_outlined;
      default:
        return Icons.link;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biblioteca')),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirSubir,
        child: const Icon(Icons.upload_file_outlined),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _busquedaCtrl,
              decoration: InputDecoration(
                labelText: 'Buscar por título',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _buscar,
                ),
              ),
              onSubmitted: (_) => _buscar(),
            ),
          ),
          Expanded(
            child: BlocConsumer<ApunteCubit, ApunteState>(
              listener: (context, state) {
                if (state is ApunteError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.mensaje)),
                  );
                }
              },
              builder: (context, state) {
                if (state is ApunteCargando) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ApunteListaCargada) {
                  if (state.apuntes.isEmpty) {
                    return const Center(child: Text('No hay apuntes.'));
                  }
                  return ListView.builder(
                    itemCount: state.apuntes.length,
                    itemBuilder: (context, i) {
                      final a = state.apuntes[i];
                      return ListTile(
                        leading: Icon(_iconoPorTipo(a.tipoArchivo)),
                        title: Text(a.titulo),
                        subtitle: Text(a.descripcion ?? a.tipoArchivo),
                        trailing: PopupMenuButton<String>(
                          onSelected: (accion) {
                            if (accion == 'descargar') _descargar(a.archivoUrl);
                            if (accion == 'eliminar') _confirmarEliminar(a);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'descargar', child: Text('Descargar')),
                            PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                          ],
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
