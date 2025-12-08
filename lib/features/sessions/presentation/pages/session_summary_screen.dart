import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/extensions/responsive_extensions.dart';
import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../../core/utils/pdf_generator.dart';
import '../../../../core/utils/ui/snackbar_utils.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_back_button.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/translated_text.dart';
import 'params/session_summary_screen_params.dart';

class SessionSummaryScreen extends StatelessWidget {
  final SessionSummaryScreenParams params;

  const SessionSummaryScreen({super.key, required this.params});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        leadingPadding: EdgeInsets.only(left: DimensionConstants.gap12Px.w),
        leading: const CustomBackButton(),
        centerTitle: true,
        title: TranslatedText(
          AppStrings.sessionDetails,
          style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font18Px.f, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap16Px.w, vertical: DimensionConstants.gap20Px.h),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildSummaryContent(context)]),
              ),
            ),
            _buildDownloadButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryContent(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(DimensionConstants.gap20Px.w),
      decoration: BoxDecoration(color: context.filledBgDark, borderRadius: BorderRadius.circular(DimensionConstants.radius16Px.r)),
      child: Text(
        params.aiGeneratedSummary,
        style: TextStyle(color: context.darkTextPrimary, fontSize: DimensionConstants.font14Px.f, fontWeight: FontWeight.w400, height: 1.6),
      ),
    );
  }

  Widget _buildDownloadButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(DimensionConstants.gap16Px.w),
      decoration: BoxDecoration(
        color: context.bottomNavBarBG,
        border: Border(top: BorderSide(color: context.darkTextSecondary.withOpacity(0.1), width: 1)),
      ),
      child: CustomButton(
        onPressed: () => _onDownloadPDF(context),
        backgroundColor: context.primary,
        textColor: Colors.white,
        borderRadius: DimensionConstants.radius52Px.r,
        padding: DimensionConstants.gap16Px.w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.download_rounded, color: Colors.white, size: 20.w),
            SizedBox(width: DimensionConstants.gap8Px.w),
            TranslatedText(
              AppStrings.downloadPDF,
              style: TextStyle(fontSize: DimensionConstants.font16Px.f, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onDownloadPDF(BuildContext context) async {
    try {
      await PdfGenerator.generateAndDownloadSessionSummaryPdf(sessionId: params.sessionId, summaryContent: params.aiGeneratedSummary);
    } catch (e) {
      if (context.mounted) {
        SnackBarUtils.showError(context, AppStrings.failedToGeneratePDF);
      }
    }
  }
}
