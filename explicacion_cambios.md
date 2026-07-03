# CAMBIOS — Épica 4: Biblioteca de Recursos (HU-11, HU-12, HU-13)

> Este documento resume exactamente qué se creó y qué se modificó respecto al estado del proyecto descrito en `Progreso-Studylink.md` (última actualización: HU-07 completada, Épicas 2 y 3 cerradas).

---

## 1. Archivos nuevos

### `backend/src/db/migrations/009_create_apunte.sql`
Tabla `apunte` para HU-11/12/13. Se agregaron dos columnas que no estaban en el MER original:
- `tipo_archivo` — `CHECK` con `'PDF' | 'Imagen' | 'Enlace' | 'Presentacion'`, tomado de la lista explícita en `AppMovil.md` sección 10.
- `descripcion` — permite búsqueda de texto en HU-12.

También incluye un índice en `id_materia` para acelerar el listado por materia.

**Correrla:**
```bash
psql -U postgres -d studylink -f backend/src/db/migrations/009_create_apunte.sql
```

### `backend/src/models/apunte.model.ts`
Capa de acceso a datos (queries `pg` directas, sin ORM, siguiendo el patrón de `solicitud.model.ts`). Funciones:
- `crearApunte`
- `buscarApuntePorId`
- `listarApuntesPorMateria`
- `buscarApuntesPorTitulo` (búsqueda `ILIKE`, opcionalmente filtrada por materia)
- `eliminarApunte` (solo permite borrar si `id_usuario` coincide con el autor)

### `backend/src/controllers/apunte.controller.ts`
Controllers: `subir`, `listarPorMateria`, `buscar`, `obtener`, `eliminar`. Sigue la regla de seguridad del proyecto: `id_usuario` siempre sale de `req.usuario!.id_usuario` (JWT), nunca del body.

### `backend/src/routes/apunte.routes.ts`
```
POST   /api/apuntes                      → subir (HU-11)
GET    /api/apuntes/buscar?q=&id_materia → buscar (HU-12)
GET    /api/apuntes/materia/:id_materia  → listarPorMateria (HU-12)
GET    /api/apuntes/:id_apunte           → obtener (HU-13)
DELETE /api/apuntes/:id_apunte           → eliminar (solo el autor)
```
Todas protegidas con `verificarToken`.

---

## 2. Decisión de diseño clave (acordada contigo)

**El backend NO maneja el archivo binario.** El cliente (Flutter) sube el PDF/imagen directo a Firebase Storage y solo envía `archivo_url` ya resuelta. El backend valida y guarda metadatos en Postgres (`titulo`, `descripcion`, `tipo_archivo`, `archivo_url`). No hay `multer` ni manejo de `multipart/form-data`.

Motivo: no había credenciales de Firebase (`serviceAccountKey.json`) disponibles para integrar `firebase-admin` en este momento. Queda como mejora futura si se decide mover la subida al backend.

Por la misma razón, HU-13 (Descargar Recursos) es simplemente `GET /api/apuntes/:id_apunte`: devuelve metadatos + `archivo_url`, y el cliente descarga directo desde ahí. El backend no hace proxy del archivo.

---

## 3. Archivos editados (bugs preexistentes, no relacionados con la Épica 4)

Al validar con `npx tsc --noEmit` aparecieron errores de compilación que ya existían antes de esta sesión. Se corrigieron para poder compilar limpio:

### `backend/src/server.ts`
- **Bug:** importaba `verificarToken, AuthRequest` desde `./middleware/auth.middleware` — la carpeta real es `middlewares/` (plural). Rompía el build por completo.
- **Fix:** se quitó ese import (no se usaba directamente en `server.ts`).
- **Bug:** `app.use('/api/solicitudes', solicitudRoutes)` estaba montado dos veces (una suelta arriba del archivo, antes de `/health`, y luego implícitamente esperado junto a las demás rutas).
- **Fix:** se dejó una sola vez, junto a los demás `app.use('/api/...')`.
- **Cambio funcional:** se agregó `import apunteRoutes from './routes/apunte.routes'` y `app.use('/api/apuntes', apunteRoutes)`.

