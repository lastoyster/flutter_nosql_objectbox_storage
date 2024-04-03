import 'package:flutter_nosql_objectbox_storage/note_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'objectbox.g.dart';

class NoteObjectBox {
  late final Store store;

  late final Box<NoteModel> noteBox;

  NoteObjectBox._create(this.store) {
    noteBox = Box<NoteModel>(store);

    if (noteBox.isEmpty()) {
      _putDemoData();
    }
  }

  static Future<NoteObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();

    final store =
        await openStore(directory: p.join(docsDir.path, "obx-example"));

    return NoteObjectBox._create(store);
  }

  void _putDemoData() {
    final demoNote = NoteModel(
        title: 'Note 1', comment: 'Note 1 comment', date: DateTime.now());

    noteBox.put(demoNote);
  }

  Stream<List<NoteModel>> getNotes() {
    final builder =
        noteBox.query().order(NoteModel_.date, flags: Order.descending);

    return builder.watch(triggerImmediately: true).map((event) => event.find());
  }

  void removeNote(int id) {
    noteBox.remove(id);
  }

  Future<void> addNotes(NoteModel data) async {
    noteBox.put(data);
  }
}
