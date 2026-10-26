import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/screens/tickets_screen.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _input = TextEditingController();
  final _messages = <_Chat>[
    const _Chat('How can I help you today?', false, '10:25 AM'),
    const _Chat('I\'m facing an issue with my parcel', true, '10:25 AM'),
    const _Chat('I can help , What is the issue ?', false, '10:25 AM', chips: [
      'Parcel Delayed',
      'Wrong Address',
      'Product Unavailable',
      'Wrong Item',
    ]),
    const _Chat('Parcel Delayed', true, '10:25 AM'),
    const _Chat('Here are few things you can do..', false, '10:25 AM', actions: ['Track Parcel', 'Report a Problem']),
  ];

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _send(String text) {
    final message = text.trim();
    if (message.isEmpty) return;
    setState(() {
      _messages.add(_Chat(message, true, '10:25 AM'));
      _input.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = profileAccent(context);
    return ProfilePage(
      title: AppStrings.helpSupport,
      trailing: TextButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const TicketsScreen()),
          );
        },
        child: Text(AppStrings.myTickets, style: AppTypography.regular.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: accent)),
      ),
      bottom: Padding(
        padding: EdgeInsets.fromLTRB(context.w(16), context.h(8), context.w(16), context.h(12)),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _input,
                onSubmitted: _send,
                style: AppTypography.regular.copyWith(fontSize: 14),
                decoration: InputDecoration(
                  hintText: AppStrings.typeMessage,
                  hintStyle: AppTypography.regular.copyWith(fontSize: 14, color: AppColors.slate400),
                  contentPadding: EdgeInsets.symmetric(horizontal: context.w(16), vertical: context.h(12)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(context.r(24)),
                    borderSide: BorderSide(color: context.torkk.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(context.r(24)),
                    borderSide: BorderSide(color: context.torkk.border),
                  ),
                ),
              ),
            ),
            SizedBox(width: context.w(8)),
            GestureDetector(
              onTap: () => _send(_input.text),
              child: Container(
                width: context.w(44),
                height: context.w(44),
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                child: Icon(Icons.send_rounded, color: Theme.of(context).colorScheme.onPrimary, size: 18),
              ),
            ),
          ],
        ),
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(16), context.h(8), context.w(16), context.h(12)),
        children: [for (final message in _messages) _bubble(context, accent, message)],
      ),
    );
  }

  Widget _bubble(BuildContext context, Color accent, _Chat message) {
    final mine = message.mine;
    return Padding(
      padding: EdgeInsets.only(bottom: context.h(10)),
      child: Column(
        crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!mine) ...[
                CircleAvatar(
                  radius: context.w(14),
                  backgroundColor: accent.withValues(alpha: 0.12),
                  child: Icon(Icons.smart_toy_outlined, size: context.w(14), color: accent),
                ),
                SizedBox(width: context.w(8)),
              ],
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.h(10)),
                  decoration: BoxDecoration(
                    color: mine ? accent.withValues(alpha: 0.12) : context.torkk.surface,
                    borderRadius: BorderRadius.circular(context.r(16)),
                    border: mine ? null : Border.all(color: context.torkk.border),
                  ),
                  child: Text(message.text, style: AppTypography.regular.copyWith(fontSize: 13, height: 1.35)),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: context.h(2), left: mine ? 0 : context.w(36)),
            child: Text(message.time, style: AppTypography.regular.copyWith(fontSize: 10, color: AppColors.slate400)),
          ),
          if (message.chips.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: context.w(36), top: context.h(8)),
              child: Wrap(
                spacing: context.w(8),
                runSpacing: context.h(8),
                children: [
                  for (final chip in message.chips)
                    GestureDetector(
                      onTap: () => _send(chip),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.h(8)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(context.r(20)),
                          border: Border.all(color: accent),
                        ),
                        child: Text(chip, style: AppTypography.regular.copyWith(fontSize: 12, color: accent)),
                      ),
                    ),
                ],
              ),
            ),
          if (message.actions.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: context.w(36), top: context.h(8)),
              child: Column(
                children: [
                  for (final action in message.actions)
                    GestureDetector(
                      onTap: action == 'Report a Problem'
                          ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(builder: (_) => const IssueCategoryScreen()),
                              );
                            }
                          : null,
                      child: Container(
                      margin: EdgeInsets.only(bottom: context.h(8)),
                      padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.h(12)),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(context.r(14)),
                        border: Border.all(color: context.torkk.border),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            action == 'Track Parcel' ? Icons.inventory_2_rounded : Icons.chat_bubble_outline_rounded,
                            color: const Color(0xFFF59E0B),
                            size: context.w(18),
                          ),
                          SizedBox(width: context.w(8)),
                          Expanded(child: Text(action, style: AppTypography.regular.copyWith(fontSize: 13, fontWeight: FontWeight.w600))),
                          Icon(Icons.chevron_right_rounded, color: AppColors.slate400, size: context.w(18)),
                        ],
                      ),
                    ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Chat {
  const _Chat(this.text, this.mine, this.time, {this.chips = const [], this.actions = const []});

  final String text;
  final bool mine;
  final String time;
  final List<String> chips;
  final List<String> actions;
}
