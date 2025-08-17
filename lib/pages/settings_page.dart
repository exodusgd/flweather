// Dart imports
import 'dart:collection';

// Flutter imports
import "package:flutter/material.dart";

// Project imports
import '../enums/temperature_units.dart';
import '../enums/shared_prefs_keys.dart';
import '../enums/location_options.dart';
import '../utils/shared_prefs_utils.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Center(
        child: Column(
          children: [
            Text("Temperature Unit"),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TemperatureUnitButton(),
            ),

            Text("Weather Location"),
            LocationDropdownMenu(),
          ],
        ),
      ),
    );
  }
}

// ------------------------ Temperature Unit button ------------------------
// Segmented button that allows changing the temperature unit
class TemperatureUnitButton extends StatefulWidget {
  const TemperatureUnitButton({super.key});

  @override
  State<TemperatureUnitButton> createState() => _TemperatureUnitButtonState();
}

class _TemperatureUnitButtonState extends State<TemperatureUnitButton> {
  // Temperature units vars
  final TemperatureUnits _defaultTemperatureUnit = TemperatureUnits.celsius;
  late TemperatureUnits _currentTemperatureUnit;
  final TemperatureUnitsUtilities _tempUnitsUtils = TemperatureUnitsUtilities();

  // InitState runs before the button is built
  @override
  void initState() {
    super.initState();
    _currentTemperatureUnit = _defaultTemperatureUnit;

    // Get temperature unit from shared preferences
    String? tempUnit = SharedPrefsUtils.instance.getString(
      SharedPrefsKeys.temperatureUnit.toString(),
    );
    if (tempUnit != null) {
      _currentTemperatureUnit = _tempUnitsUtils.convertStringToValue(tempUnit)!;
      // Call setState to update the button
      setState(() {});
    }
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
        SharedPrefsUtils.instance.setString(
          SharedPrefsKeys.temperatureUnit.toString(),
          _currentTemperatureUnit.toString(),
        );
      },
    );
  }
}

// ----------------------- Weather location dropdown -----------------------
// Defines menu entry as a DropdownMenuEntry with a Locations enum value
typedef MenuEntry = DropdownMenuEntry<LocationOptions>;

// Dropdown menu that allows changing the weather location
class LocationDropdownMenu extends StatefulWidget {
  const LocationDropdownMenu({super.key});

  @override
  State<LocationDropdownMenu> createState() => _LocationDropdownMenuState();
}

class _LocationDropdownMenuState extends State<LocationDropdownMenu> {
  final LocationOptions _defaultLocation = LocationOptions.current;
  late LocationOptions _currentLocation;

  List<LocationOptions> locationOptionsValues = [];
  Map<LocationOptions, String> _locationOptionValueToString = {};
  static late List<MenuEntry> _menuEntries;

  @override
  void initState() {
    super.initState();
    _currentLocation = _defaultLocation;
    _initValueLists();
    _initMenuEntries();
  }

  void _initValueLists() {
    for (LocationOptions loc in LocationOptions.values) {
      locationOptionsValues.add(loc);
      switch (loc) {
        case LocationOptions.current:
          _locationOptionValueToString[loc] = "Current Location";
        case LocationOptions.lisbon:
          _locationOptionValueToString[loc] = "Lisbon";
        case LocationOptions.leiria:
          _locationOptionValueToString[loc] = "Leiria";
        case LocationOptions.coimbra:
          _locationOptionValueToString[loc] = "Coimbra";
        case LocationOptions.porto:
          _locationOptionValueToString[loc] = "Porto";
        case LocationOptions.faro:
          _locationOptionValueToString[loc] = "Faro";
      }
    }
    print(_locationOptionValueToString);
  }

  void _initMenuEntries() {
    _menuEntries = UnmodifiableListView<MenuEntry>(
      locationOptionsValues.map<MenuEntry>(
        (LocationOptions loc) =>
            MenuEntry(value: loc, label: _locationOptionValueToString[loc]!),
      ),
    );
  }

  // --------------------------------- BUILD ---------------------------------
  @override
  Widget build(BuildContext context) {
    return DropdownMenu<LocationOptions>(
      initialSelection: LocationOptions.current,
      onSelected: (LocationOptions? value) {
        setState(() {
          _currentLocation = value!;
        });
      },
      dropdownMenuEntries: _menuEntries,
    );
  }
}
