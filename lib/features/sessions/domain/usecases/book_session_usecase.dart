import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/book_session_response_entity.dart';
import '../repositories/sessions_repository.dart';

class BookSessionParams extends Equatable {
  final String stripePaymentMethodId;
  final String date;
  final String startTime;
  final String endTime;
  final String summary;
  final String timezone;

  const BookSessionParams({
    required this.stripePaymentMethodId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.summary,
    required this.timezone,
  });

  @override
  List<Object> get props => [stripePaymentMethodId, date, startTime, endTime, summary, timezone];
}

class BookSessionUseCase implements UseCase<BookSessionResponseEntity, BookSessionParams> {
  final SessionsRepository repository;

  BookSessionUseCase(this.repository);

  @override
  Future<Either<Failure, BookSessionResponseEntity>> call(BookSessionParams params) async {
    return await repository.bookSession(
      stripePaymentMethodId: params.stripePaymentMethodId,
      date: params.date,
      startTime: params.startTime,
      endTime: params.endTime,
      summary: params.summary,
      timezone: params.timezone,
    );
  }
}
