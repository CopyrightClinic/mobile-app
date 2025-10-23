// ignore_for_file: constant_identifier_names

enum SessionsEndpoint {
  USER_SESSIONS, // GET /user/sessions
  SESSION_DETAILS, // GET /user/session-details
  SESSION_FEEDBACK, // PATCH /user/session/feedback
  SESSIONS_AVAILABILITY, // GET /sessions-availability
  BOOK_SESSION, // POST /session-requests/book-session
  SESSION_SUMMARY, // POST /session-summary
  CANCEL_SESSION, // POST /sessions/{sessionId}/cancel
}
