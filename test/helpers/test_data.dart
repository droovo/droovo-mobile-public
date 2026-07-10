import 'dart:convert';
import 'dart:io';

import 'package:droovo_mobile_public/models/car.dart';
import 'package:droovo_mobile_public/models/message.dart';
import 'package:droovo_mobile_public/models/ride.dart';
import 'package:droovo_mobile_public/models/user.dart';

/// Loads `test/fixtures/sample_data.json` once and exposes it as typed
/// models, so every test file works off the same fake dataset instead of
/// hand-rolling ad-hoc objects.
class TestData {
  TestData._();

  static Map<String, dynamic>? _raw;

  static Map<String, dynamic> get _data {
    return _raw ??= jsonDecode(
      File('test/fixtures/sample_data.json').readAsStringSync(),
    ) as Map<String, dynamic>;
  }

  static List<Car> get cars => (_data['cars'] as List<dynamic>)
      .map((c) => Car.fromJson(c as Map<String, dynamic>))
      .toList();

  static List<User> get users => (_data['users'] as List<dynamic>)
      .map((u) => User.fromJson(u as Map<String, dynamic>))
      .toList();

  static List<Ride> get rides => (_data['rides'] as List<dynamic>)
      .map((r) => Ride.fromJson(r as Map<String, dynamic>))
      .toList();

  static List<Group> get groups => (_data['groups'] as List<dynamic>)
      .map((g) => Group.fromJson(g as Map<String, dynamic>))
      .toList();

  static Car carByUid(String uid) => cars.firstWhere((c) => c.uid == uid);

  static Ride rideByUid(String uid) => rides.firstWhere((r) => r.uid == uid);

  static Group groupByUid(String id) => groups.firstWhere((g) => g.id == id);
}
