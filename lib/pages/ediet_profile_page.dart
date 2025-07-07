import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:star_chat/models/user_model.dart';
import 'package:star_chat/pages/cubits/edit_profile_cubit/edit_profile_cubit.dart';
import 'package:star_chat/pages/cubits/edit_profile_cubit/edit_profile_state.dart';
import 'package:star_chat/pages/cubits/home_cubit/home_cubit.dart';
import 'package:star_chat/pages/cubits/profile_cubit/profile_cubit.dart';

class EdietProfilePage extends StatelessWidget {
  EdietProfilePage({super.key});
  static const pageRoute = 'editeProfilePage';

  String? name;
  String? email;
  String? phoneNumber;
  TextEditingController fieldController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Ediet Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<EditProfileCubit, EditProfileState>(
        listener: (context, state)async {
          if (state is EditProfileSuccess) {
            await context.read<ProfileCubit>().reloadUser();
            await context.read<HomeCubit>().loadCurrentUser();
            Navigator.of(context).pop();

          }
        },
        builder: (context, state) {
          if (state is EditProfileSuccess) {
            UserModel currentUser = state.currentUserEditing;
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/images/OIP5.jpg'),
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
                    hint: currentUser.name,
                    textInputType: TextInputType.name,
                    onChange: (data) {
                      name = data;
                    },
                  ),
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
                    hint: currentUser.email,
                    textInputType: TextInputType.text,
                    onChange: (data) {
                      email = data;
                    },
                  ),
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
                        context.read<EditProfileCubit>().editProfile(
                          name: name,
                          email: email,
                          phoneNumber: phoneNumber,
                        );
                        // Navigator.of(context).pop();
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
            );
          } else if (state is EditProfileInitial) {
            UserModel currntUser = state.currentUserEditing;
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/images/OIP5.jpg'),
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
                    hint: currntUser.name,
                    textInputType: TextInputType.name,
                    onChange: (data) {
                      name = data;
                    },
                  ),
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
                    hint: currntUser.email,
                    textInputType: TextInputType.text,
                    onChange: (data) {
                      email = data;
                    },
                  ),
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
                        
                        await context.read<EditProfileCubit>().editProfile(
                          name: name,
                          email: email,
                          phoneNumber: phoneNumber,
                        );
                        await context.read<HomeCubit>().loadCurrentUser(); ////////////////////////////
                        // await context.read<ProfileCubit>().reloadUser(); //////////////////////////////
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
            );
          } else {
            return Center(
              child: CircularProgressIndicator(color: Colors.lightBlue),
            );
          }
        },
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
