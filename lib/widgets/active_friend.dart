import 'package:flutter/material.dart';
import '../models/friend_model.dart';

class ActiveFriend extends StatelessWidget {
  final FriendModel friend;
  const ActiveFriend({required this.friend, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundImage:
              friend.friendProfileImage == ''
                  ? AssetImage('assets/images/profile.jpg') as ImageProvider
                  : NetworkImage(friend.friendProfileImage),
          radius: 38,
        ),
        Text(
          friend.friendName,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}


