# PROGRESS.md — Estado del Proyecto StudyLink

> Este archivo se actualiza cada vez que se cierra una Historia de Usuario o se toma una decisión de diseño importante. Con esto tienes el contexto necesario para seguir sin repetir pasos ni contradecir decisiones ya tomadas.

**Última actualización:** Merge de las ramas de ambos integrantes completado y verificado (compila limpio, servidor arranca, `/health` responde). Épicas 1, 2, 3, 4, 5, 6 y 9 cerradas por completo. `develop` y `main` — recordar sincronizar `main` con este merge cuando se decida el próximo hito.

---

## 1. Stack y arquitectura (decisiones ya tomadas, no reabrir sin acuerdo del equipo)

- **Backend:** Node.js + Express + **TypeScript**.
- **Base de datos:** PostgreSQL. Cliente `psql` local v16, servidor v18 (desfase conocido, no afecta a `pg`).
- **Autenticación:** JWT (7 días de expiración). Contraseñas hasheadas con `bcrypt` (10 salt rounds).
- **Patrón de capas backend:** `routes/` → `controllers/` → `models/` (queries SQL directas con `pg`, sin ORM).
- **Regla de seguridad:** el `id_usuario` autenticado **nunca** se toma del `body` — siempre sale del JWT verificado.

## 2. Estructura de carpetas actual

```
backend/src/
├── config/database.ts
├── db/migrations/       # 001 a 015, ver sección 3
├── middlewares/auth.middleware.ts
├── models/               # usuario, solicitud, grupo, sesion, apunte, evento, recordatorio, calificacion, flashcard, cuestionario
├── controllers/           # uno por módulo, mismo listado que models/
├── routes/                # uno por módulo, mismo listado que models/
└── server.ts               # monta /api/auth, /usuarios, /solicitudes, /grupos, /sesiones, /apuntes, /eventos, /recordatorios, /calificaciones, /flashcards, /cuestionarios
```

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
| 009 | `009_create_apunte.sql` | `apunte` | Versión final (post-merge): `tipo_archivo` (no `tipo`), `descripcion`, `archivo_url VARCHAR(500)`, índice en `id_materia`. |
| 010 | `010_create_evento_calendario.sql` | `evento_calendario` | `id_grupo` nullable (no está en MER); CHECK cruzado con `compartido`. CHECK `fecha_fin > fecha_inicio`. |
| 011 | `011_create_recordatorio.sql` | `recordatorio` | Tabla nueva, no está en el MER. Backend no envía push (sin credenciales FCM) — solo persiste, cliente hace polling. |
| 012 | `012_create_calificacion.sql` | `calificacion` | Tal cual el MER. `UNIQUE(id_sesion, id_tutorado)`. |
| 013 | `013_create_flashcard.sql` | `flashcard`, `tarjeta` | Tal cual el MER. |
| 014 | `014_create_cuestionario.sql` | `cuestionario`, `pregunta` | Se agregó `opciones` JSONB (nullable, no está en MER) en `pregunta`. |
| 015 | `015_alter_apunte_esquema.sql` | `apunte` (ALTER) | **Solo necesaria si tu base de datos local se creó con la migración 009 original** (antes del merge de ramas): renombra `tipo`→`tipo_archivo`, agrega `descripcion`, agranda `archivo_url` a 500, agrega índice. Si vas a crear la base de datos desde cero, usa directamente la migración 009 (versión final) y **omite la 015**. |

