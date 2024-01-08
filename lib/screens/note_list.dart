// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_note_taking_app/blocs/note_list_bloc.dart';
import 'package:simple_note_taking_app/models/note_model.dart';
import 'package:simple_note_taking_app/screens/note_editor.dart';

class NoteList extends StatefulWidget {
  const NoteList({super.key});

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  final List<String> items = ['Edit', 'Delete'];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => NoteListBloc()..add(FetchNotes()),
        child: BlocConsumer<NoteListBloc, NoteListState>(
            listenWhen: (previous, current) =>
                previous.noteFetchStatus != current.noteFetchStatus,
            listener: (context, state) async {
              if (state.noteFetchStatus == NoteFetchStatus.success) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notes Fetched!')));
              } else if (state.noteFetchStatus == NoteFetchStatus.failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to fetch notes!')));
              }
            },
            builder: (context, state) {
              return Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                      title: const Text('Notes',
                          style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.blue),
                  floatingActionButton: FloatingActionButton(
                      backgroundColor: Colors.purple,
                      shape: const CircleBorder(),
                      child: const Icon(Icons.add, color: Colors.white),
                      onPressed: () async {
                        var note = await Navigator.push<Note>(context,
                            MaterialPageRoute(builder: (context) {
                          return const NoteEditor();
                        }));

                        if (note != null) {
                          BlocProvider.of<NoteListBloc>(context)
                              .add(AddNotes(note: note));
                        }
                      }),
                  body: state.noteFetchStatus == NoteFetchStatus.initial
                      ? const Center(child: CircularProgressIndicator())
                      : Scrollbar(
                          thickness: 10,
                          child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: ListView.separated(
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 10),
                                  itemCount: state.notes.length,
                                  itemBuilder: (context, index) {
                                    var note = state.notes[index];
                                    return SizedBox(
                                        height: 100,
                                        child: ListTile(
                                          tileColor: Color(note.color),
                                          trailing: DropdownButton<String>(
                                              icon:
                                                  const Icon(Icons.more_horiz),
                                              onChanged: (value) async {
                                                if (value != null) {
                                                  if (value == 'Edit') {
                                                    var updatedNote =
                                                        await Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    NoteEditor(
                                                                        note:
                                                                            note)));

                                                    if (updatedNote != null) {
                                                      BlocProvider.of<
                                                                  NoteListBloc>(
                                                              context)
                                                          .add(UpdateNotes(
                                                              note:
                                                                  updatedNote));
                                                    }
                                                  } else if (value ==
                                                      'Delete') {
                                                    BlocProvider.of<
                                                                NoteListBloc>(
                                                            context)
                                                        .add(DeleteNotes(
                                                            id: note.id));
                                                  }
                                                }
                                              },
                                              items: items.map((String item) {
                                                return DropdownMenuItem<String>(
                                                    value: item,
                                                    child: Text(item));
                                              }).toList()),
                                          title: Text(note.title,
                                              style: const TextStyle(
                                                  color: Colors.white)),
                                          subtitle: Text(note.content,
                                              overflow: TextOverflow.ellipsis),
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return SimpleDialog(
                                                      backgroundColor:
                                                          Color(note.color),
                                                      title: Row(children: [
                                                        Text(note.title,
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white)),
                                                        const Spacer(),
                                                        IconButton(
                                                            icon: const Icon(
                                                                Icons.close,
                                                                color: Colors
                                                                    .white),
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context))
                                                      ]),
                                                      shape:
                                                          const BeveledRectangleBorder(),
                                                      titlePadding: const EdgeInsets.all(10),
                                                      contentPadding: const EdgeInsets.all(10),
                                                      children: [
                                                        Text(note.content)
                                                      ]);
                                                });
                                          },
                                        ));
                                  }))));
            }));
  }
}
