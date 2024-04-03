import 'package:flutter/material.dart';
import 'package:flutter_nosql_objectbox_storage/main.dart';
import 'package:flutter_nosql_objectbox_storage/note_model.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final titleEditingController = TextEditingController();
  final commentEditingController = TextEditingController();

  Dismissible Function(BuildContext, int) _itemBuilder(List<NoteModel> notes) =>
      (BuildContext context, int index) {
        final item = notes[index];

        return Dismissible(
          key: ValueKey(notes[index]),
          background: Container(
            padding: const EdgeInsets.only(left: 16),
            color: Colors.green,
            child: const Align(
                alignment: Alignment.centerLeft, child: Icon(Icons.edit)),
          ),
          secondaryBackground: Container(
            padding: const EdgeInsets.only(right: 16),
            color: Colors.red,
            child: const Align(
                alignment: Alignment.centerRight, child: Icon(Icons.close)),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              _confirmDelete(item.id);
            } else if (direction == DismissDirection.startToEnd) {
              _showAlert(true, item);
            }
            return null;
          },
          child: ListTile(
            leading: const Icon(Icons.notes_sharp),
            title: Text(item.title),
            trailing: Text(item.dateFormat.toString()),
            subtitle: Text(item.comment),
          ),
        );
      };

  void _addNote() {
    if (titleEditingController.text.isEmpty &&
        commentEditingController.text.isEmpty) return;

    final data = NoteModel(
        title: titleEditingController.text,
        comment: commentEditingController.text,
        date: DateTime.now());

    objectBox.addNotes(data);
    Navigator.pop(context);
  }

  Future<void> _editNote(NoteModel item) async {
    if (titleEditingController.text.isEmpty &&
        commentEditingController.text.isEmpty) return;

    final data = NoteModel(
        id: item.id,
        title: titleEditingController.text,
        comment: commentEditingController.text,
        date: DateTime.now());

    objectBox.addNotes(data);
    Navigator.pop(context);
  }

  Future<void> _confirmDelete(int id) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Confirmation"),
          content: const Text("Are you sure you want to delete this item?"),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  objectBox.removeNote(id);
                  Navigator.pop(context);
                },
                child: const Text("Delete")),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAlert(bool isEdit, item) async {
    if (isEdit) {
      final NoteModel noteDate = item;

      titleEditingController.text = noteDate.title;
      commentEditingController.text = noteDate.comment;
    } else {
      titleEditingController.text = '';
      commentEditingController.text = '';
    }

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add Notes'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleEditingController,
                  decoration: const InputDecoration(hintText: 'Add Notes'),
                ),
                TextField(
                  controller: commentEditingController,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: 'Add Comments'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close', style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () => isEdit ? _editNote(item) : _addNote(),
                child: Text(isEdit ? 'Edit' : 'Add'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('My Notes'),
      ),
      body: StreamBuilder<List<NoteModel>>(
        stream: objectBox.getNotes(),
        builder: (context, snapShot) {
          return ListView.builder(
              shrinkWrap: true,
              itemCount: snapShot.hasData ? snapShot.data!.length : 0,
              itemBuilder: _itemBuilder(snapShot.data ?? []));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAlert(false, []),
        child: const Icon(Icons.add),
      ),
    );
  }
}
