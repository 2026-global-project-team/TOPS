import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'camera_test_page.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CameraTestPage(camera: cameras.first),
    ),
  );
}