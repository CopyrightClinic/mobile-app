import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UpdateProfileUseCase updateProfileUseCase;
  final ChangePasswordUseCase changePasswordUseCase;

  ProfileBloc({required this.updateProfileUseCase, required this.changePasswordUseCase}) : super(ProfileInitial()) {
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<ChangePasswordRequested>(_onChangePasswordRequested);
  }

  Future<void> _onUpdateProfileRequested(UpdateProfileRequested event, Emitter<ProfileState> emit) async {
    emit(UpdateProfileLoading());

    final result = await updateProfileUseCase(UpdateProfileParams(name: event.name, phoneNumber: event.phoneNumber, address: event.address));

    result.fold(
      (failure) => emit(UpdateProfileError(failure.message ?? tr(AppStrings.updateProfileFailed))),
      (profile) => emit(UpdateProfileSuccess(profile, tr(AppStrings.profileUpdatedSuccessfully))),
    );
  }

  Future<void> _onChangePasswordRequested(ChangePasswordRequested event, Emitter<ProfileState> emit) async {
    emit(ChangePasswordLoading());

    final result = await changePasswordUseCase(ChangePasswordParams(currentPassword: event.currentPassword, newPassword: event.newPassword));

    result.fold(
      (failure) => emit(ChangePasswordError(failure.message ?? tr(AppStrings.changePasswordFailed))),
      (message) => emit(ChangePasswordSuccess(message)),
    );
  }
}
