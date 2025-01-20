import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: NotesListScreen(),
    );
  }
}

class NotesListScreen extends StatefulWidget {
  @override
  _NotesListScreenState createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  List<dynamic> notes = [];

  // URL of the API
  final String apiUrl = 'http://10.0.2.2/notes_appp/index.php';

  // Fetch notes from the API
  Future<void> fetchNotes() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      setState(() {
        notes = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load notes');
    }
  }

  // Add a new note
  Future<void> addNote(String title, String content) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {'title': title, 'content': content},
    );
    if (response.statusCode == 200) {
      fetchNotes(); // Refresh the list after adding
    } else {
      throw Exception('Failed to add note');
    }
  }

  // Delete a note
  Future<void> deleteNote(String id) async {
    final response = await http.delete(Uri.parse('$apiUrl?id=$id'));
    if (response.statusCode == 200) {
      fetchNotes(); // Refresh the list after deleting
    } else {
      // show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete note'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNotes(); // Load notes initially
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notes')),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return ListTile(
            title: Text(note['title']),
            subtitle: Text(note['content']),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                deleteNote(note['id']);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open a dialog to add a new note
          showDialog(
            context: context,
            builder: (context) {
              final titleController = TextEditingController();
              final contentController = TextEditingController();
              return AlertDialog(
                title: Text('Add Note'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(labelText: 'Title'),
                      controller: titleController,
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Content'),
                      controller: contentController,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      addNote(titleController.text, contentController.text);
                      Navigator.of(context).pop();
                    },
                    child: Text('Save'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
