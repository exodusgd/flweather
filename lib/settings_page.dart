// Flutter imports
import "package:flutter/material.dart";

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Center(
        child: Column(children: [Text("Temperature Unit"), TemperatureUnitButton()]),
      ),
    );
  }
}

enum TemperatureUnits { celsius, fahrenheit }

class TemperatureUnitButton extends StatefulWidget {
  const TemperatureUnitButton({super.key});

  @override
  State<TemperatureUnitButton> createState() => _TemperatureUnitButtonState();
}

class _TemperatureUnitButtonState extends State<TemperatureUnitButton> {
  TemperatureUnits currentTemperatureUnit = TemperatureUnits.celsius;

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
      selected: <TemperatureUnits>{currentTemperatureUnit},
      onSelectionChanged: (Set<TemperatureUnits> newSelection) {
        setState(() {
          currentTemperatureUnit = newSelection.first;
        });
      },
    );
  }
}
