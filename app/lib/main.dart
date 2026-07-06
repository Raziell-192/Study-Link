import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/solicitudes/data/repositories/solicitud_repository_impl.dart';
import 'features/solicitudes/domain/repositories/solicitud_repository.dart';
import 'features/solicitudes/presentation/cubit/solicitud_cubit.dart';
import 'features/materia/data/repositories/materia_repository_impl.dart';
import 'features/materia/domain/repositories/materia_repository.dart';
import 'features/grupos/data/repositories/grupo_repository_impl.dart';
import 'features/grupos/domain/repositories/grupo_repository.dart';
import 'features/grupos/presentation/cubit/grupo_cubit.dart';
import 'features/apuntes/data/repositories/apunte_repository_impl.dart';
import 'features/apuntes/domain/repositories/apunte_repository.dart';
import 'features/apuntes/presentation/cubit/apunte_cubit.dart';
import 'features/estadisticas/data/repositories/estadistica_repository_impl.dart';
import 'features/estadisticas/domain/repositories/estadistica_repository.dart';
import 'features/estadisticas/presentation/cubit/estadistica_cubit.dart';
import 'features/logros/data/repositories/logro_repository_impl.dart';
import 'features/logros/domain/repositories/logro_repository.dart';
import 'features/logros/presentation/cubit/logro_cubit.dart';
import 'features/objetivos/data/repositories/objetivo_repository_impl.dart';
import 'features/objetivos/domain/repositories/objetivo_repository.dart';
import 'features/objetivos/presentation/cubit/objetivo_cubit.dart';
import 'features/calificaciones/data/repositories/calificacion_repository_impl.dart';
import 'features/calificaciones/domain/repositories/calificacion_repository.dart';
import 'features/calificaciones/presentation/cubit/calificacion_cubit.dart';
import 'features/calendario/data/repositories/evento_repository_impl.dart';
import 'features/calendario/domain/repositories/evento_repository.dart';
import 'features/calendario/presentation/cubit/evento_cubit.dart';

void main() {
  runApp(const StudyLinkApp());
}

class StudyLinkApp extends StatelessWidget {
  const StudyLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (_) => AuthRepositoryImpl()),
        RepositoryProvider<SolicitudRepository>(create: (_) => SolicitudRepositoryImpl()),
	      RepositoryProvider<MateriaRepository>(create: (_) => MateriaRepositoryImpl()),
	      RepositoryProvider<GrupoRepository>(create: (_) => GrupoRepositoryImpl()),
        RepositoryProvider<ApunteRepository>(create: (_) => ApunteRepositoryImpl()),
        RepositoryProvider<EstadisticaRepository>(create: (_) => EstadisticaRepositoryImpl()),
        RepositoryProvider<LogroRepository>(create: (_) => LogroRepositoryImpl()),
        RepositoryProvider<ObjetivoRepository>(create: (_) => ObjetivoRepositoryImpl()),
        RepositoryProvider<CalificacionRepository>(create: (_) => CalificacionRepositoryImpl()),
        RepositoryProvider<EventoRepository>(create: (_) => EventoRepositoryImpl()),

      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AuthCubit(context.read<AuthRepository>())),
          BlocProvider(create: (context) => SolicitudCubit(context.read<SolicitudRepository>())),
	        BlocProvider(create: (context) => GrupoCubit(context.read<GrupoRepository>())),
          BlocProvider(create: (context) => ApunteCubit(context.read<ApunteRepository>())),
          BlocProvider(create: (context) => EstadisticaCubit(context.read<EstadisticaRepository>())),
          BlocProvider(create: (context) => LogroCubit(context.read<LogroRepository>())),
          BlocProvider(create: (context) => ObjetivoCubit(context.read<ObjetivoRepository>())),
          BlocProvider(create: (context) => CalificacionCubit(context.read<CalificacionRepository>())),
          BlocProvider(create: (context) => EventoCubit(context.read<EventoRepository>())),
          
        ],
        child: MaterialApp.router(
          title: 'StudyLink',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.claro,
          darkTheme: AppTheme.oscuro,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
