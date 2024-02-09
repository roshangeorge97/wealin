import 'package:SmartSaver/chat.dart';
import 'package:SmartSaver/settings_page.dart';
import 'package:SmartSaver/summary_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'expense_income.dart';

class Goal {
  String? key;
  String name;
  double targetAmount;
  DateTime finishDate;
  double currentAmount; // New field
  String priorityLabel;

  Goal(this.name, this.targetAmount, this.finishDate, this.currentAmount,
      this.priorityLabel);

  Goal.withKey(this.key, this.name, this.targetAmount, this.finishDate,
      this.currentAmount, this.priorityLabel);
}

class FinancialGoalsPage extends StatefulWidget {
  @override
  _FinancialGoalsPageState createState() => _FinancialGoalsPageState();
}

class _FinancialGoalsPageState extends State<FinancialGoalsPage> {
  bool isLoading = true; // Add a loading indicator
  @override
  void initState() {
    super.initState();
    _fetchUserGoals();
  }

  Future<void> _fetchUserGoals() async {
    final userGoals = await fetchUserGoals();
    setState(() {
      goals = userGoals;
      isLoading = false; // Data is loaded, set isLoading to false
    });
  }

  List<Goal> goals = [];

  TextEditingController nameController = TextEditingController();
  TextEditingController targetAmountController = TextEditingController();
  TextEditingController currentAmountController = TextEditingController();
  TextEditingController targetDateController =
      TextEditingController(text: 'Select Date');
  TextEditingController priorityController =
      TextEditingController(text: 'Priority Low');
  int _bottomNavigationBarIndex = 2; // Index for the selected tab
  DateTime? selectedDate;
  // Define priority labels
  static const String lowPriorityLabel = 'Low';
  static const String mediumPriorityLabel = 'Medium';
  static const String highPriorityLabel = 'High';

  // Function to convert priority labels to integer values for sorting
  int priorityLabelToInt(String priorityLabel) {
    switch (priorityLabel) {
      case lowPriorityLabel:
        return 0;
      case mediumPriorityLabel:
        return 1;
      case highPriorityLabel:
        return 2;
      default:
        return 0; // Default to Low priority
    }
  }

  // Sort goals by priority label (High > Medium > Low)
  void sortGoalsByPriority() {
    goals.sort((a, b) =>
        priorityLabelToInt(b.priorityLabel) -
        priorityLabelToInt(a.priorityLabel));
  }

