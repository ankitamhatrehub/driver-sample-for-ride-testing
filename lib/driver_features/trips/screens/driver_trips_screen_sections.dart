part of 'package:rider_app/driver_features/trips/screens/driver_trips_screen.dart';

extension _DriverTripsScreenStateSections on _DriverTripsScreenState {
  void _showInvoiceDialog(BuildContext context, Map<String, dynamic> trip) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: context.torkk.surface,
        elevation: 16,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: Color(0xFF6366F1),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trip Invoice',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: context.torkk.textPrimary,
                          ),
                        ),
                        Text(
                          'Ride #${trip['id'] ?? ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.torkk.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: context.torkk.surfaceMuted,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: context.torkk.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: context.torkk.surfaceMuted,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.torkk.border),
                        ),
                        child: Column(
                          children: [
                            _invoiceRow(
                              'Customer',
                              trip['customer_name'] ?? 'Customer',
                            ),
                            const SizedBox(height: 6),
                            _invoiceRow(
                              'Date',
                              trip['date']?.toString().split('T').first ?? '',
                            ),
                            const SizedBox(height: 6),
                            _invoiceRow(
                              'Vehicle',
                              trip['vehicle_type']?.toUpperCase() ?? 'CAB',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: context.torkk.surfaceMuted,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.torkk.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ROUTE DETAILS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: context.legible(Color(0xFF6366F1)),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.radio_button_checked,
                                  size: 16,
                                  color: Color(0xFF10B981),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    trip['pickup_address'] ?? 'Pickup Address',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.torkk.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 7),
                              child: SizedBox(
                                height: 14,
                                child: VerticalDivider(
                                  color: Color(0xFFCBD5E1),
                                  thickness: 1.5,
                                ),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 16,
                                  color: Color(0xFFEF4444),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    trip['drop_address'] ?? 'Drop Address',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.torkk.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: context.torkk.surfaceMuted,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.torkk.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FARE BREAKDOWN',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: context.legible(Color(0xFF6366F1)),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _invoiceRow(
                              'Estimated Distance',
                              '${trip['distance_km'] ?? '0.0'} km',
                            ),
                            const SizedBox(height: 6),
                            _invoiceRow(
                              'Total Customer Fare',
                              '₹${(trip['fare'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                            ),
                            Divider(height: 18, color: context.torkk.border),
                            _invoiceRow(
                              'Your Earnings',
                              '₹${(trip['driver_earnings'] as num?)?.toStringAsFixed(2) ?? (trip['fare'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                              isBold: true,
                              color: const Color(0xFF10B981),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: trip['status'] == 'completed'
                                ? const Color(
                                    0xFF10B981,
                                  ).withValues(alpha: 0.12)
                                : const Color(
                                    0xFFEF4444,
                                  ).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            trip['status']?.toUpperCase() ?? 'COMPLETED',
                            style: TextStyle(
                              color: trip['status'] == 'completed'
                                  ? const Color(0xFF059669)
                                  : const Color(0xFFDC2626),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(
                      color: Color(0xFFCBD5E1),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    foregroundColor: context.legible(Color(0xFF475569)),
                  ),
                  child: const Text(
                    'Close Invoice',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _invoiceRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: context.torkk.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? context.themed(light: Colors.black87, dark: context.torkk.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripList(List<dynamic> filteredTrips) {
    if (filteredTrips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.blueGrey.shade200),
            const SizedBox(height: 16),
            Text(
              'No trips found',
              style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTrips,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredTrips.length,
        itemBuilder: (context, index) {
          final trip = filteredTrips[index];
          final date = trip['date']?.toString().split('T').first ?? '';
          final status = trip['status']?.toString() ?? '';
          final isCompleted = status == 'completed';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: (isCompleted ? Colors.green : Colors.red)
                    .withValues(alpha: 0.15),
                child: Icon(
                  isCompleted
                      ? Icons.check_circle_outline_rounded
                      : Icons.cancel_outlined,
                  color: isCompleted ? Colors.green : Colors.red,
                  size: 24,
                ),
              ),
              title: Text(
                '${trip['pickup_address'] ?? 'Pickup'} → ${trip['drop_address'] ?? 'Drop'}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              subtitle: Text(
                '$date • ${trip['customer_name'] ?? 'Customer'}',
                style: const TextStyle(fontSize: 11),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '₹${(trip['driver_earnings'] as num?)?.toStringAsFixed(2) ?? (trip['fare'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? const Color(0xFF10B981) : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: context.themed(light: Colors.blueGrey, dark: context.torkk.textSecondary),
                    ),
                    onPressed: () => _showInvoiceDialog(context, trip),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
