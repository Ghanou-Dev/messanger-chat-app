import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:star_chat/models/message_model.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../const.dart';
import '../models/friend_model.dart';
import '../models/user_model.dart';

class ChatPage extends StatefulWidget {
  final UserModel currentUser;
  final FriendModel currentFriend;
  const ChatPage({
    required this.currentUser,
    required this.currentFriend,
    super.key,
  });

  static final pageRoute = '/chatPage';

  @override
  State<ChatPage> createState() => _StateChatPage();
}

class _StateChatPage extends State<ChatPage> {
  @override
  void initState() {
    super.initState();
    chatID = generateChatUID(
      widget.currentUser.uid,
      widget.currentFriend.friendUID,
    );
  }

  String? chatID;
  final TextEditingController _textFieldController = TextEditingController();
  final ScrollController _listController = ScrollController();

  // Generate Chat UID
  String generateChatUID(String userUID, String friendUID) {
    return userUID.compareTo(friendUID) > 0
        ? '${userUID}_And_$friendUID'
        : '${friendUID}_And_$userUID';
  }

  // sendMessageToFirestore
  Future<void> sendMessageToFireStore(String text) async {
    if (text.isEmpty) return;
    await FirebaseFirestore.instance
        .collection(kChatsCollection)
        .doc(chatID)
        .collection(kMessagesCollection)
        .add({
          kMessage: text,
          kSenderUID: widget.currentUser.uid,
          kReceiverUID: widget.currentFriend.friendUID,
          kSendAt: FieldValue.serverTimestamp(),
          kType: kText,
        });
    // update last send message
    await FirebaseFirestore.instance
        .collection(kUsersCollection)
        .doc(widget.currentUser.uid)
        .collection(kFriendsCollection)
        .doc(widget.currentFriend.friendSearchID)
        .update({kLastSend: FieldValue.serverTimestamp()});
  }

