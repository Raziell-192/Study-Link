# PROGRESS.md — Estado del Proyecto StudyLink

> Este archivo se actualiza cada vez que se cierra una Historia de Usuario o se toma una decisión de diseño importante. Con esto tienes el contexto necesario para seguir sin repetir pasos ni contradecir decisiones ya tomadas.

**Última actualización:** HU-07 completada. Épica 2 (Solicitudes y Tutorías) y Épica 3 (Grupos de Estudio) cerradas por completo.
---

## 1. Stack y arquitectura (decisiones ya tomadas, no reabrir sin acuerdo del equipo)

- **Backend:** Node.js + Express + **TypeScript** (se decidió TS sobre JS plano por consistencia de tipos con Dart/Flutter y por el tamaño del proyecto).
- **Base de datos:** PostgreSQL. Cliente `psql` local es v16, servidor es v18 (desfase conocido, no afecta a la librería `pg` de Node — ver sección "Pendientes").
- **Autenticación:** JWT (`jsonwebtoken`) con expiración de 7 días. Contraseñas hasheadas con `bcrypt` (10 salt rounds).
- **Patrón de capas backend:** `routes/` → `controllers/` → `models/` (queries SQL directas con `pg`, sin ORM).
- **Regla de seguridad aplicada en todo el backend:** el `id_usuario` de la persona autenticada **nunca** se toma del `body` de la petición — siempre sale del JWT verificado (`req.usuario.id_usuario` vía middleware). Ningún endpoint debe romper esta regla.

## 2. Estructura de carpetas actual

backend/src/
├── config/database.ts          # Pool de conexión a PostgreSQL
├── db/migrations/               # Scripts SQL, uno por tabla, numerados en orden de ejecución
├── middlewares/auth.middleware.ts  # verificarToken — protege rutas, llena req.usuario
├── models/                      # usuario.model.ts, solicitud.model.ts, grupo.model.ts, sesion.model.ts
├── controllers/                 # auth, usuario, solicitud, grupo, sesion .controller.ts
├── routes/                      # auth, usuario, solicitud, grupo, sesion .routes.ts
└── server.ts                    # entry point, monta /api/auth, /api/usuarios, /api/solicitudes, /api/grupos, /api/sesiones

## 3. Migraciones SQL ejecutadas (en orden)

