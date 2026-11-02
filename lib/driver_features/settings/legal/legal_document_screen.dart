import 'package:flutter/material.dart';

import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';

/// One piece of a legal document: a section heading or a paragraph.
class LegalBlock {
  const LegalBlock.heading(this.text) : isHeading = true;
  const LegalBlock.text(this.text) : isHeading = false;

  final String text;
  final bool isHeading;
}

/// Shared page for the policy and agreement screens in this folder.
class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.blocks,
  });

  final String title;
  final List<LegalBlock> blocks;

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: title,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(8),
          context.w(20),
          context.h(32),
        ),
        itemCount: blocks.length,
        itemBuilder: (context, index) {
          final block = blocks[index];
          if (block.isHeading) {
            return Padding(
              padding: EdgeInsets.only(
                top: context.h(18),
                bottom: context.h(8),
              ),
              child: Text(
                block.text,
                style: AppTypography.bold.copyWith(
                  fontSize: 16,
                  height: 1.3,
                  color: context.torkk.textPrimary,
                ),
              ),
            );
          }
          return Padding(
            padding: EdgeInsets.only(bottom: context.h(10)),
            child: Text(
              block.text,
              style: AppTypography.regular.copyWith(
                fontSize: 14,
                height: 1.5,
                color: context.torkk.textSecondary,
              ),
            ),
          );
        },
      ),
    );
  }
}