  // Desplay messages from firebase
  Widget _desplayMessages() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection(kChatsCollection)
              .doc(chatID)
              .collection(kMessagesCollection)
              .orderBy(kSendAt, descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.blueGrey],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Text(
                'Say Hello !',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          );
        }
        // moving the list view
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _listController.animateTo(
            0,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        });
        List<MessageModel> messagesList =
            snapshot.data!.docs.map((doc) {
              return MessageModel.fromJson(doc.data()!);
            }).toList();

        return ListView.builder(
          reverse: true,
          controller: _listController,
          itemCount: messagesList.length,
          itemBuilder: (context, index) {
            MessageModel message = messagesList[index];
            bool isMe = message.senderUID == widget.currentUser.uid;
            if (message.type == kText) {
              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child:
                    isMe
                        ? Container(
                          padding: EdgeInsets.all(13),
                          margin: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(0),
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                            color: Colors.blue.shade600,
                          ),
                          child: Text(
                            message.message,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        )
                        : Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: CircleAvatar(
                                backgroundImage:
                                    widget.currentFriend.friendProfileImage ==
                                            ''
                                        ? AssetImage(
                                              'assets/images/profile.jpg',
                                            )
                                            as ImageProvider
                                        : NetworkImage(
                                          widget
                                              .currentFriend
                                              .friendProfileImage,
                                        ),
                                radius: 18,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(13),
                              margin: EdgeInsets.symmetric(
                                // horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(20),
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                ),
                                color: Colors.grey[300],
                              ),
                              child: Text(
                                message.message,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
              );
            } else if (message.type == kImage) {
              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child:
                    isMe
                        ? Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Image.network(message.message, width: 200),
                        )
                        : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: CircleAvatar(
                                backgroundImage:
                                    widget.currentFriend.friendProfileImage ==
                                            ''
                                        ? AssetImage(
                                              'assets/images/profile.jpg',
                                            )
                                            as ImageProvider
                                        : NetworkImage(
                                          widget
                                              .currentFriend
                                              .friendProfileImage,
                                        ),
                                radius: 18,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isMe ? Colors.blue : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Image.network(message.message, width: 200),
                            ),
                          ],
                        ),
              );
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  File? imageFile;

  Future<String?> uploadImageToCloudinary(File imageFile) async {
    const cloudName = 'dzpv6h0sz';
    const uploadPreset = 'unsigned_present_ghanou';

    final mimeType = lookupMimeType(imageFile.path);
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    // انشاء طلب من نوع Multipart لاضافة حقول وملفات
    final request = http.MultipartRequest('POST', url);
    // اضافة preset لحقول البيانات
    request.fields[kUploadPreset] = uploadPreset;

    // انشاء ملف من الهاتف و اضافته الى الطلب
    final file = await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      contentType: mimeType != null ? MediaType.parse(mimeType) : null,
    );
    // اضافته الى الطلب
    request.files.add(file);

    // ارسال الطلب الى Cloudinary
    final respons = await request.send();

    // التعامل مع الرد
    if (respons.statusCode == 200) {
      final strRespons = await respons.stream.bytesToString();
      final jsonRespons = jsonDecode(strRespons);

      // ارجاع رابط الصورة
      return jsonRespons['secure_url'];
    } else {
      debugPrint('فشل في رفع الصورة الى Cloudinari : ${respons.statusCode}');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          contentPadding: EdgeInsets.all(0),
          leading: CircleAvatar(
            backgroundImage:
                widget.currentFriend.friendProfileImage == ''
                    ? AssetImage('assets/images/profile.jpg') as ImageProvider
                    : NetworkImage(widget.currentFriend.friendProfileImage),
            radius: 22,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                widget.currentFriend.friendName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Text(
                'Active',
                style: TextStyle(
                  fontFamily: 'lateef',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          trailing: IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.error_rounded,
              color: Colors.blueGrey,
              size: 26,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Divider(color: Colors.grey[300], thickness: 2, height: 2),
          Expanded(child: _desplayMessages()),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: IconButton(
                  onPressed: () async {
                    final XFile? picktImage = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    if (picktImage != null) {
                      setState(() {
                        imageFile = File(picktImage.path);
                      });
                      // upload image to cloudinary && get image url
                      final urlImage = await uploadImageToCloudinary(
                        imageFile!,
                      );
                      String imageUrl = urlImage ?? '';
                      // update in firestore
                      await FirebaseFirestore.instance
                          .collection(kChatsCollection)
                          .doc(chatID)
                          .collection(kMessagesCollection)
                          .add({
                            kMessage: imageUrl,
                            kSenderUID: widget.currentUser.uid,
                            kReceiverUID: widget.currentFriend.friendUID,
                            kSendAt: FieldValue.serverTimestamp(),
                            kType: kImage,
                          });
                    }
                  },
                  icon: const Icon(
                    Icons.photo_library,
                    color: Colors.blueGrey,
                    size: 30,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.multiline,
                    maxLines: 4,
                    minLines: 1,
                    textInputAction: TextInputAction.newline,
                    controller: _textFieldController,
                    cursorColor: Colors.blueGrey,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: 'Send message',
                      hintStyle: TextStyle(color: Colors.grey),
                      suffixIcon: IconButton(
                        onPressed: () async {
                          final messageText = _textFieldController.text.trim();
                          _textFieldController.clear();
                          await sendMessageToFireStore(messageText);
                          // تحديث اخر رسالة
                          await FirebaseFirestore.instance
                              .collection(kUsersCollection)
                              .doc(widget.currentUser.uid)
                              .collection(kFriendsCollection)
                              .doc(widget.currentFriend.friendSearchID)
                              .update({kLastMessage: messageText});

                          await FirebaseFirestore.instance
                              .collection(kUsersCollection)
                              .doc(widget.currentFriend.friendUID)
                              .collection(kFriendsCollection)
                              .doc(widget.currentUser.searchID)
                              .update({kLastMessage: messageText});
                        },
                        icon: Icon(Icons.send_rounded, color: Colors.blueGrey),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.blueGrey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.blueGrey),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
