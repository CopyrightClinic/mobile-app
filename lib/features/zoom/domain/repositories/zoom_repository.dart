import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/zoom_meeting_credentials_entity.dart';

abstract class ZoomRepository {
  Future<Either<Failure, ZoomMeetingCredentialsEntity>> getMeetingCredentials(String meetingId);
}
