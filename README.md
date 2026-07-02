# StudyLink 📚

Plataforma móvil de aprendizaje colaborativo universitario. Conecta estudiantes para tutorías, grupos de estudio, biblioteca de apuntes, flashcards, cuestionarios, calendario y seguimiento de progreso académico — con soporte offline.

## 📂 Estructura del repositorio

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

## 🛠️ Stack Tecnológico

| Capa | Tecnología |
|---|---|
| Frontend | Flutter & Dart |
| Backend | Node.js + Express (REST API / JSON) |
| BD remota | PostgreSQL |
| BD local (offline) | Isar Database |
| Almacenamiento | Firebase Storage |
| Notificaciones | Firebase Cloud Messaging |
| Arquitectura | MVVM + Clean Architecture (Repository Pattern con fallback online/offline) |

## 🚀 Cómo empezar

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

## 🌿 Estrategia de ramas (Git Flow simplificado)

- `main` → versión estable / releases.
- `develop` → integración de features en desarrollo.
- `feature/HU-XX-nombre-corto` → una rama por historia de usuario (ver `docs/HistoriasDeUsuario.md`).
- `fix/nombre-del-bug` → correcciones puntuales.

Ejemplo: para la historia **HU-04 Crear Solicitud de Estudio**, la rama sería:
```
feature/HU-04-crear-solicitud-estudio
```

## 📋 Flujo de trabajo sugerido

1. Crea un Issue en GitHub por cada Historia de Usuario (usa la plantilla en `.github/ISSUE_TEMPLATE/`).
2. Crea una rama `feature/HU-XX-...` desde `develop`.
3. Trabaja, haz commits pequeños y descriptivos (ver convención abajo).
4. Abre un Pull Request hacia `develop` referenciando el issue (`Closes #12`).
5. Revisión de código → merge → siguiente historia.

### Convención de commits (Conventional Commits)
```
feat(auth): agregar registro con matrícula institucional
fix(calendario): corregir zona horaria en eventos compartidos
docs(readme): actualizar instrucciones de instalación
chore(backend): configurar eslint y prettier
```

## 📖 Documentación funcional

Toda la documentación del proyecto (requisitos, casos de uso, historias de usuario y modelo de datos) vive en [`docs/`](./docs).

## 📄 Licencia

Pendiente de definir (MIT sugerido para proyectos académicos).
