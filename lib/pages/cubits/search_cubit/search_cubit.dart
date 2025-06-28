import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:star_chat/const.dart';
import 'package:star_chat/models/user_model.dart';
import 'package:star_chat/pages/cubits/search_cubit/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchInitial());

  // دالة للبحث عن الاصدقاء
  List<UserModel> searchResults = [];
  Future<void> searchFriends(BuildContext context, String searchID) async {
    try {
      emit(SearchLoaded());
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection(kUsersCollection)
              .where(kSearchID, isEqualTo: searchID)
              .get();
      if (snapshot.docs.isEmpty) {
        emit(SearchEmpty());
        return;
      }

      if (snapshot.docs.isNotEmpty) {
        emit(SearchSuccess());
        for (var doc in snapshot.docs) {
          searchResults.add(UserModel.fromJson(doc.data()!));
        }
      }
    } catch (ex) {
      debugPrint('خطأ اثناء البحث : $ex');
      emit(SearchFailiare(errorMessage: 'خطأ اثناء البحث '));
    }
  }
}
