import 'package:child_care_app/screens/favorite_facilities_page.dart';
import 'package:child_care_app/screens/home_page.dart';
import 'package:child_care_app/screens/scrap_recruitment_page.dart';
import 'package:flutter/material.dart';

class HomeBottomNavigationBar extends StatefulWidget {
  const HomeBottomNavigationBar({super.key});

  @override
  _HomeBottomNavigationBarState createState() =>
      _HomeBottomNavigationBarState();
}

class _HomeBottomNavigationBarState extends State<HomeBottomNavigationBar> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    FavoriteFacilitiesPage(),
    ScrapRecruitmentPage(),
    Placeholder(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _widgetOptions[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color.fromARGB(255, 0, 60, 164),
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(
        color: Colors.grey, // 선택된 아이템의 라벨 색상을 회색으로 설정
        fontSize: 14, // 선택된 아이템의 라벨 크기를 키움
      ),
      unselectedLabelStyle: const TextStyle(
        color: Colors.grey, // 선택되지 않은 아이템의 라벨 색상을 회색으로 설정
        fontSize: 14, // 선택되지 않은 아이템의 라벨 크기를 키움
      ),
      showUnselectedLabels: true,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: 30), // 아이콘 크기 조정
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.star, size: 30), // 아이콘 크기 조정
          label: '관심 기관',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark, size: 30), // 아이콘 크기 조정
          label: '스크랩 공고',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.more_horiz, size: 30), // 아이콘 크기 조정
          label: '더보기',
        ),
      ],
    );
  }
}
