import 'package:finance_manager/dailyinput.dart';
import 'package:finance_manager/spendingsbydate.dart';
import 'package:flutter/material.dart';
class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: deviceHeight * 0.2, // Adjust the height as needed
            decoration: const BoxDecoration(
              color: Colors.amber, // Amber as the primary color for drawer header
            ),
            child: const Center(
              child: Text(
                'Drawer Header',
                style: TextStyle(
                  color: Colors.white, // White text color for drawer header
                  fontSize: 24,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Spendings By Date'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DailySpendingByDateScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Daily records'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DailyExpenseScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
