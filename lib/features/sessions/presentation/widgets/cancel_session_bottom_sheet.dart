import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/image_constants.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/global_image.dart';
import '../../../../core/widgets/translated_text.dart';
import '../bloc/sessions_bloc.dart';
import '../bloc/sessions_event.dart';
import '../bloc/sessions_state.dart';

class CancelSessionBottomSheet extends StatelessWidget {
  final String sessionId;
  final String reason;

  const CancelSessionBottomSheet({super.key, required this.sessionId, required this.reason});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionsBloc, SessionsState>(
      listener: (context, state) {
        if (state.lastOperation == SessionsOperation.cancelSession) {
          if (state.hasSuccess) {
            context.pop();
          }
        }
      },
      child: Container(
        color: const Color(0xFF16181E),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: AppTheme.customBackgroundGradient,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(DimensionConstants.radius20Px.r),
              topRight: Radius.circular(DimensionConstants.radius20Px.r),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45.w,
                height: 4.h,
                margin: EdgeInsets.only(top: DimensionConstants.gap12Px.h),
                decoration: BoxDecoration(color: context.white, borderRadius: BorderRadius.circular(2.r)),
              ),
              SizedBox(height: DimensionConstants.gap32Px.h),
              GlobalImage(
                assetPath: ImageConstants.warning,
                width: DimensionConstants.gap48Px.w,
                height: DimensionConstants.gap48Px.h,
                loadingSize: DimensionConstants.gap40Px.w,
              ),
              SizedBox(height: DimensionConstants.gap24Px.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap24Px.w),
                child: Column(
                  children: [
                    TranslatedText(
                      AppStrings.cancelSessionTitle,
                      style: TextStyle(
                        color: context.darkTextPrimary,
                        fontSize: DimensionConstants.font20Px.f,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: DimensionConstants.gap12Px.h),
                    TranslatedText(
                      AppStrings.cancelSessionMessage,
                      style: TextStyle(
                        color: context.darkTextSecondary,
                        fontSize: DimensionConstants.font14Px.f,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: DimensionConstants.gap32Px.h),
              BlocBuilder<SessionsBloc, SessionsState>(
                builder: (context, state) {
                  final isProcessing = state.isProcessingCancel;
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap24Px.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            onPressed: isProcessing ? null : () => context.pop(),
                            backgroundColor: context.buttonSecondary,
                            textColor: context.darkTextPrimary,
                            borderColor: context.buttonSecondary,
                            borderWidth: 1,
                            borderRadius: 50.r,
                            height: 48.h,
                            padding: 0,
                            child: TranslatedText(
                              AppStrings.keepSession,
                              style: TextStyle(fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w600, color: context.darkTextPrimary),
                            ),
                          ),
                        ),
                        SizedBox(width: DimensionConstants.gap12Px.w),
                        Expanded(
                          child: CustomButton(
                            onPressed:
                                isProcessing
                                    ? null
                                    : () {
                                      context.read<SessionsBloc>().add(CancelSessionRequested(sessionId: sessionId, reason: reason));
                                    },
                            isLoading: isProcessing,
                            backgroundColor: context.red,
                            textColor: Colors.white,
                            borderRadius: 50.r,
                            height: 48.h,
                            padding: 0,
                            loadingSize: 20.w,
                            loadingStrokeWidth: 2,
                            child: TranslatedText(
                              AppStrings.cancelSession,
                              style: TextStyle(fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: DimensionConstants.gap24Px.h),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }
}
