import 'package:flutter/material.dart';

class CampoFormulario extends StatelessWidget {
  final TextEditingController controller;
  final String etiqueta;
  final IconData icono;
  final bool esPassword;
  final TextInputType? tipoTeclado;
  final String? Function(String?)? validador;

  const CampoFormulario({
    super.key,
    required this.controller,
    required this.etiqueta,
    required this.icono,
    this.esPassword = false,
    this.tipoTeclado,
    this.validador,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: esPassword,
      keyboardType: tipoTeclado,
      validator: validador,
      decoration: InputDecoration(
        labelText: etiqueta,
        prefixIcon: Icon(icono),
      ),
    );
  }
}
