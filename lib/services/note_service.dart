import 'package:simple_note_taking_app/models/note_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NoteService {
  final String baseUrl = 'https://your-mock-api-url.com';
  late SharedPreferences _prefs;

  NoteService._privateConstructor();

  static final NoteService _instance = NoteService._privateConstructor();

  static NoteService get instance => _instance;

  init() {
    initializeSharedPreferences();
  }

  void initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<List<Note>> fetchNotes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/notes'));

      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Note.fromJson(json)).toList();
    } catch (e) {
      //get it from local storage
      var notes = _prefs.getStringList('notes') ?? [];
      return notes.map((note) => Note.fromJson(jsonDecode(note))).toList();
    }
  }

  Future<Note> addNote(Note note) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notes'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(note.toJson()),
      );

      return Note.fromJson(json.decode(response.body));
    } catch (e) {
      List<String> notes = _prefs.getStringList('notes') ?? [];
      notes.add(jsonEncode(note));
      await _prefs.setStringList('notes', notes);
      return note;
    }
  }

  Future<Note> updateNote(Note updatedNote) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notes/${updatedNote.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(updatedNote.toJson()),
      );

      return Note.fromJson(json.decode(response.body));
    } catch (e) {
      List<String> json = _prefs.getStringList('notes') ?? [];
      List<Note> notes =
          json.map((note) => Note.fromJson(jsonDecode(note))).toList();
      var index = notes.indexWhere((note) => note.id == updatedNote.id);
      notes[index] = updatedNote;
      await _prefs.setStringList(
          'notes', notes.map((note) => jsonEncode(note)).toList());
      return updatedNote;
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await http.delete(Uri.parse('$baseUrl/notes/$id'));
    } catch (e) {
      List<String> notes = _prefs.getStringList('notes') ?? [];
      var index = notes.indexWhere((note) => note.contains(id));
      notes.removeAt(index);
      await _prefs.setStringList('notes', notes);
    }
  }
}
