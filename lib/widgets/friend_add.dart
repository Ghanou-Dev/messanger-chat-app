import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star_chat/models/friend_model.dart';
import 'package:star_chat/pages/bottom_bar.dart';
import 'package:star_chat/providers/user_provider.dart';
import '../models/user_model.dart';
import '../const.dart';

class FriendAdd extends StatefulWidget {
  final UserModel friend;
  FriendAdd({required this.friend, super.key});

  @override
  State<FriendAdd> createState() => _FriendAddState();
}

class _FriendAddState extends State<FriendAdd> {
  Map<String, dynamic>? friendData;
  List<FriendModel>? friends;

  bool isAdd = false;
  @override
  void initState() {
    super.initState();
    friendData = widget.friend.toMap();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      friends = context.read<UserProvider>().friends;
      if (friends != null) {
        setState(() {
          isAdd = friends!.any(
            (friend) => friend.friendSearchID == friendData![kFriendSearchID],
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            friendData![kProfileImage] != ''
                ? NetworkImage(friendData![kProfileImage])
                : AssetImage('assets/images/profile.jpg') as ImageProvider,
      ),
      title: Text(friendData![kName] ?? 'جار تحميل الاسم'),
      trailing: IconButton(
        onPressed: () {
          context.read<UserProvider>().addFriend(widget.friend);
          scaffoldMessage(context, 'Add Friend Successfully');
          setState(() {
            isAdd = true;
          });
          Navigator.of(context).pushReplacementNamed(BottomBar.pageRoute);
        },
        icon:
            isAdd
                ? Icon(Icons.check, color: Colors.green, weight: 2)
                : Icon(Icons.person_add_alt_1, color: Colors.blue, weight: 2),
      ),
    );
  }
}
