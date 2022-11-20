import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddNote extends StatefulWidget {
  const AddNote({super.key});

  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  final _titleController = TextEditingController();
  final _emojiController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _published = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Add note"),
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            constraints: BoxConstraints(maxWidth: 760),
            child: ListView(
              children: [
                // Title field
                TextField(
                  decoration: const InputDecoration(labelText: "Title"),
                  controller: _titleController,
                ),
                const SizedBox(height: 30),
                // Emoij field
                TextField(
                  decoration: const InputDecoration(labelText: "Emoji"),
                  controller: _emojiController,
                ),
                const SizedBox(height: 30),
                // Body field
                TextField(
                  maxLines: null,
                  decoration: const InputDecoration(
                    labelText: "Body",
                    border: OutlineInputBorder(),
                  ),
                  controller: _bodyController,
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    const Text("Published?"),
                    Checkbox(
                        value: _published,
                        onChanged: (bool? value) {
                          setState(() {
                            _published = value!;
                          });
                        }),
                  ],
                ),
                const SizedBox(height: 30.0),
                ElevatedButton(
                  onPressed: () {
                    final note = <String, dynamic>{
                      "version": 1,
                      "title": _titleController.text,
                      "emoji": _emojiController.text,
                      "body": _bodyController.text,
                      "published": _published,
                      "date": DateTime.now(),
                    };
                    FirebaseFirestore.instance
                        .collection("notes")
                        .doc()
                        .set(note)
                        .onError((e, _) => print("Error writing document: $e"));
                  },
                  child: const Text("add note"),
                ),
              ],
            ),
          ),
        ));
  }
}

class EditNote extends StatefulWidget {
  final QueryDocumentSnapshot queryDocumentSnapshot;
  const EditNote({
    super.key,
    required this.queryDocumentSnapshot,
  });

  @override
  State<EditNote> createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  var _titleController = TextEditingController();
  var _emojiController = TextEditingController();
  var _bodyController = TextEditingController();
  bool _published = false;
  @override
  void initState() {
    _titleController =
        TextEditingController(text: widget.queryDocumentSnapshot["title"]);
    _emojiController =
        TextEditingController(text: widget.queryDocumentSnapshot["emoji"]);
    _bodyController =
        TextEditingController(text: widget.queryDocumentSnapshot["body"]);
    _published = widget.queryDocumentSnapshot["published"];
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Edit note"),
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            constraints: BoxConstraints(maxWidth: 760),
            child: ListView(
              children: [
                // Title field
                TextField(
                  decoration: const InputDecoration(labelText: "Title"),
                  controller: _titleController,
                ),
                const SizedBox(height: 30),
                // Emoij field
                TextField(
                  decoration: const InputDecoration(labelText: "Emoji"),
                  controller: _emojiController,
                ),
                const SizedBox(height: 30),
                // Body field
                TextField(
                  maxLines: null,
                  decoration: const InputDecoration(
                    labelText: "Body",
                    border: OutlineInputBorder(),
                  ),
                  controller: _bodyController,
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    const Text("Published?"),
                    Checkbox(
                        value: _published,
                        onChanged: (bool? value) {
                          setState(() {
                            _published = value!;
                          });
                        }),
                  ],
                ),
                const SizedBox(height: 30.0),
                ElevatedButton(
                  onPressed: () {
                    final note = <String, dynamic>{
                      "title": _titleController.text,
                      "emoji": _emojiController.text,
                      "body": _bodyController.text,
                      "published": _published,
                    };
                    FirebaseFirestore.instance
                        .collection("notes")
                        .doc(widget.queryDocumentSnapshot.id)
                        .update(note)
                        .onError((e, _) => print("Error writing document: $e"));
                    Navigator.pushNamedAndRemoveUntil(
                        context, "/", (route) => false);
                  },
                  child: const Text("update note"),
                ),
              ],
            ),
          ),
        ));
    ;
  }
}
