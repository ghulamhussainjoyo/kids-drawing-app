import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kids_drawing_flutter/core/tools/stationary.tools.dart';
import 'package:kids_drawing_flutter/data/models/tools/stationary.model.dart';
import 'package:kids_drawing_flutter/features/drawing/widgets/tools/controller.tools.dart';
import 'package:kids_drawing_flutter/features/drawing/widgets/tools/drawing.tools.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

class DrawingScreenNew extends StatefulWidget {
  const DrawingScreenNew({super.key});
  @override
  State<DrawingScreenNew> createState() => _DrawingScreenNew();
}

class _DrawingScreenNew extends State<DrawingScreenNew> {
  double density = 0.45;
  StationaryModel? selectedTool;
  final StationaryTools stationaryTools = StationaryTools();
  final ValueNotifier<String> selectedCategory = ValueNotifier('pencil');

  @override
  void dispose() {
    selectedCategory.dispose();
    super.dispose();
  }

  void onToolSelect(StationaryModel tool) {
    selectedTool = tool;
  }

  void onCategoryTap(String name) {
    selectedCategory.value = name;
  }

  void onDensityChanged(double value) {
    density = value;
  }

  List<double> getInsets(BuildContext context) {
    final orientation = NativeDeviceOrientationReader.orientation(context);
    final landscapeRight = NativeDeviceOrientation.landscapeRight;
    final notchOnRight = orientation == landscapeRight;
    final toolsFlex = notchOnRight ? 3.0 : 2.0;
    final rightInsets = MediaQuery.viewPaddingOf(context).right * 0.7;
    final notchInset = notchOnRight ? rightInsets : 0.0;
    return [toolsFlex, notchInset];
  }

  @override
  Widget build(BuildContext context) {
    return NativeDeviceOrientationReader(
      builder: (context) {
        final [toolsFlex, notchInset] = getInsets(context);
        return CupertinoPageScaffold(
          child: Row(
            children: [
              Flexible(
                flex: 2,
                fit: FlexFit.tight,
                child: ValueListenableBuilder<String>(
                  valueListenable: selectedCategory,
                  builder: (context, name, child) {
                    return ControllerTools(
                      density: density,
                      onDensityChanged: onDensityChanged,
                      selectedCategoryImage: stationaryTools.getCategoryImage(
                        name,
                      ),
                      onBack: () => Navigator.of(context).maybePop(),
                    );
                  },
                ),
              ),
              Flexible(
                flex: 5,
                fit: FlexFit.tight,
                child: Container(color: Colors.blue),
              ),
              Flexible(
                fit: FlexFit.tight,
                flex: toolsFlex.toInt(),
                child: ValueListenableBuilder<String>(
                  valueListenable: selectedCategory,
                  builder: (context, name, child) {
                    return DrawingTools(
                      notchInset: notchInset,
                      onToolSelect: onToolSelect,
                      onCategoryTap: onCategoryTap,
                      selectedCategory: name,
                      stationaryTools: stationaryTools,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
