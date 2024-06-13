// ignore_for_file: avoid_types_as_parameter_names, use_build_context_synchronously

import 'package:finance_manager/budgetscreen.dart';
import 'package:finance_manager/dailyinput.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_manager/spendingsbydate.dart';
import 'package:intl/intl.dart'; // Import the screen to navigate to

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  ExpenseScreenState createState() => ExpenseScreenState();
}

class ExpenseScreenState extends State<ExpenseScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String uid = FirebaseAuth.instance.currentUser!.uid;
  List<Map<String, dynamic>> dailyExpenses = [];
  List<Map<String, dynamic>> weeklyExpenses = [];
  double totalDailyExpenses = 0.0;
  double totalWeeklyExpenses = 0.0;
  double totalDailySpendings = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    try {
      QuerySnapshot dailySnapshot = await _firestore.collection('daily_expenses').doc(uid).collection('my_daily_expense').get();
      List<Map<String, dynamic>> dailyData = dailySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      QuerySnapshot weeklySnapshot = await _firestore.collection('weekly_expenses').doc(uid).collection('my_weekly_expense').get();
      List<Map<String, dynamic>> weeklyData = weeklySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      double dailyTotal = dailySnapshot.docs.fold(0, (sum, doc) => sum + (doc.data() as Map<String, dynamic>)['amount']);
      double weeklyTotal = weeklySnapshot.docs.fold(0, (sum, doc) => sum + (doc.data() as Map<String, dynamic>)['amount']);

      setState(() {
        dailyExpenses = dailyData;
        weeklyExpenses = weeklyData;
        totalDailyExpenses = dailyTotal;
        totalWeeklyExpenses = weeklyTotal;
      });

      // Debug prints to verify data
      if (kDebugMode) {
        print('Daily Expenses: $dailyExpenses');
      }
      if (kDebugMode) {
        print('Weekly Expenses: $weeklyExpenses');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching expenses: $e');
      }
    }
  }

  Future<void> _addExpense(String collection) async {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Enter expense name'),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(hintText: 'Enter amount'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                String name = nameController.text;
                double amount = double.parse(amountController.text);
                await _firestore.collection('expenses').doc(uid).collection(collection).add({
                  'name': name,
                  'amount': amount,
                  'timestamp': Timestamp.now()
                });
                Navigator.of(context).pop();
                _fetchExpenses();
              } catch (e) {
                if (kDebugMode) {
                  print('Error adding expense: $e');
                }
              }
            },
            child: const Text('Add'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: const Text('Expense Tracker', style: TextStyle(color: Colors.white),),
      ),
      body: ListView(
        children: [
          ExpansionTile(
            title: const Text('Daily Expenses',),
            children: [
              ...dailyExpenses.map((expense) => ListTile(
                title: Text('${expense['name']} - ${expense['amount']}'),
                subtitle: Text(
                   DateFormat('dd MMMM yyyy').format(
                          (expense['timestamp'] as Timestamp).toDate()),
              ))),
              TextButton(
                onPressed: () => _addExpense('daily_expenses'),
                child: const Text('Add Daily Expense'),
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('Weekly Expenses'),
            children: [
              ...weeklyExpenses.map((expense) => ListTile(
                title: Text('${expense['name']} - ${expense['amount']}'),
                subtitle: Text((expense['timestamp'] as Timestamp).toDate().toString()),
              )),
              TextButton(
                onPressed: () => _addExpense('weekly_expenses'),
                child: const Text('Add Weekly Expense'),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DailySpendingByDateScreen()),
              );
            },
            child: const Text('Spendings By Date'),
          ),

           ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DailyExpenseScreen()),
              );
            },
            child: const Text('Daily records'),
          ),
           ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BudgetScreen()),
              );
            },
            child: const Text('Budget'),
          ),
          const SizedBox(height: 20), 
          Center(child: Text('Total Daily Expenses: ${totalDailyExpenses.toStringAsFixed(0)}')),
          Center(child: Text('Total Weekly Expenses: ${totalWeeklyExpenses.toStringAsFixed(0)}')),
          Center(child: Text('Total Budget: ${(totalDailyExpenses+totalWeeklyExpenses).toStringAsFixed(0)}')),
        ],
      ),
    );
  }
}
