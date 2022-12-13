import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class FutureNotes extends StatefulWidget {
  const FutureNotes({super.key});

  @override
  State<FutureNotes> createState() => _FutureNotesState();
}

class _FutureNotesState extends State<FutureNotes> {
  var futureDoc = FirebaseFirestore.instance.doc("future/active");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dom's Weeknotes"),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 760),
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder(
            stream: futureDoc.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              var doc = snapshot.data;
              return ListView(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Futurenotes",
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      FirebaseAuth.instance.currentUser?.email ==
                              "dom@chuffed.solutions"
                          ? TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, "/edit-future");
                              },
                              child: Text("edit"))
                          : const SizedBox.shrink(),
                    ],
                  ),
                  MarkdownBody(data: doc!["top_level"]),
                  SizedBox(height: 20.0),
                  Image.network(doc["current_work_image_url"]),
                  SizedBox(height: 20.0),
                  MarkdownBody(data: doc["goals_success"]),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class EditFutureNote extends StatefulWidget {
  const EditFutureNote({super.key});

  @override
  State<EditFutureNote> createState() => _EditFutureNoteState();
}

class _EditFutureNoteState extends State<EditFutureNote> {
  DocumentReference<Map<String, dynamic>> futureDoc =
      FirebaseFirestore.instance.doc("future/active");
  TextEditingController _topLevelController = TextEditingController();
  TextEditingController _photoUrlController = TextEditingController();
  TextEditingController _goalsSuccessController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Futurenotes"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              title: const Text('Daily'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: const Text('Weekly'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: const Text('Future'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          constraints: const BoxConstraints(maxWidth: 760),
          child: FutureBuilder(
            future: futureDoc.get(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                _topLevelController =
                    TextEditingController(text: snapshot.data!["top_level"]);
                _photoUrlController = TextEditingController(
                    text: snapshot.data!["current_work_image_url"]);
                _goalsSuccessController = TextEditingController(
                    text: snapshot.data!["goals_success"]);
              }
              return ListView(
                children: [
                  const SizedBox(height: 20.0),
                  TextField(
                    maxLines: null,
                    decoration: const InputDecoration(
                      labelText: "Top Level",
                      border: OutlineInputBorder(),
                    ),
                    controller: _topLevelController,
                  ),
                  const SizedBox(height: 20.0),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: "Current Work Image URL",
                    ),
                    controller: _photoUrlController,
                  ),
                  const SizedBox(height: 20.0),
                  TextField(
                    maxLines: null,
                    decoration: const InputDecoration(
                      labelText: "Goals and Success",
                      border: OutlineInputBorder(),
                    ),
                    controller: _goalsSuccessController,
                  ),
                  const SizedBox(height: 20.0),
                  FirebaseAuth.instance.currentUser?.email ==
                          "dom@chuffed.solutions"
                      ? ElevatedButton(
                          onPressed: () {
                            final note = <String, dynamic>{
                              "top_level": _topLevelController.text,
                              "current_work_image_url":
                                  _photoUrlController.text,
                              "goals_success": _goalsSuccessController.text,
                            };
                            futureDoc.update(note).onError(
                                (e, _) => print("Error writing document: $e"));
                            Navigator.pushNamedAndRemoveUntil(
                                context, "/future", (route) => false);
                          },
                          child: const Text("update note"),
                        )
                      : const Text("Not Authorised")
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
