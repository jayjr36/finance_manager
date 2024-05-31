import 'package:finance_manager/budgetscreen.dart';
import 'package:finance_manager/constants.dart';
import 'package:finance_manager/dailyinput.dart';
import 'package:finance_manager/dailyanalysis.dart';
import 'package:finance_manager/expense.dart';
import 'package:finance_manager/goals.dart';
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
   // const ExpenseScreen(),
   const BudgetScreen(),
    const IncomeScreen(),
    //const DailyExpenseScreen(),
    const GoalsScreen(),
    const DailyTrackerScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final constants = Constants();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: constants.secondColor,
          borderRadius: const BorderRadius.all(Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: constants.secondColor,
              spreadRadius: 1,
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        margin: const EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(25)),
          child: BottomNavigationBar(
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
                label: 'Goals',
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
        ),
      ),
    );
  }
}
