import 'package:equatable/equatable.dart';

class BookSessionCardEntity extends Equatable {
  final String brand;
  final String last4;
  final int expMonth;
  final int expYear;

  const BookSessionCardEntity({required this.brand, required this.last4, required this.expMonth, required this.expYear});

  @override
  List<Object> get props => [brand, last4, expMonth, expYear];
}

class BookSessionPaymentMethodEntity extends Equatable {
  final String id;
  final String type;
  final BookSessionCardEntity card;

  const BookSessionPaymentMethodEntity({required this.id, required this.type, required this.card});

  @override
  List<Object> get props => [id, type, card];
}

class BookSessionRequestEntity extends Equatable {
  final String id;
  final String userId;
  final String requestedDate;
  final String startTime;
  final String endTime;
  final String status;
  final String? acceptedBy;
  final DateTime expiresAt;
  final BookSessionPaymentMethodEntity? paymentMethod;
  final String? summary;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookSessionRequestEntity({
    required this.id,
    required this.userId,
    required this.requestedDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.acceptedBy,
    required this.expiresAt,
    this.paymentMethod,
    this.summary,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    requestedDate,
    startTime,
    endTime,
    status,
    acceptedBy,
    expiresAt,
    paymentMethod,
    summary,
    createdAt,
    updatedAt,
  ];
}

class BookSessionAvailableAttorneyEntity extends Equatable {
  final String id;
  final String name;
  final String email;

  const BookSessionAvailableAttorneyEntity({required this.id, required this.name, required this.email});

  @override
  List<Object> get props => [id, name, email];
}

class BookSessionDataEntity extends Equatable {
  final BookSessionRequestEntity sessionRequest;
  final List<BookSessionAvailableAttorneyEntity> availableAttorneys;

  const BookSessionDataEntity({required this.sessionRequest, required this.availableAttorneys});

  @override
  List<Object> get props => [sessionRequest, availableAttorneys];
}

class BookSessionResponseEntity extends Equatable {
  final String message;
  final BookSessionDataEntity data;

  const BookSessionResponseEntity({required this.message, required this.data});

  @override
  List<Object> get props => [message, data];
}
