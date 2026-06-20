import 'package:flutter/material.dart';

import 'screens/entry_gate_screen.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Room962App());
}

class Room962App extends StatelessWidget {
  const Room962App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ROOM +962',
      debugShowCheckedModeBanner: false,
      theme: RoomTheme.theme,
      home: const EntryGateScreen(),
    );
  }
}
