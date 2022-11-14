import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

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
      ),
      home: const Homepage(),
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Dom's Weeknotes"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder(
            stream: db
                .collection('notes')
                .orderBy('date', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
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
                        date: doc["date"].toDate(),
                        title: doc["title"],
                        emoji: doc["emoji"],
                        body: doc["body"].replaceAll("\\n", "\n"),
                        published: doc["published"]);
                  });
            }),
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
  const NoteV1(
      {super.key,
      required this.date,
      required this.title,
      required this.emoji,
      required this.body,
      required this.published});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('yyyy-MM-dd').format(date),
        ),
        SizedBox(
          height: 10.0,
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.headline3,
        ),
        Text(
          emoji,
          style: Theme.of(context).textTheme.headline3,
        ),
        SizedBox(
          height: 10.0,
        ),
        MarkdownBody(data: body),
        SizedBox(
          height: 10.0,
        ),
        Divider(),
        SizedBox(
          height: 30.0,
        )
      ],
    );
  }
}
