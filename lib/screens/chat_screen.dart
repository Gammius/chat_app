import 'package:chat_app/widgets/message/messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String docID;
  final String docName;
  late final String _messageUrl = "chats/$docID/messages";
  ChatScreen({required this.docID ,super.key, required this.docName});

  @override
  Widget build(BuildContext context) {
    TextEditingController _newMassageController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(docName),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(_messageUrl)
              .orderBy("createdAt", descending: true).snapshots(),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(),);
            }

            return Column(
              children: [
                Expanded(
                  child: (() {
                    if(snapshot.data == null
                        || snapshot.hasData
                        || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("Сообщений пока нет"),);
                    } else{
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ListView.separated(
                          reverse: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) => Messages(
                          message: snapshot.data!.docs[index]["text"],
                          selfMessage: FirebaseAuth.instance.currentUser!.uid ==
                              snapshot.data!.docs[index]["senderID"],
                          senderID: snapshot.data!.docs[index]["senderID"],
                        ),
                        separatorBuilder: (context, index) => const SizedBox(height: 25,),
                    ),
                      );
                    }
                  }()),
                    ),
                    Row(
                    children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: TextField(
                          controller: _newMassageController,
                          decoration: const InputDecoration(
                            labelText: "Сообщение..."
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if(_newMassageController.text.isEmpty) return;
                        FirebaseFirestore.instance.collection(_messageUrl).add({
                          "text": _newMassageController.text,
                          "createdAt": Timestamp.now(),
                          "senderID": FirebaseAuth.instance.currentUser!.uid,
                        });
                        _newMassageController.clear();
                      },
                      icon: const Icon(Icons.send),),
                  ],
                ),
              ],
            );
          }
      ),
    );
  }
}
