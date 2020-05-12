import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/firebase_values.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final _fireStore = Firestore.instance;
FirebaseUser firebaseUser;
final BorderRadius _selfUser = BorderRadius.only(
  topLeft: Radius.circular(30.0),
  bottomLeft: Radius.circular(30.0),
  bottomRight: Radius.circular(30.0),
);
final BorderRadius _otherUser = BorderRadius.only(
  topRight: Radius.circular(30.0),
  bottomLeft: Radius.circular(30.0),
  bottomRight: Radius.circular(30.0),
);

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final messageTextController = TextEditingController();
  String message;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: null,
        /*actions: <Widget>[
          IconButton(
              icon: Icon(Icons.info),
              onPressed: () async {
//                await _auth.signOut();
//                Navigator.pop(context);
              }),
        ],*/
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStreamBuilder(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () async {
                      messageTextController.clear();
                      print(firebaseUser.email);
                      _fireStore.collection(kMessageCollection).add({
                        kMessageSender: firebaseUser.email,
                        kMessageText: message,
                        kMessageTime: FieldValue.serverTimestamp()
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getUserData() async {
    try {
      var user = await _auth.currentUser();
      if (user != null) {
        firebaseUser = user;
      } else {
        Navigator.pop(context);
      }
    } catch (exception) {
      print(exception);
    }
  }

//  void getMessages() async {
//    var result = await _fireStore.collection(kMessageCollection).getDocuments();
//    var documents = result.documents;
//    for (var document in documents) {
//      print(document.data.values);
//    }
//  }
}

class MessagesStreamBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String email = ModalRoute.of(context).settings.arguments;
    print(email);
    return StreamBuilder<QuerySnapshot>(
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.blueAccent,
            ),
          );
        }
        final messages = snapshot.data.documents.reversed;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final messageText = message.data[kMessageText];
          final messageSender = message.data[kMessageSender];
          final currentUser = firebaseUser.email;
          final messageTime = message.data[kMessageTime] as Timestamp;
          bool isCurrentUser =
              messageSender.toString() == currentUser ? true : false;
          final textWidget = MessageBubble(
            text: messageText.toString(),
            sender: messageSender.toString(),
            timestamp: messageTime,
            isCurrentUser: isCurrentUser,
          );
          messageBubbles.add(textWidget);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
            children: messageBubbles,
          ),
        );
      },
      stream: _fireStore
          .collection(kMessageCollection)
          .orderBy(kMessageTime, descending: false)
          .snapshots(),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final String sender;
  final bool isCurrentUser;
  final Timestamp timestamp;
  MessageBubble(
      {@required this.text,
      @required this.sender,
      @required this.isCurrentUser,
      @required this.timestamp});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style: TextStyle(
              color: Colors.black45,
              fontSize: 12.0,
            ),
          ),
          Material(
            elevation: 5.0,
            color: isCurrentUser ? Colors.lightBlueAccent : Colors.white,
            borderRadius: isCurrentUser ? _selfUser : _otherUser,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 18.0,
                  color: isCurrentUser ? Colors.white : Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*
ListView.builder(itemBuilder: (context, index) {
                    return Column(
                      children: <Widget>[
                        Text(
                          messageText.toString(),
                        ),
                        Text('From : $sender'),
                      ],
                    );
                  })
                  */
