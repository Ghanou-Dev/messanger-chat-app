import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:star_chat/providers/user_provider.dart';
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

  @override
  void initState() {
    super.initState();
    logedIn();
    // saveUserData();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await context.read<UserProvider>().loadCurrentUser(uid);
    });
  }

  // تسجيل الدخول في ذاكرة الجهاز
  void logedIn() async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setBool(kIsLogedIn, true);
  }

  // حفظ بيانات المستخدم في ذاكرة الجهاز
  // void saveUserData() async {
  //   final preferences = await SharedPreferences.getInstance();
  //   final uid = FirebaseAuth.instance.currentUser!.uid;
  //   preferences.setString(kUserID, uid);
  // }

  // دالة للبحث عن الاصدقاء
  Future<void> searchFriends(BuildContext context, String searchID) async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance
            .collection(kUsersCollection)
            .where(kSearchID, isEqualTo: searchID)
            .get();
    if (snapshot.docs.isEmpty) return;
    setState(() {
      searchResults.clear();
    });
    try {
      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          searchResults.add(UserModel.fromJson(doc.data()!));
        }
      }
    } catch (ex) {
      debugPrint('خطأ اثناء البحث : $ex');
      scaffoldMessage(context, 'خطأ اثناء البحث ');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(), // أو أي شاشة تحميل مؤقتة
        ),
      );
    }

    final friends = userProvider.friends;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: TextField(
              controller: textFieldController,
              onSubmitted: (val) async {
                await searchFriends(context, val);
                Navigator.of(context).pushNamed(
                  SearchPage.pageRoute,
                  arguments: {'searchResults': searchResults},
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
                          context
                                      .read<UserProvider>()
                                      .currentUser!
                                      .profileImage ==
                                  ''
                              ? AssetImage('assets/images/profile.jpg')
                                  as ImageProvider
                              : NetworkImage(
                                context
                                    .read<UserProvider>()
                                    .currentUser!
                                    .profileImage,
                              ),
                      radius: 38,
                    ),
                    Text(
                      context.read<UserProvider>().currentUser == null
                          ? 'جاري تحميل الاسم...'
                          : context.watch<UserProvider>().currentUser!.name,
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
            child:
                friends.isEmpty
                    ? Center(
                      child: Text(
                        'لا يوجد أصدقاء بعد',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        return FriendWidget(
                          friendSearchID: friends[index].friendSearchID,
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
