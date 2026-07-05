import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

void main() {
  runApp(const StudyLinkApp());
}

class StudyLinkApp extends StatelessWidget {
  const StudyLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthRepository>(
      create: (_) => AuthRepositoryImpl(),
      child: BlocProvider(
        create: (context) => AuthCubit(context.read<AuthRepository>()),
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
