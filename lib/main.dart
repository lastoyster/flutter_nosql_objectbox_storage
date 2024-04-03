import 'package:flutter/material.dart';
import 'package:flutter_nosql_objectbox_storage.dart';

import 'note_object_box.dart';

late NoteObjectBox objectBox;

Future<void> main() async {
  objectBox = await NoteObjectBox.create();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Notes using ObjectBox',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const NoteScreen(),
    );
  }
}
