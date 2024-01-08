import 'package:flutter/material.dart';
import 'package:simple_note_taking_app/screens/note_list.dart';
import 'package:simple_note_taking_app/services/note_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NoteService.instance.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: NoteList());
  }
}
