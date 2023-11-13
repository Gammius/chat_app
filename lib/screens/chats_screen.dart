import 'package:chat_app/screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  Future<void> configureFCM() async{
    final fcm = FirebaseMessaging.instance;
    final setting = await fcm.requestPermission();
  }

  @override
  void initState() {
    super.initState();

    configureFCM();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat app"),
        actions: [
          DropdownButton(
              icon: const Icon(Icons.more_vert, color: Colors.white,),
              items: const [
                DropdownMenuItem<String>(
                  value: "logOut",
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app, color: Colors.black87,),
                      SizedBox(width: 5,),
                      Text("Выйти"),
                    ],
                  ),
                ),
              ],
              onChanged: (newValue) {
                if(newValue == "logOut"){
                  FirebaseAuth.instance.signOut();
                }
              }
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("chats").snapshots(),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(),);
            }

            if(snapshot.data == null || snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("Чатов пока нет!"),);
            }


            return ListView.separated(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) => ListTile(
                leading: const CircleAvatar(backgroundImage: NetworkImage(
                    "https://cdn-icons-png.flaticon.com/512/147/147144.png",
                ),
                ),
                title: Text(snapshot.data!.docs[index]["title"]),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ChatScreen(
                          docID: snapshot.data!.docs[index].id,
                          docName: snapshot.data!.docs[index]["title"],
                      ),
                  ),
                  );
                },
              ),
              separatorBuilder: (context, index) => const Divider(),
            );
          }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          String? _newChatName = await showDialog<String>(
              context: context,
              builder: (context) {
                TextEditingController _controller = TextEditingController();
                return AlertDialog(
                  title: const Text("Введите название диалога"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _controller,
                        decoration: const InputDecoration(labelText: "Название чата"),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {Navigator.pop(context);},
                      child: const Text("Отмена"),
                    ),
                    TextButton(
                      onPressed: () {
                        if(_controller.text.isEmpty) return;
                        Navigator.pop(context, _controller.text);
                      },
                      child: const Text("OK"),
                    ),
                  ],
                );
              }
          );
          if(_newChatName == null || _newChatName.isEmpty) return;
          FirebaseFirestore.instance.collection("chats").add({
            "title": _newChatName},
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
