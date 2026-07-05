# PROGRESS.md — Estado del Proyecto StudyLink

> Este archivo se actualiza cada vez que se cierra una Historia de Usuario o se toma una decisión de diseño importante. Con esto tienes el contexto necesario para seguir sin repetir pasos ni contradecir decisiones ya tomadas.

**Última actualización:** Backend completo — Épicas 1 a 10 cerradas (todas las HU salvo Gamificación, HU-30/31, que aún no se ha tocado). Pendiente fusionar `develop` a `main`.

---

## 1. Stack y arquitectura (decisiones ya tomadas, no reabrir sin acuerdo del equipo)

- **Backend:** Node.js + Express + **TypeScript**.
- **Base de datos:** PostgreSQL. Cliente `psql` local v16, servidor v18 (desfase conocido, no afecta a `pg`).
- **Autenticación:** JWT (7 días de expiración). Contraseñas hasheadas con `bcrypt` (10 salt rounds).
- **Patrón de capas backend:** `routes/` → `controllers/` → `models/` (queries SQL directas con `pg`, sin ORM).
- **Regla de seguridad:** el `id_usuario` autenticado **nunca** se toma del `body` — siempre sale del JWT verificado.
- **Patrón de permisos por rol de grupo:** varias HU (programar sesión, registrar asistencia) validan que quien actúa sea `Organizador` o `Tutor` en `miembro_grupo`, usando `obtenerRolEnGrupo()`.

## 2. Estructura de carpetas actual

```
backend/src/
├── config/database.ts
├── db/migrations/       # 001 a 018, ver sección 3
├── middlewares/auth.middleware.ts
├── models/               # usuario, solicitud, grupo, sesion, apunte, evento, recordatorio,
│                         # calificacion, flashcard, cuestionario, conversacion, mensaje,
│                         # objetivo, estadistica, asistencia
├── controllers/           # uno por módulo, mismo listado que models/
├── routes/                # uno por módulo, mismo listado que models/
└── server.ts               # monta las ~15 rutas /api/*
```

## 3. Migraciones SQL ejecutadas (en orden)

| # | Archivo | Tabla | Notas |
|---|---|---|---|
| 001 | `001_create_usuario.sql` | `usuario` | `contraseña` → `contrasena` (sin ñ). |
| 002 | `002_create_materia.sql` | `materia` | 3 registros de prueba. |
| 003 | `003_create_solicitud_estudio.sql` | `solicitud_estudio` | `id_tutor` (nullable, no en MER) y `titulo`. |
| 004 | `004_create_usuario_materia.sql` | `usuario_materia` | `UNIQUE(id_usuario, id_materia)`. |
| 005 | `005_create_grupo.sql` | `grupo` | `id_materia` (nullable, no en MER). |
| 006 | `006_create_miembro_grupo.sql` | `miembro_grupo` | `fecha_union`. |
| 007 | `007_alter_miembro_grupo_rol.sql` | `miembro_grupo` (ALTER) | Se agregó `'Organizador'` al CHECK. |
| 008 | `008_create_sesion_estudio.sql` | `sesion_estudio` | `id_creador`. `modalidad`: Presencial/Virtual. |
| 009 | `009_create_apunte.sql` | `apunte` | Versión final: `tipo_archivo`, `descripcion`, `archivo_url VARCHAR(500)`, índice en `id_materia`. |
| 010 | `010_create_evento_calendario.sql` | `evento_calendario` | `id_grupo` nullable; CHECK cruzado con `compartido`. |
| 011 | `011_create_recordatorio.sql` | `recordatorio` | Tabla nueva, no está en el MER. Sin push real (sin FCM), solo persiste + polling. |
| 012 | `012_create_calificacion.sql` | `calificacion` | Tal cual el MER. `UNIQUE(id_sesion, id_tutorado)`. |
| 013 | `013_create_flashcard.sql` | `flashcard`, `tarjeta` | Tal cual el MER. |
| 014 | `014_create_cuestionario.sql` | `cuestionario`, `pregunta` | `opciones` JSONB (nullable, no en MER). |
| 015 | `015_alter_apunte_esquema.sql` | `apunte` (ALTER) | **Solo si tu BD se creó con la migración 009 original, antes del merge de ramas.** Si creas la BD desde cero, usa la 009 final y omite esta. |
| 016 | `016_create_conversacion_mensaje.sql` | `conversacion`, `mensaje` | `id_usuario_1/2` (privada) o `id_grupo` (grupal) en `conversacion`, no está en el MER. CHECK exige exactamente los campos de cada tipo. |
| 017 | `017_create_objetivo.sql` | `objetivo` | Tal cual el MER + `fecha_creacion`. `progreso` 0-100, estado derivado (no persistido). |
| 018 | `018_create_asistencia.sql` | `asistencia` | Tal cual el MER. `UNIQUE(id_sesion, id_usuario)`, registro único (no check-in/out separado). |

