import 'package:custom_color_picker/color_picker_widget.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color selectedColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: CircleColorPicker(
                  controller: CircleColorPickerController(initialColor: selectedColor),
                  onChanged: (value) {
                    // Schedule the state update for after the current frame.
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        selectedColor = value;
                      });
                    });
                  },
                ),
              ),
            ),
            Container(
              color: selectedColor, // Reflect the selected color.
              width: double.infinity,
              height: 100,
            ),
          ],
        ),
      ),
    );
  }
}
