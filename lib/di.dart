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
import 'features/auth/domain/usecases/send_email_verification_usecase.dart';
import 'features/auth/domain/usecases/verify_password_reset_otp_usecase.dart';
import 'features/auth/domain/usecases/reset_password_usecase.dart';
import 'features/auth/domain/usecases/complete_profile_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/cubit/resend_otp_cubit.dart';
import 'features/payments/data/datasources/payment_remote_data_source.dart';
import 'features/payments/data/repositories/payment_repository_impl.dart';
import 'features/payments/domain/repositories/payment_repository.dart';
import 'features/payments/domain/usecases/add_payment_method_usecase.dart';
import 'features/payments/domain/usecases/get_payment_methods_usecase.dart';
import 'features/payments/domain/usecases/delete_payment_method_usecase.dart';
import 'features/payments/presentation/bloc/payment_bloc.dart';
import 'features/sessions/data/datasources/sessions_remote_data_source.dart';
import 'features/sessions/data/repositories/sessions_repository_impl.dart';
import 'features/sessions/domain/repositories/sessions_repository.dart';
import 'features/sessions/domain/usecases/get_user_sessions_usecase.dart';
import 'features/sessions/domain/usecases/cancel_session_usecase.dart';
import 'features/sessions/domain/usecases/get_session_details_usecase.dart';
import 'features/sessions/domain/usecases/submit_session_feedback_usecase.dart';
import 'features/sessions/domain/usecases/get_session_availability_usecase.dart';
import 'features/sessions/domain/usecases/book_session_usecase.dart';
import 'features/sessions/presentation/bloc/sessions_bloc.dart';
import 'features/sessions/presentation/bloc/session_details_bloc.dart';
import 'features/profile/data/datasources/profile_remote_data_source.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/update_profile_usecase.dart';
import 'features/profile/domain/usecases/change_password_usecase.dart';
import 'features/profile/domain/usecases/delete_account_usecase.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/speech_to_text/data/datasources/speech_to_text_local_data_source.dart';
import 'features/speech_to_text/data/repositories/speech_to_text_repository_impl.dart';
import 'features/speech_to_text/domain/repositories/speech_to_text_repository.dart';
import 'features/speech_to_text/domain/usecases/initialize_speech_recognition_usecase.dart';
import 'features/speech_to_text/domain/usecases/start_speech_recognition_usecase.dart';
import 'features/speech_to_text/domain/usecases/stop_speech_recognition_usecase.dart';
import 'features/speech_to_text/domain/usecases/pause_speech_recognition_usecase.dart';
import 'features/speech_to_text/domain/usecases/resume_speech_recognition_usecase.dart';
import 'features/speech_to_text/presentation/bloc/speech_to_text_bloc.dart';
import 'features/harold_ai/data/datasources/harold_remote_data_source.dart';
import 'features/harold_ai/data/repositories/harold_repository_impl.dart';
import 'features/harold_ai/domain/repositories/harold_repository.dart';
import 'features/harold_ai/domain/usecases/evaluate_query_usecase.dart';
import 'features/harold_ai/presentation/bloc/harold_ai_bloc.dart';
import 'core/services/zoom_service.dart';
import 'features/zoom/data/datasources/zoom_remote_data_source.dart';
import 'features/zoom/data/repositories/zoom_repository_impl.dart';
import 'features/zoom/domain/repositories/zoom_repository.dart';
import 'features/zoom/domain/usecases/get_meeting_credentials_usecase.dart';
import 'features/zoom/presentation/bloc/zoom_bloc.dart';

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

  /// Register Zoom Service as a singleton
  sl.registerLazySingleton(() => ZoomService(sl<ApiService>()));

  // Zoom Data Sources
  sl.registerLazySingleton<ZoomRemoteDataSource>(() => ZoomRemoteDataSourceImpl(apiService: sl()));

  // Zoom Repository
  sl.registerLazySingleton<ZoomRepository>(() => ZoomRepositoryImpl(remoteDataSource: sl()));

  // Zoom Use Cases
  sl.registerLazySingleton(() => GetMeetingCredentialsUseCase(sl()));

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(apiService: sl<ApiService>()));
  sl.registerLazySingleton<PaymentRemoteDataSource>(() => PaymentRemoteDataSourceImpl(apiService: sl<ApiService>()));
  sl.registerLazySingleton<SessionsRemoteDataSource>(() => SessionsRemoteDataSourceImpl(apiService: sl<ApiService>()));
  sl.registerLazySingleton<ProfileRemoteDataSource>(() => ProfileRemoteDataSourceImpl(apiService: sl<ApiService>()));
  sl.registerLazySingleton<SpeechToTextLocalDataSource>(() => SpeechToTextLocalDataSourceImpl());
  sl.registerLazySingleton<HaroldRemoteDataSource>(() => HaroldRemoteDataSourceImpl(apiService: sl<ApiService>()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<PaymentRepository>(() => PaymentRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<SessionsRepository>(() => SessionsRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<SpeechToTextRepository>(() => SpeechToTextRepositoryImpl(localDataSource: sl()));
  sl.registerLazySingleton<HaroldRepository>(() => HaroldRepositoryImpl(remoteDataSource: sl()));

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SignupUseCase(sl()));
  sl.registerLazySingleton(() => VerifyEmailUseCase(sl()));
  sl.registerLazySingleton(() => SendEmailVerificationUseCase(sl()));
  sl.registerLazySingleton(() => VerifyPasswordResetOtpUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => CompleteProfileUseCase(sl()));
  sl.registerLazySingleton(() => AddPaymentMethodUseCase(sl()));
  sl.registerLazySingleton(() => GetPaymentMethodsUseCase(sl()));
  sl.registerLazySingleton(() => DeletePaymentMethodUseCase(sl()));
  sl.registerLazySingleton(() => GetUserSessionsUseCase(sl()));
  sl.registerLazySingleton(() => CancelSessionUseCase(sl()));
  sl.registerLazySingleton(() => GetSessionDetailsUseCase(sl()));
  sl.registerLazySingleton(() => SubmitSessionFeedbackUseCase(sl()));
  sl.registerLazySingleton(() => BookSessionUseCase(sl()));
  sl.registerLazySingleton(() => InitializeSpeechRecognitionUseCase(sl()));
  sl.registerLazySingleton(() => StartSpeechRecognitionUseCase(sl()));
  sl.registerLazySingleton(() => StopSpeechRecognitionUseCase(sl()));
  sl.registerLazySingleton(() => PauseSpeechRecognitionUseCase(sl()));
  sl.registerLazySingleton(() => ResumeSpeechRecognitionUseCase(sl()));
  sl.registerLazySingleton(() => EvaluateQueryUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetSessionAvailabilityUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl()));

  // Bloc
  sl.registerLazySingleton(
    () => AuthBloc(
      loginUseCase: sl(),
      signupUseCase: sl(),
      verifyEmailUseCase: sl(),
      sendEmailVerificationUseCase: sl(),
      verifyPasswordResetOtpUseCase: sl(),
      resetPasswordUseCase: sl(),
      completeProfileUseCase: sl(),
      authRepository: sl(),
    ),
  );

  // Payment Bloc
  sl.registerLazySingleton(() => PaymentBloc(addPaymentMethodUseCase: sl(), getPaymentMethodsUseCase: sl(), deletePaymentMethodUseCase: sl()));

  // Sessions Bloc
  sl.registerLazySingleton(
    () => SessionsBloc(getUserSessionsUseCase: sl(), cancelSessionUseCase: sl(), getSessionAvailabilityUseCase: sl(), bookSessionUseCase: sl()),
  );

  // Session Details Bloc
  sl.registerFactory(() => SessionDetailsBloc(getSessionDetailsUseCase: sl(), cancelSessionUseCase: sl(), submitSessionFeedbackUseCase: sl()));

  // Speech to Text Bloc
  sl.registerFactory(
    () => SpeechToTextBloc(initializeUseCase: sl(), startUseCase: sl(), stopUseCase: sl(), pauseUseCase: sl(), resumeUseCase: sl(), repository: sl()),
  );

  // Harold AI Bloc
  sl.registerLazySingleton(() => HaroldAiBloc(evaluateQueryUseCase: sl()));

  // Profile Bloc
  sl.registerLazySingleton(() => ProfileBloc(updateProfileUseCase: sl(), changePasswordUseCase: sl(), deleteAccountUseCase: sl()));

  // Zoom Bloc
  sl.registerFactory(() => ZoomBloc(zoomService: sl(), getMeetingCredentialsUseCase: sl()));

  // Cubit
  sl.registerFactory(() => ResendOtpCubit());
}
