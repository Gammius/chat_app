import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Messages extends StatelessWidget {
  final String message;
  final bool selfMessage;
  final String senderID;
  const Messages({super.key,
    required this.message,
    required this.selfMessage,
    required this.senderID
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection("users").doc(senderID).get(),
      builder: (context, snapshot) {
        return Row(
        mainAxisAlignment:
        selfMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                constraints: const BoxConstraints(
                  maxWidth: 300,
                ),
                decoration: BoxDecoration(
                  color: selfMessage ? Colors.grey : Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: !selfMessage ? Radius.zero: Radius.circular(10),
                    bottomRight: selfMessage ? Radius.zero: Radius.circular(10),
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                  selfMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      snapshot.connectionState == ConnectionState.waiting ||
                          !snapshot.hasData ? "Загрузка..."
                          : snapshot.data!["username"],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: selfMessage
                          ? Colors.black
                          : Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 5,),
                    Text(
                      message,
                      style: TextStyle(color: selfMessage
                          ? Colors.black
                          : Theme.of(context).colorScheme.secondary),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -20,
                  left: selfMessage ? -30 : null,
                  right: !selfMessage ? -30 : null,
                  child: CircleAvatar(
                    backgroundImage:
                    snapshot.connectionState == ConnectionState.waiting ||
                        !snapshot.hasData ||
                        snapshot.data!["imageUrl"] == null
                        ? null
                        : NetworkImage(snapshot.data!["imageUrl"]),
                  ),
              ),
            ],
          ),
        ],
      );
    }
    );
  }
}
