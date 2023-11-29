import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled2/model/messageModel.dart';
import 'package:untitled2/model/user%20data%20model.dart';
import 'package:uuid/uuid.dart';

import '../model/chatroommodel.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel tergetuser;
  final ChatRoomId chatroom;
  final UserModel? userModel;
  final User? FirebaseUser;

  const ChatRoomPage(
      {super.key,
      required this.tergetuser,
      required this.chatroom,
      required this.userModel,
      required this.FirebaseUser});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messagecontroller = TextEditingController();

  void sendMessage() async {
    const uuid = Uuid();

    String message = messagecontroller.text.trim();
    messagecontroller.clear();

    if (message.isNotEmpty) {
      MessageModel newMessage = MessageModel(
        text: message,
        createdon: DateTime.now().toString(),
        messageId: uuid.v1(),
        seen: false,
        sender: widget.userModel!.uid,
      );

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection('messages')
          .doc(newMessage.messageId)
          .set(newMessage.toMap());

      // Update Lastmsg property
      widget.chatroom.Lastmsg = message;
      await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());

      log("message sent");
    }
  }


  void OpenProfileImg() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.zero)),
            elevation: 10,
            backgroundColor: Colors.black,
            child: Container(
              width: 600,
              height: 500,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(
                          widget.tergetuser.profilepicture.toString()))),
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            GestureDetector(
                onTap: () {
                  OpenProfileImg();
                },
                child: CircleAvatar(
                    backgroundColor: Colors.green,
                    radius: 30,
                    child: CircleAvatar(
                      foregroundImage: NetworkImage(
                          widget.tergetuser.profilepicture.toString()),
                      radius: 27,
                    ))),
            Padding(
              padding: const EdgeInsets.only(right: 78.0),
              child: Text(
                widget.tergetuser.fullname.toString(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    fontFamily: 'mohit',
                    color: Colors.red[900]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.call, color: Colors.black, size: 28)),
            )
          ]),
          backgroundColor: Colors.orange,
          toolbarHeight: 80),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: Container(
              decoration: BoxDecoration(),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("chatrooms")
                    .doc(widget.chatroom.chatroomid)
                    .collection("messages")
                    .orderBy("createdon", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot dataSnapshot =
                          snapshot.data as QuerySnapshot;
                      return ListView.builder(
                        reverse: true,
                        itemBuilder: (context, index) {
                          MessageModel currentmsgModel = MessageModel.fromMap(
                              dataSnapshot.docs[index].data()
                                  as Map<String, dynamic>);

                          return Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8),
                            child: Row(
                              mainAxisAlignment: (currentmsgModel.sender ==
                                      widget.userModel!.uid)
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 8),
                                    margin: EdgeInsets.symmetric(vertical: 2),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(7)),
                                        color: (currentmsgModel.sender ==
                                                widget.userModel!.uid)
                                            ? Colors.yellow
                                            : Colors.orange),
                                    child:
                                        Text(currentmsgModel.text.toString())),
                              ],
                            ),
                          );
                        },
                        itemCount: dataSnapshot.docs.length,
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text("Error occupied Check your internet"),
                      );
                    } else {
                      return Center(
                        child: Text("Hey ... Start a Chat"),
                      );
                    }
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return const Center(
                      child: Text("Error Check Your Internet Connection"),
                    );
                  }
                },
              ),
            )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                color: Colors.grey[300],
                child: Row(
                  children: [
                    Flexible(
                        child: TextField(
                      maxLines: null,
                      controller: messagecontroller,
                      decoration: InputDecoration(
                          hintText: "Enter Message", border: InputBorder.none),
                    )),
                    IconButton(
                        onPressed: () {
                        sendMessage();
                        },
                        icon: Icon(
                          Icons.send,
                          color: Colors.orange,
                          size: 30,
                        ))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
