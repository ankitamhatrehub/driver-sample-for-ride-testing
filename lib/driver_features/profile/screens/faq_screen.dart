import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

const _kycAnswer =
    'KYC helps verify your identity and required documents before you can start driving with Torkk. It ensures a safe and secure platform for all drivers and users, and is required as per regulatory guidelines.';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final _search = TextEditingController();
  String? _topic;
  int? _open;
  bool? _helpful;

  static const _topics = [
    _Topic('KYC & Verification', Icons.description_outlined, [
      _Qa('Why do I need to complete KYC?', _kycAnswer),
      _Qa(
        'What happens after KYC is complete?',
        'Once KYC is approved you can go online and start receiving ride and parcel requests.',
      ),
    ]),
    _Topic('DigiLocker', Icons.lock_outline, [
      _Qa(
        'Why connect DigiLocker?',
        'DigiLocker fetches your Aadhaar and licence so you do not have to upload those documents again.',
      ),
    ]),
    _Topic('Documents', Icons.description_outlined, [
      _Qa(
        'Which documents are required?',
        'Aadhaar, PAN, driving licence, vehicle RC, and a live face check are required before you can drive.',
      ),
    ]),
    _Topic('Bank & Face Verification', Icons.account_balance_outlined, [
      _Qa(
        'Why verify my bank account?',
        'Ride and parcel earnings are sent to the account you verify during onboarding.',
      ),
    ]),
    _Topic('Troubleshooting & Support', Icons.support_agent, [
      _Qa(
        'I cannot go online. What should I do?',
        'Check that location is on, your documents are verified, and you have a stable network connection.',
      ),
    ]),
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<_Topic> get _visible {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return _topics;
    return [
      for (final topic in _topics)
        if (topic.title.toLowerCase().contains(query) ||
            topic.items.any(
              (item) => item.question.toLowerCase().contains(query),
            ))
          topic,
    ];
  }

  @override
  Widget build(BuildContext context) {
    _Topic? topic;
    for (final item in _topics) {
      if (item.title == _topic) topic = item;
    }
    return ProfilePage(
      title: AppStrings.faqs,
      onBack: () {
        if (_topic != null) {
          setState(() {
            _topic = null;
            _open = null;
          });
          return;
        }
        Navigator.of(context).pop();
      },
      bottom: _open == null
          ? null
          : Padding(
              padding: EdgeInsets.fromLTRB(
                context.w(20),
                context.h(8),
                context.w(20),
                context.h(16),
              ),
              child: Column(
                children: [
                  Text(
                    AppStrings.answerHelpful,
                    style: AppTypography.regular.copyWith(
                      fontSize: 13,
                      color: context.torkk.textSecondary,
                    ),
                  ),
                  SizedBox(height: context.h(10)),
                  Row(
                    children: [
                      Expanded(
                        child: _helpButton(
                          context,
                          AppStrings.yes,
                          Icons.thumb_up_alt_outlined,
                          true,
                        ),
                      ),
                      SizedBox(width: context.w(10)),
                      Expanded(
                        child: _helpButton(
                          context,
                          AppStrings.no,
                          Icons.thumb_down_alt_outlined,
                          false,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(4),
          context.w(20),
          context.h(20),
        ),
        children: [
          Text(
            AppStrings.faqSubtitle,
            style: AppTypography.regular.copyWith(
              fontSize: 13,
              color: context.torkk.textSecondary,
            ),
          ),
          SizedBox(height: context.h(12)),
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            style: AppTypography.regular.copyWith(fontSize: 14),
            decoration: InputDecoration(
              hintText: AppStrings.searchQuestions,
              hintStyle: AppTypography.regular.copyWith(
                fontSize: 14,
                color: AppColors.slate400,
              ),
              prefixIcon: const Icon(Icons.search, color: AppColors.slate400),
              filled: true,
              fillColor: context.torkk.surface,
              contentPadding: EdgeInsets.symmetric(vertical: context.h(12)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.r(14)),
                borderSide: BorderSide(color: context.torkk.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.r(14)),
                borderSide: BorderSide(color: context.torkk.border),
              ),
            ),
          ),
          SizedBox(height: context.h(14)),
          if (topic == null)
            for (final item in _visible) ...[
              _outlineRow(
                context,
                icon: item.icon,
                title: item.title,
                onTap: () => setState(() {
                  _topic = item.title;
                  _open = null;
                }),
              ),
              SizedBox(height: context.h(10)),
            ]
          else
            for (var i = 0; i < topic.items.length; i++) ...[
              _questionCard(context, i, topic.items[i]),
              SizedBox(height: context.h(10)),
            ],
        ],
      ),
    );
  }

  Widget _helpButton(
    BuildContext context,
    String label,
    IconData icon,
    bool yes,
  ) {
    final accent = profileAccent(context);
    final selected = _helpful == yes;
    return OutlinedButton.icon(
      onPressed: () => setState(() => _helpful = yes),
      style: OutlinedButton.styleFrom(
        foregroundColor: accent,
        backgroundColor: selected
            ? accent.withValues(alpha: 0.08)
            : Colors.white,
        side: BorderSide(color: accent),
        minimumSize: Size.fromHeight(context.h(44)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.r(12)),
        ),
      ),
      icon: Icon(icon, size: context.w(16)),
      label: Text(
        label,
        style: AppTypography.bold.copyWith(
          fontSize: 14,
          height: 1,
          color: accent,
        ),
      ),
    );
  }

  Widget _outlineRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.r(16)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(14),
          vertical: context.h(14),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.r(16)),
          border: Border.all(color: context.torkk.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: context.w(18), color: context.torkk.textPrimary),
            SizedBox(width: context.w(10)),
            Expanded(
              child: Text(
                title,
                style: AppTypography.regular.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.slate400,
              size: context.w(20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _questionCard(BuildContext context, int index, _Qa item) {
    final open = _open == index;
    return InkWell(
      onTap: () => setState(() => _open = open ? null : index),
      borderRadius: BorderRadius.circular(context.r(16)),
      child: Container(
        padding: EdgeInsets.all(context.w(14)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.r(16)),
          border: Border.all(color: context.torkk.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.question,
                    style: AppTypography.bold.copyWith(
                      fontSize: 14,
                      height: 1.3,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                Icon(
                  open
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.slate400,
                ),
              ],
            ),
            if (open) ...[
              SizedBox(height: context.h(8)),
              Text(
                item.answer,
                style: AppTypography.regular.copyWith(
                  fontSize: 13,
                  height: 1.4,
                  color: context.torkk.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Topic {
  const _Topic(this.title, this.icon, this.items);
  final String title;
  final IconData icon;
  final List<_Qa> items;
}

class _Qa {
  const _Qa(this.question, this.answer);
  final String question;
  final String answer;
}
