# PROGRESS.md — Estado del Proyecto StudyLink

> Este archivo se actualiza cada vez que se cierra una Historia de Usuario o se toma una decisión de diseño importante. Con esto tienes el contexto necesario para seguir sin repetir pasos ni contradecir decisiones ya tomadas.

**Última actualización:** HU-13 completada. Épicas 1, 2, 3 y 4 cerradas por completo. `main` y `develop` sincronizados.

---

## 1. Stack y arquitectura (decisiones ya tomadas, no reabrir sin acuerdo del equipo)

- **Backend:** Node.js + Express + **TypeScript**.
- **Base de datos:** PostgreSQL. Cliente `psql` local v16, servidor v18 (desfase conocido, no afecta a `pg`).
- **Autenticación:** JWT (7 días de expiración). Contraseñas hasheadas con `bcrypt` (10 salt rounds).
- **Patrón de capas backend:** `routes/` → `controllers/` → `models/` (queries SQL directas con `pg`, sin ORM).
- **Regla de seguridad:** el `id_usuario` autenticado **nunca** se toma del `body` — siempre sale del JWT verificado.

## 2. Estructura de carpetas actual
backend/src/
├── config/database.ts
├── db/migrations/
├── middlewares/auth.middleware.ts
├── models/          # usuario, solicitud, grupo, sesion, apunte .model.ts
├── controllers/      # auth, usuario, solicitud, grupo, sesion, apunte .controller.ts
├── routes/           # auth, usuario, solicitud, grupo, sesion, apunte .routes.ts
└── server.ts          # monta /api/auth, /api/usuarios, /api/solicitudes, /api/grupos, /api/sesiones, /api/apuntes

## 3. Migraciones SQL ejecutadas (en orden)

| # | Archivo | Tabla | Notas |
|---|---|---|---|
| 001 | `001_create_usuario.sql` | `usuario` | `contraseña` → `contrasena` (sin ñ). |
| 002 | `002_create_materia.sql` | `materia` | 3 registros de prueba (Estructura de Datos, Cálculo Diferencial, Bases de Datos). |
| 003 | `003_create_solicitud_estudio.sql` | `solicitud_estudio` | Se agregó `id_tutor` (nullable, no estaba en MER) y `titulo`. |
| 004 | `004_create_usuario_materia.sql` | `usuario_materia` | `UNIQUE(id_usuario, id_materia)`. |
| 005 | `005_create_grupo.sql` | `grupo` | Se agregó `id_materia` (nullable, no estaba en MER). |
| 006 | `006_create_miembro_grupo.sql` | `miembro_grupo` | Se agregó `fecha_union`. |
| 007 | `007_alter_miembro_grupo_rol.sql` | `miembro_grupo` (ALTER) | Se agregó `'Organizador'` al CHECK de `rol`. |
| 008 | `008_create_sesion_estudio.sql` | `sesion_estudio` | Se agregó `id_creador`. `modalidad`: Presencial/Virtual. |
| 009 | `009_create_apunte.sql` | `apunte` | Se agregó `tipo` (PDF/Imagen/Enlace/Presentacion). `etiquetas` del MER quedó fuera del MVP. |

**Para correr todas las migraciones en un ambiente nuevo, en este orden exacto:**
```bash
psql -U postgres -d studylink -f backend/src/db/migrations/001_create_usuario.sql
psql -U postgres -d studylink -f backend/src/db/migrations/002_create_materia.sql
psql -U postgres -d studylink -f backend/src/db/migrations/003_create_solicitud_estudio.sql
psql -U postgres -d studylink -f backend/src/db/migrations/004_create_usuario_materia.sql
psql -U postgres -d studylink -f backend/src/db/migrations/005_create_grupo.sql
psql -U postgres -d studylink -f backend/src/db/migrations/006_create_miembro_grupo.sql
psql -U postgres -d studylink -f backend/src/db/migrations/007_alter_miembro_grupo_rol.sql
psql -U postgres -d studylink -f backend/src/db/migrations/008_create_sesion_estudio.sql
psql -U postgres -d studylink -f backend/src/db/migrations/009_create_apunte.sql
```

