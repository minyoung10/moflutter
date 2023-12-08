// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../info/user.dart';
import '../../themepage/theme.dart';
import '../bottom/bottom.dart';

class NameInputDialog extends StatefulWidget {
  const NameInputDialog({Key? key}) : super(key: key);

  @override
  _NameInputDialogState createState() => _NameInputDialogState();
}

class _NameInputDialogState extends State<NameInputDialog> {
  TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shadowColor: Colors.transparent,
      contentPadding: const EdgeInsets.all(0), // padding을 0으로 설정
      insetPadding: const EdgeInsets.all(16), // 화면 주변 padding 설정
      backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      content: SizedBox(
        width: 343, // 원하는 가로 길이 설정
        height: 200, // 원하는 세로 길이 설정
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Text("이름을 입력해 주세요", style: blackw500.copyWith(fontSize: 18)),
              Container(
                width: 180, // 너비 조절
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black45),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black45),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 131,
                    height: 35,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shadowColor: Colors.transparent,
                        backgroundColor: const Color(0xFF808080),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6), // 모서리 반경 설정
                        ),
                      ),
                      child:
                          Text("취소", style: whitew700.copyWith(fontSize: 14)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  SizedBox(
                    width: 131,
                    height: 35,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shadowColor: Colors.transparent,
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6), // 모서리 반경 설정
                        ),
                      ),
                      child:
                          Text("확인", style: whitew700.copyWith(fontSize: 14)),
                      onPressed: () {
                        Navigator.pop(
                            context, _nameController.text); // 입력한 이름 반환
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<UserCredential> signInWithGoogle() async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  return await FirebaseAuth.instance.signInWithCredential(credential);
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageScreenState();
}

class _LoginPageScreenState extends State<LoginPage> {
  void _googleSignIn() async {
    try {
      UserCredential userCredential = await signInWithGoogle();

      // 사용자 이름이 이미 존재하는지 확인
      final db = FirebaseFirestore.instance;
      final docSnapshot = await db
          .collection('user')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (docSnapshot.exists) {
        // 이미 사용자 이름이 존재하면 바로 진행
        UserProvider.userName = docSnapshot['name'];
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavigation()),
        );
      } else {
        // 사용자 이름이 없다면 입력 모달 띄우기
        String? username = await showDialog<String>(
          context: context,
          builder: (context) => const NameInputDialog(),
        );

        if (username != null) {
          UserProvider.userName = username;
          // 사용자 이름이 입력되었을 때만 Firestore에 저장
          final docref =
              db.collection('user').doc(FirebaseAuth.instance.currentUser!.uid);
          await docref.set({
            'email': userCredential.user!.email,
            'uid': userCredential.user!.uid,
            'name': username,
          });

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavigation()),
          );
        }
      }
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
    }
  }

  void _anonySignIn() async {
    try {
      // 사용자 이름 입력 모달 띄우기
      String? username = await showDialog<String>(
        context: context,
        builder: (context) => const NameInputDialog(),
      );

      // username이 null인지 확인
      if (username == null) {
        // username이 null인 경우 처리 (예: 사용자가 입력 취소한 경우)
        debugPrint("Username이 null입니다. 로그인 프로세스를 중단합니다.");
        return;
      }

      UserProvider.userName = username;
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      final db = FirebaseFirestore.instance;
      final docref =
          db.collection('user').doc(FirebaseAuth.instance.currentUser!.uid);
      await docref.set({
        'uid': userCredential.user!.uid,
        'name': username,
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavigation()),
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "operation-not-allowed":
          debugPrint("프로젝트에서 익명 인증이 활성화되지 않았습니다.");
          break;
        default:
          debugPrint("알 수 없는 오류가 발생했습니다.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  _googleSignIn();
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  foregroundColor: const Color.fromRGBO(54, 209, 0, 1),
                  backgroundColor: const Color.fromRGBO(54, 209, 0, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(343, 52),
                ),
                child: Text('구글 로그인', style: whitew700.copyWith(fontSize: 18)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _anonySignIn();
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  foregroundColor: Colors.black,
                  backgroundColor: const Color.fromRGBO(54, 209, 0, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(343, 52),
                ),
                child: Text('익명 로그인', style: whitew700.copyWith(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
