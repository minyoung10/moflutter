import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../add/add_adjustment.dart';

class AdjustmentTab extends StatefulWidget {
  final String id;
  const AdjustmentTab({super.key, required this.id});
  @override
  State<AdjustmentTab> createState() => _AdjustmentTabState();
}

class _AdjustmentTabState extends State<AdjustmentTab> {
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

              // Now you can use filteredDocs to display data from Firestore
              if (docs.isNotEmpty) {
                final roomSnapshot = docs.first;
                final roomData = roomSnapshot.data();

                return Container(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Container(
                      margin:
                          const EdgeInsets.only(left: 25, right: 25, top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(roomData['title']),
                          Text(roomData['price']),
                          Text(roomData['image'].toString()),
                          const SizedBox(height: 30),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return const Center(
                    child: Text(
                  '아래 버튼을 눌러 정산을 요청해주세요!',
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
                    builder: (context) => AddAdjustment(
                          id: widget.id,
                        )),
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
                  '정산 요청하기',
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
