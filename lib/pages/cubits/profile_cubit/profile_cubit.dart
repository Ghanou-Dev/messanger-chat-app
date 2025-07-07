import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:star_chat/const.dart';
import 'package:star_chat/models/user_model.dart';
import 'package:star_chat/pages/cubits/profile_cubit/profile_state.dart';
import 'package:star_chat/services/repository.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final Repository repo;
  ProfileCubit({required this.repo}) : super(ProfileInitial());

  void go({required String pageRoute}) {
    emit(ProfileGo(pageRoute: pageRoute));
  }

  Future<void> reloadUser() async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance
            .collection(kUsersCollection)
            .doc(repo.currentUser!.uid)
            .get();

    if (snapshot.exists) {
      UserModel updatedUser = UserModel.fromJson(
        snapshot.data() as Map<String, dynamic>,
      );
      repo.currentUser = updatedUser;
      emit(ProfileUpdateSuccess(currentUserUpdate: updatedUser));
    }
  }

  // pick image from the device
  Future<File?> pickImageFromDevice() async {
    File? imageFile = await repo.pickImageFromDevice();
    if (imageFile != null) {
      emit(ProfilePickImageSuccess());
      return imageFile;
    } else {
      emit(ProfileFailurePickImage());
      return null;
    }
  }

  // upload image to cloudinary
  Future<String> uploadImageToCloudAndGetUrl(File? imageFile) async {
    if (imageFile == null) return '';
    String? url = await repo.uploadImageToCloudAndGetUrl(imageFile);
    await reloadUser();
    emit(ProfileUpdateSuccess(currentUserUpdate: repo.currentUser!));
    return url;
  }

  // update profile in accont friends
  Future<void> upDateProfileImageInAccountFriends({
    required String newImage,
    required UserModel currentUser,
  }) async {
    try {
      await repo.upDateProfileImageInAccountFriends(
        newImage: newImage,
        currentUser: currentUser,
      );
    } catch (e) {
      throw Exception('There was en Error : $e');
    }
  }
}
