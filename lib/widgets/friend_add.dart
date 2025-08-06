import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:star_chat/models/friend_model.dart';
import 'package:star_chat/pages/bottom_bar.dart';
import 'package:star_chat/pages/cubits/home_cubit/home_cubit.dart';
import 'package:star_chat/services/repository.dart';
import '../models/user_model.dart';
import '../const.dart';

class FriendAdd extends StatefulWidget {
  final UserModel friend;
  const FriendAdd({required this.friend, super.key});

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
      friends = context.read<Repository>().friends;
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
          context.read<HomeCubit>().addFriend(friend: widget.friend);
          scaffoldMessage(context, 'Add Friend Successfully');
          // setState(() {
          //   isAdd = true;
          // });
          // // tafrigh el hala
          // context.read<HomeCubit>().emit(HomeInitial());
          // context.read<HomeCubit>().loadCurrentUser();
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
