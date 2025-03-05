import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServices {
  final CollectionReference notes = FirebaseFirestore.instance.collection(
    'Notes',
  );
  Future<void> addNotes(String note) {
    return notes.add({'note': note, 'timeStamp': Timestamp.now()});
  }

  Stream<QuerySnapshot<Object?>> getNoteStream() {
    final NoteStream = notes.orderBy('timeStamp', descending: true).snapshots();
    return NoteStream;
  }

  Future<void> updateNote(String docID, newNote) {
    return notes.doc(docID).update({
      'note': newNote,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> deleteNote(String docID) {
    return notes.doc(docID).delete();
  }
}
