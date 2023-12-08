import 'package:flutter/material.dart';

import '../../themepage/theme.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
      body: Center(
        child: Column(children: [
          const SizedBox(
            height: 350,
          ),
          Text(
            '검색 기능은',
            style: blackw500.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 5),
          Text(
            '업데이트 예정이에요!',
            style: blackw500.copyWith(fontSize: 17),
          )
        ]),
      ),
    );
  }
}
