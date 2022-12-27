import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Dailies extends StatefulWidget {
  const Dailies({super.key});

  @override
  State<Dailies> createState() => _DailiesState();
}

class _DailiesState extends State<Dailies> {
  var db = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dom's Weeknotes")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                children: [
                  Image.network(
                    "/icons/drawer-icon.png",
                    height: 100,
                  ),
                  Text(
                    "Dom's Weeknotes",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.repeat,
                color: Colors.black,
              ),
              title: const Text(
                'Daily',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, "/daily", (route) => false);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.calendar_today,
              ),
              title: Text(
                'Weekly',
              ),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, "/", (route) => false);
              },
            ),
            ListTile(
              leading: Icon(Icons.arrow_forward),
              title: const Text('Future'),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, "/future", (route) => false);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          constraints: BoxConstraints(maxWidth: 760),
          child: ListView(
            children: [
              Text(
                "Daily Actions",
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 20.0),
              FirebaseAuth.instance.currentUser?.email ==
                      "dom@chuffed.solutions"
                  ? ElevatedButton(
                      onPressed: () async {
                        var collection = db.collection('daily');
                        var querySnapshots = await collection.get();
                        for (var doc in querySnapshots.docs) {
                          await doc.reference.update({'done': false});
                        }
                      },
                      child: const Text("Reset all"))
                  : const SizedBox.shrink(),
              const SizedBox(height: 20.0),
              StreamBuilder(
                stream: db.collection('daily').snapshots(),
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
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        var doc = docs[index];
                        return FirebaseAuth.instance.currentUser?.email ==
                                "dom@chuffed.solutions"
                            ? ActionItemTodo(doc: doc)
                            : ActionItem(doc: doc);
                      });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActionItem extends StatefulWidget {
  final QueryDocumentSnapshot doc;
  const ActionItem({super.key, required this.doc});

  @override
  State<ActionItem> createState() => _ActionItemState();
}

class _ActionItemState extends State<ActionItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.circle,
            color: widget.doc["done"] ? Colors.greenAccent : Colors.grey,
          ),
          title: Text(widget.doc["action"]),
        ),
        Divider(),
      ],
    );
  }
}

class ActionItemTodo extends StatefulWidget {
  final QueryDocumentSnapshot doc;
  const ActionItemTodo({super.key, required this.doc});

  @override
  State<ActionItemTodo> createState() => _ActionItemTodoState();
}

class _ActionItemTodoState extends State<ActionItemTodo> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Checkbox(
            onChanged: (bool? value) {
              var getDoc = FirebaseFirestore.instance
                  .collection("daily")
                  .doc(widget.doc.id);
              getDoc.update({"done": value});
              setState(() {});
            },
            value: widget.doc["done"],
          ),
          title: Text(widget.doc["action"]),
        ),
        Divider(),
      ],
    );
  }
}
