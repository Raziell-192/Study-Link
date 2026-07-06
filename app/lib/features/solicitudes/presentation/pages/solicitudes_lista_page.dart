import 'package:flutter/material.dart';

class SolicitudesListaPage extends StatelessWidget {
  // 1. Declaramos la variable para recibir el ID
  final String idMateria;

  // 2. La agregamos como un parámetro nombrado requerido en el constructor
  const SolicitudesListaPage({
    super.key, 
    required this.idMateria,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Solicitudes'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Aquí se mostrarán las solicitudes próximamente.'),
            const SizedBox(height: 10),
            // Mostramos el ID en pantalla para verificar que llega bien
            Text(
              'ID de la Materia: $idMateria', 
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}