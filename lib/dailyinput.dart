// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_manager/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';

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
  String? _selectedExpense;
  bool _isCustomCategory = false;
  final _customCategoryController = TextEditingController();
  bool isloading = true;

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daily Spending Input',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor:
            Constants().primaryColor, // Amber as the primary color for app bar
      ),
      body: LoadingOverlay(
        isLoading: isloading,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('categories')
                    .doc(uid)
                    .collection('my_categories')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  var categories = snapshot.data!.docs;

                  // Ensure the selected category is valid
                  if (_selectedCategory != null &&
                      !categories.any(
                          (category) => category.id == _selectedCategory)) {
                    _selectedCategory = null;
                  }

                  // Add the "Other" option manually
                  var categoryItems = categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category.id,
                      child: Text(category['name']),
                    );
                  }).toList();
                  categoryItems.add(
                    const DropdownMenuItem<String>(
                      value: 'Other',
                      child: Text('Other'),
                    ),
                  );

                  return DropdownButton<String>(
                    value: _selectedCategory,
                    hint: const Text('Select category'),
                    items: categoryItems,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                        _isCustomCategory = value == 'Other';
                        _selectedExpense =
                            null; // Reset selected expense when category changes
                      });
                    },
                    style: const TextStyle(
                        color: Colors.black), // Amber text color for dropdown
                    dropdownColor: Colors
                        .white, // Amber accent color for dropdown background
                  );
                },
              ),
              if (_selectedCategory != null && !_isCustomCategory)
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('categories')
                      .doc(uid)
                      .collection('my_categories')
                      .doc(_selectedCategory)
                      .collection('expenses')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    var expenses = snapshot.data!.docs;

                    // Ensure the selected expense is valid
                    if (_selectedExpense != null &&
                        !expenses.any(
                            (expense) => expense['name'] == _selectedExpense)) {
                      _selectedExpense = null;
                    }

                    return DropdownButton<String>(
                      value: _selectedExpense,
                      hint: const Text('Select expense'),
                      items: expenses.map((expense) {
                        return DropdownMenuItem<String>(
                          value: expense['name'],
                          child: Text(expense['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedExpense = value;
                        });
                      },
                      style: const TextStyle(
                          color: Colors.black), // Amber text color for dropdown
                    );
                  },
                ),
              if (_isCustomCategory)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.2),
                  child: TextField(
                    controller: _customCategoryController,
                    decoration: const InputDecoration(
                      hintText: 'Enter expense',
                      hintStyle: TextStyle(
                          color: Colors.black), // Amber hint text color
                    ),
                    style: const TextStyle(
                        color: Colors.black), // Amber text color for text field
                  ),
                ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.2),
                child: TextField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    hintText: 'Enter amount',
                    hintStyle: TextStyle(color: Colors.black),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _submitSpending(_selectedCategory);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants().primaryColor,
                  surfaceTintColor: Colors.black,
                ),
                child: const Text(
                  'Submit Spending',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitSpending(String? category) async {
    setState(() {
      isloading = true;
    });
    String name = _isCustomCategory
        ? _customCategoryController.text.trim()
        : _selectedExpense ?? '';
    double amount = double.parse(_amountController.text.trim());
    await _firestore
        .collection('daily_spending')
        .doc(uid)
        .collection('my_daily_spending')
        .add({
      'name': name,
      'amount': amount,
      'timestamp': Timestamp.now(),
    });
    _analyzeSpending(name, amount, category);
    _clearForm();
    setState(() {
      isloading = false;
    });
  }

  void _clearForm() {
    setState(() {
      _selectedCategory = null;
      _selectedExpense = null;
      _isCustomCategory = false;
      _customCategoryController.clear();
      _amountController.clear();
    });
  }

  Future<void> _analyzeSpending(
      String name, double amount, String? category) async {
    // Fetch the predefined budget for the given expense within the selected category
    QuerySnapshot budgetSnapshot = await _firestore
        .collection('categories')
        .doc(uid)
        .collection('my_categories')
        .doc(_selectedCategory) // Use the selected category ID
        .collection('expenses')
        .where('name', isEqualTo: name)
        .get();

    if (budgetSnapshot.docs.isNotEmpty) {
      double budgetAmount = budgetSnapshot.docs.first['total_amount'];

      // Calculate the total daily spending for that expense
      QuerySnapshot dailyExpensesSnapshot = await _firestore
          .collection('daily_spending')
          .doc(uid)
          .collection('my_daily_spending')
          .where('name', isEqualTo: name)
          .get();
      double totalDailySpending = dailyExpensesSnapshot.docs
          .fold(0, (total, doc) => total + doc['amount']);

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
      await _firestore
          .collection('expense_analysis')
          .doc(uid)
          .collection('my_expense_analysis')
          .add({
        'name': name,
        'amount': amount,
        'total_daily_spending': totalDailySpending,
        'status': status,
        'difference': difference,
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Expense Analysis: $status')));
    } else {
      await _firestore
          .collection('expense_analysis')
          .doc(uid)
          .collection('my_expense_analysis')
          .add({
        'name': name,
        'amount': amount,
        'total_daily_spending': amount,
        'status': 'No predefined budget found',
        'difference': 0,
        'timestamp': Timestamp.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No predefined budget found for $name')));
    }
  }
}
