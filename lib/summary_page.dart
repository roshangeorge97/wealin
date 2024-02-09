import 'package:SmartSaver/chat.dart';
import 'package:SmartSaver/savings_page.dart';
import 'package:SmartSaver/settings_page.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

import 'expense_income.dart';

FirebaseAuth auth = FirebaseAuth.instance;

final firebase_auth.User? user = FirebaseAuth.instance.currentUser;

class SummaryPage extends StatefulWidget {
  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class TransactionModel {
  final String date;
  final String category;
  final double amount;

  TransactionModel(this.date, this.category, this.amount);
}

class _SummaryPageState extends State<SummaryPage> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  int _bottomNavigationBarIndex = 0; // Index for the selected tab
  int _pageViewIndex = 0;
  bool isLoading = false;
  late PageController _pageController;
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _pageViewIndex);
    // Fetch the default one-month transactions when the page is opened
    final lastMonth = DateTime.now().subtract(Duration(days: 30));
    startDate = lastMonth;
    fetchDataFromFirebase(startDate, endDate);
  }

  void _onSliderIndexChanged(int index) {
    setState(() {
      _pageViewIndex = index;
    });
  }

  Future<void> fetchDataFromFirebase(
      DateTime startDate, DateTime endDate) async {
    setState(() {
      isLoading = true; // Show the circular progress indicator
    });
    final User? user = FirebaseAuth.instance.currentUser;
    final DatabaseReference databaseReference =
        FirebaseDatabase.instance.reference();
    final DatabaseReference expensesRef = databaseReference.child('expenses');
    final DatabaseReference incomeRef =
        databaseReference.child('income').child(user!.uid);

    // Fetch all cash expenses
    final DatabaseEvent cashEvent =
        await expensesRef.child('cash').child(user.uid).once();
    final DataSnapshot cashData = cashEvent.snapshot;
    final List<TransactionModel> cashTransactions = [];

    if (cashData.value is Map) {
      print("if");
      final Map<dynamic, dynamic> cashExpensesData =
          cashData.value as Map<dynamic, dynamic>;

      cashExpensesData.forEach((expenseId, expenseData) {
        if (expenseData is Map) {
          final String? date = expenseData['date']?.toString();
          final double amount =
              double.tryParse(expenseData['amount']?.toString() ?? '0.0') ??
                  0.0;

          if (date != null) {
            // Check if the date falls within the specified range
            final DateTime? expenseDate = DateTime.tryParse(date);
            if (expenseDate != null &&
                expenseDate.isAfter(startDate) &&
                expenseDate.isBefore(endDate)) {
              final String category = expenseData['category']?.toString() ?? '';
              cashTransactions.add(TransactionModel(date, category, amount));
            }
          }
        }
      });

      setState(() {
        isLoading = false; // Hide the circular progress indicator
      });
    }

// Fetch online expenses
    final DatabaseEvent onlineEvent =
        await expensesRef.child('online').child(user.uid).once();
    final DataSnapshot onlineData = onlineEvent.snapshot;
    final List<TransactionModel> onlineTransactions = [];

    if (onlineData.value is Map) {
      final Map<dynamic, dynamic> onlineExpensesData =
          onlineData.value as Map<dynamic, dynamic>;

      onlineExpensesData.forEach((expenseId, expenseData) {
        if (expenseData is Map) {
          final String? date = expenseData['date']?.toString();
          final double amount =
              double.tryParse(expenseData['amount']?.toString() ?? '0.0') ??
                  0.0;

          if (date != null) {
            // Check if the date falls within the specified range
            final DateTime? expenseDate = DateTime.tryParse(date);
            if (expenseDate != null &&
                expenseDate.isAfter(startDate) &&
                expenseDate.isBefore(endDate)) {
              final String category = expenseData['category']?.toString() ?? '';
              onlineTransactions.add(TransactionModel(date, category, amount));
            }
          }
        }
      });
    }

// Fetch income data
    final DatabaseEvent incomeEvent = await incomeRef.once();
    final DataSnapshot incomeData = incomeEvent.snapshot;
    final List<TransactionModel> incomeTransactions = [];

    if (incomeData.value is Map) {
      final Map<dynamic, dynamic> incomeDataMap =
          incomeData.value as Map<dynamic, dynamic>;
      incomeDataMap.forEach((incomeId, incomeData) {
        if (incomeData is Map) {
          final String? date = incomeData['date']?.toString();
          final double amount =
              double.tryParse(incomeData['amount']?.toString() ?? '0.0') ?? 0.0;

          if (date != null) {
            // Check if the date falls within the specified range
            final DateTime? incomeDate = DateTime.tryParse(date);
            if (incomeDate != null &&
                incomeDate.isAfter(startDate) &&
                incomeDate.isBefore(endDate)) {
              final String category = incomeData['category']?.toString() ?? '';
              incomeTransactions.add(TransactionModel(date, category, amount));
            }
          }
        }
      });
    }

    // Combine all transactions
    final List<TransactionModel> expensesTransactions = [
      ...cashTransactions,
      ...onlineTransactions
    ];

    // Update the pie chart and transactions list
    updateCategoryData(expensesTransactions);
    updateIncomeExpenseData(expensesTransactions, incomeTransactions);
    setState(() {
      transactions = expensesTransactions.map((transaction) {
        return '${transaction.date}|${transaction.category}|${transaction.amount.toString()}';
      }).toList();
      transactions.sort((a, b) {
        final dateA = DateTime.tryParse(a.split('|')[0]);
        final dateB = DateTime.tryParse(b.split('|')[0]);
        if (dateA == null || dateB == null) {
          return 0; // Handle parsing errors
        }
        return dateB
            .compareTo(dateA); // Sort in descending order (latest to oldest)
      });
    });
  }

  // Function to update category data
  void updateCategoryData(List<TransactionModel> transactions) {
    final Map<String, double> updatedCategoryData = {};

    // Loop through transactions and update the category data
    for (final transaction in transactions) {
      final String category = transaction.category;
      final double amount = transaction.amount;

      // If the category already exists in the map, add the amount to it
      if (updatedCategoryData.containsKey(category)) {
        updatedCategoryData[category] =
            (updatedCategoryData[category]! + amount);
      } else {
        // If the category doesn't exist, initialize it with the amount
        updatedCategoryData[category] = amount;
      }
    }

    final Map<String, double> categoryData = {};
    updatedCategoryData.forEach((category, totalExpense) {
      categoryData['$category \₹ ${totalExpense.toStringAsFixed(0)}'] =
          totalExpense;
    });
    // Update the categoryData map with the updated data
    setState(() {
      this.categoryData = categoryData;
    });
  }

  double totalIncome = 0;
