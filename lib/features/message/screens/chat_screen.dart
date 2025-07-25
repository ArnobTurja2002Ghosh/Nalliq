import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../../home/providers/store_provider.dart';
import '../providers/message_service.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String receiverEmail;
  final String receiverUserId;
  final String receiveruserName;

  const ChatScreen({
    super.key,
    required this.receiverEmail,
    required this.receiverUserId,
    required this.receiveruserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //final MessageService _messageService = MessageService();
  //final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        Provider.of<StoreProvider>(
          context,
          listen: false,
        ).loadStoreProfile(widget.receiverUserId, authProvider.user!.uid);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void sendMessage() async {
    final messageService = Provider.of<MessageService>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (_messageController.text.isNotEmpty) {
      await messageService.sendMessage(
        email: widget.receiverUserId,
        message: _messageController.text,
        currentUserId: authProvider.user!.uid,
      );
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final messageService = Provider.of<MessageService>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          onPressed: () async => Navigator.of(context).pop(),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text(
              widget.receiveruserName[0].toUpperCase() +
                  widget.receiveruserName.substring(1).toLowerCase(),
              style: GoogleFonts.poppins(
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
              stream: messageService.getMessages(
                receiverUserId: widget.receiverUserId,
                currentUserId: authProvider.user!.uid,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Something went wrong',
                      style: GoogleFonts.poppins(
                        fontSize: 18.0,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _scrollToBottom(),
                );
                print("going to print all chats");
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView(
                    controller: _scrollController,
                    children:
                        snapshot.data!.docs.map((document) {
                          print(document.id);
                          print("hi doc");
                          final Map<String, dynamic> data =
                              document.data() as Map<String, dynamic>;
                          print(data['timestamp1']);
                          return MessageBubble(
                            message: data['message'],
                            timestamp:
                                (data['timestamp1'] as Timestamp).toDate(),
                            userName:
                                data['senderEmail'].toString().split("@")[0],
                            alignment:
                                data['senderId'] == authProvider.user!.uid
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                          );
                        }).toList(),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Type a message...',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      labelStyle: const TextStyle(color: Colors.grey),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 1.0,
                        ),
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 1.0,
                        ),
                      ),
                    ),
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: IconButton(
                      onPressed: () async => sendMessage(),
                      icon: Icon(
                        Icons.arrow_upward,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
