import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../entities/auth_result.dart';
import '../entities/otp_verification_result.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResult>> login(String email, String password);
  Future<Either<Failure, AuthResult>> signup(String email, String password, String confirmPassword);
  Future<Either<Failure, OtpVerificationResult>> verifyEmail(String email, String otp);
  Future<Either<Failure, String>> sendEmailVerification(String email);
  Future<Either<Failure, String>> forgotPassword(String email);
  Future<Either<Failure, String>> verifyPasswordResetOtp(String email, String otp);
  Future<Either<Failure, String>> resetPassword(String email, String otp, String newPassword, String confirmPassword);
  Future<Either<Failure, String>> completeProfile(String name, String phoneNumber, String address);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<UserEntity?> getCurrentUser();
}
