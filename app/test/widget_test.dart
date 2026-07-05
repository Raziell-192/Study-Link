import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// 1. Asegúrate de que este import apunte correctamente a tu main.dart
// Si te da error, puedes probar con: import '../lib/main.dart';
import 'package:studylink/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // 2. Cambiado de MyApp() a StudyLinkApp()
    await tester.pumpWidget(const StudyLinkApp());

    // Nota: Como StudyLinkApp usa GoRouter (routerConfig),
    // es posible que el test del contador falle si tu pantalla inicial
    // no tiene un botón de suma o un texto con '0'.
    // ¡Pero el error de "MyApp no es una clase" ya quedará resuelto!
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}