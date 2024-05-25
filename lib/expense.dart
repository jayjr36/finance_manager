// ignore_for_file: no_leading_underscores_for_local_identifiers, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  ExpenseScreenState createState() => ExpenseScreenState();
}

class ExpenseScreenState extends State<ExpenseScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> dailyExpenses = [];
  List<Map<String, dynamic>> weeklyExpenses = [];

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    // Fetch daily expenses
    QuerySnapshot dailySnapshot = await _firestore.collection('preset_daily_expenses').get();
    List<Map<String, dynamic>> dailyData = dailySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    // Fetch weekly expenses
    QuerySnapshot weeklySnapshot = await _firestore.collection('preset_weekly_expenses').get();
    List<Map<String, dynamic>> weeklyData = weeklySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    setState(() {
      dailyExpenses = dailyData;
      weeklyExpenses = weeklyData;
    });
  }

  Future<void> _addExpense(String collection) async {
    TextEditingController _nameController = TextEditingController();
    TextEditingController _amountController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Enter expense name'),
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(hintText: 'Enter amount'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String name = _nameController.text;
              double amount = double.parse(_amountController.text);
              await _firestore.collection(collection).add({'name': name, 'amount': amount, 'timestamp': Timestamp.now()});
              Navigator.of(context).pop();
              _fetchExpenses(); 
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
        title: const Text('Expense Tracker'),
      ),
      body: ListView(
        children: [
          ExpansionTile(
            title: const Text('Daily Expenses'),
            children: [
              ...dailyExpenses.map((expense) => ListTile(
                    title: Text('${expense['name']} - \$${expense['amount']}'),
                    subtitle: Text((expense['timestamp'] as Timestamp).toDate().toString()),
                  )),
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
                    title: Text('${expense['name']} - \$${expense['amount']}'),
                    subtitle: Text((expense['timestamp'] as Timestamp).toDate().toString()),
                  )),
              TextButton(
                onPressed: () => _addExpense('weekly_expenses'),
                child: const Text('Add Weekly Expense'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}