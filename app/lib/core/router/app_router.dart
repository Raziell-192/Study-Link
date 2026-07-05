import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/registro_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/home/presentation/pages/home_page.dart';

/// Rutas actuales (auth + home). Cada épica nueva agrega sus rutas aquí,
/// una sola fuente de verdad de navegación para toda la app.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/registro', builder: (context, state) => const RegistroPage()),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
  ],
);
