import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/campo_formulario.dart';
import '../cubit/evento_cubit.dart';
import '../cubit/evento_state.dart';

class CrearEventoPage extends StatefulWidget {
  const CrearEventoPage({super.key});

  @override
  State<CrearEventoPage> createState() => _CrearEventoPageState();
}

class _CrearEventoPageState extends State<CrearEventoPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _idGrupoCtrl = TextEditingController();
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  bool _compartido = false;

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    _idGrupoCtrl.dispose();
    super.dispose();
  }

  Future<DateTime?> _elegirFechaHora(DateTime? inicial) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: inicial ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (fecha == null || !mounted) return null;
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(inicial ?? DateTime.now()),
    );
    if (hora == null) return null;
    return DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    if (_fechaInicio == null || _fechaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona fecha de inicio y fin.')),
      );
      return;
    }
    if (!_fechaFin!.isAfter(_fechaInicio!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La fecha de fin debe ser posterior al inicio.')),
      );
      return;
    }
    if (_compartido && _idGrupoCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el id del grupo para compartir el evento.')),
      );
      return;
    }
    context.read<EventoCubit>().crear(
          titulo: _tituloCtrl.text.trim(),
          descripcion: _descripcionCtrl.text.trim().isEmpty ? null : _descripcionCtrl.text.trim(),
          fechaInicio: _fechaInicio!,
          fechaFin: _fechaFin!,
          idGrupo: _compartido ? _idGrupoCtrl.text.trim() : null,
          compartido: _compartido,
        );
  }

  String _formatear(DateTime? d) => d == null ? 'Seleccionar' : d.toString().substring(0, 16);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo evento')),
      body: BlocListener<EventoCubit, EventoState>(
        listener: (context, state) {
          if (state is EventoCreado) {
            Navigator.of(context).pop(state.evento);
          } else if (state is EventoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.mensaje)),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CampoFormulario(
                    controller: _tituloCtrl,
                    etiqueta: 'Título',
                    icono: Icons.event_outlined,
                    validador: (v) => (v == null || v.isEmpty) ? 'Ingresa un título.' : null,
                  ),
                  const SizedBox(height: 16),
                  CampoFormulario(
                    controller: _descripcionCtrl,
                    etiqueta: 'Descripción (opcional)',
                    icono: Icons.notes_outlined,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final f = await _elegirFechaHora(_fechaInicio);
                      if (f != null) setState(() => _fechaInicio = f);
                    },
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text('Inicio: ${_formatear(_fechaInicio)}'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final f = await _elegirFechaHora(_fechaFin);
                      if (f != null) setState(() => _fechaFin = f);
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text('Fin: ${_formatear(_fechaFin)}'),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Compartir con un grupo'),
                    value: _compartido,
                    onChanged: (v) => setState(() => _compartido = v),
                  ),
                  if (_compartido) ...[
                    const SizedBox(height: 8),
                    CampoFormulario(
                      controller: _idGrupoCtrl,
                      etiqueta: 'ID del grupo',
                      icono: Icons.groups_outlined,
                    ),
                  ],
                  const SizedBox(height: 24),
                  BlocBuilder<EventoCubit, EventoState>(
                    builder: (context, state) {
                      final cargando = state is EventoCargando;
                      return ElevatedButton(
                        onPressed: cargando ? null : _submit,
                        child: cargando
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Crear evento'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
