import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
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
      theme: ThemeData(primarySwatch: Colors.red),
      home: NotesListScreen(),
    );
  }
}

class NotesListScreen extends StatefulWidget {
  @override
  _NotesListScreenState createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  // Create a Random instance
  final _random = Random();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note added successfully'),
          backgroundColor: Colors.green,
        ),
      );
      fetchNotes(); // Refresh the list after adding
    } else {
      throw Exception('Failed to add note');
    }
  }

  // Edit a note
Future<void> editNote(int id, String title, String content) async {
  final url = Uri.parse('http://10.0.2.2/notes_appp/index.php');
  
  // Prepare data as a Map (form-encoded)
  final data = {
    'id': id.toString(),
    'title': title,
    'content': content,
  };

  // Send the PUT request with the form-encoded data and appropriate headers
  final response = await http.put(
    url,
    // headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: data,  // Use the form-encoded data
  );

  if (kDebugMode) {
    print('Sending data: ${data}');
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');
  }

  // Handle the response
  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Note edited successfully'),
        backgroundColor: Colors.green,
      ),
    );
    fetchNotes(); // Refresh the list after editing
  } else {
    // Show an error snackbar if the update fails
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to edit note'),
        backgroundColor: Colors.red,
      ),
    );
  }
}



  // Delete a note
  Future<void> deleteNote(String id) async {
    final url = Uri.parse('http://10.0.2.2/notes_appp/index.php');
    final response = await http.delete(url, body: {'id': id});
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted note successfully'),
          backgroundColor: Colors.green,
        ),
      );
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
      appBar: AppBar(
        title: Text('Notes'),
        // add background color
        backgroundColor: Colors.redAccent,
        ),
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchNotes();
          return;
          },
        child: ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            final randomRedAccent = Colors.red[_random.nextInt(8) * 100 + 100]; // Generate a random red accent
            return Card(
              elevation: 5,
              color: randomRedAccent,
              child: ListTile(
                title: Text(note['title']),
                subtitle: Text(note['content']),
                style: ListTileStyle.drawer,
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      // Edit button
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // Open a dialog to edit the note
                          showDialog(
                            context: context,
                            builder: (context) {
                              final titleController = TextEditingController(text: note['title']);
                              final contentController = TextEditingController(text: note['content']);
                              return AlertDialog(
                                title: Text('Edit Note'),
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
                                      editNote(note['id'], titleController.text, contentController.text);
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Save'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          deleteNote(note['id'].toString());
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
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
