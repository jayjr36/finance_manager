// ignore_for_file: avoid_types_as_parameter_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DailyExpenseScreen extends StatefulWidget {
  const DailyExpenseScreen({super.key});

  @override
  DailyExpenseScreenState createState() => DailyExpenseScreenState();
}

class DailyExpenseScreenState extends State<DailyExpenseScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  List<Map<String, dynamic>> dailyExpenses = [];
  double totalExpenses = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    QuerySnapshot dailySnapshot = await _firestore.collection('preset_daily_expenses').get();
    List<Map<String, dynamic>> dailyData = dailySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    double totalExpense = dailyData.fold(0.0, (sum, expense) => sum + expense['amount']);

    setState(() {
      dailyExpenses = dailyData;
      totalExpenses = totalExpense;
    });

    _generateDailyAnalysis();
  }

  Future<void> _addDailyExpense() async {
    String name = _nameController.text;
    double amount = double.parse(_amountController.text);
    await _firestore.collection('daily_expenses').add({'name': name, 'amount': amount, 'timestamp': Timestamp.now()});
    _nameController.clear();
    _amountController.clear();
    _fetchData();
  }

  Future<void> _generateDailyAnalysis() async {
    QuerySnapshot dailySnapshot = await _firestore.collection('daily_expenses').get();
    List<Map<String, dynamic>> dailyData = dailySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    for (var expense in dailyData) {
      String expenseName = expense['name'];
      double enteredAmount = expense['amount'];
      QuerySnapshot presetSnapshot = await _firestore.collection('preset_daily_expenses').where('name', isEqualTo: expenseName).get();
     if (presetSnapshot.docs.isNotEmpty) {
        double presetAmount = (presetSnapshot.docs.first.data() as Map<String, dynamic>)['amount'] ?? 0.0;
        bool isAbove = enteredAmount > presetAmount;
        await _firestore.collection('daily_tracker').add({
          'expense_name': expenseName,
          'entered_amount': enteredAmount,
          'preset_amount': presetAmount,
          'is_above': isAbove,
          'timestamp': Timestamp.now(),
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Expense Name'),
          ),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: 'Amount'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _addDailyExpense,
            child: const Text('Add Expense'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: dailyExpenses.length,
              itemBuilder: (context, index) {
                var expense = dailyExpenses[index];
                return ListTile(
                  title: Text('${expense['name']} - \$${expense['amount']}'),
                  subtitle: Text((expense['timestamp'] as Timestamp).toDate().toString()),
                );
              },
            ),
          ),
          const Divider(),
          Text('Total Expenses: \$${totalExpenses.toStringAsFixed(2)}'),
        ],
      ),
    );
  }
}
