class SelectPaymentMethodScreenParams {
  final DateTime sessionDate;
  final String timeSlot;
  final String query;

  const SelectPaymentMethodScreenParams({required this.query, required this.sessionDate, required this.timeSlot});
}
