import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notes/firestore_services/firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirestoreServices firestore = FirestoreServices();

  void openNoteBox({String? docID, String? existingText}) {
    _controller.text = existingText ?? ''; // Prefill if editing

    showDialog(
      context: context,
      barrierDismissible: true, // Close on tapping outside
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              docID == null ? "Add a New Note" : "Edit Note",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: TextField(
              controller: _controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Write something...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _controller.clear();
                  Navigator.pop(context);
                },
                child: Text("Cancel", style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  if (_controller.text.trim().isNotEmpty) {
                    if (docID == null) {
                      firestore.addNotes(_controller.text);
                    } else {
                      firestore.updateNote(docID, _controller.text);
                    }
                    _controller.clear();
                    Navigator.pop(context);
                  }
                },
                child: Text(docID == null ? "Add Note" : "Update Note"),
              ),
            ],
          ),
    );
  }

  void confirmDelete(String docID) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Delete Note"),
            content: Text("Are you sure you want to delete this note?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Close dialog
                child: Text("Cancel", style: TextStyle(color: Colors.blue)),
              ),
              TextButton(
                onPressed: () {
                  firestore.deleteNote(docID); // Delete note
                  Navigator.pop(context); // Close dialog
                },
                child: Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "CRUD Operation In Firebase",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: firestore.getNoteStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List noteList = snapshot.data!.docs;
            return ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: noteList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = noteList[index];
                String docID = document.id;
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String noteText = data['note'];

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    title: Text(noteText, style: TextStyle(fontSize: 16)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed:
                              () => openNoteBox(
                                docID: docID,
                                existingText: noteText,
                              ),
                          icon: Icon(Icons.edit, color: Colors.green),
                          tooltip: "Edit Note",
                        ),
                        IconButton(
                          onPressed: () => confirmDelete(docID),
                          icon: Icon(Icons.delete, color: Colors.red),
                          tooltip: "Delete Note",
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Text(
                "No notes available!",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: openNoteBox,
        child: Icon(Icons.add, size: 30),
      ),
    );
  }
}
