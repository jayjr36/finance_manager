// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_manager/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class Goal {
  String id;
  String name;
  double requiredAmount;
  double percentage;
  double allocatedAmount;

  Goal({
    required this.id,
    required this.name,
    required this.requiredAmount,
    required this.percentage,
    this.allocatedAmount = 0.0,
  });

  factory Goal.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Goal(
      id: doc.id,
      name: data['name'] ?? '',
      requiredAmount: data['requiredAmount']?.toDouble() ?? 0.0,
      percentage: data['percentage']?.toDouble() ?? 0.0,
      allocatedAmount: data['allocatedAmount']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'requiredAmount': requiredAmount,
      'percentage': percentage,
      'allocatedAmount': allocatedAmount,
    };
  }
}

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  GoalsScreenState createState() => GoalsScreenState();
}

class GoalsScreenState extends State<GoalsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Goal> _goals = [];
  List<Map<String, dynamic>> dailySpendings = [];
  List<Map<String, dynamic>> incomes = [];

  @override
  void initState() {
    super.initState();
    _fetchGoals();
    _fetchDailySpendings(DateTime.now());
    _fetchIncomes();
    _distributeMoney();
  }

  Future<void> _fetchGoals() async {
    QuerySnapshot snapshot = await _firestore.collection('goals').get();
    setState(() {
      _goals = snapshot.docs.map((doc) => Goal.fromFirestore(doc)).toList();
    });
  }

  Future<void> _fetchDailySpendings(DateTime date) async {
    DateTime now = DateTime.now();
    Timestamp startOfMonth =
        Timestamp.fromDate(DateTime(now.year, now.month, 1, 0, 0, 0));
    Timestamp endOfMonth =
        Timestamp.fromDate(DateTime(now.year, now.month + 1, 0, 23, 59, 59));

    QuerySnapshot snapshot = await _firestore
        .collection('daily_spending')
        .where('timestamp', isGreaterThanOrEqualTo: startOfMonth)
        .where('timestamp', isLessThanOrEqualTo: endOfMonth)
        .get();
    setState(() {
      dailySpendings = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> _fetchIncomes() async {
    QuerySnapshot snapshot = await _firestore.collection('incomes').get();
    List<Map<String, dynamic>> data = snapshot.docs.map((doc) {
      Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;
      docData['id'] = doc.id;
      return docData;
    }).toList();

    setState(() {
      incomes = data;
    });
  }

  void _distributeMoney() {
    double totalIncome = incomes.fold(0, (sum, item) => sum + item['amount']);
    double totalSpending =
        dailySpendings.fold(0, (sum, item) => sum + item['amount']);
    double availableMoney = totalIncome - totalSpending;

    for (var goal in _goals) {
      double allocation = availableMoney * (goal.percentage / 100);
      double updatedAmount =
          goal.requiredAmount > allocation ? allocation : goal.requiredAmount;
      _firestore
          .collection('goals')
          .doc(goal.id)
          .update({'allocatedAmount': updatedAmount});
    }
  }

  Future<void> _showGoalDialog({Goal? goal}) async {
    final TextEditingController nameController =
        TextEditingController(text: goal?.name ?? '');
    final TextEditingController requiredAmountController =
        TextEditingController(text: goal?.requiredAmount.toString() ?? '');
    final TextEditingController percentageController =
        TextEditingController(text: goal?.percentage.toString() ?? '');

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(goal == null ? 'Add Goal' : 'Edit Goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: requiredAmountController,
                decoration: const InputDecoration(labelText: 'Required Amount'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: percentageController,
                decoration: const InputDecoration(labelText: 'Percentage'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    requiredAmountController.text.isEmpty ||
                    percentageController.text.isEmpty) {
                  // Handle validation
                  return;
                }

                final name = nameController.text;
                final requiredAmount =
                    double.parse(requiredAmountController.text);
                final percentage = double.parse(percentageController.text);

                if (goal == null) {
                  // Add new goal
                  final newGoal = Goal(
                    id: '',
                    name: name,
                    requiredAmount: requiredAmount,
                    percentage: percentage,
                  );
                  await _firestore.collection('goals').add(newGoal.toMap());
                } else {
                  // Update existing goal
                  final updatedGoal = Goal(
                    id: goal.id,
                    name: name,
                    requiredAmount: requiredAmount,
                    percentage: percentage,
                    allocatedAmount: goal.allocatedAmount,
                  );
                  await _firestore
                      .collection('goals')
                      .doc(goal.id)
                      .update(updatedGoal.toMap());
                }

                _fetchGoals();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _editGoal(Goal goal) {
    _showGoalDialog(goal: goal);
  }

  void _deleteGoal(String goalId) async {
    await _firestore.collection('goals').doc(goalId).delete();
    _fetchGoals();
  }

  final constants = Constants();
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: constants.primaryColor,
        title: const Text('GOALS'),
        actions: [
          TextButton(
              onPressed: () {
                _distributeMoney();
              },
              child:const Text('disburse'))
        ],
      ),
      body: ListView.builder(
        itemCount: _goals.length,
        itemBuilder: (context, index) {
          final goal = _goals[index];
          return Card(
            margin: const EdgeInsets.all(15),
            elevation: 5,
            shadowColor: const Color.fromARGB(255, 104, 94, 5),
            child: ListTile(
              title: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'GOAL',
                        style: constants.boldFont,
                      ),
                      SizedBox(
                        width: w * 0.4,
                      ),
                      Text(
                        goal.name,
                        style: constants.normalFont,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'GOAL AMOUNT',
                        style: constants.boldFont,
                      ),
                      SizedBox(
                        width: w * 0.23,
                      ),
                      Text(
                        '${goal.requiredAmount}',
                        style: constants.normalFont,
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'AMOUNT PAID',
                        style: constants.boldFont,
                      ),
                      SizedBox(
                        width: w * 0.25,
                      ),
                      Text(
                        '${goal.allocatedAmount}',
                        style: constants.normalFont,
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'AMOUNT REMAINING',
                        style: constants.boldFont,
                      ),
                      SizedBox(
                        width: w * 0.13,
                      ),
                      Text(
                        'remainder',
                        style: constants.normalFont,
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'TIME SPAN',
                        style: constants.boldFont,
                      ),
                      SizedBox(
                        width: w * 0.3,
                      ),
                      Text(
                        'TO AND FROM',
                        style: constants.normalFont,
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'PERCENTAGE',
                        style: constants.boldFont,
                      ),
                      SizedBox(
                        width: w * 0.25,
                      ),
                      Text(
                        '${goal.percentage}',
                        style: constants.normalFont,
                      )
                    ],
                  )
                ],
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    child: const Text(
                      'EDIT',
                      style:
                          TextStyle(color: Color.fromARGB(255, 161, 147, 19)),
                    ),
                    onPressed: () => _editGoal(goal),
                  ),
                  TextButton(
                    child: const Text(
                      'DELETE',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () => _deleteGoal(goal.id),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _showGoalDialog();
        },
      ),
    );
  }
}
