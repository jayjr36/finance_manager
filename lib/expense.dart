import 'package:finance_manager/goals.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_manager/spendingsbydate.dart'; // Import the screen to navigate to

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  ExpenseScreenState createState() => ExpenseScreenState();
}

class ExpenseScreenState extends State<ExpenseScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
      QuerySnapshot dailySnapshot = await _firestore.collection('daily_expenses').get();
      List<Map<String, dynamic>> dailyData = dailySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      QuerySnapshot weeklySnapshot = await _firestore.collection('weekly_expenses').get();
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
      print('Daily Expenses: $dailyExpenses');
      print('Weekly Expenses: $weeklyExpenses');
    } catch (e) {
      print('Error fetching expenses: $e');
    }
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
              try {
                String name = _nameController.text;
                double amount = double.parse(_amountController.text);
                await _firestore.collection(collection).add({
                  'name': name,
                  'amount': amount,
                  'timestamp': Timestamp.now()
                });
                Navigator.of(context).pop();
                _fetchExpenses();
              } catch (e) {
                print('Error adding expense: $e');
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
            title: const Text('Daily Expenses',style: TextStyle(backgroundColor: Colors.yellow),),
            children: [
              ...dailyExpenses.map((expense) => ListTile(
                title: Text('${expense['name']} - ${expense['amount']}'),
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
                MaterialPageRoute(builder: (context) => const GoalsScreen()),
              );
            },
            child: const Text('Goals'),
          ),
          SizedBox(height: 20), // Add some space for better separation
          // Display total values for daily expenses, weekly expenses, and daily spendings
          Text('Total Daily Expenses: ${totalDailyExpenses.toStringAsFixed(2)}'),
          Text('Total Weekly Expenses: ${totalWeeklyExpenses.toStringAsFixed(2)}'),
          Text('Total Daily Spendings: ${totalDailySpendings.toStringAsFixed(2)}'),
        ],
      ),
    );
  }
}
