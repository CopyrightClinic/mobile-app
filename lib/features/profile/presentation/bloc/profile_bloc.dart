import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/storage/user_storage.dart';
import '../../domain/entities/profile_entity.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UpdateProfileUseCase updateProfileUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;

  ProfileBloc({required this.updateProfileUseCase, required this.changePasswordUseCase, required this.deleteAccountUseCase})
    : super(ProfileInitial()) {
    on<GetProfileRequested>(_onGetProfileRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<ChangePasswordRequested>(_onChangePasswordRequested);
    on<DeleteAccountRequested>(_onDeleteAccountRequested);
  }

  Future<void> _onGetProfileRequested(GetProfileRequested event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());

    try {
      final user = await UserStorage.getUser();
      if (user != null) {
        final profile = ProfileEntity(
          id: user.id,
          name: user.name,
          email: user.email,
          phoneNumber: user.phoneNumber,
          address: user.address,
          createdAt: user.createdAt,
          updatedAt: user.updatedAt,
        );
        emit(ProfileLoaded(profile));
      } else {
        emit(ProfileError(tr(AppStrings.userNotFound)));
      }
    } catch (e) {
      emit(ProfileError(tr(AppStrings.failedToLoadProfile)));
    }
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

  Future<void> _onDeleteAccountRequested(DeleteAccountRequested event, Emitter<ProfileState> emit) async {
    emit(DeleteAccountLoading());

    final result = await deleteAccountUseCase(NoParams());

    result.fold(
      (failure) => emit(DeleteAccountError(failure.message ?? tr(AppStrings.deleteAccountFailed))),
      (message) => emit(DeleteAccountSuccess(message)),
    );
  }
}
