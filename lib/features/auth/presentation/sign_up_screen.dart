import 'package:copyright_clinic_flutter/core/constants/dimensions.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_scaffold.dart';
import 'package:copyright_clinic_flutter/core/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, scrolledUnderElevation: 0),
      body: SafeArea(child: Padding(padding: EdgeInsets.symmetric(horizontal: DimensionConstants.gap24Px.w), child: Column(children: []))),
    );
  }
}
