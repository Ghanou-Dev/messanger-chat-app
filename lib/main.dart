import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:star_chat/const.dart';
import 'package:star_chat/firebase_options.dart';
import 'package:star_chat/pages/change_password_page.dart';
import 'package:star_chat/pages/cubits/auth_cubit/auth_cubit.dart';
import 'package:star_chat/pages/cubits/chat_cubit/chat_cubit.dart';
import 'package:star_chat/pages/cubits/home_cubit/home_cubit.dart';
import 'package:star_chat/pages/cubits/profile_cubit/profile_cubit.dart';
import 'package:star_chat/pages/cubits/search_cubit/search_cubit.dart';
import 'package:star_chat/pages/ediet_profile_page.dart';
import 'package:star_chat/pages/home_chat_page.dart';
import 'package:star_chat/pages/search_page.dart';
import 'package:star_chat/pages/splash.dart';
import 'package:star_chat/services/repository.dart';
import 'package:star_chat/simple_bloc_observer.dart';
import 'pages/bottom_bar.dart';
import './pages/singup_screen.dart';
import './pages/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final preferences = await SharedPreferences.getInstance();
  bool isLogedIn = preferences.getBool(kIsLogedIn) ?? false;

  Repository repo = Repository();

  Bloc.observer = SimpleBlocObserver();
  runApp(
    MultiRepositoryProvider(
      providers: [RepositoryProvider<Repository>.value(value: repo)],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthCubit(repo: context.read<Repository>()),
          ),
          BlocProvider(
            create: (context) => HomeCubit(repo: context.read<Repository>()),
          ),
          BlocProvider(
            create: (context) => ProfileCubit(repo: context.read<Repository>()),
          ),
          BlocProvider(create: (context) => ChatCubit()),
          BlocProvider(create: (context) => SearchCubit()),
        ],
        child: StarChat(isLoggedIn: isLogedIn),
      ),
    ),
  );
}

class StarChat extends StatelessWidget {
  final bool isLoggedIn;
  const StarChat({required this.isLoggedIn, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Splash.pageoute,
      routes: {
        Splash.pageoute: (context)=> const Splash(),
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
