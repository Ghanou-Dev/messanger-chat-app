import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:star_chat/const.dart';
import 'package:star_chat/pages/bottom_bar.dart';
import 'package:star_chat/pages/cubits/auth_cubit/auth_cubit.dart';
import 'package:star_chat/pages/cubits/auth_cubit/auth_state.dart';
import '../pages/singup_screen.dart';
import '../widgets/costum_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const pageRoute = 'loginScreen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(AssetImage('assets/images/OIP2.jpg'), context);
  }

  // variables
  String? email;
  String? password;
  GlobalKey<FormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          scaffoldMessage(context, 'Success');
          Navigator.of(context).pushReplacementNamed(BottomBar.pageRoute);
        } else if (state is LoginFialur) {
          scaffoldMessage(context, state.messageError);
        } else if (state is AuthGo) {
          Navigator.of(context).pushNamed(state.pageRoute);
        }
      },
      builder: (context, state) {
        if (state is AuthLoaded) {
          return ModalProgressHUD(
            inAsyncCall: true,
            child: buildScaffold(context),
          );
        } else {
          return buildScaffold(context);
        }
      },
    );
  }

  Scaffold buildScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: formKey,
        child: ListView(
          children: [
            const SizedBox(height: 70),
            Text(
              'Start Chat',
              style: TextStyle(
                fontFamily: 'lateef',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Image.asset(
              'assets/images/OIP2.jpg',
              height: 200,
              width: double.infinity,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.only(left: 15),
              child: Text(
                'Log in',
                style: TextStyle(
                  fontFamily: 'lateef',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade800,
                ),
              ),
            ),
            CostumTextfield(
              hint: 'Email',
              icon: Icon(Icons.email_outlined),
              validator: (data) {
                if (data!.isEmpty) {
                  return 'Field is required !';
                }
                return null;
              },
              onChanged: (val) {
                email = val;
              },
            ),
            CostumTextfield(
              obscure: true,
              hint: 'Password',
              icon: Icon(Icons.lock_outline),
              onChanged: (val) {
                password = val;
              },
              validator: (data) {
                if (data!.isEmpty) {
                  return 'Field is required !';
                }
                return null;
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 15.0, left: 15, top: 15),
              child: ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    context.read<AuthCubit>().logIn(
                      email: email,
                      password: password,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Text(
                    'Log in',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Don\'t have an accounte?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                TextButton(
                  onPressed: () {
                    context.read<AuthCubit>().go(
                      pageRoute: SingupScreen.pageRoute,
                    );
                  },
                  child: Text(
                    'Sing Up',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
