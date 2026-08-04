import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../config/routes/app_router.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/ui/snackbar_utils.dart';
import '../../../di.dart';
import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../features/auth/presentation/bloc/auth_event.dart';

/// Logs the user out automatically when an authenticated request comes back
/// with 401 (expired / invalidated session token).
class SessionExpiryInterceptor extends Interceptor {
  bool _isHandling = false;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    final hadAuthToken = err.requestOptions.headers.containsKey('Authorization');

    if (statusCode == 401 && hadAuthToken && !_isHandling) {
      _isHandling = true;
      _handleSessionExpired();
    }

    handler.next(err);
  }

  void _handleSessionExpired() {
    // Clears tokens + user and emits AuthUnauthenticated.
    sl<AuthBloc>().add(LogoutRequested());

    final context = AppRouter.rootNavigatorKey.currentContext;
    if (context != null && context.mounted) {
      SnackBarUtils.showError(context, tr(AppStrings.sessionExpired));
    }

    // Global redirect so logout works from any screen, not only the few
    // that listen for AuthUnauthenticated.
    AppRouter.router.go(AppRoutes.welcomeRouteName);

    _isHandling = false;
  }
}
