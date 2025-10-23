class MarkAllAsReadResponseModel {
  final String message;
  final int markedCount;

  const MarkAllAsReadResponseModel({required this.message, required this.markedCount});

  factory MarkAllAsReadResponseModel.fromJson(Map<String, dynamic> json) {
    return MarkAllAsReadResponseModel(message: json['message'], markedCount: json['markedCount']);
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'markedCount': markedCount};
  }
}
