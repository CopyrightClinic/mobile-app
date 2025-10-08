import 'package:dartz/dartz.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/exception/custom_exception.dart';
import '../../domain/entities/zoom_meeting_credentials_entity.dart';
import '../../domain/repositories/zoom_repository.dart';
import '../datasources/zoom_remote_data_source.dart';

class ZoomRepositoryImpl implements ZoomRepository {
  final ZoomRemoteDataSource remoteDataSource;

  ZoomRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ZoomMeetingCredentialsEntity>> getMeetingCredentials(String meetingId) async {
    try {
      final credentials = await remoteDataSource.getMeetingCredentials(meetingId);
      return Right(credentials.toEntity());
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('${AppStrings.zoomErrorFetchCredentials}: $e'));
    }
  }
}
