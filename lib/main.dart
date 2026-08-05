import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tops/Main/main_shell.dart';
import 'package:tops/Screen/Archive/archive_page.dart';
import 'package:tops/Screen/Explore/pages/explore_page.dart';

import 'package:tops/Screen/login/login.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://bpduvnezgiqvlqpeewyk.supabase.co',
    anonKey: 'sb_publishable_NIee2UdH2QM83aBagkzK6Q_IIBJyN73',
  );

  try {
    cameras = await availableCameras();
  } catch (e) {
    cameras = [];
    debugPrint('카메라 초기화 실패: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TOPS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Pretendard',
      ),
      home: const MainShell(),
    );
  }
}