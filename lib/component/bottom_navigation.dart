import 'package:alc_mobile_app/screen/account_page.dart';
import 'package:alc_mobile_app/screen/check_price_page.dart';
import 'package:alc_mobile_app/screen/menu_page.dart';
import 'package:alc_mobile_app/screen/rail_card_page.dart';
import 'package:alc_mobile_app/screen/signage_transaction_page.dart';
import 'package:alc_mobile_app/screen/stock_count/stock_count_page.dart';
import 'package:flutter/material.dart';

class Bottomnavigation extends StatefulWidget {
  final int indextpage;

  const Bottomnavigation(this.indextpage, {super.key});

  @override
  State<Bottomnavigation> createState() => BottomnavigationState();
}

class BottomnavigationState extends State<Bottomnavigation> {
  late int currentIndex;

  final List<Map<String, dynamic>> itemstabs = [
    {'icon': Icons.home_outlined, 'label': 'หน้าแรก', 'page': const MenuPage()},
    {'icon': Icons.list_alt_outlined, 'label': 'เรียลการ์ด', 'page': const /* RailCardPage() */SignageTransactionListPage()},
    {'icon': Icons.inventory_2_outlined, 'label': 'นับสต๊อก', 'page': const StockCountPage()},
    {'icon': Icons.price_change_outlined, 'label': 'เช็คราคา', 'page': const CheckPricePage() },
    {'icon': Icons.account_box_outlined, 'label': 'จัดการบัญชี', 'page': const AccountPage()},
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.indextpage;
  }

  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: itemstabs[currentIndex]['page'],
      bottomNavigationBar: BottomNavigationBar(
        
        iconSize: 24,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
        unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        onTap: onTabTapped,
        currentIndex: currentIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black45,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: itemstabs.map((tab) {
          return BottomNavigationBarItem(
            icon: Icon(tab['icon']),
            label: tab['label'],
          );
        }).toList(),
      ),
    );
  }
}