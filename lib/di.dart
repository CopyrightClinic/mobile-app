import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'core/network/api_service/api_service.dart';
import 'core/network/dio_service.dart';
import 'core/network/endpoints/api_endpoints.dart';
import 'core/network/interceptors/api_interceptor.dart';
import 'core/network/interceptors/logging_interceptor.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/signup_usecase.dart';
import 'features/auth/domain/usecases/verify_email_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/cubit/resend_otp_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core & Network

  /// Register Dio as a singleton
  sl.registerLazySingleton<Dio>(() {
    final baseOptions = BaseOptions(baseUrl: ApiEndpoint.baseUrl);
    return Dio(baseOptions);
  });

  /// Register Dio Service as a singleton
  sl.registerLazySingleton<DioService>(() {
    final cacheOptions = CacheOptions(policy: CachePolicy.noCache, maxStale: const Duration(days: 30), store: MemCacheStore());
    return DioService(
      dioClient: sl<Dio>(),
      globalCacheOptions: cacheOptions,
      interceptors: [
        ApiInterceptor(),
        DioCacheInterceptor(options: cacheOptions),
        if (kDebugMode) LoggingInterceptor(),
        // RefreshTokenInterceptor(dioClient: sl<Dio>()),
      ],
    );
  });

  /// Register API Service as a singleton
  sl.registerLazySingleton<ApiService>(() => ApiService(sl<DioService>()));

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(apiService: sl<ApiService>()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl()));

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SignupUseCase(sl()));
  sl.registerLazySingleton(() => VerifyEmailUseCase(sl()));

  // Bloc
  sl.registerFactory(() => AuthBloc(loginUseCase: sl(), signupUseCase: sl(), verifyEmailUseCase: sl(), authRepository: sl()));

  // Cubit
  sl.registerFactory(() => ResendOtpCubit());
}
