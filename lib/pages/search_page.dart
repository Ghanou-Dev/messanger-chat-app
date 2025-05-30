import 'package:flutter/material.dart';
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
    var args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    List<UserModel> searchResults = args['searchResults'];

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
      body:
          searchResults.isEmpty
              ? Center(
                child: Text(
                  'لا يوجد أصدقاء بهذا المعرف',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
              : Column(
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
              ),
    );
  }
}
