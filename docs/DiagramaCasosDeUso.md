---

###Archivo 2: `DiagramaCasosDeUso.md`

```markdown
# Diagrama de Casos de Uso - StudyLink

```mermaid
flowchart LR
    Usuario[Estudiante]
    Tutor[Tutor]
    Admin[Administrador]

    UC1((Registrarse))
    UC2((Iniciar Sesión))
    UC3((Gestionar Perfil))
    UC4((Crear Solicitud de Estudio))
    UC5((Buscar Tutor))
    UC6((Unirse a Grupo))
    UC7((Crear Grupo))
    UC8((Participar en Sesión))
    UC9((Gestionar Calendario Personal))
    UC10((Consultar Calendario Compartido))
    UC11((Subir Apuntes))
    UC12((Descargar Apuntes))
    UC13((Crear Flashcards))
    UC14((Crear Cuestionarios))
    UC15((Consultar Estadísticas))
    UC16((Gestionar Objetivos))
    UC17((Enviar Mensajes))
    UC18((Calificar Tutor))
    UC19((Consultar Logros))

    UC20((Aceptar Tutorías))
    UC21((Gestionar Sesiones))
    UC22((Compartir Material))
    UC23((Consultar Reputación))
    UC24((Registrar Asistencia))

    UC25((Gestionar Usuarios))
    UC26((Moderar Contenido))
    UC27((Gestionar Reportes))
    UC28((Administrar Categorías))

    Usuario --> UC1
    Usuario --> UC2
    Usuario --> UC3
    Usuario --> UC4
    Usuario --> UC5
    Usuario --> UC6
    Usuario --> UC7
    Usuario --> UC8
    Usuario --> UC9
    Usuario --> UC10
    Usuario --> UC11
    Usuario --> UC12
    Usuario --> UC13
    Usuario --> UC14
    Usuario --> UC15
    Usuario --> UC16
    Usuario --> UC17
    Usuario --> UC18
    Usuario --> UC19

    Tutor --> UC20
    Tutor --> UC21
    Tutor --> UC22
    Tutor --> UC23
    Tutor --> UC24

    Admin --> UC25
    Admin --> UC26
    Admin --> UC27
    Admin --> UC28