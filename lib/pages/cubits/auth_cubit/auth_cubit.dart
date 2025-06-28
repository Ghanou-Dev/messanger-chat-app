import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:star_chat/const.dart';
import 'package:star_chat/pages/bottom_bar.dart';
import 'package:star_chat/pages/cubits/auth_cubit/auth_state.dart';
import 'package:star_chat/services/repository.dart';

class AuthCubit extends Cubit<AuthState> {
  final Repository repo;
  AuthCubit({required this.repo}) : super(AuthInitial());

  Future<void> logIn({required email, required password}) async {
    try {
      emit(AuthLoaded());
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email!,
        password: password!,
      );
      final prf = await SharedPreferences.getInstance();
      prf.setString(kUserID, credential.user!.uid);
      // تحميل بيانات المستخدم
      await repo.loadCurrentUser();
      emit(LoginSuccess());
    } on FirebaseAuthException catch (e) {
      emit(LoginFialur(messageError: 'Invalid email or password!'));
    }
  }

  void go({required String pageRoute}) {
    emit(AuthGo(pageRoute: pageRoute));
  }

  Future<void> singUp(
    BuildContext context, {
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      emit(AuthLoaded());
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      // create userID
      String searchID = await generateUniqueUserId(8);
      // تسجيل البيانات المستخدم في Firestore
      await FirebaseFirestore.instance
          .collection(kUsersCollection)
          .doc(credential.user!.uid)
          .set({
            kUID: credential.user!.uid,
            kName: name,
            kEmail: email,
            kPassword: password,
            kProfileImage: '',
            kSearchID: searchID,
            kCreatedAt: FieldValue.serverTimestamp(),
          });

      final prf = await SharedPreferences.getInstance();
      prf.setString(kUserID, credential.user!.uid);
      // تحميل بيانات المستخدم
      await repo.loadCurrentUser();
      // go to home page
      emit(SingupSuccess());
      emit(AuthGo(pageRoute: BottomBar.pageRoute));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        emit(SingupFailure(messageError: 'The Password Provided Is Too Weak.'));
      } else if (e.code == 'email-already-in-use') {
        emit(
          SingupFailure(
            messageError: 'Account is already exists for that email.',
          ),
        );
      }
    } catch (e) {
      emit(SingupFailure(messageError: 'There was an Error .'));
    }
  }
}
