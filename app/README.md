# StudyLink App (Flutter)

Este directorio contendrá el proyecto Flutter. Aún no está inicializado.

Para crearlo:

```bash
cd app
flutter create . --org com.studylink --project-name studylink
```

Estructura sugerida (Clean Architecture + MVVM):

```
lib/
├── main.dart
├── core/              # Constantes, temas (Material 3), utils
├── data/
│   ├── datasources/   # remote (API) y local (Isar)
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   └── usecases/
└── presentation/
    ├── viewmodels/    # BLoC/Cubit
    ├── views/         # Pantallas
    └── widgets/       # Componentes reutilizables
```