**Para levantar la base de datos desde cero (nuevo integrante, sin datos previos), en este orden — sin correr la 015:**
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
psql -U postgres -d studylink -f backend/src/db/migrations/016_create_conversacion_mensaje.sql
psql -U postgres -d studylink -f backend/src/db/migrations/017_create_objetivo.sql
psql -U postgres -d studylink -f backend/src/db/migrations/018_create_asistencia.sql
```

## 4. Decisiones de diseño importantes

- **`id_tutor` como columna simple** en `solicitud_estudio` (no tabla intermedia): cada tutoría tiene un solo tutor según `AppMovil.md`.
- **HU-05 (Buscar Tutor)** es MVP simple: filtra `nivel_conocimiento = 'Avanzado'`, ordena por `reputacion`. No es el scoring multi-factor completo de la sección 8.
- **Crear grupo usa transacción real** (`BEGIN`/`COMMIT`/`ROLLBACK`) por los 2 INSERTs relacionados.
- **Rol `'Organizador'`** agregado al ENUM de `miembro_grupo` para el creador del grupo.
- **HU-10**: solo `id_creador` expulsa/cambia roles; cualquier miembro lista.
- **HU-07**: se pospuso hasta terminar Épica 3. Solo Organizador/Tutor programan sesiones.
- **HU-11 — sin Firebase Storage real**: recibe `archivo_url` como string, no el binario.
- **`tipo_archivo`/`descripcion`** en `apunte`: no están en el MER, agregados por AppMovil.md y para búsqueda de texto.
- **HU-19** combina `Evento_Calendario` (compartido) + `Sesion_Estudio` del grupo en una sola línea de tiempo.
- **HU-20 — sin push real**: tabla `recordatorio` nueva (no en MER), backend solo persiste, cliente hace polling.
- **HU-26**: `calificacion` tal cual el MER (una `puntuacion` global), sin desglose de los 4 criterios de AppMovil.md sección 17.
- **`usuario.reputacion` se recalcula automáticamente** tras cada calificación (`AVG(puntuacion)`), promedio simple.
- **HU-15**: "compartir" flashcard = visibilidad pública de solo lectura, no edición colaborativa (el MER no soporta multi-autor).
- **`pregunta.opciones` (JSONB, no en MER)**: necesaria para `OpcionMultiple`/`RelacionConceptos`.
- **HU-17 es stateless**: no se persisten intentos de cuestionario (no hay entidad "Intento" en el MER). Limitación conocida.
- **Cuestionarios colaborativos no implementados**: el MER no soporta multi-autor.
- **Chat (HU-21/22) usa REST + polling, no WebSockets**: decisión consistente con no tener infraestructura de tiempo real (mismo criterio que Recordatorios). El cliente pregunta periódicamente por mensajes nuevos usando `?desde=<fecha>`.
- **Conversación privada usa columnas `id_usuario_1/2`** (no tabla de participantes N:M): más simple para el caso 1 a 1. El par se normaliza en orden alfabético de UUID al crear, para respetar el `UNIQUE` y evitar duplicados A-B / B-A.
- **Objetivo: solo `progreso` (0-100), sin columna `estado` separada**: el estado cualitativo (No iniciado/En progreso/Completado) se deriva en el backend con `derivarEstado()`, no se persiste. "Dominado" (mencionado en AppMovil.md) no tiene umbral numérico claro — no se deriva automáticamente, limitación conocida.
- **HU-25 (Estadísticas) es un MVP con datos ya existentes**: horas de estudio y sesiones completadas se calculan de `sesion_estudio` (vía membresía en `miembro_grupo`); tutorías impartidas/recibidas de `solicitud_estudio`. **No incluye** flashcards estudiadas ni cuestionarios completados — no hay tablas de tracking para esos eventos (decisión explícita: no crearlas todavía). "Sesión completada" se aproxima como `fecha_fin < NOW()`, no hay marca explícita de asistencia real vs solo "ya pasó".
- **Asistencia (HU-28) es registro único, no check-in/check-out en tiempo real**: el tutor registra `hora_ingreso` y `hora_salida` de una vez (usualmente después de la sesión), no en el momento exacto en que cada quien entra/sale. `UNIQUE(id_sesion, id_usuario)` con `ON CONFLICT DO UPDATE` permite corregir un registro sin fallar por duplicado.
- **Solo Organizador/Tutor del grupo pueden registrar asistencia** de una sesión — mismo patrón de permisos que HU-07.

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
| HU-12 | Consultar Biblioteca | `GET /api/apuntes/buscar?q=...`, `GET /api/apuntes/materia/:id_materia` |
| HU-13 | Descargar Recursos | `GET /api/apuntes/:id_apunte/descargar`, `DELETE /api/apuntes/:id_apunte` |
| HU-14 | Crear Flashcards | `POST /api/flashcards`, `POST /api/flashcards/:id/tarjetas` |
| HU-15 | Compartir Flashcards | `PATCH /api/flashcards/:id/compartir`, `GET /api/flashcards/compartidas` |
| HU-16 | Crear Cuestionario | `POST /api/cuestionarios` |
| HU-17 | Resolver Cuestionario | `GET /api/cuestionarios/:id`, `POST /api/cuestionarios/:id/resolver` |
| HU-18 | Crear Evento Personal | `POST /api/eventos`, `GET/DELETE /api/eventos/:id` |
| HU-19 | Calendario Compartido | `GET /api/eventos/grupo/:id_grupo` |
| HU-20 | Recibir Recordatorios | `POST /api/recordatorios`, `GET /api/recordatorios/pendientes`, `PATCH /api/recordatorios/:id/enviado` |
| HU-21 | Mensajes Privados | `POST /api/conversaciones/privada`, `POST /api/mensajes`, `GET /api/mensajes/conversacion/:id?desde=` |
| HU-22 | Chat Grupal | `POST /api/conversaciones/grupo/:id_grupo` (+ mismos endpoints de mensaje) |
| HU-23 | Crear Objetivo | `POST /api/objetivos` |
| HU-24 | Actualizar Progreso | `PATCH /api/objetivos/:id/progreso` |
| HU-25 | Consultar Estadísticas | `GET /api/estadisticas/mias` |
| HU-26 | Calificar Tutor | `POST /api/calificaciones` |
| HU-27 | Consultar Reputación | `GET /api/calificaciones/tutor/:id_usuario` |
| HU-28 | Registrar Asistencia | `POST /api/asistencia` |
| HU-29 | Consultar Historial de Asistencia | `GET /api/asistencia/mi-historial`, `GET /api/asistencia/sesion/:id_sesion` |

**Épicas 1, 2, 3, 4, 5, 6, 7, 8, 9 y 10: completas.**
**Épica 11 (Gamificación, HU-30/31): sin empezar.**

## 6. Siguiente paso pendiente

- **Épica 11: Gamificación** (HU-30 Obtener Logros, HU-31 Consultar Insignias) — es lo único que falta del backend planeado en `HistoriasDeUsuario.md`.
- **Fusionar `develop` → `main`**: pendiente en esta sesión, hito grande (todo el backend funcional).
- **Empezar el frontend Flutter**: no se ha tocado nada de `app/` todavía — todo el trabajo hasta ahora es backend puro, probado vía `curl`.

## 7. Bugs corregidos en sesión de merge de ramas (no ligados a una HU específica)

- `server.ts` tenía un import roto a `./middleware/` inexistente (es `middlewares/`).
- Imports duplicados del mismo módulo en varios archivos de rutas/controllers — consolidados.
- `@types/express` en `^5.0.6` con `express@^4.19.2` real — mismatch de tipos. Fijado a `^4.17.21`.
- Faltaba `@types/pg` — agregado.

## 8. Pendientes técnicos

- Desfase `psql` 16 vs servidor 18 en la máquina de Raziel — no afecta al backend.
- `JWT_SECRET` es un valor simple (`CETI`) — cambiar antes de producción.
- Sin runner de migraciones automático.
- Sin tests automatizados.
- Conectar Firebase Storage real (HU-11) y Firebase Admin/FCM real (HU-20) cuando haya credenciales.
- Falta tabla de "intentos de cuestionario" para HU-17/HU-25 si se quiere trackear historial real.
- Chat (HU-21/22) usa polling, no WebSockets — mejora futura si se quiere tiempo real de verdad.
- HU-25 no incluye flashcards estudiadas ni cuestionarios completados (sin tracking de esos eventos).

## 9. Cómo levantar el proyecto desde cero (para un nuevo integrante)

```bash
cd backend
npm install
cp .env.example .env
psql -U postgres -c "CREATE DATABASE studylink;"
# correr las migraciones de la sección 3, en el orden ahí indicado (sin la 015)
npm run dev
```
Servidor en `http://localhost:3000`. Probar con `curl http://localhost:3000/health`.
