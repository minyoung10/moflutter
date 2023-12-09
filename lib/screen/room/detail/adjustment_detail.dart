import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

import '../../../themepage/theme.dart';
import '../../bottom/home.dart';

class AdjustmentDetail extends StatefulWidget {
  final String eventId;
  final String docId;

  const AdjustmentDetail({
    super.key,
    required this.eventId,
    required this.docId,
  });

  @override
  State<AdjustmentDetail> createState() => _AdjustmentDetailState();
}

class _AdjustmentDetailState extends State<AdjustmentDetail> {
  User? user = FirebaseAuth.instance.currentUser;
  XFile? _image; //이미지를 담을 변수 선언
  final ImagePicker picker = ImagePicker(); //ImagePicker 초기화
  String scannedText = ""; // textRecognizer로 인식된 텍스트를 담을 String
  String people = "";
  String money = "";
  bool isMatched = false;

  //이미지를 가져오는 함수
  Future getImage() async {
    //pickedFile에 ImagePicker로 가져온 이미지가 담긴다.
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path); //가져온 이미지를 _image에 저장
      });
      getRecognizedText(_image!); // 이미지를 가져온 뒤 텍스트 인식 실행
    }
  }

  void getRecognizedText(XFile image) async {
    // XFile 이미지를 InputImage 이미지로 변환
    final InputImage inputImage = InputImage.fromFilePath(image.path);

    // textRecognizer 초기화, 이때 script에 인식하고자하는 언어를 인자로 넘겨줌
    // ex) 영어는 script: TextRecognitionScript.latin, 한국어는 script: TextRecognitionScript.korean
    final textRecognizer =
        GoogleMlKit.vision.textRecognizer(script: TextRecognitionScript.korean);

    // 이미지의 텍스트 인식해서 recognizedText에 저장
    RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    // Release resources
    await textRecognizer.close();

    // 인식한 텍스트 정보를 scannedText에 저장
    scannedText = "";
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        scannedText = "$scannedText${line.text}\n";
        debugPrint("scanned: $scannedText");
      }
    }

    setState(() {
      RegExp peopleExp = RegExp(r"(.*) 님께");
      people = peopleExp.firstMatch(scannedText)!.group(1)!;

// '원' 앞에 있는 숫자를 찾는 정규 표현식
      RegExp moneyExp = RegExp(r"(\d+)원");
      money = moneyExp.firstMatch(scannedText)!.group(1)!;

      debugPrint('people: $people');
      debugPrint('money: $money');
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: firestore
            .collection('Biginfo')
            .doc(widget.eventId)
            .collection('adjustments')
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data!.docs;
          final filteredDocs =
              docs.where((doc) => doc['id'] == widget.docId).toList();
          if (filteredDocs.isNotEmpty) {
            final eventSnapshot = filteredDocs.first;
            final eventData = eventSnapshot.data();
            final String eventTitle = eventData['title'];
            final String price = eventData['price'];
            final String name = eventData['people'];
            final List<String> payedList =
                List<String>.from(eventData['payed']);
            final bool isPayed = payedList.contains(user!.uid);

            return Scaffold(
              appBar: AppBar(
                leading: Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
                title: Text(eventTitle),
                actions: <Widget>[
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.create),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('Biginfo')
                              .doc(widget.eventId)
                              .collection('adjustments')
                              .doc(widget.docId)
                              .delete();
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 13)
                    ],
                  ),
                ],
              ),
              body: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.only(left: 25, right: 25),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 10),
                      isPayed
                          ? Stack(children: [
                              Container(
                                width: 343,
                                height: 256,
                                color: const Color.fromRGBO(227, 255, 217, 1),
                              ),
                              Positioned(
                                top: 16,
                                left: 16,
                                child: SizedBox(
                                  width: 311,
                                  height: 224,
                                  child: _image != null && _image!.path != null
                                      ? Image.file(
                                          File(_image!.path),
                                          fit: BoxFit.fill,
                                        )
                                      : Text(
                                          '정산이 완료되었습니다',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                ),
                              ),
                            ])
                          : Container(
                              width: 343,
                              height: 256,
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, top: 20),
                              color: const Color.fromRGBO(
                                  227, 255, 217, 1), // 연두색 설정
                              child: InkWell(
                                onTap: () {
                                  getImage();
                                  debugPrint(money);
                                  if (people == name && money == price) {
                                    isMatched = true;
                                  }
                                  if (isMatched) {
                                    FirebaseFirestore.instance
                                        .collection('Biginfo')
                                        .doc(widget.eventId)
                                        .collection('adjustments')
                                        .doc(widget.docId)
                                        .update({
                                      'payed':
                                          FieldValue.arrayUnion([user!.uid]),
                                      'paylist':
                                          FieldValue.arrayRemove([user!.uid])
                                    });
                                  }
                                },
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text("정산 화면을 인증해주세요!"),
                                    SizedBox(height: 20),
                                    Icon(Icons.camera_alt_outlined, size: 100)
                                  ],
                                ),
                              )),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  Text("정산 완료",
                                      style: blackw700.copyWith(
                                        fontSize: 18,
                                      )),
                                ],
                              ),
                              FutureBuilder(
                                future: fetchCompletedPayments(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text("에러: ${snapshot.error}");
                                  } else {
                                    List<String>? completedPayments =
                                        snapshot.data;
                                    return Column(
                                      children: completedPayments!
                                          .map((user) => Text(user))
                                          .toList(),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          const VerticalDivider(
                              thickness: 2, color: Colors.black),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("미완료",
                                  style: blackw700.copyWith(
                                    fontSize: 18,
                                  )),
                              FutureBuilder(
                                future: fetchPendingPayments(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text("에러: ${snapshot.error}");
                                  } else {
                                    List<String>? pendingPayments =
                                        snapshot.data;
                                    return Column(
                                      children: pendingPayments!
                                          .map((user) => Text(user))
                                          .toList(),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const Text('');
          }
        });
  }

  Future<List<String>> fetchCompletedPayments() async {
    DocumentSnapshot<Map<String, dynamic>> docSnapshot = await FirebaseFirestore
        .instance
        .collection('Biginfo')
        .doc(widget.eventId)
        .collection('adjustments')
        .doc(widget.docId)
        .get();

    if (!docSnapshot.exists) {
      return [];
    }

    Map<String, dynamic> adjustmentData = docSnapshot.data()!;

    List<String> userIds = List<String>.from(adjustmentData['payed'] ?? []);
    List<String> userNames = [];

    for (String userId in userIds) {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance.collection('user').doc(userId).get();

      if (userSnapshot.exists) {
        userNames.add(userSnapshot['name']);
      }
    }

    return userNames;
  }

  Future<List<String>> fetchPendingPayments() async {
    DocumentSnapshot<Map<String, dynamic>> docSnapshot = await FirebaseFirestore
        .instance
        .collection('Biginfo')
        .doc(widget.eventId)
        .collection('adjustments')
        .doc(widget.docId)
        .get();

    if (!docSnapshot.exists) {
      return [];
    }

    Map<String, dynamic> adjustmentData = docSnapshot.data()!;

    List<String> userIds = List<String>.from(adjustmentData['paylist'] ?? []);
    List<String> userNames = [];

    for (String userId in userIds) {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance.collection('user').doc(userId).get();

      if (userSnapshot.exists) {
        userNames.add(userSnapshot['name']);
      }
    }

    return userNames;
  }
}
