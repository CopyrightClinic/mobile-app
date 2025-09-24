import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileBloc({required this.updateProfileUseCase}) : super(ProfileInitial()) {
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
  }

  Future<void> _onUpdateProfileRequested(UpdateProfileRequested event, Emitter<ProfileState> emit) async {
    emit(UpdateProfileLoading());

    final result = await updateProfileUseCase(UpdateProfileParams(name: event.name, phoneNumber: event.phoneNumber, address: event.address));

    result.fold(
      (failure) => emit(UpdateProfileError(failure.message ?? tr(AppStrings.updateProfileFailed))),
      (profile) => emit(UpdateProfileSuccess(profile, tr(AppStrings.profileUpdatedSuccessfully))),
    );
  }
}
