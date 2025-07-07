import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:star_chat/const.dart';
import 'package:star_chat/models/user_model.dart';
import 'package:star_chat/pages/change_password_page.dart';
import 'package:star_chat/pages/cubits/home_cubit/home_cubit.dart';
import 'package:star_chat/pages/cubits/profile_cubit/profile_cubit.dart';
import 'package:star_chat/pages/cubits/profile_cubit/profile_state.dart';
import 'package:star_chat/pages/ediet_profile_page.dart';
import 'package:star_chat/pages/login_screen.dart';
import 'package:star_chat/services/repository.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Repository repo;
  @override
  void initState() {
    super.initState();
    repo = context.read<Repository>();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await context.read<HomeCubit>().loadCurrentUser();
      await context.read<ProfileCubit>().reloadUser();
      
    });
  }

  void singOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool(kIsLogedIn, false);
    Navigator.of(context).pushReplacementNamed(LoginScreen.pageRoute);
  }

  @override
  Widget build(BuildContext context) {
    UserModel? currentUser = repo.currentUser;
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white54),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileFailurePickImage) {
            scaffoldMessage(context, 'Picked Image Failure!');
          }
        },
        builder: (context, state) {
          if (state is ProfileUpdateSuccess) {
            UserModel? currentUser = state.currentUserUpdate;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Profile',
                  style: TextStyle(
                    fontFamily: 'lateef',
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: double.infinity, height: 26),
                GestureDetector(
                  onTap: () async {
                    File? imageFile =
                        await context
                            .read<ProfileCubit>()
                            .pickImageFromDevice();
                    // upload image to cloudinary
                    String imageUrl = await context
                        .read<ProfileCubit>()
                        .uploadImageToCloudAndGetUrl(imageFile);
                    // update image in firestore
                    await FirebaseFirestore.instance
                        .collection(kUsersCollection)
                        .doc(currentUser.uid)
                        .update({kProfileImage: imageUrl});
                    await context.read<HomeCubit>().loadCurrentUser();
                    await context.read<ProfileCubit>().reloadUser();
                    // update image in Collection frinds
                    await context
                        .read<ProfileCubit>()
                        .upDateProfileImageInAccountFriends(
                          newImage: imageUrl,
                          currentUser: currentUser,
                        );
                  },
                  child: CircleAvatar(
                    backgroundImage:
                        currentUser.profileImage == ''
                            ? AssetImage('assets/images/profile.jpg')
                                as ImageProvider
                            : NetworkImage(currentUser.profileImage),
                    radius: 68,
                  ),
                ),
                Text(
                  currentUser.name,
                  style: TextStyle(
                    fontFamily: 'lateef',
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 110),
                    Text(
                      'UID: ${currentUser.searchID}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.blueGrey,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: currentUser.searchID),
                        );
                        scaffoldMessage(context, 'Copy UID Successfully !');
                      },
                      icon: Icon(
                        Icons.copy_outlined,
                        color: Colors.blueGrey,
                        size: 15,
                      ),
                    ),
                    const SizedBox(width: 85),
                  ],
                ),
                Expanded(
                  child: ListView(
                    children: [
                      buildListTile(
                        onTap: () {
                          Navigator.of(
                            context,
                          ).pushNamed(EdietProfilePage.pageRoute);
                        },
                        text: 'Edite Profile',
                        iconListTile: Icons.person_outline,
                        iconElevatedButton: Icons.arrow_forward_ios_outlined,
                      ),
                      buildListTile(
                        onTap: () {},
                        text: 'Notifications',
                        iconListTile: Icons.notifications_outlined,
                        iconElevatedButton: Icons.arrow_forward_ios_outlined,
                      ),
                      buildListTile(
                        onTap: () {},
                        text: 'Shipping Address',
                        iconListTile: Icons.person_pin_circle_outlined,
                        iconElevatedButton: Icons.arrow_forward_ios_outlined,
                      ),
                      buildListTile(
                        onTap: () {
                          Navigator.of(
                            context,
                          ).pushNamed(ChangePasswordPage.pageRoute);
                        },
                        text: 'Change Password',
                        iconListTile: Icons.lock_outline_rounded,
                        iconElevatedButton: Icons.arrow_forward_ios_outlined,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 15.0,
                    left: 15,
                    right: 15,
                    bottom: 5,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      iconColor: Colors.white,
                      backgroundColor: Colors.blue,
                      minimumSize: Size(double.infinity, 46),
                    ),
                    onPressed: () {
                      singOut();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout),
                        const SizedBox(width: 6),
                        Text(
                          'Sign Out',
                          style: TextStyle(
                            fontFamily: 'lateef',
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Profile',
                style: TextStyle(
                  fontFamily: 'lateef',
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: double.infinity, height: 26),
              GestureDetector(
                onTap: () async {
                  File? imageFile =
                      await context.read<ProfileCubit>().pickImageFromDevice();
                  // upload image to cloudinary
                  String imageUrl = await context
                      .read<ProfileCubit>()
                      .uploadImageToCloudAndGetUrl(imageFile);
                  // update image in firestore
                  await FirebaseFirestore.instance
                      .collection(kUsersCollection)
                      .doc(currentUser.uid)
                      .update({kProfileImage: imageUrl});
                  await context.read<HomeCubit>().loadCurrentUser();
                  // update image in Collection frinds
                  await context
                      .read<ProfileCubit>()
                      .upDateProfileImageInAccountFriends(
                        newImage: imageUrl,
                        currentUser: currentUser,
                      );
                  setState(() {});
                },
                child: CircleAvatar(
                  backgroundImage:
                      currentUser!.profileImage == ''
                          ? AssetImage('assets/images/profile.jpg')
                              as ImageProvider
                          : NetworkImage(currentUser.profileImage),
                  radius: 68,
                  child: CircularProgressIndicator(color: Colors.lightBlue),
                ),
              ),

              Text(
                currentUser.name,
                style: TextStyle(
                  fontFamily: 'lateef',
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 110),
                  Text(
                    'UID: ${currentUser.searchID}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.blueGrey,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: currentUser.searchID),
                      );
                      scaffoldMessage(context, 'Copy UID Successfully !');
                    },
                    icon: Icon(
                      Icons.copy_outlined,
                      color: Colors.blueGrey,
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 85),
                ],
              ),
              Expanded(
                child: ListView(
                  children: [
                    buildListTile(
                      onTap: () {
                        Navigator.of(
                          context,
                        ).pushNamed(EdietProfilePage.pageRoute);
                      },
                      text: 'Edite Profile',
                      iconListTile: Icons.person_outline,
                      iconElevatedButton: Icons.arrow_forward_ios_outlined,
                    ),
                    buildListTile(
                      onTap: () {},
                      text: 'Notifications',
                      iconListTile: Icons.notifications_outlined,
                      iconElevatedButton: Icons.arrow_forward_ios_outlined,
                    ),
                    buildListTile(
                      onTap: () {},
                      text: 'Shipping Address',
                      iconListTile: Icons.person_pin_circle_outlined,
                      iconElevatedButton: Icons.arrow_forward_ios_outlined,
                    ),
                    buildListTile(
                      onTap: () {
                        Navigator.of(
                          context,
                        ).pushNamed(ChangePasswordPage.pageRoute);
                      },
                      text: 'Change Password',
                      iconListTile: Icons.lock_outline_rounded,
                      iconElevatedButton: Icons.arrow_forward_ios_outlined,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 15.0,
                  left: 15,
                  right: 15,
                  bottom: 5,
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    iconColor: Colors.white,
                    backgroundColor: Colors.blue,
                    minimumSize: Size(double.infinity, 46),
                  ),
                  onPressed: () {
                    singOut();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout),
                      const SizedBox(width: 6),
                      Text(
                        'Sign Out',
                        style: TextStyle(
                          fontFamily: 'lateef',
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );

          // return Center(
          //   child: CircularProgressIndicator(color: Colors.lightBlue),
          // );
        },
      ),
    );
  }

  Padding buildListTile({
    required String text,
    required IconData iconListTile,
    required iconElevatedButton,
    required void Function()? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          radius: 24,
          child: Icon(iconListTile, color: Colors.white),
        ),
        title: Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: IconButton(
          onPressed: () {},
          icon: Icon(iconElevatedButton, size: 18),
        ),
      ),
    );
  }
}
