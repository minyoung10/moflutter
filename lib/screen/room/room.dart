import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../info/user.dart';
import '../../themepage/theme.dart';
import '../bottom/home.dart';
import 'tab/adjustment.dart';
import 'tab/discussion.dart';
import 'tab/meeting.dart';
import 'tab/notification.dart';

class Room extends StatefulWidget {
  final String id;

  const Room({
    required this.id,
    super.key,
  });

  @override
  State<Room> createState() => _RoomState();
}

class _RoomState extends State<Room> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: firestore.collection('Biginfo').snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final docs = snapshot.data!.docs;
          final filteredDocs =
              docs.where((doc) => doc['id'] == widget.id).toList();

          if (filteredDocs.isNotEmpty) {
            final roomSnapshot = filteredDocs.first;
            final roomData = roomSnapshot.data();

            Map<String, dynamic> usersJob = roomData['users_job'];
            UserProvider.userJob = usersJob[UserProvider.userName];
            return Scaffold(
              backgroundColor: Colors.white,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 349,
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.4),
                            BlendMode.darken,
                          ),
                          child: Image.network(
                            roomData['roomImage'].toString(),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 62,
                        left: 10,
                        child: IconButton(
                          onPressed: () {
                            Navigator.popUntil(
                                context, ModalRoute.withName('/'));
                          },
                          color: Colors.white,
                          icon: const Icon(
                            Icons.arrow_back_ios_rounded,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 73,
                        right: 70,
                        child: GestureDetector(
                          onTap: () async {
                            _showMember(context, '1');
                          },
                          child: const SizedBox(
                              width: 30,
                              height: 18,
                              child: Icon(
                                Icons.people,
                                color: Colors.white,
                              )),
                        ),
                      ),
                      Positioned(
                        top: 77,
                        right: 25,
                        child: GestureDetector(
                          onTap: () async {
                            _showDeleteConfirmationDialog(context);
                          },
                          child: SizedBox(
                            width: 30,
                            height: 18,
                            child: Image.asset('assets/images/kebap.png'),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 230,
                        left: 25,
                        child: Text(roomData['title'],
                            style: whitew700.copyWith(
                              fontSize: 24.0,
                            )),
                      ),
                      Positioned(
                        top: 270,
                        left: 170,
                        child: Container(
                          width: 100,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(3), // 반지름 값을 설정합니다.
                            color: const Color.fromRGBO(227, 255, 217, 1),
                          ),
                          child: Center(
                            child: Text('팀 코드 | ${roomData['code']}',
                                style: const TextStyle(
                                    color: Color.fromRGBO(36, 137, 0, 1),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14)),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 270,
                        left: 25,
                        child: Container(
                          width: 130,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(3), // 반지름 값을 설정합니다.
                            color: const Color.fromRGBO(227, 255, 217, 1),
                          ),
                          child: Center(
                            child: Text(roomData['mission'],
                                style: const TextStyle(
                                    color: Color.fromRGBO(36, 137, 0, 1),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14)),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 317),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(23),
                            topRight: Radius.circular(23),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: 379,
                                  height: 50,
                                  child: TabBar(
                                    indicator: UnderlineTabIndicator(
                                      borderSide: const BorderSide(
                                        width: 2, // Bottom line width
                                      ), // Bottom line padding
                                      borderRadius: BorderRadius.circular(
                                          2), // Adjust the radius as needed
                                    ),
                                    indicatorWeight: 3,
                                    indicatorColor:
                                        const Color.fromRGBO(36, 38, 37, 1),
                                    indicatorSize: TabBarIndicatorSize.label,
                                    indicatorPadding: const EdgeInsets.only(
                                        bottom: 1), // Adjust horizontal padding
                                    controller: _tabController,
                                    // label color
                                    labelColor:
                                        const Color.fromRGBO(36, 38, 37, 1),
                                    // unselected label color
                                    unselectedLabelColor: const Color.fromARGB(
                                        255, 151, 151, 151),

                                    tabs: const [
                                      SizedBox(
                                        width: 90,
                                        child: Tab(
                                          child: Text(
                                            '공지사항',
                                            style: TextStyle(
                                              fontFamily: 'Pretendard',
                                              fontSize: 18, // Font size
                                              fontWeight: FontWeight
                                                  .w700, // Font weight 700
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 90,
                                        child: Tab(
                                          child: Text(
                                            '모임',
                                            style: TextStyle(
                                              fontFamily: 'Pretendard',
                                              fontSize: 18, // Font size
                                              fontWeight: FontWeight
                                                  .w700, // Font weight 700
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 90,
                                        child: Tab(
                                          child: Text(
                                            '회의록',
                                            style: TextStyle(
                                              fontFamily: 'Pretendard',
                                              fontSize: 18, // Font size
                                              fontWeight: FontWeight
                                                  .w700, // Font weight 700
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 90,
                                        child: Tab(
                                          child: Text(
                                            '정산',
                                            style: TextStyle(
                                              fontFamily: 'Pretendard',
                                              fontSize: 18, // Font size
                                              fontWeight: FontWeight
                                                  .w700, // Font weight 700
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                                height: 0,
                                color: Color.fromRGBO(170, 170, 170, 1))
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 485,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        NotificationTab(id: widget.id),
                        MeetingTab(id: widget.id),
                        DiscussionTab(id: widget.id),
                        AdjustmentTab(id: widget.id),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Text('');
          }
        });
  }

  void _showMember(BuildContext context, String text) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(23.0)),
      ),
      builder: (BuildContext context) {
        return StreamBuilder(
          stream: firestore.collection('Biginfo').snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final docs = snapshot.data!.docs;
            final filteredDocs =
                docs.where((doc) => doc['id'] == widget.id).toList();

            if (filteredDocs.isNotEmpty) {
              final roomSnapshot = filteredDocs.first;
              final roomData = roomSnapshot.data();
              List<dynamic> usersNameList = roomData["users_name"];

              Map<String, dynamic> usersJob = roomData['users_job'];
              UserProvider.userJob = usersJob[UserProvider.userName];

              return Container(
                width: double.infinity,
                height: 200,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          '멤버',
                          style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1),
                        ),
                        const SizedBox(height: 10),
                        for (var userName in usersNameList)
                          Row(
                            children: [
                              Text(
                                userName.toString(),
                                style: blackw700.copyWith(fontSize: 20),
                              ),
                              Text(
                                ' ${usersJob[userName.toString()]}',
                                style: blackw500.copyWith(fontSize: 16),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return const Text('');
            }
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
            height: 139, // 원하는 세로 길이 설정
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 29),
                Text("정말 삭제하시겠어요?", style: blackw500.copyWith(fontSize: 18)),
                const SizedBox(height: 31),
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
                            Text("삭제", style: whitew700.copyWith(fontSize: 14)),
                        onPressed: () async {
                          try {
                            // Replace "Biginfo" with the actual collection name
                            await FirebaseFirestore.instance
                                .collection("Biginfo")
                                .doc(widget.id)
                                .delete();
                            Navigator.popUntil(
                                context, ModalRoute.withName('/'));
                          } catch (e) {
                            debugPrint("Error deleting document: $e");
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
