import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star_chat/const.dart';
import 'package:star_chat/providers/user_provider.dart';
import 'package:star_chat/widgets/costum_textfield.dart';

class ChangePasswordPage extends StatelessWidget {
  ChangePasswordPage({super.key});

  static const pageRoute = 'changePasswordPage';

  String? password;
  String? newPassword;
  String? confirmPassword;
  GlobalKey<FormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    UserProvider provider = context.read<UserProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'ChangePassword',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/OIP5.jpg'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Text(
                  'Password',
                  style: TextStyle(
                    fontFamily: 'lateef',
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              CostumTextfield(
                onChanged: (val) {
                  password = val;
                },
                hint: 'Enter your Password',
                icon: Icon(Icons.lock),
                validator: (data) {
                  if (data!.isEmpty) {
                    return 'Field is required !';
                  } else if (data != provider.currentUser!.password) {
                    return 'Ivalid Password !';
                  }
                  return null;
                },
                obscure: true,
                capitalization: TextCapitalization.none,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Text(
                  'New Password',
                  style: TextStyle(
                    fontFamily: 'lateef',
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              CostumTextfield(
                onChanged: (val) {
                  newPassword = val;
                },
                validator: (data) {
                  if (data!.isEmpty) {
                    return 'Field is required !';
                  }
                  return null;
                },
                hint: 'Enter your New Password',
                icon: Icon(Icons.lock),
                obscure: true,
                capitalization: TextCapitalization.none,
              ),
              const SizedBox(height: 8),
              CostumTextfield(
                onChanged: (val) {
                  confirmPassword = val;
                },
                validator: (data) {
                  if (data!.isEmpty) {
                    return 'Field is required !';
                  }
                  return null;
                },
                hint: 'Confirm your Password',
                icon: Icon(Icons.lock),
                obscure: true,
                capitalization: TextCapitalization.none,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      if (newPassword == confirmPassword) {
                        await FirebaseFirestore.instance
                            .collection(kUsersCollection)
                            .doc(provider.currentUser!.uid)
                            .update({kPassword: newPassword});
                        context.read<UserProvider>().loadCurrentUser(provider.currentUser!.uid);
                        
                        scaffoldMessage(
                          context,
                          'Change Password Successfully',
                        );
                        Navigator.of(context).pop();
                      } else {
                        scaffoldMessage(context, 'INVALID PASSWORD');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 54),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
