// ignore_for_file: constant_identifier_names

enum AuthEndpoint {
  SIGNUP, // POST /auth/signup
  LOGIN, // POST /auth/login
  VERIFY_EMAIL, // POST /auth/verify-email
  SEND_EMAIL_VERIFICATION, // POST /auth/send-email-verification
  FORGOT_PASSWORD, // POST /auth/forgot-password
  VERIFY_OTP, // POST /auth/verify-otp
  RESET_PASSWORD, // POST /auth/reset-password
}
