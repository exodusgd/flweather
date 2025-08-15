// Flutter imports
import "package:flutter/material.dart";

// Package imports
import 'package:shared_preferences/shared_preferences.dart';

// Project imports
import 'enums/temperature_units.dart';
import 'enums/shared_prefs_keys.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Center(
        child: Column(
          children: [Text("Temperature Unit"), TemperatureUnitButton()],
        ),
      ),
    );
  }
}

class TemperatureUnitButton extends StatefulWidget {
  const TemperatureUnitButton({super.key});

  @override
  State<TemperatureUnitButton> createState() => _TemperatureUnitButtonState();
}

class _TemperatureUnitButtonState extends State<TemperatureUnitButton> {
  // Shared preferences
  SharedPreferences? _sharedPrefs;

  // Temperature units vars
  final TemperatureUnits _defaultTemperatureUnit = TemperatureUnits.celsius;
  late TemperatureUnits _currentTemperatureUnit;
  final TemperatureUnitsUtilities _tempUnitsUtils = TemperatureUnitsUtilities();

  // InitState runs before the button is built
  @override
  void initState() {
    super.initState();
    _currentTemperatureUnit = _defaultTemperatureUnit;
    // Initializes shared preferences
    _initSharedPreferences();
  }

  void _initSharedPreferences() async {
    _sharedPrefs = await SharedPreferences.getInstance();
    // Get temperature unit from shared preferences
    String? tempUnit = _sharedPrefs!.getString(
      SharedPrefsKeys.temperatureUnit.toString(),
    );
    _currentTemperatureUnit = _tempUnitsUtils.convertStringToValue(
      tempUnit!,
    )!;
    // Call setState to update the button
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TemperatureUnits>(
      segments: const <ButtonSegment<TemperatureUnits>>[
        ButtonSegment<TemperatureUnits>(
          value: TemperatureUnits.celsius,
          label: Text("Celsius"),
        ),
        ButtonSegment<TemperatureUnits>(
          value: TemperatureUnits.fahrenheit,
          label: Text("Fahrenheit"),
        ),
      ],
      selected: <TemperatureUnits>{_currentTemperatureUnit},
      onSelectionChanged: (Set<TemperatureUnits> newSelection) {
        setState(() {
          _currentTemperatureUnit = newSelection.first;
        });
        if (_sharedPrefs != null) {
          _sharedPrefs!.setString(
            SharedPrefsKeys.temperatureUnit.toString(),
            _currentTemperatureUnit.toString(),
          );
        }
      },
    );
  }
}
