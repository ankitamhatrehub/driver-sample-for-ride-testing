import 'package:flutter/material.dart';

import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/unified_button.dart';

class CoinBottomButton extends StatelessWidget {
  const CoinBottomButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.w(20),
        context.h(8),
        context.w(20),
        context.h(16),
      ),
      child: UnifiedButton(label: label, onPressed: onPressed),
    );
  }
}
