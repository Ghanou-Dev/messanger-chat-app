import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star_chat/models/user_model.dart';
import 'package:star_chat/pages/chat_page.dart';
import 'package:star_chat/services/repository.dart';
import '../const.dart';
import '../models/friend_model.dart';

class FriendWidget extends StatelessWidget {
  final String friendSearchID;
  const FriendWidget({required this.friendSearchID, super.key});

  @override
  Widget build(BuildContext context) {
    UserModel currentUser = context.read<Repository>().currentUser!;
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection(kUsersCollection)
              .doc(currentUser.uid)
              .collection(kFriendsCollection)
              .doc(friendSearchID)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(title: Text('جاري تحميل البيانات...'));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const ListTile(title: Text('لم يتم العثور على الصديق'));
        }

        FriendModel friend = FriendModel.fromjson(snapshot.data!.data()!);
        final data = friend.toMap();

        return ListTile(
          onTap: () {
            debugPrint('تم الضغط على ListTile ');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ChatPage(
                      currentUser: currentUser,
                      currentFriend: friend,
                    ),
              ),
            );
          },
          leading: GestureDetector(
            onTap: () {
              debugPrint('تم الضغط على الصورة Profile ');
            },
            child: CircleAvatar(
              backgroundImage:
                  friend.friendProfileImage != ''
                      ? NetworkImage(friend.friendProfileImage)
                      : const AssetImage('assets/images/profile.jpg')
                          as ImageProvider,
              radius: 25,
            ),
          ),
          title: Text(
            data[kFriendName] ?? 'جار تحميل الاسم',
            style: TextStyle(fontWeight: FontWeight.normal),
          ),
          subtitle: Text(
            data[kLastMessage] == ''
                ? data[kAddAt] != null
                    ? 'Add At ${(data[kAddAt] as Timestamp).toDate().hour}:${(data[kAddAt] as Timestamp).toDate().minute.toString().padLeft(2, '0')}'
                    : 'جاري تحميل التاريخ'
                : 'last: ${data[kLastMessage]}',
            overflow: TextOverflow.fade,
          ),
        );
      },
    );
  }
}
