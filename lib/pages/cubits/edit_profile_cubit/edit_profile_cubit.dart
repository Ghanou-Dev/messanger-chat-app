import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:star_chat/const.dart';
import 'package:star_chat/models/user_model.dart';
import 'package:star_chat/pages/cubits/edit_profile_cubit/edit_profile_state.dart';
import 'package:star_chat/services/repository.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  final Repository repo;
  EditProfileCubit({required this.repo}) : super(EditProfileInitial(currentUserEditing: repo.currentUser!));

  UserModel? currentUpdateUser;

  Future<void> editProfile({String? name, String? email, String? phoneNumber}) async {
    if (name == null || name.isEmpty) {
      name = repo.currentUser!.name;
    }
    if (email == null || email.isEmpty) {
      email = repo.currentUser!.email;
    }
    if (phoneNumber == null || phoneNumber.isEmpty) {
      phoneNumber = '';
    }
    await FirebaseFirestore.instance
        .collection(kUsersCollection)
        .doc(repo.currentUser!.uid)
        .update({kName: name, kEmail: email, kPhoneNumber: phoneNumber});
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance
            .collection(kUsersCollection)
            .doc(repo.currentUser!.uid)
            .get();

    if (snapshot.exists) {
      currentUpdateUser = UserModel.fromJson(
        snapshot.data() as Map<String, dynamic>,
      );
    }
    // update user model
    repo.currentUser = currentUpdateUser;
    // update name in friends collection
    repo.updateNameInAccountFriends(name: name);
    emit(EditProfileSuccess(currentUserEditing: currentUpdateUser!));
  }
}
