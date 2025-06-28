import 'package:star_chat/models/friend_model.dart';
import 'package:star_chat/models/user_model.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoaded extends HomeState {}

class HomeSuccess extends HomeState {
  final UserModel currentUser;
  final List<FriendModel> friendsList;
  HomeSuccess({required this.currentUser, required this.friendsList});
}

class HomeFailiar extends HomeState {}

class HomeGo extends HomeState {
  final String pageRoute;
  HomeGo({required this.pageRoute});
}

// class HomeGetFriends extends HomeState{}
// class HomeFriendsEmpty extends HomeState{}

class HomeSuccessAddFriend extends HomeState {}

class HomeFailureAddFriend extends HomeState {}
