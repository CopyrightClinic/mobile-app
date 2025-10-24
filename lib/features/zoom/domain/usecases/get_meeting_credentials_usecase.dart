import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/zoom_meeting_credentials_entity.dart';
import '../repositories/zoom_repository.dart';

class GetMeetingCredentialsUseCase {
  final ZoomRepository repository;

  GetMeetingCredentialsUseCase(this.repository);

  Future<Either<Failure, ZoomMeetingCredentialsEntity>> call(String meetingId) async {
    return await repository.getMeetingCredentials(meetingId);
  }
}
