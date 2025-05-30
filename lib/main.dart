import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:star_chat/const.dart';
import 'package:star_chat/firebase_options.dart';
import 'package:star_chat/pages/change_password_page.dart';
import 'package:star_chat/pages/ediet_profile_page.dart';
import 'package:star_chat/pages/home_chat_page.dart';
import 'package:star_chat/pages/search_page.dart';
import 'package:star_chat/providers/user_provider.dart';
import 'pages/bottom_bar.dart';
import './pages/singup_screen.dart';
import './pages/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final preferences = await SharedPreferences.getInstance();
  bool isLogedIn = preferences.getBool(kIsLogedIn) ?? false;

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => UserProvider())],
      child:  StarChat(isLoggedIn: isLogedIn,),
    ),
  );
}

class StarChat extends StatelessWidget {
  final bool isLoggedIn;
  const StarChat({required this.isLoggedIn ,super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/':
            isLoggedIn
                ? (context) => const BottomBar()
                : (context) => const LoginScreen(),
        LoginScreen.pageRoute: (context) => const LoginScreen(),
        SingupScreen.pageRoute: (context) => const SingupScreen(),
        BottomBar.pageRoute: (context) => const BottomBar(),
        SearchPage.pageRoute: (context) => const SearchPage(),
        HomeChatPage.pageRoute: (context) => HomeChatPage(),
        EdietProfilePage.pageRoute: (context) => EdietProfilePage(),
        ChangePasswordPage.pageRoute: (context) => ChangePasswordPage(),
      },
    );
  }
}
