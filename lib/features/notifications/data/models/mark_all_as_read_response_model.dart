class MarkAllAsReadResponseModel {
  final String message;
  final int markedCount;

  const MarkAllAsReadResponseModel({required this.message, required this.markedCount});

  factory MarkAllAsReadResponseModel.fromJson(Map<String, dynamic> json) {
    return MarkAllAsReadResponseModel(message: json['message'] as String, markedCount: json['markedCount'] as int);
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'markedCount': markedCount};
  }
}
