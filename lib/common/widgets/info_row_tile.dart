import 'package:flutter/material.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

/// A reusable row displaying an icon, a label, and a value.
///
/// Used across profile, documents, settings, and summary screens
/// wherever key-value information is displayed in a list.
class InfoRowTile extends StatelessWidget {
  const InfoRowTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.iconBgColor,
    this.labelStyle,
    this.valueStyle,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(vertical: 10),
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final Color? iconBgColor;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: padding,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBgColor ?? context.adaptiveTint(Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: iconColor ?? const Color(0xFF6366F1),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: labelStyle ??
                      TextStyle(
                        fontSize: 12,
                        color: context.torkk.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: valueStyle ??
                      TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.torkk.textPrimary,
                      ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: row,
      );
    }
    return row;
  }
}
