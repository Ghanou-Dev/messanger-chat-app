import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:star_chat/const.dart';
import 'package:star_chat/pages/cubits/search_cubit/search_cubit.dart';
import 'package:star_chat/pages/cubits/search_cubit/search_state.dart';
import '../models/user_model.dart';
import '../widgets/friend_add.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  static const pageRoute = '/searchPage';

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    List<UserModel> searchResults = context.read<SearchCubit>().searchResults;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Searching ',
          style: TextStyle(
            fontFamily: 'lateef',
            fontSize: 32,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      body: BlocConsumer<SearchCubit, SearchState>(
        listener: (context, state) {
          if (state is SearchFailiare) {
            scaffoldMessage(context, state.errorMessage);
          }
        },
        builder: (context, state) {
          if (state is SearchLoaded) {
            return Center(child: CircularProgressIndicator(color: Colors.blue));
          } else if (state is SearchSuccess) {
            return Column(
              children: [
                Divider(color: Colors.grey.shade300, thickness: 2, height: 2),
                const SizedBox(height: 15),
                Expanded(
                  child: ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      return FriendAdd(friend: searchResults[index]);
                    },
                  ),
                ),
              ],
            );
          } else {
            return Center(
              child: Text(
                'لا يوجد أصدقاء بهذا المعرف',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
        },
      ),
    );
  }
}
