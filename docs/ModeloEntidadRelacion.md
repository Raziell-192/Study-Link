# Modelo Entidad-Relación (MER) - StudyLink

## Entidades Principales

### Usuario
Representa a cualquier estudiante registrado en la plataforma.

| Campo | Tipo |
| :--- | :--- |
| id_usuario (PK) | UUID |
| matricula | VARCHAR |
| nombre_completo | VARCHAR |
| correo | VARCHAR |
| contraseña | VARCHAR |
| carrera | VARCHAR |
| semestre | INTEGER |
| fecha_registro | TIMESTAMP |
| foto_perfil | VARCHAR |
| reputacion | DECIMAL |

---

### Materia
Catálogo de materias disponibles.

| Campo | Tipo |
| :--- | :--- |
| id_materia (PK) | UUID |
| nombre | VARCHAR |
| descripcion | TEXT |

---

### Usuario_Materia
Relaciona usuarios con materias dominadas o de interés.

| Campo | Tipo |
| :--- | :--- |
| id_usuario_materia (PK) | UUID |
| id_usuario (FK) | UUID |
| id_materia (FK) | UUID |
| nivel_conocimiento | ENUM ('Básico', 'Intermedio', 'Avanzado') |

---

### Solicitud_Estudio
Solicitudes creadas por los estudiantes.

| Campo | Tipo |
| :--- | :--- |
| id_solicitud (PK) | UUID |
| id_usuario (FK) | UUID |
| id_materia (FK) | UUID |
| titulo | VARCHAR |
| descripcion | TEXT |
| modalidad | ENUM ('Individual', 'Grupal') |
| fecha_creacion | TIMESTAMP |
| estado | ENUM ('Abierta', 'En proceso', 'Cerrada') |

---

### Grupo
Grupos de estudio.

| Campo | Tipo |
| :--- | :--- |
| id_grupo (PK) | UUID |
| nombre | VARCHAR |
| descripcion | TEXT |
| fecha_creacion | TIMESTAMP |
| id_creador (FK) | UUID |

---

### Miembro_Grupo
Relación N:M entre usuarios y grupos.

| Campo | Tipo |
| :--- | :--- |
| id_miembro (PK) | UUID |
| id_usuario (FK) | UUID |
| id_grupo (FK) | UUID |
| rol | ENUM ('Tutor', 'Tutorado') |

---

### Sesion_Estudio
Sesiones programadas.

| Campo | Tipo |
| :--- | :--- |
| id_sesion (PK) | UUID |
| id_grupo (FK) | UUID |
| tema | VARCHAR |
| descripcion | TEXT |
| fecha_inicio | TIMESTAMP |
| fecha_fin | TIMESTAMP |
| modalidad | ENUM |

---

### Asistencia
Control de asistencia.

| Campo | Tipo |
| :--- | :--- |
| id_asistencia (PK) | UUID |
| id_sesion (FK) | UUID |
| id_usuario (FK) | UUID |
| hora_ingreso | TIMESTAMP |
| hora_salida | TIMESTAMP |

---

### Evento_Calendario
Eventos personales y compartidos.

| Campo | Tipo |
| :--- | :--- |
| id_evento (PK) | UUID |
| id_usuario (FK) | UUID |
| titulo | VARCHAR |
| descripcion | TEXT |
| fecha_inicio | TIMESTAMP |
| fecha_fin | TIMESTAMP |
| compartido | BOOLEAN |

---

### Apunte
Biblioteca de recursos.

| Campo | Tipo |
| :--- | :--- |
| id_apunte (PK) | UUID |
| id_usuario (FK) | UUID |
| id_materia (FK) | UUID |
| titulo | VARCHAR |
| archivo_url | VARCHAR |
| fecha_subida | TIMESTAMP |

---

### Flashcard
Conjuntos de tarjetas de estudio.

| Campo | Tipo |
| :--- | :--- |
| id_flashcard (PK) | UUID |
| id_usuario (FK) | UUID |
| titulo | VARCHAR |
| compartida | BOOLEAN |
| fecha_creacion | TIMESTAMP |

---

### Tarjeta
Contenido individual de una flashcard.

| Campo | Tipo |
| :--- | :--- |
| id_tarjeta (PK) | UUID |
| id_flashcard (FK) | UUID |
| pregunta | TEXT |
| respuesta | TEXT |

---

### Cuestionario
Evaluaciones académicas.

| Campo | Tipo |
| :--- | :--- |
| id_cuestionario (PK) | UUID |
| id_usuario (FK) | UUID |
| titulo | VARCHAR |
| compartido | BOOLEAN |
| fecha_creacion | TIMESTAMP |

---

### Pregunta
Preguntas del cuestionario.

| Campo | Tipo |
| :--- | :--- |
| id_pregunta (PK) | UUID |
| id_cuestionario (FK) | UUID |
| pregunta | TEXT |
| tipo | ENUM |
| respuesta_correcta | TEXT |

---

### Objetivo
Metas académicas.

| Campo | Tipo |
| :--- | :--- |
| id_objetivo (PK) | UUID |
| id_usuario (FK) | UUID |
| titulo | VARCHAR |
| descripcion | TEXT |
| progreso | INTEGER |
| fecha_limite | DATE |

---

### Logro
Catálogo de insignias.

| Campo | Tipo |
| :--- | :--- |
| id_logro (PK) | UUID |
| nombre | VARCHAR |
| descripcion | TEXT |
| icono | VARCHAR |

---

### Usuario_Logro
Relación entre usuarios y logros.

| Campo | Tipo |
| :--- | :--- |
| id_usuario_logro (PK) | UUID |
| id_usuario (FK) | UUID |
| id_logro (FK) | UUID |
| fecha_obtenido | TIMESTAMP |

---

### Calificacion
Evaluaciones de tutorías.

| Campo | Tipo |
| :--- | :--- |
| id_calificacion (PK) | UUID |
| id_sesion (FK) | UUID |
| id_tutor (FK) | UUID |
| id_tutorado (FK) | UUID |
| puntuacion | INTEGER |
| comentario | TEXT |
| fecha | TIMESTAMP |

---

### Conversacion
Chats privados y grupales.

| Campo | Tipo |
| :--- | :--- |
| id_conversacion (PK) | UUID |
| tipo | ENUM ('Privada', 'Grupal') |

---

### Mensaje
Mensajes enviados.

| Campo | Tipo |
| :--- | :--- |
| id_mensaje (PK) | UUID |
| id_conversacion (FK) | UUID |
| id_usuario (FK) | UUID |
| contenido | TEXT |
| fecha_envio | TIMESTAMP |

---

## Relaciones Principales
* Usuario (1) ------ (N) Solicitud_Estudio
* Usuario (N) ------ (N) Materia
* Usuario (1) ------ (N) Apunte
* Usuario (1) ------ (N) Objetivo
* Usuario (N) ------ (N) Grupo
* Grupo (1) ------ (N) Sesion_Estudio
* Sesion_Estudio (1) ------ (N) Asistencia
* Usuario (1) ------ (N) Evento_Calendario
* Usuario (1) ------ (N) Flashcard
* Flashcard (1) ------ (N) Tarjeta
* Usuario (1) ------ (N) Cuestionario
* Cuestionario (1) ------ (N) Pregunta
* Usuario (N) ------ (N) Logro
* Sesion_Estudio (1) ------ (N) Calificacion
* Conversacion (1) ------ (N) Mensaje
* Usuario (1) ------ (N) Mensaje