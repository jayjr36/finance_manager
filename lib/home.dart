import 'package:finance_manager/dailyinput.dart';
import 'package:finance_manager/dailyanalysis.dart';
import 'package:finance_manager/expense.dart';
import 'package:finance_manager/incomes.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const ExpenseScreen(),
    const IncomeScreen(),
    const DailyExpenseScreen(),
    const DailyTrackerScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.yellow,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Incomes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Daily Expense',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Tracker',
          ),
        ],
        currentIndex: _selectedIndex,
        
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.yellow[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
