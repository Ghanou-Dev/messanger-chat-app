import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:star_chat/const.dart';
import 'package:star_chat/models/friend_model.dart';
import 'package:star_chat/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class UserProvider with ChangeNotifier {
  UserModel? _currentUser;
  List<FriendModel> _friends = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? get currentUser => _currentUser;
  List<FriendModel> get friends => _friends;

  set currentUser(valu) {
    _currentUser = valu;
    notifyListeners();
  }

  Future<void> updateNameInAccountFriends({
    required String name,
  }) async {
    if (_currentUser == null) return;
    // نقوم بأحضار جميع المستخدمين
    final querySnapshot =
        await FirebaseFirestore.instance.collection(kUsersCollection).get();
    for (var snapshot in querySnapshot.docs) {
      if (_currentUser!.uid == snapshot.id) continue;
      final friendRef = FirebaseFirestore.instance
          .collection(kUsersCollection)
          .doc(snapshot.id)
          .collection(kFriendsCollection)
          .doc(_currentUser!.searchID);

      final friendDoc = await friendRef.get();
      if (friendDoc.exists) {
        friendRef.update({
          kFriendName: name,
        });
      }
    }
  }

  // update profile in accont friends
  Future<void> upDateProfileImageInAccountFriends(String newImage) async {
    if (_currentUser == null) return;
    // احضار جميع الحسابات
    final QuerySnapshot =
        await FirebaseFirestore.instance.collection(kUsersCollection).get();
    for (var snapshot in QuerySnapshot.docs) {
      final uid = snapshot.id;
      if (_currentUser!.uid == uid) continue;
      // نقوم بانشاء ريفرانس لبيانات المستخدم في حساب الصديق لكي نقوم بتحديثها ان وجدت
      final friendRef = FirebaseFirestore.instance
          .collection(kUsersCollection)
          .doc(uid)
          .collection(kFriendsCollection)
          .doc(_currentUser!.searchID);
      // نقوم بأحضار وثيقة المستخدم
      final friendDoc = await friendRef.get();
      // نتحقق من وجودها
      if (friendDoc.exists) {
        // نقوم بتحديث البيانات الموجودة فيها
        friendRef.update({kFriendProfileImage: newImage});
      }
    }
  }

  // pick image from the device
  Future<File?> pickImageFromDevice() async {
    XFile? pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      return imageFile;
    } else {
      return null;
    }
  }

  // upload image to cloudinary
  Future<String> uploadImageToCloudAndGetUrl(File? imageFile) async {
    if (imageFile == null) return '';

    const String cloudName = 'dzpv6h0sz';
    const String uploadPreset = 'unsigned_present_ghanou';
    Uri url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );
    final mimeType = lookupMimeType(imageFile!.path);
    final request = http.MultipartRequest('POST', url);
    // اضافة upload_preset لنستطيع رفع الصورة
    request.fields[kUploadPreset] = uploadPreset;
    // انشاء انشاء الملف الي سيحتوي الصورة من الجهاز
    final file = await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      contentType: mimeType != null ? MediaType.parse(mimeType) : null,
    );
    // اضافة الملف الى الطلب
    request.files.add(file);
    // ارسال الطلب
    final response = await request.send();
    // التحقق من نجاح الطلب
    if (response.statusCode == 200) {
      final stringResponse = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(stringResponse);
      // ارجاع رابط الصورة

      return jsonResponse['secure_url'];
    } else {
      debugPrint('فشل في رفع الصورة : ${response.statusCode}');
      return '';
    }
  }

  // دالة لتحميل بيانات المستخدم الحالي
  Future<void> loadCurrentUser(String uid) async {
    final doc = await _firestore.collection(kUsersCollection).doc(uid).get();
    _currentUser = UserModel.fromJson(doc.data()!);
    listenToFriendsList();
    notifyListeners();
  }

  // دالة لاضافة الصديق
  Future<void> addFriend(UserModel friend) async {
    if (_currentUser == null) return;
    // تحميل بيانات الصديق
    FriendModel newFriend = FriendModel(
      friendUID: friend.uid,
      friendName: friend.name,
      friendSearchID: friend.searchID,
      friendProfileImage: friend.profileImage,
      addAt: FieldValue.serverTimestamp(),
      lastSend: FieldValue.serverTimestamp(),
      lastMessage: '',
    );
    // تحميل المستخدم كصديق
    FriendModel meAsFriend = FriendModel(
      friendUID: currentUser!.uid,
      friendName: currentUser!.name,
      friendSearchID: currentUser!.searchID,
      friendProfileImage: currentUser!.profileImage,
      addAt: FieldValue.serverTimestamp(),
      lastSend: FieldValue.serverTimestamp(),
      lastMessage: '',
    );

    // اضافة بيانات الصديق ال Firestor
    await _firestore
        .collection(kUsersCollection)
        .doc(_currentUser!.uid)
        .collection(kFriendsCollection)
        .doc(friend.searchID)
        .set(newFriend.toMap());
    // اضافة بيانات المستخدم كصديق في Firestore
    await _firestore
        .collection(kUsersCollection)
        .doc(friend.uid)
        .collection(kFriendsCollection)
        .doc(_currentUser!.searchID)
        .set(meAsFriend.toMap());
  }

  // دالة لتحميل و مراقبة قائمة الاصدقاء
  // انشاء مستمع ليراقب حالة قائمة الاصدقاء
  StreamSubscription? _friendSub;

  void listenToFriendsList() {
    if (_currentUser == null) return;
    _friendSub?.cancel();
    _friendSub = _firestore
        .collection(kUsersCollection)
        .doc(_currentUser!.uid)
        .collection(kFriendsCollection)
        .orderBy(kLastSend, descending: true)
        .snapshots()
        .listen((snapshot) {
          _friends =
              snapshot.docs.map((doc) {
                return FriendModel.fromjson(doc.data());
              }).toList();
          notifyListeners();
        });
  }

  @override
  void dispose() {
    // انهاء الاشتراك عند تدمير Provider
    _friendSub?.cancel();
    super.dispose();
  }
}
