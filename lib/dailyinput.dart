// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DailyExpenseScreen extends StatefulWidget {
  const DailyExpenseScreen({super.key});

  @override
  DailyExpenseScreenState createState() => DailyExpenseScreenState();
}

class DailyExpenseScreenState extends State<DailyExpenseScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String uid = FirebaseAuth.instance.currentUser!.uid;
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  Future<void> _addSpending() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Daily Spending'),
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
              String name = _nameController.text.trim();
              double amount = double.parse(_amountController.text.trim());
              await _firestore.collection('daily_spending').doc(uid).collection('my_daily_spending').add({'name': name, 'amount': amount, 'timestamp': Timestamp.now()});
              Navigator.of(context).pop();
              _analyzeSpending(name, amount);
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

  Future<void> _analyzeSpending(String name, double amount) async {
    QuerySnapshot budgetSnapshot = await _firestore.collection('daily_expenses').doc(uid).collection('my_daily_expenses').where('name', isEqualTo: name).get();
    if (budgetSnapshot.docs.isNotEmpty) {
      double budgetAmount = budgetSnapshot.docs.first['amount'];
      String status;
      double difference;
      if (amount < budgetAmount) {
        status = 'Saved Money';
        difference = budgetAmount - amount;
      } else if (amount == budgetAmount) {
        status = 'Within Budget';
        difference = 0;
      } else {
        status = 'Overspent';
        difference = amount - budgetAmount;
      }

      await _firestore.collection('expense_analysis').doc(uid).collection('my_expense_analysis').add({
        'name': name,
        'amount': amount,
        'status': status,
        'difference': difference,
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Expense Analysis: $status')));
    } else {
      await _firestore.collection('expense_analysis').doc(uid).collection('my_expense_analysis').add({
        'name': name,
        'amount': amount,
        'status': 'out of budget',
        'difference': 0,
        'timestamp': Timestamp.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No predefined budget found for $name')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Spending Input'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _addSpending,
          child: const Text('Add Daily Spending'),
        ),
      ),
    );
  }
}