### `backend/src/routes/solicitud.routes.ts`
- **Bug:** dos `import { ... } from '../controllers/solicitud.controller'` que redeclaraban `crear` y `listarPorMateria` (identificador duplicado en TS).
- **Fix:** un solo import: `import { crear, listarPorMateria, aceptar } from '../controllers/solicitud.controller';`

### `backend/src/routes/grupo.routes.ts`
- **Bug:** tres imports acumulados del mismo módulo (`crear`, luego `crear, unirse`, luego `crear, unirse, listar, expulsar, cambiarRol`), todos redeclarando `crear` y `unirse`.
- **Fix:** un solo import: `import { crear, unirse, listar, expulsar, cambiarRol } from '../controllers/grupo.controller';`

### `backend/src/routes/auth.routes.ts`
- **Bug:** dos imports del mismo módulo, redeclarando `registrar`.
- **Fix:** un solo import: `import { registrar, iniciarSesion } from '../controllers/auth.controller';`

### `backend/src/controllers/grupo.controller.ts`
- **Bug:** tres imports acumulados del mismo módulo (`grupo.model`), redeclarando `crearGrupo`.
- **Fix:** consolidados en dos imports:
  ```typescript
  import { crearGrupo, buscarGrupoPorId, esMiembro, unirseAGrupo } from '../models/grupo.model';
  import { listarMiembros, expulsarMiembro, cambiarRolMiembro } from '../models/grupo.model';
  ```

> **Patrón detectado:** en varios archivos, cada vez que se agregaba un endpoint nuevo se sumaba un `import` adicional del mismo módulo en vez de extender el existente. Vale la pena tenerlo presente para las próximas HU y revisar el import antes de guardar.

### `backend/package.json`
- **Bug:** `@types/express` estaba fijado en `^5.0.6`, pero la dependencia real es `express@^4.19.2` (Express 4). Ese desfase de versiones de tipos causaba errores `Argument of type 'string | string[]' is not assignable to parameter of type 'string'` al leer `req.params` en casi todos los controllers (Express 5 tipa los params distinto).
- **Fix:** `"@types/express": "^4.17.21"`.
- **Bug:** faltaba `@types/pg` como devDependency → error `Could not find a declaration file for module 'pg'`.
- **Fix:** se agregó `"@types/pg": "^8.11.10"`.

Después de estos cambios hay que correr `npm install` de nuevo para que se apliquen las nuevas versiones de tipos.

---

## 4. Verificación realizada

```bash
cd backend
npm install
npx tsc --noEmit
```
Resultado: compilación limpia, cero errores.

> Nota de entorno: en el sandbox donde trabajé, `npm install` normal falló al compilar el binario nativo de `bcrypt` (descarga bloqueada por la configuración de red del sandbox, no por el código). Usé `npm install --ignore-scripts` solo para poder validar los tipos con `tsc`. En tu máquina, con acceso normal a internet, `npm install` sin flags debería funcionar sin problema.

---

## 5. Actualización pendiente en `Progreso-Studylink.md`

Falta reflejar estos cambios en el archivo de progreso. Puntos a agregar:

1. **Tabla de migraciones (sección 3):** fila para `009_create_apunte.sql` + agregarla al bloque de comandos `psql`.
2. **Decisiones de diseño (sección 4):** las tres decisiones de la Épica 4 (backend no maneja binarios, descarga vía URL, `tipo_archivo` tomado de AppMovil.md).
3. **Historias de Usuario completadas (sección 5):** filas para HU-11, HU-12, HU-13 + marcar "Épica 4: completa".
4. **Siguiente paso pendiente (sección 6):** quitar la Épica 4 de las candidatas; dejar Épica 5, 6 y 9 como opciones abiertas.
5. Opcionalmente, un apartado nuevo documentando los bugs corregidos (útil para que quien retome sepa que ya no están, y no los "redescubra").

---

## 6. Próxima decisión pendiente

No hay épica siguiente decidida. Candidatas según `HistoriasDeUsuario.md`:
- **Épica 5: Flashcards y Cuestionarios** (HU-14 a HU-17)
- **Épica 6: Calendario y Organización** (HU-18 a HU-20)
- **Épica 9: Evaluación y Reputación** (HU-26, HU-27)
