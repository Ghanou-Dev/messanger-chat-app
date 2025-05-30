import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

// consts variables ............................................................
const String kUsersCollection = 'users';
const String kFriendsCollection = 'friends';
const String kChatsCollection = 'chats';
const String kMessagesCollection = 'messages';

const String kUID = 'UID';
const String kName = 'name';
const String kEmail = 'email';
const String kPhoneNumber = 'phoneNumber';
const String kPassword = 'password';
const String kSearchID = 'searchID';
const String kProfileImage = 'profileImage';
const String kCreatedAt = 'createdAt';

const String kFriendUID = 'friendUID';
const String kFriendName = 'friendName';
const String kFriendSearchID = 'friendSearchID';
const String kFriendProfileImage = 'friendProfileImage';
const String kAddAt = 'addAt';
const String kLastSend = 'lastSend';
const String kLastMessage = 'lastMessage';

const String kMessage = 'message';
const String kSenderUID = 'senderUID';
const String kReceiverUID = 'receiverUID';
const String kSendAt = 'sendAt';
const String kType = 'type';

const String kText = 'text';
const String kImage = 'image';

const String kUploadPreset = 'upload_preset';

const String kIsLogedIn = 'isLogedIn';
const String kUserID = 'userID';

// consts methods ............................................................
// اضهار صناك بار
void scaffoldMessage(BuildContext context, String text) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(text), duration: Duration(seconds: 2)));
}

// معرف فريد
Random _random = Random.secure();
const chars = 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890';
String generateId(int length) {
  return List.generate(
    length,
    (index) => chars[_random.nextInt(chars.length)],
  ).join();
}

// دالة للتأكد من تمييز المعرف
Future<bool> checkUserIdExists(String userId) async {
  var snapshot =
      await FirebaseFirestore.instance
          .collection(kUsersCollection)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
  return snapshot.docs.isNotEmpty;
}

// دالة توليد المعرف الفريد و التحقق منه
Future<String> generateUniqueUserId(int length) async {
  String userid;
  bool exists = true;
  do {
    userid = generateId(8);
    exists = await checkUserIdExists(userid);
  } while (exists);

  return userid;
}
