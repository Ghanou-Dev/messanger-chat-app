import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:star_chat/models/friend_model.dart';
import 'package:star_chat/models/user_model.dart';
import 'package:star_chat/pages/cubits/home_cubit/home_state.dart';
import 'package:star_chat/services/repository.dart';

class HomeCubit extends Cubit<HomeState> {
  final Repository repo;
  HomeCubit({required this.repo}) : super(HomeInitial());

  Future<void> loadCurrentUser() async {
    emit(HomeLoaded());
    await repo.loadCurrentUser();
    
    emit(HomeSuccess(currentUser: repo.currentUser!,friendsList: repo.friends));

    // استمع لأي تغيير لاحق في الأصدقاء
    repo.listenToFriendsList(onChanged: (newFriends) {
      emit(HomeSuccess(
        currentUser: repo.currentUser!,
        friendsList: List<FriendModel>.from(newFriends), /////////////////
      ));
    });
  }

  Future<void> addFriend({required UserModel friend}) async {
    try {
      await repo.addFriend(friend);
    } catch (e) {
      emit(HomeFailureAddFriend());
    }
  }

  void go({required String pageRoute}) {
    emit(HomeGo(pageRoute: pageRoute));
  }
}
