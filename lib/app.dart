import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import 'config/routes/app_router.dart';
import 'config/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'shared_features/theme/data/models/theme_model.dart';
import 'shared_features/theme/view_models/bloc/theme_cubit.dart';
import 'shared_features/localization/view_models/bloc/localization_cubit.dart';
import 'shared_features/localization/data/models/localization_model.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/payments/presentation/bloc/payment_bloc.dart';
import 'features/sessions/presentation/bloc/sessions_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'di.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
        BlocProvider<LocalizationCubit>(create: (context) => LocalizationCubit()),
        BlocProvider<AuthBloc>(create: (context) => sl<AuthBloc>()),
        BlocProvider<PaymentBloc>(create: (context) => sl<PaymentBloc>()),
        BlocProvider<SessionsBloc>(create: (context) => sl<SessionsBloc>()),
        BlocProvider<ProfileBloc>(create: (context) => sl<ProfileBloc>()),
      ],
      child: BlocBuilder<LocalizationCubit, LocalizationModel>(
        builder: (context, localization) {
          if (context.locale != localization.locale) {
            context.setLocale(localization.locale);
          }
          return BlocBuilder<ThemeCubit, ThemeModel>(
            builder: (context, theme) {
              return MaterialApp.router(
                themeMode: theme.themeMode,
                debugShowCheckedModeBanner: false,
                title: tr(AppStrings.appName),
                theme: AppTheme().light,
                darkTheme: AppTheme().dark,
                routerConfig: AppRouter.router,
                locale: context.locale,
                supportedLocales: context.supportedLocales,
                localizationsDelegates: context.localizationDelegates,
              );
            },
          );
        },
      ),
    );
  }
}
