import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:star_chat/pages/cubits/auth_cubit/auth_cubit.dart';
import 'package:star_chat/pages/cubits/auth_cubit/auth_state.dart';
import 'package:star_chat/pages/login_screen.dart';
import '../const.dart';
import '../widgets/costum_textfield.dart';

class SingupScreen extends StatefulWidget {
  const SingupScreen({super.key});
  static const pageRoute = '/singup';

  @override
  State<SingupScreen> createState() => _SingupScreenState();
}

class _SingupScreenState extends State<SingupScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(AssetImage('assets/images/OIP2.jpg'), context);
  }

  // variables
  String? name;
  String? email;
  String? password;
  GlobalKey<FormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthGo) {
          Navigator.of(context).pushReplacementNamed(state.pageRoute);
        } else if (state is SingupFailure) {
          scaffoldMessage(context, state.messageError);
        } else if (state is SingupSuccess) {
          scaffoldMessage(context, 'Success .');
        }
      },
      builder: (context, state) {
        if (state is AuthLoaded) {
          return ModalProgressHUD(
            inAsyncCall: true,
            progressIndicator: CircularProgressIndicator(color: Colors.lightBlue,),
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
            const SizedBox(height: 40),
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
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/OIP2.jpg',
              height: 200,
              width: double.infinity,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.only(left: 15),
              child: Text(
                'Sing Up',
                style: TextStyle(
                  fontFamily: 'lateef',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade800,
                ),
              ),
            ),
            CostumTextfield(
              hint: 'Name',
              icon: Icon(Icons.person_outline),
              capitalization: TextCapitalization.sentences,
              onChanged: (val) {
                name = val;
              },
              validator: (data) {
                if (data!.isEmpty) {
                  return 'Field is required !';
                }
                return null;
              },
            ),
            CostumTextfield(
              hint: 'Email',
              icon: Icon(Icons.email_outlined),
              onChanged: (val) {
                email = val;
              },
              validator: (data) {
                if (data!.isEmpty) {
                  return 'Field is required !';
                }
                return null;
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
                    await context.read<AuthCubit>().singUp(
                      context,
                      email: email!,
                      password: password!,
                      name: name!,
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
                    'Sing up',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Alredy have an accounte?',
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
                      pageRoute: LoginScreen.pageRoute,
                    );
                  },
                  child: Text(
                    'Log in',
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
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
