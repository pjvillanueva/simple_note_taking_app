import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:simple_note_taking_app/models/note_model.dart';
import 'package:simple_note_taking_app/services/note_service.dart';

enum NoteFetchStatus { initial, success, failure }

class NoteListState extends Equatable {
  const NoteListState({required this.notes, this.noteFetchStatus});
  final List<Note> notes;
  final NoteFetchStatus? noteFetchStatus;

  @override
  List<Object?> get props => [notes, noteFetchStatus];

  NoteListState copyWith({
    List<Note>? notes,
    NoteFetchStatus? noteFetchStatus,
  }) {
    return NoteListState(
      notes: notes ?? this.notes,
      noteFetchStatus: noteFetchStatus ?? this.noteFetchStatus,
    );
  }
}

abstract class NoteListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchNotes extends NoteListEvent {
  FetchNotes();
  @override
  List<Object?> get props => [];
}

class AddNotes extends NoteListEvent {
  AddNotes({required this.note});
  final Note note;
  @override
  List<Object?> get props => [note];
}

class UpdateNotes extends NoteListEvent {
  UpdateNotes({required this.note});
  final Note note;
  @override
  List<Object?> get props => [note];
}

class DeleteNotes extends NoteListEvent {
  DeleteNotes({required this.id});
  final String id;
  @override
  List<Object?> get props => [id];
}

class NoteListBloc extends Bloc<NoteListEvent, NoteListState> {
  NoteListBloc()
      : super(const NoteListState(
            notes: [], noteFetchStatus: NoteFetchStatus.initial)) {
    on<NoteListEvent>(_onEvent);
  }

  void _onEvent(NoteListEvent event, Emitter<NoteListState> emit) async {
    if (event is FetchNotes) {
      emit(state.copyWith(noteFetchStatus: NoteFetchStatus.initial));
      await Future.delayed(const Duration(seconds: 4));
      var notes = await NoteService.instance.fetchNotes();
      notes.sort((a, b) => a.timeCreated.compareTo(b.timeCreated));
      emit(state.copyWith(
          noteFetchStatus: NoteFetchStatus.success, notes: notes));
    } else if (event is AddNotes) {
      var note = await NoteService.instance.addNote(event.note);
      emit(state.copyWith(notes: [...state.notes, note]));
    } else if (event is UpdateNotes) {
      var note = await NoteService.instance.updateNote(event.note);
      emit(state.copyWith(
          notes: [...state.notes]
            ..removeWhere((element) => element.id == note.id)
            ..add(note)
            ..sort((a, b) => a.timeCreated.compareTo(b.timeCreated))));
    } else if (event is DeleteNotes) {
      await NoteService.instance.deleteNote(event.id);
      emit(state.copyWith(
          notes: [...state.notes]
            ..removeWhere((element) => element.id == event.id)));
    }
  }
}
