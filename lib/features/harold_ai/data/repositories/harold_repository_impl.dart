import 'package:dartz/dartz.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/exception/custom_exception.dart';

import '../datasources/harold_remote_data_source.dart';
import '../models/harold_request_model.dart';
import '../../domain/entities/harold_evaluation_result.dart';
import '../../domain/repositories/harold_repository.dart';

class HaroldRepositoryImpl implements HaroldRepository {
  final HaroldRemoteDataSource remoteDataSource;

  HaroldRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, HaroldEvaluationResult>> evaluateQuery(String query) async {
    try {
      final request = HaroldEvaluateRequestModel(query: query);
      final response = await remoteDataSource.evaluateQuery(request);

      return Right(response.toEntity());
    } on CustomException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('${AppStrings.unexpectedErrorOccurredWhileEvaluatingQuery}: $e'));
    }
  }
}
