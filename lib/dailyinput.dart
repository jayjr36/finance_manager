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
  final _amountController = TextEditingController();
  String? _selectedCategory;
  bool _isCustomCategory = false;
  final _customCategoryController = TextEditingController();

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

  
   Future<void> _addSpending() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Daily Spending'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('categories').doc(uid).collection('my_categories').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                var categories = snapshot.data!.docs;
                return DropdownButton<String>(
                  value: _selectedCategory,
                  hint: const Text('Select expense'),
                  items: categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category['name'],
                      child: Text(category['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                      _isCustomCategory = value == 'Other';
                    });
                  },
                );
              },
            ),
            if (_isCustomCategory)
              TextField(
                controller: _customCategoryController,
                decoration: const InputDecoration(hintText: 'Enter expense'),
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
              String name = _isCustomCategory
                  ? _customCategoryController.text.trim()
                  : _selectedCategory ?? '';
              double amount = double.parse(_amountController.text.trim());
              await _firestore.collection('daily_spending').doc(uid).collection('my_daily_spending').add({
                'name': name,
                'amount': amount,
                'timestamp': Timestamp.now(),
              });
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
  // Fetch the predefined budget for the given category
  QuerySnapshot budgetSnapshot = await _firestore.collection('categories').doc(uid).collection('my_categories').where('name', isEqualTo: name).get();
  if (budgetSnapshot.docs.isNotEmpty) {
    double budgetAmount = budgetSnapshot.docs.first['amount'];
    
    // Calculate the total daily spending for that category
    QuerySnapshot dailyExpensesSnapshot = await _firestore.collection('daily_spending').doc(uid).collection('my_daily_spending').where('name', isEqualTo: name).get();
    double totalDailySpending = dailyExpensesSnapshot.docs.fold(0, (total, doc) => total + doc['amount']);

    // Compare the total daily spending with the budget
    String status;
    double difference = budgetAmount - totalDailySpending;
    if (totalDailySpending < budgetAmount) {
      status = 'Within Budget';
    } else if (totalDailySpending == budgetAmount) {
      status = 'Budget reached';
    } else {
      status = 'Overspent';
      difference = totalDailySpending - budgetAmount;
    }

    // Update Firestore with the analysis
    await _firestore.collection('expense_analysis').doc(uid).collection('my_expense_analysis').add({
      'name': name,
      'amount': amount,
      'total_daily_spending': totalDailySpending,
      'status': status,
      'difference': difference,
      'timestamp': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Expense Analysis: $status')));
  } else {
    await _firestore.collection('expense_analysis').doc(uid).collection('my_expense_analysis').add({
      'name': name,
      'amount': amount,
      'total_daily_spending': amount,
      'status': 'No predefined budget found',
      'difference': 0,
      'timestamp': Timestamp.now(),
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No predefined budget found for $name')));
  }
}

}
