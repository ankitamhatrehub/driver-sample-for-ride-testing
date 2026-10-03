import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rider_app/common/widgets/custom_button.dart';
import 'package:rider_app/common/routes/app_routes.dart';

// --- DRIVER RIDE REQUESTS SCREEN ---
class DriverRequestsScreen extends StatelessWidget {
  const DriverRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Request')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Text(
                    'Rider: Jane Doe',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text('Pickup: Central Park, West End'),
                  Text('Dropoff: 5th Avenue Mall'),
                  Divider(height: 32),
                  Text(
                    'Est. Fare: \$18.50',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Accept',
                    onTap: () {
                      context.pushReplacement(AppRoutes.navigation);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
