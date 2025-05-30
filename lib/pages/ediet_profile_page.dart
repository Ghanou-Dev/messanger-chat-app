import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star_chat/const.dart';
import 'package:star_chat/models/user_model.dart';
import 'package:star_chat/providers/user_provider.dart';

class EdietProfilePage extends StatelessWidget {
  EdietProfilePage({super.key});
  static const pageRoute = 'editeProfilePage';

  String? name;
  String? email;
  String? phoneNumber;
  TextEditingController fieldController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    UserProvider provider = context.read<UserProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Ediet Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('assets/images/OIP5.jpg'),
            // const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: const Text(
                'Edit Name',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            customTextField(
              hint: provider.currentUser!.name,
              textInputType: TextInputType.name,
              onChange: (data) {
                name = data;
              },
            ),
            // const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: const Text(
                'Edit Email',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            customTextField(
              hint: provider.currentUser!.email,
              textInputType: TextInputType.text,
              onChange: (data) {
                email = data;
              },
            ),
            // const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: const Text(
                'Phone Number',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            customTextField(
              hint: 'PhoneNumber',
              textInputType: TextInputType.phone,
              onChange: (data) {
                phoneNumber = data;
              },
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () async {
                  if (name == null || name!.isEmpty) {
                    name = provider.currentUser!.name;
                  }
                  if (email == null || email!.isEmpty) {
                    email = provider.currentUser!.email;
                  }
                  if (phoneNumber == null || phoneNumber!.isEmpty) {
                    phoneNumber = '';
                  }
                  await FirebaseFirestore.instance
                      .collection(kUsersCollection)
                      .doc(provider.currentUser!.uid)
                      .update({
                        kName: name,
                        kEmail: email,
                        kPhoneNumber: phoneNumber,
                      });
                  DocumentSnapshot snapshot =
                      await FirebaseFirestore.instance
                          .collection(kUsersCollection)
                          .doc(provider.currentUser!.uid)
                          .get();
                  UserModel? currentUpdateUser;
                  if (snapshot.exists) {
                    currentUpdateUser = UserModel.fromJson(
                      snapshot.data() as Map<String, dynamic>,
                    );
                  }
                  // update user model
                  provider.currentUser = currentUpdateUser;
                  // update name in friends collection
                  provider.updateNameInAccountFriends(name: name!);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 54),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'Save',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding customTextField({
    required String hint,
    required void Function(String)? onChange,
    required TextInputType textInputType,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: TextField(
        textInputAction: TextInputAction.next,
        onChanged: onChange,
        keyboardType: textInputType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.blueGrey),
          ),
        ),
      ),
    );
  }
}
