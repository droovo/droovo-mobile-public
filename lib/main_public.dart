import 'package:flutter/material.dart';

import 'helpers/distance_helper.dart';
import 'helpers/pricing_calculator.dart';
import 'models/lat_lng.dart';

/// Entry point for contributors.
///
/// This app has **no product screens** — the private app's real UI stays
/// in the private GitLab repo. This page only proves that the code in
/// `lib/helpers/` runs as a real Flutter app, by calling a couple of
/// helpers live. The actual coverage lives in `test/`.
void main() {
  runApp(const DroovoPublicHelpersApp());
}

class DroovoPublicHelpersApp extends StatelessWidget {
  const DroovoPublicHelpersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Droovo — Public Helpers',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const HelperDemoPage(),
    );
  }
}

class HelperDemoPage extends StatelessWidget {
  const HelperDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    const tunis = LatLng(36.8065, 10.1815);
    const sfax = LatLng(34.7406, 10.7603);

    final distanceKm = DistanceHelper.calculateDistanceKm(tunis, sfax);
    final distanceText = DistanceHelper.calculateDistanceText(tunis, sfax);
    final pricing = PricingCalculator.calculatePrice(
      distanceKm: distanceKm,
      passengerCount: 3,
      fuelType: 'diesel',
      hasAC: true,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Droovo — Public Helpers')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'This project has no product screens.\n'
                'It exists so the community can improve the pure business '
                'logic in lib/helpers/ — see test/ for the full suite.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text('Sample: Tunis → Sfax distance = $distanceText'),
              Text('Sample: suggested price/seat = ${pricing['price']} DT'),
            ],
          ),
        ),
      ),
    );
  }
}
