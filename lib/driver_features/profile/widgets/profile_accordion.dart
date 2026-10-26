import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class ProfileSection {
  const ProfileSection(this.title, this.body, {this.readMore = false});

  final String title;
  final String body;
  final bool readMore;
}

class ProfileAccordion extends StatefulWidget {
  const ProfileAccordion({super.key, required this.sections});

  final List<ProfileSection> sections;

  @override
  State<ProfileAccordion> createState() => _ProfileAccordionState();
}

class _ProfileAccordionState extends State<ProfileAccordion> {
  int? _open;
  bool _readMore = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: context.h(10)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: context.torkk.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < widget.sections.length; i++) ...[
            if (i > 0) Divider(height: 1, color: context.torkk.border),
            InkWell(
              onTap: () => setState(() {
                _open = _open == i ? null : i;
                _readMore = false;
              }),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: context.w(14), vertical: context.h(14)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.sections[i].title,
                            style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Icon(
                          _open == i ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                          color: AppColors.slate400,
                        ),
                      ],
                    ),
                    if (_open == i) ...[
                      SizedBox(height: context.h(8)),
                      Text(
                        widget.sections[i].body,
                        maxLines: widget.sections[i].readMore && !_readMore ? 4 : null,
                        overflow: widget.sections[i].readMore && !_readMore ? TextOverflow.ellipsis : null,
                        style: AppTypography.regular.copyWith(fontSize: 13, height: 1.4, color: context.torkk.textSecondary),
                      ),
                      if (widget.sections[i].readMore && !_readMore)
                        GestureDetector(
                          onTap: () => setState(() => _readMore = true),
                          child: Padding(
                            padding: EdgeInsets.only(top: context.h(4)),
                            child: Text(
                              AppStrings.readMore,
                              style: AppTypography.regular.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: profileAccent(context),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
