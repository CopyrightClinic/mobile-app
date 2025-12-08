class ClearAllNotificationsResponseModel {
  final String message;
  final int clearedCount;

  const ClearAllNotificationsResponseModel({required this.message, required this.clearedCount});

  factory ClearAllNotificationsResponseModel.fromJson(Map<String, dynamic> json) {
    return ClearAllNotificationsResponseModel(message: json['message'], clearedCount: json['clearedCount']);
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'clearedCount': clearedCount};
  }
}

