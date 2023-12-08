import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mo_final/info/user.dart';

import '../../../themepage/theme.dart';
import '../add/add_discussion.dart';
import '../detail/detail.discussion.dart';

class DiscussionTab extends StatefulWidget {
  final String id;
  const DiscussionTab({super.key, required this.id});
  @override
  State<DiscussionTab> createState() => DiscussionTabState();
}

class DiscussionTabState extends State<DiscussionTab> {
  final firestore = FirebaseFirestore.instance;
  String? roomDataId;
  String? userindex;

  var scroll = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: firestore
                .collection('Biginfo')
                .doc(widget.id)
                .collection('discussions')
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final docs = snapshot.data!.docs;

              if (docs.isNotEmpty) {
                final roomData = docs.toList();

                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        debugPrint(roomData[index]['id']);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DiscussionDetail(
                              roomId: widget.id,
                              docId: roomData[index]['id'],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 25, right: 25, bottom: 25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  roomData[index]['title'],
                                  style: blackw700.copyWith(fontSize: 18),
                                ),
                                const Spacer(),
                                Text(
                                  '${roomData[index]['writer']} (${roomData[index]['job']})',
                                  style: blackw500.copyWith(fontSize: 18),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              width: double.infinity,
                              color: const Color.fromRGBO(
                                  227, 255, 217, 1), // 연두색 설정
                              child: Text(
                                roomData[index]['context'],
                                style: blackw500.copyWith(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                return const Center(
                    child: Text(
                  '아래 버튼을 눌러 회의록을 작성하세요!',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ));
              }
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddDisussion(
                    id: widget.id,
                    job: UserProvider.userJob as String,
                  ),
                ),
              );
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
                  '공지 작성하기',
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
        const SizedBox(height: 20),
      ],
    );
  }
}
