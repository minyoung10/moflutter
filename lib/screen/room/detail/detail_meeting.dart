import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../themepage/theme.dart';
import '../../bottom/home.dart';
import '../edit/edit_meeting.dart';

class MeetingDetail extends StatefulWidget {
  final String roomId;
  final String docId;

  const MeetingDetail({
    super.key,
    required this.roomId,
    required this.docId,
  });

  @override
  State<MeetingDetail> createState() => _MeetingDetailState();
}

class _MeetingDetailState extends State<MeetingDetail> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: firestore
            .collection('Biginfo')
            .doc(widget.roomId)
            .collection('meetings')
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
            final roomSnapshot = filteredDocs.first;
            final roomData = roomSnapshot.data();
            final title = roomData['title'] as String;
            final writer = roomData['writer'] as String;
            final job = roomData['job'] as String;
            List<String> images = List.castFrom(roomData['images']);

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
                title: const Text(
                  '모임',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                actions: <Widget>[
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.create),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditMeeting(
                                roomId: widget.roomId,
                                docId: widget.docId,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('Biginfo')
                              .doc(widget.roomId)
                              .collection('meetings')
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
                      const SizedBox(height: 20),
                      Text(title,
                          style: blackw700.copyWith(
                            fontSize: 24,
                          )),
                      Row(
                        children: [
                          const Spacer(),
                          Text(
                            '$writer ($job)',
                            style: blackw500.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      for (String imageUrl in images)
                        Column(
                          children: [
                            SizedBox(
                              width: 343,
                              height: 256,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.network(
                                  imageUrl,
                                  width: MediaQuery.of(context).size.width,
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            ),
                            const SizedBox(height: 27),
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
        });
  }
}
