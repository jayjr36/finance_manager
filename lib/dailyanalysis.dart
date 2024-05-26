import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DailyTrackerScreen extends StatefulWidget {
  const DailyTrackerScreen({super.key});

  @override
  DailyTrackerScreenState createState() => DailyTrackerScreenState();
}

class DailyTrackerScreenState extends State<DailyTrackerScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> analysisData = [];
  double totalOverspent = 0.0;
  double totalSaved = 0.0;
  double totalPredefinedBudget = 0.0;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAnalysisData();
    _fetchTotalPredefinedBudget();
  }

  Future<void> _fetchAnalysisData() async {
    QuerySnapshot snapshot = await _firestore.collection('expense_analysis').get();
    List<Map<String, dynamic>> data = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    double overspent = 0.0;
    double saved = 0.0;

    for (var expense in data) {
      if (expense['status'] == 'Overspent') {
        overspent += expense['difference'];
      } else if (expense['status'] == 'Saved Money') {
        saved += expense['difference'];
      }
    }

    setState(() {
      analysisData = data;
      totalOverspent = overspent;
      totalSaved = saved;
    });
  }

  Future<void> _fetchTotalPredefinedBudget() async {
    QuerySnapshot snapshot = await _firestore.collection('daily_expenses').get();
    double budget = 0.0;

    for (var expense in snapshot.docs) {
      budget += expense['amount'];
    }

    setState(() {
      totalPredefinedBudget = budget;
    });
  }

  Future<void> _addDailySpending() async {
    String name = _nameController.text;
    double amount = double.parse(_amountController.text);

    // Save daily spending
    await _firestore.collection('daily_spending').add({'name': name, 'amount': amount, 'timestamp': Timestamp.now()});

    // Compare with predefined budget
    QuerySnapshot budgetSnapshot = await _firestore.collection('daily_expenses').where('name', isEqualTo: name).get();
    if (budgetSnapshot.docs.isNotEmpty) {
      double predefinedAmount = budgetSnapshot.docs.first['amount'];
      double difference = predefinedAmount - amount;
      String status;

      if (difference < 0) {
        status = 'Overspent';
        difference = -difference;
      } else {
        status = 'Saved Money';
      }

      // Save analysis
      await _firestore.collection('expense_analysis').add({
        'name': name,
        'amount': amount,
        'status': status,
        'difference': difference,
        'timestamp': Timestamp.now(),
      });

      // Refresh analysis data
      _fetchAnalysisData();
    }

    _nameController.clear();
    _amountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Tracker'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
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
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _addDailySpending,
                    child: const Text('Add Daily Spending'),
                  ),
                ],
              ),
            ),
            const Divider(),
            analysisData.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Amount')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Difference')),
                        DataColumn(label: Text('Date')),
                      ],
                      rows: analysisData.map((data) {
                        Color statusColor;
                        if (data['status'] == 'Overspent') {
                          statusColor = Colors.red;
                        } else if (data['status'] == 'Saved Money') {
                          statusColor = Colors.green;
                        } else {
                          statusColor = Colors.orange;
                        }

                        return DataRow(cells: [
                          DataCell(Text(data['name'])),
                          DataCell(Text('\$${data['amount'].toStringAsFixed(2)}')),
                          DataCell(Text(data['status'], style: TextStyle(color: statusColor))),
                          DataCell(Text('\$${data['difference'].toStringAsFixed(2)}')),
                          DataCell(Text((data['timestamp'] as Timestamp).toDate().toString())),
                        ]);
                      }).toList(),
                    ),
                  ),
            const SizedBox(height: 20),
            Text('Total Amount Overspent: \$${totalOverspent.toStringAsFixed(2)}', style: TextStyle(color: Colors.red)),
            Text('Total Amount Saved: \$${totalSaved.toStringAsFixed(2)}', style: TextStyle(color: Colors.green)),
            Text('Total Predefined Budget: \$${totalPredefinedBudget.toStringAsFixed(2)}', style: TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}
