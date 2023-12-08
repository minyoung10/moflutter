import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../info/room.dart';
import '../../../themepage/theme.dart';
import '../../bottom/home.dart';

class EditMeeting extends StatefulWidget {
  final String roomId;
  final String docId;

  const EditMeeting({
    super.key,
    required this.roomId,
    required this.docId,
  });

  @override
  State<EditMeeting> createState() => _EditMeetingState();
}

class _EditMeetingState extends State<EditMeeting> {
  final picker = ImagePicker();
  XFile? image; // 카메라로 촬영한 이미지를 저장할 변수
  List<XFile?> multiImage = []; // 갤러리에서 여러장의 사진을 선택해서 저장할 변수
  List<XFile?> images = []; // 가져온 사진들을 보여주기 위한 변수
  List<String> Fireimages = [];
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '모임 수정',
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Center(
              child: Text('추가할 이미지를 선택해 주세요.',
                  style: blackw700.copyWith(
                    fontSize: 16,
                  ))),
          const SizedBox(height: 10),
          Center(
            child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(227, 255, 217, 1),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 0.5,
                        blurRadius: 5)
                  ],
                ),
                child: IconButton(
                    onPressed: () async {
                      multiImage = await picker.pickMultiImage();
                      setState(() {
                        //갤러리에서 가지고 온 사진들은 리스트 변수에 저장되므로 addAll()을 사용해서 images와 multiImage 리스트를 합쳐줍니다.
                        images.addAll(multiImage);
                        _uploadImageToFirebase();
                      });
                    },
                    icon: const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 30,
                      color: Colors.black54,
                    ))),
          ),
          Container(
            margin: const EdgeInsets.only(left: 20, right: 20),
            child: GridView.builder(
              padding: const EdgeInsets.all(0),
              shrinkWrap: true,
              itemCount:
                  images.length, //보여줄 item 개수. images 리스트 변수에 담겨있는 사진 수 만큼.
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, //1 개의 행에 보여줄 사진 개수
                childAspectRatio: 1 / 1, //사진 의 가로 세로의 비율
                mainAxisSpacing: 10, //수평 Padding
                crossAxisSpacing: 10, //수직 Padding
              ),
              itemBuilder: (BuildContext context, int index) {
                // 사진 오른 쪽 위 삭제 버튼을 표시하기 위해 Stack을 사용함
                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          image: DecorationImage(
                              fit: BoxFit.cover, //사진을 크기를 상자 크기에 맞게 조절
                              image: FileImage(File(images[index]!
                                      .path // images 리스트 변수 안에 있는 사진들을 순서대로 표시함
                                  )))),
                    ),
                    Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        //삭제 버튼
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.close,
                              color: Colors.white, size: 15),
                          onPressed: () {
                            //버튼을 누르면 해당 이미지가 삭제됨
                            setState(() {
                              images.remove(images[index]);
                            });
                          },
                        ))
                  ],
                );
              },
            ),
          ),
          StreamBuilder(
              stream: firestore
                  .collection('Biginfo')
                  .doc(widget.roomId)
                  .collection('meetings')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                final filteredDocs =
                    docs.where((doc) => doc['id'] == widget.docId).toList();
                final roomSnapshot = filteredDocs.first;
                final roomData = roomSnapshot.data();
                List<String> existingImageUrls =
                    List.castFrom(roomData['images']);
                final title = roomData['title'] as String;
                return Column(
                  children: [
                    const SizedBox(height: 40),
                    Text('제목을 수정해 주세요',
                        style: blackw700.copyWith(
                          fontSize: 16,
                        )),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: TextFormField(
                        key: const ValueKey(1),
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black45),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black45),
                          ),
                        ),
                        initialValue: title,
                        onChanged: (value) {
                          setState(() {
                            RoomProvider.title = value;
                          });
                        },
                        onSaved: (value) {
                          RoomProvider.title = value;
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: ElevatedButton(
                        onPressed: () async {
                          final docRef = FirebaseFirestore.instance
                              .collection('Biginfo')
                              .doc(widget.roomId)
                              .collection('meetings')
                              .doc(widget.docId);

                          existingImageUrls.addAll(uploadedImageUrls);
                          await docRef.update({
                            "images": existingImageUrls,
                            "title": RoomProvider.title ?? roomData['title'],
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          disabledBackgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: const SizedBox(
                          width: 343,
                          height: 45,
                          child: Center(
                            child: Text(
                              '수정하기',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
        ],
      ),
    );
  }

  List<String> uploadedImageUrls = []; // List to store uploaded image URLs

  _uploadImageToFirebase() async {
    // 선택한 이미지들이 있는지 확인
    if (multiImage.isEmpty) {
      if (kDebugMode) {
        debugPrint('이미지가 선택되지 않았습니다.');
      }
      return;
    }

    try {
      for (var xFile in multiImage) {
        if (xFile != null) {
          // 선택한 파일에서 이미지 데이터 읽기
          final imageBytes = await File(xFile.path).readAsBytes();

          // Firebase Storage에 이미지를 업로드할 위치에 대한 참조 생성
          final imageName = '${DateTime.now().microsecondsSinceEpoch}.jpg';
          final storageReference = FirebaseStorage.instance.ref(imageName);

          // 이미지를 Firebase Storage에 업로드
          await storageReference.putData(imageBytes);

          // 업로드된 이미지의 URL 가져오기
          final TaskSnapshot taskSnapshot =
              await storageReference.putData(imageBytes);
          final imageUrl = await taskSnapshot.ref.getDownloadURL();

          // 업로드 된 이미지 URL 저장 또는 활용
          setState(() {
            uploadedImageUrls.add(imageUrl);
          });

          if (kDebugMode) {
            debugPrint('이미지 업로드 성공');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('이미지 업로드 실패: $e');
      }
    }
  }
}
