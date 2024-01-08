import 'package:flutter/material.dart';
import 'package:simple_note_taking_app/models/note_model.dart';
import 'package:uuid/uuid.dart';

class NoteEditor extends StatefulWidget {
  const NoteEditor({super.key, this.note});

  final Note? note;

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final uuid = const Uuid();
  Color color = Colors.amber;

  @override
  void initState() {
    if (widget.note != null) {
      titleController.text = widget.note?.title ?? '';
      contentController.text = widget.note?.content ?? '';
      color =
          widget.note?.color != null ? Color(widget.note!.color) : Colors.amber;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Note Editor')),
        body: SingleChildScrollView(
          child: Form(
              key: _formKey,
              child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(children: [
                    TextFormField(
                        controller: titleController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Title must not be empty';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(hintText: 'Title')),
                    TextFormField(
                        controller: contentController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Content must not be empty';
                          }
                          return null;
                        },
                        maxLines: 10,
                        decoration: const InputDecoration(hintText: 'Content')),
                    const SizedBox(height: 10),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const Text('Color:', style: TextStyle(fontSize: 18)),
                      ColorContainer(
                          color: Colors.amber,
                          currentColor: color,
                          changeColor: (color) {
                            setState(() {
                              this.color = color;
                            });
                          }),
                      ColorContainer(
                          color: Colors.pink,
                          currentColor: color,
                          changeColor: (color) {
                            setState(() {
                              this.color = color;
                            });
                          }),
                      ColorContainer(
                          color: Colors.orange,
                          currentColor: color,
                          changeColor: (color) {
                            setState(() {
                              this.color = color;
                            });
                          }),
                      ColorContainer(
                          color: Colors.green,
                          currentColor: color,
                          changeColor: (color) {
                            setState(() {
                              this.color = color;
                            });
                          })
                    ]),
                    const SizedBox(height: 10),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        child: const Text('Save Note',
                            style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            var notes = Note(
                                id: widget.note?.id ?? uuid.v1(),
                                title: titleController.text,
                                content: contentController.text,
                                timeCreated:
                                    widget.note?.timeCreated ?? DateTime.now(),
                                color: color.value);
                            Navigator.pop(context, notes);
                          }
                        })
                  ]))),
        ));
  }
}

class ColorContainer extends StatelessWidget {
  const ColorContainer(
      {super.key,
      required this.color,
      required this.changeColor,
      required this.currentColor});

  final Function(Color) changeColor;
  final Color color;
  final Color currentColor;
  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
                color: color,
                border: color == currentColor
                    ? Border.all(width: 3.0, color: Colors.blue)
                    : null)),
        onPressed: () => changeColor.call(color));
  }
}