// Function to update income and expense data
  void updateIncomeExpenseData(
      List<TransactionModel> expenses, List<TransactionModel> income) {
    double totalExpenses = 0;
    double totalSavings = 0;

    // Calculate total expenses
    for (final expense in expenses) {
      totalExpenses += expense.amount;
    }

    // Calculate total income
    totalIncome = 0;
    for (final transaction in income) {
      totalIncome += transaction.amount;
    }

    // Calculate savings (Income - Expenses)
    totalSavings = totalIncome - totalExpenses;

    // Round the values to the nearest integer
    totalExpenses = totalExpenses.roundToDouble();
    totalSavings = totalSavings.roundToDouble();

    // Update the incomeExpenseSavingsData map
    setState(() {
      incomeExpenseSavingsData = {
        'Expenses \₹ $totalExpenses': totalExpenses,
        'Savings \₹ $totalSavings': totalSavings,
      };
    });
  }

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

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });
    }
  }

  final List<Widget> _pages = [
    SummaryPage(), // Dashboard page
    IncomeExpenseAddPage(), // Expenses/Income page
    // SavingsPage(), // Savings page
    SettingsPage(), // Settings page
  ];
  // Pie Chart Data
  Map<String, double> categoryData = {
    'Food \₹ 300': 300.0,
    'Shopping \₹ 150': 150.0,
    'Entertainment \₹ 100': 100.0,
    'Transportation \₹ 200': 200.0,
  };

  Map<String, double> incomeExpenseSavingsData = {
    'Expenses \₹ 650': 650.0,
    'Savings \₹ 300': 350.0,
  };

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: 16.0),
              Column(
                children: <Widget>[
                  SizedBox(height: 16.0),
                  Column(
                    children: <Widget>[
                      Text(
                        'Category Distribution',
                        style: TextStyle(
                          color: Color(0xff6982c7),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Container(
                        height: 450, // Adjust the height as needed
                        child: PieChart(
                          dataMap: categoryData,
                          animationDuration: Duration(seconds: 1),
                          chartLegendSpacing: 10.0,
                          legendOptions: LegendOptions(
                            legendPosition: LegendPosition.bottom,
                          ),
                          chartValuesOptions: ChartValuesOptions(
                            showChartValueBackground: true,
                            showChartValues: true,
                            showChartValuesInPercentage: true,
                            showChartValuesOutside: false,
                            decimalPlaces: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 32.0),
              Column(
                children: <Widget>[
                  Text(
                    'Income Distribution',
                    style: TextStyle(
                      color: Color(0xff6982c7),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Container(
                    height: 450, // Set a fixed height for the PieChart widget
                    child: PieChart(
                      dataMap: incomeExpenseSavingsData,
                      animationDuration: Duration(seconds: 1),
                      chartLegendSpacing: 5.0,
                      legendOptions: LegendOptions(
                        legendPosition: LegendPosition.bottom,
                      ),
                      chartValuesOptions: ChartValuesOptions(
                        showChartValueBackground: true,
                        showChartValues: true,
                        showChartValuesInPercentage: true,
                        showChartValuesOutside: false,
                        decimalPlaces: 0,
                      ),
                      totalValue: totalIncome,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // Transactions Page
      ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          final transactionData =
              transaction.split('|'); // Split the transaction data
          final date = transactionData[0];
          final category = transactionData[1];
          final amount = double.parse(transactionData[2]);

          return TransactionWidget(
            date: date,
            category: category,
            amount: amount,
          );
        },
      ),
    ];
    return Scaffold(
      appBar: null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Date selectors
          SizedBox(height: 30),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Financial Dashboard',
                  style: TextStyle(
                    fontSize: 25,
                    color: Color(0xff6982c7),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                if (!isLoading)
                  Center(
                    child: CircularProgressIndicator(),
                  ),
                SizedBox(
                  height: 15.0,
                ),
                Center(
                    child: SizedBox(
                  width: MediaQuery.of(context).size.width -
                      30, // Adjust width as needed
                  child: Container(
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Start Date',
                                style: TextStyle(
                                  color: Color(0xff6982c7),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              TextFormField(
                                readOnly: true,
                                onTap: () async {
                                  DateTime? selectedDate = await showDatePicker(
                                    context: context,
                                    initialDate: startDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (selectedDate != null &&
                                      selectedDate != startDate) {
                                    setState(() {
                                      startDate = selectedDate;
                                    });
                                  }
                                },
                                controller: TextEditingController(
                                  text: "${startDate.toLocal()}".split(' ')[0],
                                ),
                              ),
                              SizedBox(height: 16.0),
                              Text(
                                'End Date',
                                style: TextStyle(
                                  color: Color(0xff6982c7),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              TextFormField(
                                readOnly: true,
                                onTap: () async {
                                  DateTime? selectedDate = await showDatePicker(
                                    context: context,
                                    initialDate: endDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (selectedDate != null &&
                                      selectedDate != endDate) {
                                    setState(() {
                                      endDate = selectedDate;
                                    });
                                  }
                                },
                                controller: TextEditingController(
                                  text: "${endDate.toLocal()}".split(' ')[0],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Align(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: () {
                              fetchDataFromFirebase(startDate, endDate);
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                              ),
                              minimumSize:
                                  MaterialStateProperty.all(Size(10, 40)),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Color(0xff6982c7)),
                            ),
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ))
              ],
            ),
          ),
          SizedBox(height: 20.0),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width - 30,
              decoration: BoxDecoration(
                color: Color(0xff6982c7),
                border: Border.all(),
                borderRadius: BorderRadius.circular(5.0),
              ),
              padding: EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Financial Health Score',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '6.2',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(0,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.ease);
                  },
                  child: Text(
                    'Pie Charts',
                    style: TextStyle(
                      fontWeight: _pageViewIndex == 0
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: _pageViewIndex == 0
                          ? Color(0xff6982c7)
                          : Color(0xff727272),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(1,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.ease);
                  },
                  child: Text(
                    'Transactions View',
                    style: TextStyle(
                      fontWeight: _pageViewIndex == 1
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: _pageViewIndex == 1
                          ? Color(0xff6982c7)
                          : Color(0xff727272),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Add PageView for sliding between Pie Charts and Transactions
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onSliderIndexChanged,
              children: pages,
            ),
          ),

          // Heading for Slider View
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
    );
  }
}

final Map<String, IconData> categoryIcons = {
  'Housing': Icons.home,
  'Transportation': Icons.directions_car,
  'Food and Dining': Icons.restaurant,
  'Utilities': Icons.flash_on,
  'Personal Expense': Icons.person,
  'Miscellaneous': Icons.category,
};

class TransactionWidget extends StatelessWidget {
  final String date;
  final String category;
  final double amount;

  TransactionWidget({
    required this.date,
    required this.category,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final IconData? categoryIcon =
        categoryIcons[category]; // Get the icon for the category
    return ListTile(
      title: Text(
        'Date: $date',
        style: TextStyle(
          color: Color(0xff6982c7),
          fontSize: 15,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
      subtitle: Text(
        'Category: $category\nAmount: ₹ $amount',
        style: TextStyle(
          color: Color(0xff6982c7),
          fontSize: 15,
          fontWeight: FontWeight.w100,
          fontFamily: 'Poppins',
        ),
      ),
      trailing: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
              Color(0xff6982c7), // Change this to your desired background color
        ),
        padding: EdgeInsets.all(8.0), // Adjust padding as needed
        child: Icon(
          categoryIcon,
          color: Colors.white, // Change this to your desired icon color
        ),
      ),
      // You can customize the ListTile as needed
    );
  }
}

// Define your transaction data
List<String> transactions = [
  '2023-09-01|Housing|800.0',
  '2023-09-02|Transportation|50.0',
  '2023-09-03|Food and Dining|100.0',
  '2023-09-04|Utilities|150.0',
  '2023-09-05|Personal Expense|50.0',
  '2023-09-06|Miscellaneous|30.0',
  '2023-09-07|Housing|800.0',
  '2023-09-08|Transportation|50.0',
  '2023-09-09|Food and Dining|100.0',
  '2023-09-10|Utilities|150.0',
  '2023-09-11|Personal Expense|50.0',
  '2023-09-12|Miscellaneous|30.0',
  // Add more transactions as needed
];