  Goal? selectedGoal;
  void _onBottomNavBarIndexChanged(int index) {
    setState(() {
      _bottomNavigationBarIndex = index;
      if (index == 4) {
        // If the "Settings" icon is clicked (index 3), navigate to the SettingsPage
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatPage(),
          ),
        );
      }
      if (index == 3) {
        // If the "Settings" icon is clicked (index 3), navigate to the SettingsPage
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SettingsPage(),
          ),
        );
      }
      if (index == 2) {
        // If the "Settings" icon is clicked (index 3), navigate to the SettingsPage
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FinancialGoalsPage(),
          ),
        );
      }
      if (index == 1) {
        // If the "Settings" icon is clicked (index 3), navigate to the SettingsPage
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => IncomeExpenseAddPage(),
          ),
        );
      }
      if (index == 0) {
        // If the "Settings" icon is clicked (index 3), navigate to the SettingsPage
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SummaryPage(),
          ),
        );
      }
    });
  }

  Future<double> calculateProgress(Goal goal) async {
    final currentSavings = await calculateCurrentSavings(goal);
    return currentSavings / goal.targetAmount;
  }

  Future<int> calculateCurrentSavings(Goal goal) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final DatabaseReference databaseReference =
          FirebaseDatabase.instance.reference();
      final DatabaseReference goalRef =
          databaseReference.child('goals').child(user.uid).child(goal.key!);

      final DatabaseEvent event = await goalRef.once();

      final DataSnapshot? snapshot = event.snapshot;
      if (snapshot != null) {
        print("enter1");
        final dynamic goalData = snapshot.value;

        print("enter2");
        final int currentAmount = (goalData['currentAmount'] as int?) ?? 0;

        // Now you have the current amount for this specific goal
        // You can use it to calculate savings or progress
        int currentSavings = currentAmount; // Modify this based on your logic

        // You can implement your savings calculation logic here
        // For example, if you want to calculate savings as the difference between the target and current amount:
        // double currentSavings = goal.targetAmount - currentAmount;

        // Ensure that currentSavings is not negative
        if (currentSavings < 0) {
          currentSavings = 0;
        }
        print(currentSavings);
        // You can now use the calculated currentSavings in your app
        return currentSavings;
      }
    }

    // Default to 0.0 if user is not authenticated or goal data is not found
    return 0;
  }

  Future<String> getSavingsSuggestions() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return 'User is not authenticated.';
    }

    final DatabaseReference databaseReference =
        FirebaseDatabase.instance.reference();
    final DatabaseReference expensesRef = databaseReference.child('expenses');

    // Calculate the start and end dates for the last month
    final now = DateTime.now();
    final lastMonthStart = DateTime(now.year, now.month - 1, now.day);
    final lastMonthEnd = DateTime(now.year, now.month, now.day);

    try {
      final DatabaseEvent event =
          await expensesRef.child('cash').child(user.uid).once();
      final DataSnapshot cashExpensesSnapshot = event.snapshot;
      final DatabaseEvent event1 =
          await expensesRef.child('online').child(user.uid).once();
      final DataSnapshot onlineExpensesSnapshot = event1.snapshot;

      final cashExpensesData =
          cashExpensesSnapshot.value as Map<dynamic, dynamic>? ?? {};
      final onlineExpensesData =
          onlineExpensesSnapshot.value as Map<dynamic, dynamic>? ?? {};

      final lastMonthCashExpenses = filterExpensesForLastMonth(
          cashExpensesData, lastMonthStart, lastMonthEnd);
      final lastMonthOnlineExpenses = filterExpensesForLastMonth(
          onlineExpensesData, lastMonthStart, lastMonthEnd);

      // Define threshold values based on expert financial rules
      final thresholdValues = {
        'Housing': 5000, // Suggested threshold value for Housing
        'Transportation': 2500, // Suggested threshold value for Transportation
        'Food and Dining':
            2000, // Suggested threshold value for Food and Dining
        'Utilities': 1000, // Suggested threshold value for Utilities
        'Personal Expense':
            2000, // Suggested threshold value for Personal Expense
        'Miscellaneous': 4000, // Suggested threshold value for Miscellaneous
      };

      // Analyze expenses and provide suggestions
      final suggestions = <String>[];

      final cashCategoryWiseExpenses =
          categorizeExpenses(lastMonthCashExpenses);
      final onlineCategoryWiseExpenses =
          categorizeExpenses(lastMonthOnlineExpenses);

      for (final category in cashCategoryWiseExpenses.keys) {
        print("enter in");
        final totalExpense =
            calculateTotalExpense(cashCategoryWiseExpenses[category]!);
        print("enter in2");
        final threshold = thresholdValues[category] ?? 0;
        print("enter in2");

        if (totalExpense > threshold) {
          print("enter in if");
          final savings = totalExpense - threshold;
          suggestions.add(
              'Reduce spending on $category (Cash). You can save \₹$savings.');
        } else {
          print("enter in else");
        }
      }

      for (final category in onlineCategoryWiseExpenses.keys) {
        print("enter in ");
        final totalExpense =
            calculateTotalExpense(onlineCategoryWiseExpenses[category]!);
        final threshold = thresholdValues[category] ?? 0.0;

        if (totalExpense > threshold) {
          print("enter in if");
          final savings = totalExpense - threshold;
          suggestions.add(
              'Reduce spending on $category (Online). You can save \₹${savings.toStringAsFixed(2)}.');
        }
      }

      if (suggestions.isEmpty) {
        suggestions.add(
            'Great job! Your expenses are within budget for all categories.');
      }

      return suggestions.join('\n');
    } catch (e) {
      print('Error fetching expenses: $e');
      return 'An error occurred while fetching expenses.';
    }
  }

  Map<String, dynamic> filterExpensesForLastMonth(
      Map<dynamic, dynamic> expensesData, DateTime start, DateTime end) {
    // Implement logic to filter expenses within the last month's date range
    final filteredExpenses = <String, dynamic>{};

    for (final entry in expensesData.entries) {
      final expenseDate = DateTime.tryParse(entry.value['date'] ?? '');

      if (expenseDate != null &&
          expenseDate.isAfter(start) &&
          expenseDate.isBefore(end)) {
        filteredExpenses[entry.key] = entry.value;
      }
    }

    return filteredExpenses;
  }

  Map<String, List<Map<dynamic, dynamic>>> categorizeExpenses(
      Map<dynamic, dynamic> expensesData) {
    // Implement logic to categorize expenses based on their categories
    final categoryWiseExpenses = <String, List<Map<dynamic, dynamic>>>{};

    for (final entry in expensesData.entries) {
      final category = entry.value['category'] as String? ?? 'Other';
      categoryWiseExpenses.putIfAbsent(category, () => []);
      categoryWiseExpenses[category]!.add(entry.value);
    }

    return categoryWiseExpenses;
  }

  double calculateTotalExpense(List<Map<dynamic, dynamic>> expenses) {
    // Implement logic to calculate the total expense for a category
    double total = 0.0;
    for (final expense in expenses) {
      final amount = double.tryParse(expense['amount'].toString()) ?? 0.0;
      print("enter in 2");
      total += amount;
    }
    return total;
  }

  void _editGoal(Goal goal) {
    nameController.text = goal.name;
    targetAmountController.text = goal.targetAmount.toString();
    currentAmountController.text =
        goal.currentAmount.toString(); // Populate current amount
    selectedDate = goal.finishDate;
    priorityController.text = goal.priorityLabel;

    setState(() {
      selectedGoal = goal;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Edit Goal',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xff6982c7),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Goal Name',
                    labelStyle: TextStyle(color: Color(0xff6982c7)),
                  ),
                ),
                TextField(
                  controller: targetAmountController,
                  decoration: InputDecoration(
                    labelText: 'Target Amount (\₹)',
                    labelStyle: TextStyle(color: Color(0xff6982c7)),
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller:
                      currentAmountController, // Include the current amount field
                  decoration: InputDecoration(
                    labelText: 'Current Amount (\₹)',
                    labelStyle: TextStyle(color: Color(0xff6982c7)),
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: targetDateController,
                  decoration: InputDecoration(
                    labelText: 'Finish Date',
                    labelStyle: TextStyle(color: Color(0xff6982c7)),
                  ),
                  onTap: () => _selectDate(context),
                ),
                TextFormField(
                  controller: priorityController,
                  decoration: InputDecoration(
                    labelText: 'Priority',
                    labelStyle: TextStyle(color: Color(0xff6982c7)),
                  ),
                  readOnly: true,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            'Select Priority',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff6982c7),
                            ),
                          ),
                          content: Container(
                            width: double.maxFinite,
                            child: DropdownButtonFormField<String>(
                              value: priorityController.text,
                              items: [
                                lowPriorityLabel,
                                mediumPriorityLabel,
                                highPriorityLabel,
                              ].map((priorityLabel) {
                                return DropdownMenuItem<String>(
                                  value: priorityLabel,
                                  child: Text('Priority $priorityLabel'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  priorityController.text =
                                      value ?? lowPriorityLabel;
                                });
                                Navigator.of(context).pop();
                              },
                              decoration: InputDecoration(
                                labelText: 'Priority',
                                labelStyle: TextStyle(color: Color(0xff6982c7)),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xff6982c7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _updateGoal(goal);
                Navigator.of(context).pop();
              },
              child: Text(
                'Save',
                style: TextStyle(
                  color: Color(0xff6982c7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _updateGoal(Goal goal) async {
    if (nameController.text.isNotEmpty &&
        targetAmountController.text.isNotEmpty &&
        selectedDate != null) {
      final DatabaseReference databaseReference =
          FirebaseDatabase.instance.reference();
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final DatabaseReference goalRef =
            databaseReference.child('goals').child(user.uid).child(goal.key!);

        await goalRef.update({
          'name': nameController.text,
          'targetAmount': double.parse(targetAmountController.text),
          'finishDate': selectedDate!.toIso8601String(),
          'priorityLabel': priorityController.text,
          'currentAmount': double.parse(
              currentAmountController.text), // Include currentAmount
        });

        nameController.clear();
        targetAmountController.clear();
        selectedDate = null;
        priorityController.text = lowPriorityLabel;
        currentAmountController.clear(); // Clear the current amount field
        selectedGoal = null;
      }
    }
  }

  void _addGoal() async {
    if (nameController.text.isNotEmpty &&
        targetAmountController.text.isNotEmpty &&
        selectedDate != null &&
        currentAmountController.text.isNotEmpty) {
      // Check if the current amount is not empty
      final newGoal = Goal(
        nameController.text,
        double.parse(targetAmountController.text),
        selectedDate!,
        double.parse(currentAmountController.text), // Parse the current amount
        priorityController.text,
      );

      // Get the current user
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Create a reference to the Firebase database
        final DatabaseReference databaseReference =
            FirebaseDatabase.instance.reference();

        // Push the new goal data to the database under the user's UID
        final DatabaseReference newGoalRef =
            databaseReference.child('goals').child(user.uid).push();
        // Set the goal data, including currentAmount
        await newGoalRef.set({
          'name': newGoal.name,
          'targetAmount': newGoal.targetAmount,
          'finishDate': newGoal.finishDate.toIso8601String(),
          'priorityLabel': newGoal.priorityLabel,
          'currentAmount': newGoal.currentAmount,
        });
      }
    }
    // Sort goals by priority after adding
    sortGoalsByPriority();
    // Clear the form fields and reset selected values
    nameController.clear();
    targetAmountController.clear();
    selectedDate = null;
    priorityController.text = lowPriorityLabel; // Reset priority label to Low
    currentAmountController.clear(); // Clear the current amount field
    selectedGoal = null; // Clear the selected goal
  }

  Future<List<Goal>> fetchUserGoals() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final DatabaseReference databaseReference =
          FirebaseDatabase.instance.reference();

      print('Fetching user goals for user: ${user.uid}'); // Add this line

      // Listen to the database reference for changes and get the initial data
      databaseReference.child('goals').child(user.uid).onValue.listen((event) {
        final DataSnapshot dataSnapshot = event.snapshot;
        final goalsData = dataSnapshot.value;

        print('Goals Data: $goalsData'); // Add this line to check goalsData

        if (goalsData != null && goalsData is Map) {
          final List<Goal> userGoals = [];
          try {
            goalsData.forEach((goalId, goalData) {
              print('Goal Data for $goalId: $goalData'); // Debug statement

              final goal = Goal.withKey(
                goalId, // Firebase key as the first parameter
                goalData?['name'] ?? '',
                goalData?['targetAmount']?.toDouble() ?? 0.0,
                DateTime.tryParse(goalData?['finishDate'] ?? '') ??
                    DateTime.now(),
                goalData?['currentAmount']?.toDouble() ?? 0.0,
                goalData?['priorityLabel'] ?? 'Low',
              );
              userGoals.add(goal);
            });

            // Sort goals by priority
            userGoals.sort((a, b) =>
                priorityLabelToInt(b.priorityLabel) -
                priorityLabelToInt(a.priorityLabel));

            setState(() {
              goals = userGoals; // Update the goals list with fetched data
              isLoading = false; // Data is loaded, set isLoading to false
            });
          } catch (e) {
            print('Error parsing goals data: $e');
          }
        }
      });
    } else {
      print(
          'User is not authenticated'); // Add this line to check authentication
    }

    return goals; // Return the goals list
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      targetDateController.text = "${picked.toLocal()}".split(' ')[0];
    }
  }

  void _deleteGoal(Goal goal) async {
    setState(() {
      goals.remove(goal);
    });

    // Create a reference to the Firebase database
    final DatabaseReference databaseReference =
        FirebaseDatabase.instance.reference();

    // Get the current user
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Find the goal reference in Firebase using its key and remove it
        await databaseReference
            .child('goals')
            .child(user.uid)
            .child(goal.key!)
            .remove();
      } catch (e) {
        print('Error deleting goal: $e');
      }
    }
  }

  Widget buildSavingsSuggestions() {
    return FutureBuilder<String>(
      future: getSavingsSuggestions(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show a loading indicator while waiting for data.
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final suggestions = snapshot.data;

          return Text(
            suggestions!,
            style: TextStyle(
              color: Color(0xffffffff),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
          body: Column(
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  'Financial Goals',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff6982c7),
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              isLoading // Show a loading indicator if data is being fetched
                  ? CircularProgressIndicator()
                  : goals.isEmpty // Show a message if there are no goals
                      ? Text('No goals found.')
                      : Expanded(
                          child: ListView.builder(
                            itemCount: goals.length,
                            itemBuilder: (context, index) {
                              final goal = goals[index];
                              final remainingDays = goal.finishDate
                                  .difference(DateTime.now())
                                  .inDays;
                              return Dismissible(
                                key: Key(goal.name),
                                onDismissed: (direction) {
                                  if (direction ==
                                      DismissDirection.endToStart) {
                                    _deleteGoal(goal);
                                  }
                                },
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.only(right: 16.0),
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                child: Card(
                                  color: Color(0xff6982c7),
                                  elevation: 3,
                                  child: ListTile(
                                    title: Text(
                                      goal.name,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xffffffff),
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Target Amount: \₹${goal.targetAmount.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: Color(0xffffffff),
                                          ),
                                        ),
                                        Text(
                                          'Finish Date: ${goal.finishDate.toLocal().toString().split(' ')[0]}',
                                          style: TextStyle(
                                            color: Color(0xffffffff),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        FutureBuilder<double>(
                                          future: calculateProgress(goal),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<double> snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return LinearProgressIndicator(
                                                value:
                                                    0.0, // While loading, show 0% progress
                                                backgroundColor:
                                                    Colors.grey[300],
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  Color(0xff6982c7),
                                                ),
                                              );
                                            } else if (snapshot.hasError) {
                                              // Handle errors
                                              return Text(
                                                  'Error: ${snapshot.error}');
                                            } else {
                                              final double? progress =
                                                  snapshot.data;
                                              return LinearProgressIndicator(
                                                value: progress ?? 0.0,
                                                backgroundColor:
                                                    Colors.grey[300],
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  Color(0xff6982c7),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Priority: ${goal.priorityLabel}',
                                          style: TextStyle(
                                            color: Color(0xffffffff),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Remaining Days: $remainingDays',
                                          style: TextStyle(
                                            color: Color(0xffffffff),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Suggestions:',
                                          style: TextStyle(
                                            color: Color(0xffffffff),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        buildSavingsSuggestions(),
                                      ],
                                    ),
                                    onTap: () {
                                      _editGoal(goal);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _bottomNavigationBarIndex,
            onTap: _onBottomNavBarIndexChanged,
            selectedItemColor:
                Color(0xff6982c7), // Change this color to your desired color
            unselectedItemColor: Color(0xff727272),
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.attach_money),
                label: 'Expendictures',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.savings),
                label: 'Saving Quest',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_rounded), // Icon for Savings
                label: 'Portfolio', // Label for Savings
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble),
                label: 'Ask Wealo',
              ),
            ],
            selectedLabelStyle: TextStyle(color: Color(0xff6982c7)),
            unselectedLabelStyle: TextStyle(color: Color(0xff727272)),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Clear the form fields when adding a new goal
              nameController.clear();
              targetAmountController.clear();
              selectedDate = null;
              priorityController.text =
                  lowPriorityLabel; // Set default priority label to Low
              selectedGoal = null; // Clear the selected goal

              // Show the dialog for adding a new goal
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      'Add Goal',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff6982c7),
                      ),
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Goal Name',
                              labelStyle: TextStyle(color: Color(0xff6982c7)),
                            ),
                          ),
                          TextField(
                            controller: targetAmountController,
                            decoration: InputDecoration(
                              labelText: 'Target Amount (\₹)',
                              labelStyle: TextStyle(color: Color(0xff6982c7)),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          TextField(
                            controller:
                                currentAmountController, // Add Current Amount field
                            decoration: InputDecoration(
                              labelText: 'Current Amount (\₹)',
                              labelStyle: TextStyle(color: Color(0xff6982c7)),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          TextField(
                            controller: targetDateController,
                            decoration: InputDecoration(
                              labelText: 'Finish Date',
                              labelStyle: TextStyle(color: Color(0xff6982c7)),
                            ),
                            onTap: () => _selectDate(context),
                          ),
                          TextFormField(
                            controller: priorityController,
                            decoration: InputDecoration(
                              labelText: 'Priority',
                              labelStyle: TextStyle(color: Color(0xff6982c7)),
                            ),
                            readOnly: true,
                            onTap: () {
                              // Show a dialog with the priority options when tapped
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                      'Select Priority',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff6982c7),
                                      ),
                                    ),
                                    content: Container(
                                      width: double.maxFinite,
                                      child: DropdownButtonFormField<String>(
                                        value: priorityController.text,
                                        items: [
                                          lowPriorityLabel,
                                          mediumPriorityLabel,
                                          highPriorityLabel,
                                        ].map((priorityLabel) {
                                          return DropdownMenuItem<String>(
                                            value: priorityLabel,
                                            child:
                                                Text('Priority $priorityLabel'),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            priorityController.text =
                                                value ?? lowPriorityLabel;
                                          });
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'Priority',
                                          labelStyle: TextStyle(
                                              color: Color(0xff6982c7)),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the form dialog
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xff6982c7),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _addGoal(); // Update the goal
                          Navigator.of(context).pop(); // Close the form dialog
                        },
                        child: Text(
                          'Add',
                          style: TextStyle(
                            color: Color(0xff6982c7),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            child: Icon(Icons.add),
          )),
    );
  }
}
