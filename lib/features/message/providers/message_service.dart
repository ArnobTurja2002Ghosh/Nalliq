import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/models/message_model.dart';

class MessageService extends ChangeNotifier {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<void> sendMessage({
    required String message,
    required String email,
    required String currentUserId,
  }) async {
    final DateTime timestamp = DateTime.now();
    final userDoc =
        await _fireStore.collection('users').doc(currentUserId).get();
    final String currentUserEmail =
        userDoc.data()!['email'] as String? ?? "0.0";

    List<String> chatId = [currentUserId, email];
    chatId.sort();
    await _fireStore
        .collection('chat')
        .doc(chatId.join("*"))
        .collection('messages')
        .add(
          MessageModel(
            message: message,
            receiverId: email,
            timestamp: timestamp,
            senderId: currentUserId,
            senderEmail: currentUserEmail,
          ).toMap(),
        );
  }

  Stream<QuerySnapshot> getMessages({
    required String currentUserId,
    required String receiverUserId,
  }) {
    List<String> chatId = [currentUserId, receiverUserId];
    chatId.sort();
    print(chatId.join("*"));

    return _fireStore
        .collection('chat')
        .doc(chatId.join("*"))
        .collection('messages')
        .orderBy('timestamp1', descending: false)
        .snapshots();
  }
}
