# StudyLink 

Plataforma móvil de aprendizaje colaborativo universitario. Conecta estudiantes para tutorías, grupos de estudio, biblioteca de apuntes, flashcards, cuestionarios, calendario y seguimiento de progreso académico — con soporte offline.

##  Estructura del repositorio

```
studylink/
├── app/                # Frontend Flutter (Android/iOS)
├── backend/            # API REST Node.js + Express
│   └── src/
├── docs/               # Documentación funcional del proyecto
│   ├── AppMovil.md               # Descripción general, objetivos, RF/RNF, stack
│   ├── DiagramaCasosDeUso.md     # Diagrama de casos de uso (Mermaid)
│   ├── HistoriasDeUsuario.md     # Historias de usuario (13 épicas)
│   └── ModeloEntidadRelacion.md  # Modelo Entidad-Relación
├── .github/
│   └── ISSUE_TEMPLATE/  # Plantillas para issues de historias de usuario
└── README.md
```

##  Stack Tecnológico

| Capa | Tecnología |
|---|---|
| Frontend | Flutter & Dart |
| Backend | Node.js + Express (REST API / JSON) |
| BD remota | PostgreSQL |
| BD local (offline) | Isar Database |
| Almacenamiento | Firebase Storage |
| Notificaciones | Firebase Cloud Messaging |
| Arquitectura | MVVM + Clean Architecture (Repository Pattern con fallback online/offline) |

##  Cómo empezar

### Backend
```bash
cd backend
npm install
npm run dev
```

### App móvil
```bash
cd app
flutter pub get
flutter run
```

## Documentación funcional

Toda la documentación del proyecto (requisitos, casos de uso, historias de usuario y modelo de datos) vive en [`docs/`](./docs).
