import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:star_chat/const.dart';
import 'package:star_chat/pages/bottom_bar.dart';
import 'package:star_chat/pages/login_screen.dart';
import 'package:star_chat/services/repository.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});
  static const String pageoute = 'splash';

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    checkUserLoaded();
  }

  void checkUserLoaded() async {
    var prfns = await SharedPreferences.getInstance();
    bool isLogedIn = prfns.getBool(kIsLogedIn) ?? false;
    if (isLogedIn) {
      try {
        Repository repo = context.read<Repository>();
        await repo.loadCurrentUser();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BottomBar()),
        );
      } catch (e) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xffd4e4ed),
      body: Center(
        child: Image.asset(
          'assets/images/android_12.png',
          width: size.width * 0.58,
        ),
      ).animate().fadeOut(
        duration: 2.seconds,
        delay: 1.seconds,
        curve: Curves.easeOut,
      ),
      // body: Center(child: CircularProgressIndicator(color: Colors.lightBlue)),
    );
  }
}