**Para levantar la base de datos desde cero (nuevo integrante, sin datos previos):**
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
psql -U postgres -d studylink -f backend/src/db/migrations/010_create_evento_calendario.sql
psql -U postgres -d studylink -f backend/src/db/migrations/011_create_recordatorio.sql
psql -U postgres -d studylink -f backend/src/db/migrations/012_create_calificacion.sql
psql -U postgres -d studylink -f backend/src/db/migrations/013_create_flashcard.sql
psql -U postgres -d studylink -f backend/src/db/migrations/014_create_cuestionario.sql
```
(No corras la 015 en una base de datos nueva — es solo para migrar una base creada antes del merge.)

## 4. Decisiones de diseño importantes

- **`id_tutor` como columna simple** en `solicitud_estudio` (no tabla intermedia): cada tutoría tiene un solo tutor según `AppMovil.md`.
- **HU-05 (Buscar Tutor)** es MVP simple: filtra `nivel_conocimiento = 'Avanzado'`, ordena por `reputacion`. No es el scoring multi-factor completo de la sección 8.
- **Crear grupo usa transacción real** (`BEGIN`/`COMMIT`/`ROLLBACK`) por los 2 INSERTs relacionados.
- **Rol `'Organizador'`** agregado al ENUM de `miembro_grupo` para el creador del grupo.
- **HU-10**: solo `id_creador` expulsa/cambia roles; cualquier miembro lista. Creador no puede auto-expulsarse.
- **HU-07**: se pospuso hasta terminar Épica 3 (dependencia de `Grupo`). Solo Organizador/Tutor programan sesiones.
- **HU-11 — el backend NO maneja el binario**: el cliente (Flutter) sube el archivo directo a Firebase Storage y manda `archivo_url` ya resuelta. Backend solo valida y guarda metadatos. Motivo: sin credenciales de Firebase (`serviceAccountKey.json`) disponibles.
- **HU-13**: "descargar" es `GET /api/apuntes/:id_apunte` (metadatos + `archivo_url`); el cliente descarga directo desde ahí, sin proxy del backend.
- **`tipo_archivo`** (PDF/Imagen/Enlace/Presentacion) y **`descripcion`** en `apunte`: no están en el MER, se agregaron por `AppMovil.md` sección 10 y para habilitar búsqueda de texto (HU-12).
- **HU-19 (Calendario Compartido)** combina `Evento_Calendario` (compartido) + `Sesion_Estudio` del grupo en una sola línea de tiempo (`GET /api/eventos/grupo/:id_grupo`), marcando el `origen` de cada item — evita duplicar datos que ya existen como sesiones.
- **HU-20 (Recordatorios)**: tabla nueva no contemplada en el MER. Backend NO envía push notifications (sin credenciales FCM) — solo persiste y expone `GET /api/recordatorios/pendientes`; el cliente hace polling y decide cómo notificar, marcando `enviado` después vía `PATCH`.
- **Compartir un evento requiere ser miembro del grupo** — mismo criterio de permisos usado en Épica 3.
- **HU-26 (Calificar Tutor)**: `calificacion` tal cual el MER (una `puntuacion` 1-5 + `comentario`), sin desglose por los 4 criterios que menciona `AppMovil.md` sección 17 — esos quedan como guía cualitativa para el comentario, no columnas separadas (mismo criterio que HU-07). Validaciones: sesión existe, tutorado es miembro del grupo, tutor tiene rol Tutor/Organizador en ese grupo, nadie se autocalifica, `UNIQUE(id_sesion, id_tutorado)` evita calificar dos veces.
- **`usuario.reputacion` se recalcula automáticamente** tras cada calificación exitosa (`AVG(puntuacion)`). Es un promedio simple, no el sistema de recomendación multi-factor completo de la sección 8 (mismo límite ya documentado en HU-05).
- **HU-15 (Compartir Flashcards) = visibilidad pública, no edición colaborativa**: el MER no tiene `id_grupo`/`id_materia` en `Flashcard`, solo `compartida BOOLEAN`. Se implementó como "visible para todos, solo lectura", no edición multi-usuario.
- **`pregunta.opciones` (JSONB, no está en el MER)**: necesaria para renderizar opciones de tipo `OpcionMultiple`/`RelacionConceptos`. `NULL` para `VerdaderoFalso`/`RespuestaCorta`.
- **HU-17 (Resolver Cuestionario) es stateless**: no hay entidad "Intento" en el MER, así que no se persisten los intentos — se califica al momento y se devuelve el resultado, sin guardar historial. Limitación conocida para el "Seguimiento del Progreso" de la sección 15 (pendiente si se hace la Épica 8).
- **Cuestionarios colaborativos** (multi-autor) **no implementados** — el MER no soporta multi-autor en `Cuestionario`. Mismo criterio que flashcards compartidas.

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
| HU-12 | Consultar Biblioteca | `GET /api/apuntes/buscar?q=...&id_materia=...`, `GET /api/apuntes/materia/:id_materia` |
| HU-13 | Descargar Recursos | `GET /api/apuntes/:id_apunte/descargar` (además `DELETE /api/apuntes/:id_apunte`, solo el autor) |
| HU-14 | Crear Flashcards | `POST /api/flashcards`, `POST /api/flashcards/:id_flashcard/tarjetas` |
| HU-15 | Compartir Flashcards | `PATCH /api/flashcards/:id_flashcard/compartir`, `GET /api/flashcards/compartidas` |
| HU-16 | Crear Cuestionario | `POST /api/cuestionarios` |
| HU-17 | Resolver Cuestionario | `GET /api/cuestionarios/:id_cuestionario`, `POST /api/cuestionarios/:id_cuestionario/resolver` |
| HU-18 | Crear Evento Personal | `POST /api/eventos`, `GET /api/eventos`, `GET/DELETE /api/eventos/:id_evento` |
| HU-19 | Calendario Compartido | `GET /api/eventos/grupo/:id_grupo` |
| HU-20 | Recibir Recordatorios | `POST /api/recordatorios`, `GET /api/recordatorios/pendientes`, `GET /api/recordatorios`, `PATCH /api/recordatorios/:id_recordatorio/enviado` |
| HU-26 | Calificar Tutor | `POST /api/calificaciones` |
| HU-27 | Consultar Reputación | `GET /api/calificaciones/tutor/:id_usuario` |

**Épicas 1, 2, 3, 4, 5, 6 y 9: completas.**

## 6. Siguiente paso pendiente

Elegir la siguiente épica. Candidatas naturales según `HistoriasDeUsuario.md`:
- **Épica 7: Comunicación** (HU-21, HU-22) — probablemente requiere websockets/chat en tiempo real, más compleja que lo hecho hasta ahora.
- **Épica 8: Seguimiento Académico** (HU-23 en adelante) — buen candidato para agregar la tabla de "intentos de cuestionario" pendiente de HU-17.
- **Épica 10: Asistencia** — ya existe la entidad `Asistencia` en el MER desde la Épica 3 (sesiones), no se ha implementado el registro/consulta.

Sin decisión tomada — preguntar al retomar.

**Coordinación de equipo pendiente:** fusionar este `develop` (ya con el trabajo de ambos integrantes combinado) a `main` cuando se decida el próximo hito. Confirmar con el equipo antes de tocar `main`.

## 7. Bugs corregidos durante esta sesión de merge (no ligados a una HU específica)

- `server.ts` tenía un import roto a una carpeta `./middleware/` inexistente (es `middlewares/`) — se limpió.
- Imports duplicados del mismo módulo en `solicitud.routes.ts`, `grupo.routes.ts`, `auth.routes.ts` y `grupo.controller.ts` (cada HU nueva agregaba un import en vez de extender el existente) — consolidados en uno solo por archivo.
- `@types/express` estaba en `^5.0.6` pero el proyecto usa `express@^4.19.2` — mismatch de tipos causaba errores en `req.params`. Fijado a `^4.17.21`.
- Faltaba `@types/pg` como devDependency — agregado.
- Verificado con `npx tsc --noEmit`: compila limpio tras el merge de ambas ramas.

## 8. Pendientes técnicos

- Desfase `psql` 16 vs servidor 18 en la máquina de Raziel — no afecta al backend.
- `JWT_SECRET` es un valor simple (`CETI`) — cambiar antes de producción.
- Sin runner de migraciones automático — se ejecutan a mano y en orden.
- Sin tests automatizados todavía.
- Conectar Firebase Storage real (HU-11) y Firebase Admin/FCM real (HU-20) cuando haya credenciales — hoy ambos son MVPs (URL manual / polling del cliente).
- Falta tabla de "intentos de cuestionario" para HU-17 si se quiere trackear historial (relacionado con Épica 8).

## 9. Cómo levantar el proyecto desde cero (para un nuevo integrante)

```bash
cd backend
npm install
cp .env.example .env
psql -U postgres -c "CREATE DATABASE studylink;"
# correr las migraciones 001 a 014 de la sección 3, en orden (NO correr la 015 en una BD nueva)
npm run dev
```
Servidor en `http://localhost:3000`. Probar con `curl http://localhost:3000/health`.
