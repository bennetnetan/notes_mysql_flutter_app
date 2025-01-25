import 'package:flutter/material.dart';
import 'package:notes_mysql_app/notes_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(primarySwatch: Colors.red),
      home: NotesListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
