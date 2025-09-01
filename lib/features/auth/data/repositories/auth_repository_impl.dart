import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/exception/custom_exception.dart';
import '../../../../core/utils/storage/token_storage.dart';
import '../../../../core/utils/logger/logger.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_request_model.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/otp_verification_result.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AuthResult>> login(String email, String password) async {
    try {
      final request = LoginRequestModel(email: email, password: password);
      Log.d('AuthRepositoryImpl', 'Making login request for email: $email');

      final response = await remoteDataSource.login(request);
      Log.d('AuthRepositoryImpl', 'Login response received: ${response.message}');

      // Save access token
      await TokenStorage.saveAccessToken(response.accessToken);
      Log.d('AuthRepositoryImpl', 'Access token saved successfully');

      return Right(AuthResult(user: response.toEntity(), message: response.message));
    } on CustomException catch (e) {
      Log.e('AuthRepositoryImpl', 'CustomException during login: ${e.message}', StackTrace.current);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      Log.e('AuthRepositoryImpl', 'Unexpected error during login: $e', stackTrace);
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> signup(String email, String password, String confirmPassword) async {
    try {
      final request = SignupRequestModel(email: email, password: password, confirmPassword: confirmPassword);
      Log.d('AuthRepositoryImpl', 'Making signup request for email: $email');

      final response = await remoteDataSource.signup(request);
      Log.d('AuthRepositoryImpl', 'Signup response received: ${response.message}');

      // Save access token
      await TokenStorage.saveAccessToken(response.accessToken);
      Log.d('AuthRepositoryImpl', 'Access token saved successfully');

      return Right(AuthResult(user: response.toEntity(), message: response.message));
    } on CustomException catch (e) {
      Log.e('AuthRepositoryImpl', 'CustomException during signup: ${e.message}', StackTrace.current);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      Log.e('AuthRepositoryImpl', 'Unexpected error during signup: $e', stackTrace);
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, OtpVerificationResult>> verifyEmail(String email, String otp) async {
    try {
      final request = VerifyOtpRequestModel(email: email, otp: otp);
      Log.d('AuthRepositoryImpl', 'Making OTP verification request for email: $email');

      final response = await remoteDataSource.verifyEmail(request);
      Log.d('AuthRepositoryImpl', 'OTP verification response received: ${response.message}');

      return Right(OtpVerificationResult(message: response.message, isValid: response.isVerified));
    } on CustomException catch (e) {
      Log.e('AuthRepositoryImpl', 'CustomException during OTP verification: ${e.message}', StackTrace.current);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      Log.e('AuthRepositoryImpl', 'Unexpected error during OTP verification: $e', stackTrace);
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<void> logout() async {
    await TokenStorage.clearAccessToken();
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await TokenStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    // This would typically fetch user data from local storage or make an API call
    // For now, we'll return null as we need to implement user storage
    return null;
  }

  @override
  Future<Either<Failure, String>> sendEmailVerification(String email) async {
    try {
      final request = SendEmailVerificationRequestModel(email: email);
      final response = await remoteDataSource.sendEmailVerification(request);
      return Right(response.message);
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> forgotPassword(String email) async {
    try {
      final request = ForgotPasswordRequestModel(email: email);
      final response = await remoteDataSource.forgotPassword(request);
      return Right(response.message);
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> verifyPasswordResetOtp(String email, String otp) async {
    try {
      final request = VerifyOtpRequestModel(email: email, otp: otp);
      final response = await remoteDataSource.verifyPasswordResetOtp(request);
      return Right(response.message);
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> resetPassword(String email, String otp, String newPassword, String confirmPassword) async {
    try {
      final request = ResetPasswordRequestModel(email: email, otp: otp, newPassword: newPassword, confirmPassword: confirmPassword);
      final response = await remoteDataSource.resetPassword(request);
      return Right(response.message);
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