| # | Archivo | Tabla | Notas |
|---|---|---|---|
| 001 | `001_create_usuario.sql` | `usuario` | Columna `contraseña` del MER se renombró a `contrasena` (sin ñ) para evitar comillas en cada query. |
| 002 | `002_create_materia.sql` | `materia` | 3 registros de prueba insertados manualmente (Estructura de Datos, Cálculo Diferencial, Bases de Datos). |
| 003 | `003_create_solicitud_estudio.sql` | `solicitud_estudio` | Se agregó columna `id_tutor` (nullable, FK a usuario) que **no estaba en el MER original**. También se agregó `titulo` (no estaba en el MER, pero sí en las HU/AppMovil.md). |
| 004 | `004_create_usuario_materia.sql` | `usuario_materia` | Constraint `UNIQUE(id_usuario, id_materia)` para evitar duplicados. |
| 005 | `005_create_grupo.sql` | `grupo` | Se agregó `id_materia` (nullable, no estaba en el MER) porque HU-08 exige materia asociada. |
| 006 | `006_create_miembro_grupo.sql` | `miembro_grupo` | Se agregó `fecha_union` (no estaba en el MER). `rol` inicialmente solo aceptaba Tutor/Tutorado. |
| 007 | `007_alter_miembro_grupo_rol.sql` | `miembro_grupo` (ALTER) | Se agregó el valor `'Organizador'` al CHECK de `rol`, para el creador del grupo. |
| 008 | `008_create_sesion_estudio.sql` | `sesion_estudio` | Se agregó `id_creador` (no estaba en el MER). `modalidad` definida como `'Presencial'`/`'Virtual'`. CHECK `fecha_fin > fecha_inicio`. |

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
```
(Aún no tenemos un runner automático de migraciones — está en pendientes.)

## 4. Decisiones de diseño importantes (con su justificación)

- **`id_tutor` como columna simple en `solicitud_estudio`** (en vez de tabla intermedia `solicitud_tutor`): se eligió la opción simple porque `AppMovil.md` especifica que cada tutoría (individual o grupal) tiene un solo tutor.
- **HU-05 (Buscar Tutor) implementado como MVP simple**: filtra usuarios con `nivel_conocimiento = 'Avanzado'` en `usuario_materia` para la materia dada, ordenados por `reputacion DESC`. No es el sistema de scoring multi-factor completo que describe la sección 8 de `AppMovil.md` — eso queda como mejora futura.
- **Crear grupo usa transacción real** (`BEGIN`/`COMMIT`/`ROLLBACK`) porque implica 2 INSERTs relacionados (grupo + creador como miembro). Es el único lugar del código que usa `pool.connect()` manual en vez de `pool.query()` directo.
- **Rol `'Organizador'` agregado al ENUM de `miembro_grupo`** (migración 007): el creador de un grupo no encaja como "Tutor" ni "Tutorado".
- **HU-10 (Gestionar Miembros)**: solo el `id_creador` del grupo puede expulsar o cambiar roles; cualquier miembro puede listar. El creador no puede expulsarse a sí mismo.
- **HU-07 (Programar Sesión)**: `Sesion_Estudio` depende de `Grupo`, se pospuso hasta terminar la Épica 3, respetando el MER tal cual. Solo `Organizador` o `Tutor` del grupo pueden programar sesiones, un `Tutorado` no puede.

## 5. Historias de Usuario completadas

| HU | Descripción | Endpoint(s) |
|---|---|---|
| HU-01 | Registro de Usuario | `POST /api/auth/registro` |
| HU-02 | Inicio de Sesión | `POST /api/auth/login` |
| HU-03 | Gestión de Perfil | `GET /api/usuarios/perfil`, `PUT /api/usuarios/perfil` |
| HU-04 | Crear Solicitud de Estudio | `POST /api/solicitudes`, `GET /api/solicitudes/materia/:id_materia` |
| HU-05 | Buscar Tutor | `GET /api/usuarios/tutores/:id_materia` |
| HU-06 | Aceptar Tutoría | `PATCH /api/solicitudes/:id_solicitud/aceptar` |
| HU-07 | Programar Sesión | `POST /api/sesiones`, `GET /api/sesiones/grupo/:id_grupo` |
| HU-08 | Crear Grupo | `POST /api/grupos` |
| HU-09 | Unirse a Grupo | `POST /api/grupos/:id_grupo/unirse` |
| HU-10 | Gestionar Miembros | `GET /api/grupos/:id_grupo/miembros`, `DELETE /api/grupos/:id_grupo/miembros/:id_usuario`, `PATCH /api/grupos/:id_grupo/miembros/:id_usuario/rol` |

**Épica 1 (Gestión de Usuarios): completa.**
**Épica 2 (Solicitudes y Tutorías): completa.**
**Épica 3 (Grupos de Estudio): completa.**

## 6. Siguiente paso pendiente

Elegir la siguiente épica a implementar. Candidatas naturales según `HistoriasDeUsuario.md`:
- **Épica 4: Biblioteca de Recursos** (HU-11 a HU-13) — requiere definir cómo se suben archivos.
- **Épica 6: Calendario y Organización** (HU-18 a HU-20).
- **Épica 9: Evaluación y Reputación** (HU-26, HU-27).

No hay una decisión tomada todavía sobre cuál sigue — se debe preguntar al retomar.

**Pendiente de decisión del equipo:** fusionar `develop` → `main`. Se acordó esperar a terminar la Épica 2 completa como hito; ese hito ya se cumplió (y también se completó la Épica 3).

## 7. Pendientes técnicos (no bloquean el desarrollo actual)

- Desfase de versión `psql` 16 vs servidor PostgreSQL 18 en la máquina de Raziel — no afecta al backend.
- `JWT_SECRET` en `.env` es actualmente un valor simple (`CETI`) — cambiar antes de producción.
- No hay runner de migraciones — por ahora se ejecutan a mano y en orden.
- No hay tests automatizados todavía.

## 8. Cómo levantar el proyecto desde cero (para un nuevo integrante)

```bash
cd backend
npm install
cp .env.example .env
psql -U postgres -c "CREATE DATABASE studylink;"
# correr las 8 migraciones listadas en la sección 3, en orden
npm run dev
```
Servidor disponible en `http://localhost:3000`. Probar con `curl http://localhost:3000/health`.
