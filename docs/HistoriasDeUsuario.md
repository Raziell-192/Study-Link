---

###Archivo 3: `HistoriasDeUsuario.md`

```markdown
# Historias de Usuario - StudyLink

# Épica 1: Gestión de Usuarios

## HU-01 Registro de Usuario
**Como** estudiante universitario  
**Quiero** registrarme utilizando mi matrícula institucional  
**Para** acceder a las funcionalidades de la plataforma.

### Criterios de Aceptación
* El sistema solicita matrícula, nombre completo, correo y contraseña.
* La matrícula no puede estar duplicada.
* El usuario recibe confirmación de registro exitoso.

## HU-02 Inicio de Sesión
**Como** usuario registrado  
**Quiero** iniciar sesión con mis credenciales  
**Para** acceder a mi perfil y recursos académicos.

### Criterios de Aceptación
* El sistema valida las credenciales.
* Se muestra un mensaje de error si son incorrectas.
* El usuario accede a su panel principal.

## HU-03 Gestión de Perfil
**Como** usuario  
**Quiero** editar mi información personal y académica  
**Para** mantener actualizado mi perfil.

---

# Épica 2: Solicitudes y Tutorías

## HU-04 Crear Solicitud de Estudio
**Como** estudiante  
**Quiero** crear una solicitud de ayuda académica  
**Para** encontrar apoyo en un tema específico.

### Criterios de Aceptación
* Se debe seleccionar una materia.
* Se debe indicar el tema.
* Se debe elegir modalidad individual o grupal.

## HU-05 Buscar Tutor
**Como** estudiante  
**Quiero** visualizar tutores recomendados  
**Para** recibir apoyo académico adecuado.

### Criterios de Aceptación
* El sistema muestra tutores relacionados con la materia.
* Se muestran calificaciones y disponibilidad.

## HU-06 Aceptar Tutoría
**Como** tutor  
**Quiero** aceptar solicitudes de estudio  
**Para** brindar apoyo académico a otros estudiantes.

## HU-07 Programar Sesión
**Como** tutor  
**Quiero** programar una sesión de estudio  
**Para** coordinar una reunión académica.

---

# Épica 3: Grupos de Estudio

## HU-08 Crear Grupo
**Como** usuario  
**Quiero** crear un grupo de estudio  
**Para** colaborar con otros estudiantes.

### Criterios de Aceptación
* Debe existir un nombre para el grupo.
* Debe existir una materia asociada.
* El creador se registra automáticamente como miembro.

## HU-09 Unirse a Grupo
**Como** estudiante  
**Quiero** unirme a un grupo existente  
**Para** participar en actividades colaborativas.

## HU-10 Gestionar Miembros
**Como** creador del grupo  
**Quiero** administrar los participantes  
**Para** mantener organizado el grupo.

---

# Épica 4: Biblioteca de Recursos

## HU-11 Subir Apuntes
**Como** usuario  
**Quiero** subir materiales académicos  
**Para** compartir conocimiento con otros estudiantes.

### Criterios de Aceptación
* Debe permitirse subir archivos PDF.
* Debe permitirse subir imágenes.
* El recurso debe asociarse a una materia.

## HU-12 Consultar Biblioteca
**Como** estudiante  
**Quiero** buscar materiales compartidos  
**Para** complementar mi aprendizaje.

## HU-13 Descargar Recursos
**Como** usuario  
**Quiero** descargar apuntes y materiales  
**Para** utilizarlos en mis estudios.

---

# Épica 5: Flashcards y Cuestionarios

## HU-14 Crear Flashcards
**Como** usuario  
**Quiero** crear tarjetas de estudio  
**Para** reforzar mi aprendizaje.

## HU-15 Compartir Flashcards
**Como** usuario  
**Quiero** compartir mis flashcards  
**Para** ayudar a otros estudiantes.

## HU-16 Crear Cuestionario
**Como** usuario  
**Quiero** crear cuestionarios personalizados  
**Para** evaluar mis conocimientos.

## HU-17 Resolver Cuestionario
**Como** estudiante  
**Quiero** responder cuestionarios  
**Para** medir mi comprensión de los temas.

---

# Épica 6: Calendario y Organización

## HU-18 Crear Evento Personal
**Como** usuario  
**Quiero** agregar eventos a mi calendario  
**Para** organizar mis actividades académicas.

## HU-19 Visualizar Calendario Compartido
**Como** miembro de un grupo  
**Quiero** visualizar eventos compartidos  
**Para** conocer las próximas sesiones.

## HU-20 Recibir Recordatorios
**Como** estudiante  
**Quiero** recibir notificaciones automáticas  
**Para** no olvidar mis compromisos académicos.

---

# Épica 7: Comunicación

## HU-21 Enviar Mensajes Privados
**Como** usuario  
**Quiero** comunicarme con otros estudiantes  
**Para** resolver dudas y coordinar actividades.

## HU-22 Participar en Chat Grupal
**Como** miembro de un grupo  
**Quiero** utilizar un chat compartido  
**Para** colaborar con los demás participantes.

---

# Épica 8: Seguimiento Académico

## HU-23 Crear Objetivo Académico
**Como** estudiante  
**Quiero** definir metas de aprendizaje  
**Para** dar seguimiento a mi progreso.

## HU-24 Actualizar Progreso
**Como** usuario  
**Quiero** registrar avances en mis objetivos  
**Para** conocer mi desempeño.

## HU-25 Consultar Estadísticas
**Como** estudiante  
**Quiero** visualizar estadísticas personales  
**Para** evaluar mis hábitos de estudio.

---

# Épica 9: Evaluación y Reputación

## HU-26 Calificar Tutor
**Como** tutorado  
**Quiero** evaluar una tutoría recibida  
**Para** compartir mi experiencia.

## HU-27 Consultar Reputación
**Como** estudiante  
**Quiero** visualizar la reputación de un tutor  
**Para** elegir la mejor opción disponible.

---

# Épica 10: Asistencia

## HU-28 Registrar Asistencia
**Como** tutor  
**Quiero** registrar la asistencia de los participantes  
**Para** llevar control de las sesiones.

## HU-29 Consultar Historial de Asistencia
**Como** estudiante  
**Quiero** revisar mi historial de participación  
**Para** monitorear mi compromiso académico.

---

# Épica 11: Gamificación

## HU-30 Obtener Logros
**Como** usuario  
**Quiero** recibir insignias por mis actividades académicas  
**Para** sentir motivación y reconocimiento.

## HU-31 Consultar Insignias
**Como** usuario  
**Quiero** visualizar mis logros obtenidos  
**Para** conocer mi progreso dentro de la plataforma.

---

# Épica 12: Resiliencia Offline

## HU-32 Repaso de Flashcards sin Conexión
**Como** estudiante en zonas de baja conectividad
**Quiero** acceder a mis flashcards descargadas previamente y responderlas offline
**Para** continuar estudiando sin interrupciones.

### Criterios de Aceptación
* El sistema carga los datos desde la BD Isar local si detecta desconexión.
* Al recuperar señal de internet, los progresos locales se sincronizan inmediatamente con PostgreSQL de forma transparente.

---

# Épica 13: Administración

## HU-33 Gestionar Usuarios
**Como** administrador  
**Quiero** administrar cuentas de usuario  
**Para** garantizar el correcto funcionamiento del sistema.

## HU-34 Moderar Contenido
**Como** administrador  
**Quiero** revisar materiales reportados  
**Para** mantener la calidad de la plataforma.

## HU-35 Consultar Reportes
**Como** administrador  
**Quiero** visualizar métricas generales del sistema  
**Para** apoyar la toma de decisiones.