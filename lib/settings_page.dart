import 'package:SmartSaver/chat.dart';
import 'package:SmartSaver/savings_page.dart';
import 'package:SmartSaver/summary_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_database/firebase_database.dart';

import 'expense_income.dart';
import 'home_page.dart';

FirebaseAuth auth = FirebaseAuth.instance;

class SettingsPage extends StatefulWidget {
  final firebase_auth.User? user = FirebaseAuth.instance.currentUser;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

List<Stock> watchlist = [
  Stock(name: 'Apple Inc.', price: 150.25),
  Stock(name: 'Microsoft Corporation', price: 300.75),
  Stock(name: 'Amazon.com Inc.', price: 3200.50),
  Stock(name: 'Alphabet Inc.', price: 2800.00),
  Stock(name: 'Facebook Inc.', price: 340.90),
];

class Stock {
  final String name;
  final double price;

  Stock({required this.name, required this.price});
}

class _SettingsPageState extends State<SettingsPage> {
  String? displayName;
  String? phoneNumber;
  bool _isAboutUsExpanded = false;
  bool _isTermsExpanded = false;
  bool _isPrivacyExpanded = false;
  bool _isContactUsExpanded = false;
  int _bottomNavigationBarIndex = 3; // Index for the selected tab

  @override
  void initState() {
    super.initState();
    // Fetch user data from Firebase Realtime Database
    _fetchUserData();
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

  final List<Widget> _pages = [
    SummaryPage(), // Dashboard page
    //ExpensesIncomePage(), // Expenses/Income page
    // SavingsPage(), // Savings page
    SettingsPage(), // Settings page
  ];
  Future<void> _fetchUserData() async {
    try {
      // Get a reference to your Firebase Realtime Database instance
      FirebaseDatabase _database = FirebaseDatabase.instance;
      final DatabaseReference userReference =
          _database.ref().child('users/${widget.user?.uid}');

      // Listen to the once() event and get the DataSnapshot from the event
      final DataSnapshot snapshot = (await userReference.once()).snapshot;

      if (snapshot.value != null) {
        final userData = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          displayName = userData['name'] ?? 'N/A';
          phoneNumber = userData['phoneNumber'] ?? 'N/A';
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Call _fetchUserData when the page is opened or dependencies change
    // This ensures that the user's details are updated when the page is displayed.
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Text(
                'Portfolio',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff6982c7),
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Color(0xff6982c7),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Profile',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFFFFF),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 10),
                  ListTile(
                    title: Text(
                      '$displayName',
                      style: TextStyle(
                        color: Color(0xffFFFFFF),
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    subtitle: Text(
                      '${phoneNumber != null ? phoneNumber : 'N/A'}',
                      style: TextStyle(
                        color: Color(0xffFFFFFF),
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Container(
              height: 390,
              child: ListView.builder(
                itemCount: watchlist.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(watchlist[index].name),
                    subtitle:
                        Text('\₹${watchlist[index].price.toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle logout
              },
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                minimumSize: MaterialStateProperty.all(Size(100, 50)),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0xff6982c7)),
              ),
              child: Text(
                'Logout',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
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

  Widget _buildCollapsibleSection({
    required String title,
    required bool isExpanded,
    required ValueChanged<bool> onChanged,
    required Widget content,
  }) {
    return ExpansionPanelList(
      elevation: 1,
      expandedHeaderPadding: EdgeInsets.all(0),
      expansionCallback: (int index, bool isExpanded) {
        onChanged(!isExpanded);
      },
      children: [
        ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(
                title,
                style: TextStyle(
                  fontSize: 15, // Adjust the font size
                  fontWeight: FontWeight.w400,
                  color: Color(0xff6982c7), // Heading text color
                  fontFamily: 'Poppins',
                ),
              ),
            );
          },
          body: content,
          isExpanded: isExpanded,
        ),
      ],
    );
  }

  void _handleLogout(BuildContext context) async {
    try {
      // Sign out the user using Firebase Authentication
      await FirebaseAuth.instance.signOut();
      setState(() {
        displayName = null;
        phoneNumber = null;
      });
      // Navigate back to the homepage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      print('Error logging out: $e');
    }
  }
}
