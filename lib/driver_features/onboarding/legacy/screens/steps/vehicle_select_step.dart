import 'package:flutter/material.dart';
import '../../../../../common/widgets/bouncing_widget.dart';

class VehicleSelectStep extends StatelessWidget {
  final Color primaryColor;
  final String selectedVehicleType;
  final ValueChanged<String> onVehicleSelected;
  final VoidCallback onContinue;

  const VehicleSelectStep({
    super.key,
    required this.primaryColor,
    required this.selectedVehicleType,
    required this.onVehicleSelected,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> vehicles = [
      {
        'name': 'Bike',
        'subtitle': '2 Wheeler',
        'image': 'assets/bike.png',
      },
      {
        'name': 'Auto',
        'subtitle': '3 Wheeler',
        'image': 'assets/auto.png',
      },
      {
        'name': 'Cab',
        'subtitle': '4 Wheeler',
        'image': 'assets/cab.png',
      },
      {
        'name': 'Cab EV',
        'subtitle': '4 Wheeler',
        'image': 'assets/ev_cab.png',
      },
      {
        'name': 'Cab XL',
        'subtitle': '4 Wheeler',
        'image': 'assets/xl_cab.png',
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const Text(
            'Select your Vehicle',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
              height: 1.1,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose a vehicle you want to drive',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                final bool isSelected =
                    selectedVehicleType == vehicle['name'] ||
                    (selectedVehicleType.isEmpty && index == 0);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: BouncingWidget(
                    onTap: () => onVehicleSelected(vehicle['name']!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFF8FAFC)
                            : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFE5E7EB),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 48,
                            padding: const EdgeInsets.only(right: 8),
                            child: Image.asset(
                              vehicle['image']!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.directions_car_rounded,
                                size: 36,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vehicle['name']!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  vehicle['subtitle']!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          BouncingWidget(
            onTap: onContinue,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF27272A),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SelectVehicleFaqBottomSheet extends StatelessWidget {
  const SelectVehicleFaqBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final faqItems = [
      {
        'q': 'What types of two-wheelers can I register?',
        'a':
            'You can register eligible bikes, scooters, electric bikes, and electric scooters (EV). Select Bike if your vehicle is a 2-wheeler.',
      },
      {
        'q': 'Can I register an EV or electric vehicle?',
        'a':
            'Yes. Electric vehicles are supported. You can register an electric bike/scooter under Bike, or an electric auto under Auto, provided the vehicle meets Torkk\'s requirements.',
      },
      {
        'q': 'What types of Autos are supported?',
        'a':
            'You can register both petrol/CNG and electric (EV) autos. Select Auto and provide your vehicle details for verification.',
      },
      {
        'q': 'What types of cars can I register?',
        'a':
            'You can register eligible 4-wheeler cars/cabs, including standard cabs, EV cabs, and larger vehicles eligible for Cab XL. Select the category that matches your vehicle.',
      },
    ];

    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.88,
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Top bar (Back button & Chat Icon)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Color(0xFF111827),
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: Color(0xFF111827),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                children: [
                  const Text(
                    'FAQ',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      height: 1.2,
                      letterSpacing: 0.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Solution to frequent asked questions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                      height: 1.0,
                      letterSpacing: 0.0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...faqItems.map((item) {
                    return Column(
                      children: [
                        Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            iconColor: const Color(0xFF111827),
                            collapsedIconColor: const Color(0xFF6B7280),
                            title: Text(
                              item['q']!,
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                                height: 1.1,
                                letterSpacing: 0.0,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  item['a']!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF6B7280),
                                    height: 1.5,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(color: Color(0xFFE5E5EB), height: 1),
                      ],
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                12,
                24,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              child: BouncingWidget(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27272A),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
