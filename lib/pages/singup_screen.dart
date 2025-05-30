import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:star_chat/providers/user_provider.dart';
import '../pages/bottom_bar.dart';
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
  bool isLoading = false;
  GlobalKey<FormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
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
                    setState(() {
                      isLoading = true;
                    });
                    if (formKey.currentState!.validate()) {
                      try {
                        final credential = await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                              email: email!,
                              password: password!,
                            );

                        // create userID
                        String searchID = await generateUniqueUserId(8);

                        // تسجيل البيانات المستخدم في Firestore
                        await FirebaseFirestore.instance
                            .collection(kUsersCollection)
                            .doc(credential.user!.uid)
                            .set({
                              kUID: credential.user!.uid,
                              kName: name,
                              kEmail: email,
                              kPassword: password,
                              kProfileImage: '',
                              kSearchID: searchID,
                              kCreatedAt: FieldValue.serverTimestamp(),
                            });
                        // تحميل بيانات المستخدم في UserProvider
                        final uid = FirebaseAuth.instance.currentUser!.uid;
                        await context.read<UserProvider>().loadCurrentUser(uid);
                        setState(() {
                          isLoading = false;
                        });
                        scaffoldMessage(context, 'Success ..');
                        // go to home page
                        Navigator.of(
                          context,
                        ).pushReplacementNamed(BottomBar.pageRoute);
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'weak-password') {
                          scaffoldMessage(
                            context,
                            'The Password Provided Is Too Weak.',
                          );
                          setState(() {
                            isLoading = false;
                          });
                        } else if (e.code == 'email-already-in-use') {
                          scaffoldMessage(
                            context,
                            'Account is already exists for that email.',
                          );
                          setState(() {
                            isLoading = false;
                          });
                        }
                      } catch (e) {
                        scaffoldMessage(context, 'There was an Error .');
                      }
                    }
                    setState(() {
                      isLoading = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text(
                      'Sing up',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
                      Navigator.of(context).pop();
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
      ),
    );
  }
}
