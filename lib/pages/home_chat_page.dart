import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:star_chat/models/friend_model.dart';
import 'package:star_chat/pages/cubits/home_cubit/home_cubit.dart';
import 'package:star_chat/pages/cubits/home_cubit/home_state.dart';
import 'package:star_chat/pages/cubits/search_cubit/search_cubit.dart';
import 'package:star_chat/services/repository.dart';
import '../const.dart';
import '../models/user_model.dart';
import '../pages/search_page.dart';
import '../widgets/friend_widget.dart';

class HomeChatPage extends StatefulWidget {
  const HomeChatPage({super.key});
  static const pageRoute = '/home_content';

  @override
  State<HomeChatPage> createState() => _HomeChatPageState();
}

class _HomeChatPageState extends State<HomeChatPage> {
  TextEditingController textFieldController = TextEditingController();
  List<UserModel> searchResults = [];

  late Repository repo;

  @override
  void initState() {
    super.initState();
    logedIn();
    repo = context.read<Repository>();
    // saveUserData();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await context.read<HomeCubit>().loadCurrentUser(); // loaded // success

      await saveUserData();
    });
  }

  // تسجيل الدخول في ذاكرة الجهاز
  void logedIn() async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setBool(kIsLogedIn, true);
  }

  // حفظ بيانات المستخدم في ذاكرة الجهاز
  Future<void> saveUserData() async {
    final preferences = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    preferences.setString(kUserID, uid);
  }

  @override
  Widget build(BuildContext context) {
    UserModel? currentUser = repo.currentUser;
    List<FriendModel> friends = repo.friends;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:
            false, //***************************************************/
        toolbarHeight: 70,
        title: Text(
          'Start Chat',
          style: TextStyle(
            fontFamily: 'lateef',
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontSize: 36,
          ),
        ),
      ),
      body: BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {
          if (state is HomeGo) {
            Navigator.of(context).pushNamed(
              state.pageRoute,
              arguments: {'searchResults': searchResults},
            );
          }
        },
        builder: (context, state) {
          if (state is HomeLoaded) {
            return Center(
              child: CircularProgressIndicator(color: Colors.blue),
            ); // أو أي شاشة تحميل مؤقتة
          } else if (state is HomeSuccess) {
            final currentUser = state.currentUser;
            final friends = repo.friends;

            if (friends.isEmpty) {
              return Column(
                children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextField(
                      controller: textFieldController,
                      onSubmitted: (val) async {
                        await context.read<SearchCubit>().searchFriends(
                          context,
                          val,
                        );
                        context.read<HomeCubit>().go(
                          pageRoute: SearchPage.pageRoute,
                        );
                        textFieldController.clear();
                      },
                      cursorColor: Colors.blue,
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.search),
                        suffixIconColor: Colors.blue.shade300,
                        hintText: 'Search friend',
                        hintStyle: TextStyle(color: Colors.blueGrey),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.blueGrey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            CircleAvatar(
                              backgroundImage:
                                  currentUser.profileImage == ''
                                      ? AssetImage('assets/images/profile.jpg')
                                          as ImageProvider
                                      : NetworkImage(currentUser.profileImage),
                              radius: 38,
                            ),
                            Text(
                              currentUser.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Center(
                      child: Text(
                        'لا يوجد أصدقاء بعد',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: TextField(
                    controller: textFieldController,
                    onSubmitted: (val) async {
                      await context.read<SearchCubit>().searchFriends(
                        context,
                        val,
                      ); // first state before go to search page ///////////////////
                      context.read<HomeCubit>().go(
                        pageRoute: SearchPage.pageRoute,
                      );
                      textFieldController.clear();
                    },
                    cursorColor: Colors.blue,
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.search),
                      suffixIconColor: Colors.blue.shade300,
                      hintText: 'Search friend',
                      hintStyle: TextStyle(color: Colors.blueGrey),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.blueGrey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                currentUser.profileImage == ''
                                    ? AssetImage('assets/images/profile.jpg')
                                        as ImageProvider
                                    : NetworkImage(currentUser.profileImage),
                            radius: 38,
                          ),
                          Text(
                            currentUser.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      return FriendWidget(
                        friendSearchID: friends[index].friendSearchID,
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
