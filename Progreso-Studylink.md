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
| 009 | `009_create_apunte.sql` | `apunte` | Se agregó `tipo_archivo` (CHECK `'PDF'/'Imagen'/'Enlace'/'Presentacion'`, no está en el MER) y `descripcion` (no está en el MER, permite búsqueda de texto en HU-12). Índice en `id_materia` para el listado. |

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
(Aún no tenemos un runner automático de migraciones — está en pendientes.)

## 4. Decisiones de diseño importantes (con su justificación)

- **`id_tutor` como columna simple en `solicitud_estudio`** (en vez de tabla intermedia `solicitud_tutor`): se eligió la opción simple porque `AppMovil.md` especifica que cada tutoría (individual o grupal) tiene un solo tutor.
- **HU-05 (Buscar Tutor) implementado como MVP simple**: filtra usuarios con `nivel_conocimiento = 'Avanzado'` en `usuario_materia` para la materia dada, ordenados por `reputacion DESC`. No es el sistema de scoring multi-factor completo que describe la sección 8 de `AppMovil.md` — eso queda como mejora futura.
- **Crear grupo usa transacción real** (`BEGIN`/`COMMIT`/`ROLLBACK`) porque implica 2 INSERTs relacionados (grupo + creador como miembro). Es el único lugar del código que usa `pool.connect()` manual en vez de `pool.query()` directo.
- **Rol `'Organizador'` agregado al ENUM de `miembro_grupo`** (migración 007): el creador de un grupo no encaja como "Tutor" ni "Tutorado".
- **HU-10 (Gestionar Miembros)**: solo el `id_creador` del grupo puede expulsar o cambiar roles; cualquier miembro puede listar. El creador no puede expulsarse a sí mismo.
- **HU-07 (Programar Sesión)**: `Sesion_Estudio` depende de `Grupo`, se pospuso hasta terminar la Épica 3, respetando el MER tal cual. Solo `Organizador` o `Tutor` del grupo pueden programar sesiones, un `Tutorado` no puede.
- **HU-11 (Subir Apuntes) — el backend NO maneja el binario**: se decidió que el cliente (Flutter) sube el archivo directo a Firebase Storage y solo manda `archivo_url` ya resuelta al backend. El backend únicamente valida y guarda los metadatos (`titulo`, `descripcion`, `tipo_archivo`, `archivo_url`) en Postgres. No hay `multer` ni manejo de multipart en el backend. Motivo: no había credenciales de Firebase (`serviceAccountKey.json`) disponibles para integrar `firebase-admin` en este momento; queda como mejora futura si se decide subir por el backend en vez de por el cliente.
- **HU-13 (Descargar Recursos)**: como el binario vive en Firebase, "descargar" es simplemente `GET /api/apuntes/:id_apunte`, que devuelve los metadatos + `archivo_url`, y el cliente descarga directo desde esa URL. El backend no hace proxy del archivo.
- **`tipo_archivo` con CHECK `'PDF'/'Imagen'/'Enlace'/'Presentacion'`**: se tomó de la lista explícita en `AppMovil.md` sección 10 ("Biblioteca Compartida de Apuntes"), aunque el MER no tenía esta columna.

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
| HU-11 | Subir Apuntes | `POST /api/apuntes` |
| HU-12 | Consultar Biblioteca | `GET /api/apuntes/buscar?q=...&id_materia=...`, `GET /api/apuntes/materia/:id_materia` |
| HU-13 | Descargar Recursos | `GET /api/apuntes/:id_apunte` (además `DELETE /api/apuntes/:id_apunte`, solo el autor puede borrar su apunte) |

**Épica 1 (Gestión de Usuarios): completa.**
**Épica 2 (Solicitudes y Tutorías): completa.**
**Épica 3 (Grupos de Estudio): completa.**
**Épica 4 (Biblioteca de Recursos): completa.**

## 6. Siguiente paso pendiente

Elegir la siguiente épica a implementar. Candidatas naturales según `HistoriasDeUsuario.md`:
- **Épica 6: Calendario y Organización** (HU-18 a HU-20).
- **Épica 9: Evaluación y Reputación** (HU-26, HU-27).
- **Épica 5: Flashcards y Cuestionarios** (HU-14 a HU-17).

No hay una decisión tomada todavía sobre cuál sigue — se debe preguntar al retomar.

**Bugs corregidos en esta sesión (no relacionados con una HU específica, arrastrados de antes):**
- `server.ts` importaba `verificarToken`/`AuthRequest` desde `./middleware/auth.middleware` (carpeta inexistente, es `middlewares/`). Rompía el build. Se quitó ese import (no se usaba directamente en `server.ts`) y se corrigió el montaje de rutas.
- `solicitud.routes.ts`, `grupo.routes.ts`, `auth.routes.ts` y `grupo.controller.ts` tenían imports duplicados del mismo módulo (parece que cada HU nueva agregaba un `import` en vez de extender el existente) — causaba error de TypeScript `Duplicate identifier`. Se consolidaron en un solo import por archivo.
- `@types/express` estaba en `^5.0.6` pero la dependencia real es `express@^4.19.2` (Express 4) — el mismatch de versiones de tipos causaba errores `string | string[]` en casi todos los controllers al leer `req.params`. Se fijó `@types/express` a `^4.17.21`.
- Faltaba `@types/pg` como devDependency (causaba `Could not find a declaration file for module 'pg'`). Se agregó.
- Se corrió `npx tsc --noEmit` y el proyecto compila limpio. Nota: en este sandbox `npm install` no pudo compilar el binario nativo de `bcrypt` (descarga bloqueada por red), se usó `--ignore-scripts` solo para validar tipos; en un entorno normal con acceso a red esto no debería pasar.

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
