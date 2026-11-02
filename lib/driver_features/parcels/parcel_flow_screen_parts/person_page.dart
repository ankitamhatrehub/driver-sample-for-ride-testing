part of 'package:rider_app/driver_features/parcels/parcel_flow_screen.dart';

class _PersonPage extends StatelessWidget {
  const _PersonPage({required this.sender});

  final bool sender;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final name = sender ? 'Rahul' : 'Amit';
    final role = sender ? 'Sender' : 'Receiver';
    final addressTitle = sender ? 'Pickup Address' : 'Drop Address';
    final address = sender ? 'Sector 18, Noida' : 'DLF Mall of India';
    return Scaffold(
      backgroundColor: context.torkk.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.w(8),
                context.h(4),
                context.w(16),
                0,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: context.torkk.textPrimary,
                    ),
                  ),
                  Text(
                    sender ? 'Sender Details' : 'Receiver Details',
                    style: AppTypography.bold.copyWith(
                      fontSize: 18,
                      height: 1.2,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  context.w(20),
                  context.h(8),
                  context.w(20),
                  context.h(20),
                ),
                children: [
                  Container(
                    padding: EdgeInsets.all(context.w(12)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(context.r(14)),
                      border: Border.all(color: context.torkk.border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: context.adaptiveTint(
                            const Color(0xFFF1F5F9),
                          ),
                          child: Icon(Icons.person, color: AppColors.slate400),
                        ),
                        SizedBox(width: context.w(10)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                role,
                                style: AppTypography.regular.copyWith(
                                  fontSize: 12,
                                  color: context.torkk.textSecondary,
                                ),
                              ),
                              Text(
                                name,
                                style: AppTypography.bold.copyWith(
                                  fontSize: 15,
                                  height: 1.2,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: context.adaptiveTint(
                              const Color(0xFFDCFCE7),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Verified User',
                            style: AppTypography.regular.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: context.legible(Color(0xFF16A34A)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.h(16)),
                  Text(
                    'Contact Information',
                    style: AppTypography.regular.copyWith(
                      fontSize: 13,
                      color: context.torkk.textSecondary,
                    ),
                  ),
                  SizedBox(height: context.h(8)),
                  _detailRow(
                    context,
                    Icons.phone_outlined,
                    accent,
                    'Phone number',
                    '565656565',
                  ),
                  SizedBox(height: context.h(8)),
                  _detailRow(
                    context,
                    Icons.chat_bubble_outline,
                    accent,
                    'Message',
                    'Chat with Receiver',
                  ),
                  SizedBox(height: context.h(16)),
                  Text(
                    addressTitle,
                    style: AppTypography.regular.copyWith(
                      fontSize: 13,
                      color: context.torkk.textSecondary,
                    ),
                  ),
                  SizedBox(height: context.h(8)),
                  Container(
                    padding: EdgeInsets.all(context.w(12)),
                    decoration: BoxDecoration(
                      color: context.adaptiveTint(const Color(0xFFF0FDF4)),
                      borderRadius: BorderRadius.circular(context.r(14)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: context.legible(Color(0xFF16A34A)),
                        ),
                        SizedBox(width: context.w(8)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              address,
                              style: AppTypography.bold.copyWith(
                                color: context.torkk.textPrimary,
                                fontSize: 14,
                                height: 1.2,
                              ),
                            ),
                            Text(
                              'Noida',
                              style: AppTypography.regular.copyWith(
                                fontSize: 12,
                                color: context.torkk.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    BuildContext context,
    IconData icon,
    Color color,
    String label,
    String value,
  ) {
    return Container(
      padding: EdgeInsets.all(context.w(12)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(14)),
        border: Border.all(color: context.torkk.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          SizedBox(width: context.w(10)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.regular.copyWith(
                  fontSize: 11,
                  color: AppColors.slate400,
                ),
              ),
              Text(
                value,
                style: AppTypography.bold.copyWith(
                  fontSize: 14,
                  height: 1.2,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
