import 'package:flutter/widgets.dart';
import 'package:notepadapp/dbcontroller/notes_database.dart';
import 'package:notepadapp/models/note.dart';

class DBProvider with ChangeNotifier{

  Future? isInitCompleted;
  List<Note> _list=[];

  List<Note> get list => _list;

  DBProvider() {
    isInitCompleted=getAllData();
  }

  Future<List<Note>> getAllData() async{
    final data = await NotesDatabase.instance.readAllNotes();
    _list=data;
    return data;
  }

  getSome(){
    print('some some get' + DateTime.now().toIso8601String());
    notifyListeners();
  }

  Future<bool> create (String title, String description)async {
    if(title.length>0 && description.length>0) {
      await NotesDatabase.instance.create(Note(isImportant: false,
          number: DateTime
              .now()
              .millisecondsSinceEpoch,
          title: title,
          description: description,
          createdTime: DateTime.now()));
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  upTop(Note note) async {
    int res =await NotesDatabase.instance.update(Note(id: note.id,
        isImportant: note.isImportant,
        number: note.number,
        title: note.title,
        description: note.description,
        createdTime: DateTime.now()));
    if(res == 1) {
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  update(Note note, String title, String description) async {
    int res =await NotesDatabase.instance.update(Note(id: note.id,
        isImportant: note.isImportant,
        number: note.number,
        title: title,
        description: description,
        createdTime: note.createdTime));
    if(res == 1) {
      notifyListeners();
      return true;
    } else {
      return false;
    }

  }

  delete (var i) async{
    await NotesDatabase.instance.delete(i);
    notifyListeners();
  }
}