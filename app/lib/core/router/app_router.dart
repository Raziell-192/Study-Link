import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/registro_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/solicitudes/presentation/pages/solicitudes_lista_page.dart';
import '../../features/grupos/presentation/pages/crear_grupo_page.dart';
import '../../features/grupos/presentation/pages/unirse_grupo_page.dart';
import '../../features/grupos/presentation/pages/grupo_detalle_page.dart';
import '../../features/apuntes/presentation/pages/biblioteca_page.dart';
import '../../features/estadisticas/presentation/pages/estadisticas_page.dart';
import '../../features/logros/presentation/pages/logros_page.dart';
import '../../features/objetivos/presentation/pages/objetivos_page.dart';
import '../../features/calificaciones/presentation/pages/calificar_page.dart';
import '../../features/calificaciones/presentation/pages/reputacion_page.dart';
import '../../features/calendario/presentation/pages/calendario_page.dart';
import '../../features/calendario/presentation/pages/calendario_grupo_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/registro', builder: (context, state) => const RegistroPage()),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/solicitudes/:idMateria',
      builder: (context, state) => SolicitudesListaPage(
        idMateria: state.pathParameters['idMateria']!,
      ),
    ),
    GoRoute(path: '/grupos/crear', builder: (context, state) => const CrearGrupoPage()),
    GoRoute(path: '/grupos/unirse', builder: (context, state) => const UnirseGrupoPage()),
    GoRoute(
      path: '/grupos/:idGrupo',
      builder: (context, state) => GrupoDetallePage(idGrupo: state.pathParameters['idGrupo']!),
    ),
    GoRoute(
      path: '/biblioteca/:idMateria',
      builder: (context, state) => BibliotecaPage(idMateria: state.pathParameters['idMateria']!),
    ),
    GoRoute(path: '/estadisticas', builder: (context, state) => const EstadisticasPage()),
    GoRoute(path: '/logros', builder: (context, state) => const LogrosPage()),
    GoRoute(path: '/objetivos', builder: (context, state) => const ObjetivosPage()),
    GoRoute(path: '/calificar', builder: (context, state) => const CalificarPage()),
    GoRoute(
      path: '/reputacion/:idUsuario',
      builder: (context, state) => ReputacionPage(idUsuario: state.pathParameters['idUsuario']!),
    ),
    GoRoute(path: '/calendario', builder: (context, state) => const CalendarioPage()),
    GoRoute(
      path: '/calendario/grupo/:idGrupo',
      builder: (context, state) => CalendarioGrupoPage(idGrupo: state.pathParameters['idGrupo']!),
    ),

  ],
);