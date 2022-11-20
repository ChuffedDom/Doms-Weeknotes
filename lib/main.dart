import 'package:doms_weeknotes/noteV1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Weeknotes());
}

class Weeknotes extends StatelessWidget {
  const Weeknotes({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Dom's Weeknotes",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: '--apple-system',
      ),
      initialRoute: "/",
      routes: {
        '/': (context) => const Homepage(),
        '/login': (context) => const Login(),
      },
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    var db = FirebaseFirestore.instance;
    /* FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print(user);
        setState(() {
          _userLoggedIn = false;
        });
      } else {
        setState(() {
          _userLoggedIn = true;
        });
      }
    }); */
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dom's Weeknotes"),
        /* actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: (() {
              FirebaseAuth.instance.signOut();
            }),
          )
        ], */
      ),
      floatingActionButton:
          FirebaseAuth.instance.currentUser?.email == "dom@chuffed.solutions"
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                          return AddNote();
                        },
                      ),
                    );
                  },
                  child: const Icon(Icons.add),
                )
              : const SizedBox.shrink(),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          constraints: const BoxConstraints(maxWidth: 760),
          child: StreamBuilder(
              stream: db
                  .collection('notes')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  snapshot.connectionState.name;
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                var docs = snapshot.data!.docs;
                return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var doc = docs[index];
                      return NoteV1(
                          doc: doc,
                          date: doc["date"].toDate(),
                          title: doc["title"],
                          emoji: doc["emoji"],
                          body: doc["body"].replaceAll("\\n", "\n"),
                          published: doc["published"]);
                    });
              }),
        ),
      ),
    );
  }
}

// V1 is from the old Django weeknotes, and is just date, title, emoji, body(markdown)
class NoteV1 extends StatelessWidget {
  final DateTime date;
  final String title;
  final String emoji;
  final String body;
  final bool published;
  final QueryDocumentSnapshot doc;
  const NoteV1({
    super.key,
    required this.date,
    required this.title,
    required this.emoji,
    required this.body,
    required this.published,
    required this.doc,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('yyyy-MM-dd').format(date),
        ),
        const SizedBox(height: 10.0),
        Text(
          title,
          style: Theme.of(context).textTheme.headline4,
        ),
        Text(
          emoji,
          style: Theme.of(context).textTheme.headline4,
        ),
        const SizedBox(height: 10.0),
        MarkdownBody(data: body),
        const SizedBox(height: 10.0),
        FirebaseAuth.instance.currentUser?.email == "dom@chuffed.solutions"
            ? TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) {
                        return EditNote(queryDocumentSnapshot: doc);
                      },
                    ),
                  );
                },
                child: Text("edit"),
              )
            : const SizedBox.shrink(),
        const Divider(),
        const SizedBox(height: 30.0)
      ],
    );
  }
}