## 4. Decisiones de diseño importantes

- **`id_tutor` como columna simple** en `solicitud_estudio` (no tabla intermedia): cada tutoría tiene un solo tutor según `AppMovil.md`.
- **HU-05 (Buscar Tutor)** es MVP simple: filtra `nivel_conocimiento = 'Avanzado'`, ordena por `reputacion`. No es el scoring multi-factor completo de la sección 8.
- **Crear grupo usa transacción real** (`BEGIN`/`COMMIT`/`ROLLBACK`, `pool.connect()` manual) por los 2 INSERTs relacionados.
- **Rol `'Organizador'`** agregado al ENUM de `miembro_grupo` para el creador del grupo.
- **HU-10**: solo `id_creador` expulsa/cambia roles; cualquier miembro lista. Creador no puede auto-expulsarse.
- **HU-07**: se pospuso hasta terminar Épica 3 (dependencia de `Grupo`). Solo Organizador/Tutor programan sesiones.
- **HU-11 es MVP sin Firebase Storage real**: recibe `archivo_url` como string, no el binario. Conectar Firebase después solo cambia el paso previo.
- **`tipo` en `apunte`** (PDF/Imagen/Enlace/Presentacion) agregado, no estaba en el MER. `etiquetas` quedó fuera del MVP.

## 5. Historias de Usuario completadas

| HU | Descripción | Endpoint(s) |
|---|---|---|
| HU-01 | Registro de Usuario | `POST /api/auth/registro` |
| HU-02 | Inicio de Sesión | `POST /api/auth/login` |
| HU-03 | Gestión de Perfil | `GET/PUT /api/usuarios/perfil` |
| HU-04 | Crear Solicitud | `POST /api/solicitudes`, `GET /api/solicitudes/materia/:id_materia` |
| HU-05 | Buscar Tutor | `GET /api/usuarios/tutores/:id_materia` |
| HU-06 | Aceptar Tutoría | `PATCH /api/solicitudes/:id_solicitud/aceptar` |
| HU-07 | Programar Sesión | `POST /api/sesiones`, `GET /api/sesiones/grupo/:id_grupo` |
| HU-08 | Crear Grupo | `POST /api/grupos` |
| HU-09 | Unirse a Grupo | `POST /api/grupos/:id_grupo/unirse` |
| HU-10 | Gestionar Miembros | `GET/DELETE/PATCH /api/grupos/:id_grupo/miembros/...` |
| HU-11 | Subir Apuntes | `POST /api/apuntes` |
| HU-12 | Consultar Biblioteca | `GET /api/apuntes/materia/:id_materia` |
| HU-13 | Descargar Recursos | `GET /api/apuntes/:id_apunte/descargar` |

**Épicas 1, 2, 3 y 4: completas.**

## 6. Siguiente paso pendiente

Elegir la siguiente épica. Candidatas:
- **Épica 5: Flashcards y Cuestionarios** (HU-14 a HU-17).
- **Épica 6: Calendario y Organización** (HU-18 a HU-20).
- **Épica 9: Evaluación y Reputación** (HU-26, HU-27).

Sin decisión tomada aún — preguntar al retomar.

**Pendiente técnico:** conectar Firebase Storage real para reemplazar el MVP de `archivo_url`.

## 7. Pendientes técnicos

- Desfase `psql` 16 vs servidor 18 — no afecta al backend.
- `JWT_SECRET` es un valor simple (`CETI`) — cambiar antes de producción.
- Sin runner de migraciones automático.
- Sin tests automatizados.

## 8. Cómo levantar el proyecto desde cero

```bash
cd backend
npm install
cp .env.example .env
psql -U postgres -c "CREATE DATABASE studylink;"
# correr las 9 migraciones de la sección 3, en orden
npm run dev
```
Servidor en `http://localhost:3000`. Probar con `curl http://localhost:3000/health`.