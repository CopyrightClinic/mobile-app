import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/ui/snackbar_utils.dart';
import '../../../../core/widgets/translated_text.dart';
import '../bloc/zoom_bloc.dart';
import '../bloc/zoom_event.dart';
import '../bloc/zoom_state.dart';

class ZoomConnectionDialog {
  static void show(BuildContext context, String sessionId, ZoomBloc zoomBloc) {
    zoomBloc.add(JoinMeetingWithId(meetingId: sessionId));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: zoomBloc,
          child: BlocListener<ZoomBloc, ZoomState>(
            listener: (ctx, state) {
              if (state is ZoomMeetingActive) {
                if (Navigator.of(ctx).canPop()) {
                  Navigator.of(ctx).pop();
                }
              } else if (state is ZoomMeetingFailed) {
                if (state.message == 'success') {
                  if (Navigator.of(ctx).canPop()) {
                    Navigator.of(ctx).pop();
                  }
                } else {
                  if (Navigator.of(ctx).canPop()) {
                    Navigator.of(ctx).pop();
                  }
                  SnackBarUtils.showError(context, state.message);
                }
              }
            },
            child: BlocBuilder<ZoomBloc, ZoomState>(
              builder: (ctx, state) {
                String message = AppStrings.zoomConnectingMessage;
                if (state is ZoomFetchingCredentials) {
                  message = AppStrings.loadingMeetingDetails;
                } else if (state is ZoomInitializing) {
                  message = AppStrings.zoomInitializing;
                } else if (state is ZoomJoining) {
                  message = AppStrings.connectingToMeeting;
                }

                return Dialog(
                  child: Padding(
                    padding: EdgeInsets.all(DimensionConstants.gap24Px.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        SizedBox(height: DimensionConstants.gap16Px.h),
                        TranslatedText(message, textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
