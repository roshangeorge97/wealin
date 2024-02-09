import 'package:SmartSaver/chat.dart';
import 'package:SmartSaver/savings_page.dart';
import 'package:SmartSaver/settings_page.dart';
import 'package:SmartSaver/summary_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker package
import 'package:google_ml_vision/google_ml_vision.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

class IncomeExpenseAddPage extends StatefulWidget {
  @override
  _IncomeExpenseAddPageState createState() => _IncomeExpenseAddPageState();
}

class _IncomeExpenseAddPageState extends State<IncomeExpenseAddPage> {
  PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  int _bottomNavigationBarIndex = 1; // Index for the selected tab
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Heading
          SizedBox(height: 30.0),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Financial Transaction Entry",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xff6982c7),
                fontFamily: 'Poppins',
              ),
            ),
          ),
          // Slider with Expense and Income Page
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(0,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.ease);
                  },
                  child: Text(
                    "Expense Entry",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight:
                          _currentPage == 0 ? FontWeight.bold : FontWeight.bold,
                      color: _currentPage == 0
                          ? Color(0xff6982c7)
                          : Color(0xff727272),
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
                    "Income Entry",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          _currentPage == 1 ? FontWeight.bold : FontWeight.bold,
                      color: _currentPage == 1
                          ? Color(0xff6982c7)
                          : Color(0xff727272),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // PageView for Expense and Income Forms
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                // Expense Form with Slider
                ExpenseTransactionForm(),
                // Income Form
                IncomeTransactionForm(),
              ],
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
    );
  }
}

class ExpenseTransactionForm extends StatefulWidget {
  @override
  _ExpenseTransactionFormState createState() => _ExpenseTransactionFormState();
}

class _ExpenseTransactionFormState extends State<ExpenseTransactionForm> {
  PageController _transactionPageController = PageController(initialPage: 0);
  int _currentTransactionPage = 0;

  @override
  void dispose() {
    _transactionPageController.dispose();
    super.dispose();
  }

  void _onTransactionPageChanged(int page) {
    setState(() {
      _currentTransactionPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Slider between Online Expense and Cash Expense
          Container(
            margin: EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    _transactionPageController.animateToPage(
                      0,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  },
                  child: Text(
                    "Online Expense",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: _currentTransactionPage == 0
                          ? FontWeight.bold
                          : FontWeight.bold,
                      color: _currentTransactionPage == 0
                          ? Color(0xff6982c7)
                          : Color(0xff727272),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _transactionPageController.animateToPage(
                      1,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  },
                  child: Text(
                    "Cash Expense",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: _currentTransactionPage == 1
                          ? FontWeight.bold
                          : FontWeight.bold,
                      color: _currentTransactionPage == 1
                          ? Color(0xff6982c7)
                          : Color(0xff727272),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // PageView for Online Expense and Cash Expense Forms
          Expanded(
            child: PageView(
              controller: _transactionPageController,
              onPageChanged: _onTransactionPageChanged,
              children: [
                // Online Expense Form (Same as Expense Form)
                TransactionForm(),
                // Cash Expense Form with Photo Options
                CashTransactionForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionForm extends StatefulWidget {
  @override
  _TransactionFormState createState() => _TransactionFormState();
}

bool showTransactionsQueue = false;
@override
void initState() {
  // Request SMS permission when the widget initializes
  showTransactionsQueue = false;
}

TextEditingController amountController = TextEditingController();
String selectedCategory = "Housing";

class _TransactionFormState extends State<TransactionForm> {
  DateTime? _selectedDate;
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // Wrap the entire body in SingleChildScrollView
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Center(
                child: Text(
                  "Fill the Online Expense details below",
                  style: TextStyle(
                    color: Color(0xff6982c7),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Submit Button
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showTransactionsQueue = true; // Show the TransactionsQueue
                  });
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  minimumSize: MaterialStateProperty.all(Size(300, 50)),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xff6982c7)),
                ),
                child: Text(
                  'Fetch expenses from the SMS',
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Add the transactions queue here
              if (showTransactionsQueue) TransactionsQueue(),
              SizedBox(height: 30),
              // Container for Amount input field
              Container(
                //width: 350,
                decoration: BoxDecoration(
                  color: Color(0xffb2f3f3),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TextFormField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixIcon:
                        Icon(Icons.attach_money, color: Color(0xff6982c7)),
                    labelStyle: TextStyle(
                      color: Color(0xff6982c7),
                      fontFamily: 'Poppins',
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16.0),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(height: 30),
              // Container for Date input field with date picker
              Container(
                width: 350,
                decoration: BoxDecoration(
                  color: Color(0xffb2f3f3),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: InkWell(
                  onTap: () {
                    _selectDate(context);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      prefixIcon:
                          Icon(Icons.calendar_today, color: Color(0xff6982c7)),
                      labelStyle: TextStyle(
                        color: Color(0xff6982c7),
                        fontFamily: 'Poppins',
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16.0),
                    ),
                    child: Text(
                      _selectedDate != null
                          ? "${_selectedDate!.toLocal()}".split(' ')[0]
                          : 'Select Date',
                      style: TextStyle(
                        color: Color(0xff6982c7),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Container for Category dropdown
              Container(
                // Remove the fixed width for responsiveness
                // width: 350,
                decoration: BoxDecoration(
                  color: Color(0xffb2f3f3),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: DropdownButtonFormField<String>(
                  items: [
                    "Housing",
                    "Transportation",
                    "Food and Dining",
                    "Utilities",
                    "Personal Expense",
                    "Miscellaneous",
                    // Add more category names as needed
                  ].map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(
                        category,
                        style: TextStyle(
                          color: Color(0xff6982c7),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedCategory =
                          value ?? "Housing"; // Update the selected category
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Category",
                    prefixIcon: Icon(Icons.category, color: Color(0xff6982c7)),
                    labelStyle: TextStyle(
                      color: Color(0xff6982c7),
                      fontFamily: 'Poppins',
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16.0),
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Submit Button
              ElevatedButton(
                onPressed: () async {
                  // Fetch the form values
                  DateTime selectedDate = _selectedDate ?? DateTime.now();
                  double amount = double.tryParse(amountController.text) ?? 0.0;
                  String category = selectedCategory;

                  // Access the current user
                  final User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    // Define the data to be added to the Firebase Realtime Database
                    final Map<String, dynamic> transactionData = {
                      'date': selectedDate.toLocal().toString().split(' ')[0],
                      'amount': amount,
                      'category': category,
                    };

                    try {
                      // Reference to the Firebase Realtime Database
                      final DatabaseReference databaseReference =
                          FirebaseDatabase.instance.reference();

                      // Reference to the user's data under 'expenses/online/userId'
                      final DatabaseReference userRef = databaseReference
                          .child('expenses/online/${user.uid}');

                      // Push the transaction data to Firebase
                      final DatabaseReference newTransactionRef =
                          userRef.push();
                      await newTransactionRef.set(transactionData);

                      // Optionally, you can show a success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Expense added !'),
                        ),
                      );
                    } catch (error) {
                      // Handle any potential errors
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $error'),
                        ),
                      );
                    }
                  }
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  minimumSize: MaterialStateProperty.all(Size(300, 50)),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xff6982c7)),
                ),
                child: Text(
                  'Submit',
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
      ),
    );
  }
}

var temp = "hi";

class TransactionsQueue extends StatefulWidget {
  @override
  _TransactionsQueueState createState() => _TransactionsQueueState();
}

class _TransactionsQueueState extends State<TransactionsQueue> {
  List<SmsMessage> transactions = [];
  List<String?> selectedCategories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    requestSmsPermission(); // Request SMS permission when the widget initializes
  }

  Future<void> requestSmsPermission() async {
    final PermissionStatus status = await Permission.sms.request();
    if (status.isGranted) {
      fetchAndProcessSMS(); // Permission is granted, proceed to fetch SMS
    } else {
      // Permission is denied or not yet requested, handle accordingly
      // You can show a message to the user or request permission again.
    }
  }

  Future<void> fetchAndProcessSMS() async {
    // Implement code to retrieve SMS messages from the last 10 days
    final DateTime tenDaysAgo = DateTime.now().subtract(Duration(days: 100));
    final SmsQuery query = SmsQuery();
    final List<SmsMessage> allMessages =
        await query.querySms(kinds: [SmsQueryKind.inbox]);
    // Filter messages by date (last 10 days)
    final List<SmsMessage> recentMessages = allMessages.where((message) {
      if (message.date == null) {
        return false; // Handle the case where date is null
      }
      // Check if the message date is within the last 10 days
      return message.date!.isAfter(tenDaysAgo);
    }).toList();

    final List<SmsMessage> newTransactions = [];
    for (var message in recentMessages) {
      if (message.body!.contains('debit')) {
        newTransactions.add(message);
      }
    }

    setState(() {
      transactions = newTransactions;
      selectedCategories = List<String?>.filled(transactions.length, null);
      print(transactions.length);
      print(selectedCategories.length);
      _isLoading = false;
    });
  }

  String extractAmount(String text) {
    // Define debit keywords
    final debitKeywords = [
      "debit",
      "debited",
      "spent",
      "withdraw",
      "DEBITED",
    ];

    // Convert the text to lowercase for case-insensitive matching
    final lowercaseText = text.toLowerCase();

    // Check for debit keywords
    for (final keyword in debitKeywords) {
      final keywordIndex = lowercaseText.indexOf(keyword);
      if (keywordIndex != -1) {
        // Find the substring after the debit keyword
        final amountSubstring =
            lowercaseText.substring(keywordIndex + keyword.length);
        temp = amountSubstring;

        // Use a regular expression to find the first number (amount) in the substring
        final RegExp regExp = RegExp(r'(\d+(\.\d+)?)');
        final match = regExp.firstMatch(amountSubstring);

        if (match != null) {
          return match.group(0)!;
        }
      }
    }

    // Check for INR

    // If no amount is found, you can return a default value or handle it differently
    return "Amount Not Found";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          child: Column(
            children: transactions.asMap().entries.map((entry) {
              int index = entry.key;
              SmsMessage message = entry.value;

              return Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      'Date: ${message.date}',
                      style: TextStyle(
                        color: Color(0xff6982c7),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      'Concerning: $temp',
                      style: TextStyle(
                        color: Color(0xff6982c7),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Amount: ${extractAmount(message.body!)}',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      items: [
                        "Housing",
                        "Transportation",
                        "Food and Dining",
                        "Utilities",
                        "Personal Expense",
                        "Miscellaneous",
                        // Add more category names as needed
                      ].map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(
                            category,
                            style: TextStyle(
                              color: Color(0xff6982c7),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          selectedCategories[index] =
                              value; // Update the selected category
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Category",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        if (_isLoading)
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            final User? user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              final DatabaseReference databaseReference =
                  FirebaseDatabase.instance.reference();

              for (int i = 0; i < transactions.length; i++) {
                final SmsMessage message = transactions[i];
                final String? selectedCategory = selectedCategories[i];

                final transactionData = {
                  'date': message.date.toString().split(' ')[0] ?? '',
                  'amount': extractAmount(message.body!),
                  'category': selectedCategory ?? "Uncategorized",
                };

                final DatabaseReference userRef = databaseReference
                    .child('expenses')
                    .child('online')
                    .child(user.uid);
                final DatabaseReference newTransactionRef = userRef.push();
                newTransactionRef.set(transactionData);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Expenses added!'),
                ),
              );
            }
            setState(() {
              showTransactionsQueue = false;
              transactions = [];
              selectedCategories = [];
            });
          },
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            minimumSize: MaterialStateProperty.all(Size(300, 50)),
            backgroundColor:
                MaterialStateProperty.all<Color>(Color(0xff6982c7)),
          ),
          child: Text(
            'Submit All Transactions',
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }
}

class CashTransactionForm extends StatefulWidget {
  @override
  _CashTransactionFormState createState() => _CashTransactionFormState();
}

class _CashTransactionFormState extends State<CashTransactionForm> {
  bool _photoUploaded = false;
  String? scannedData; // Store scanned data here
  DateTime? _selectedDate;
  String? selectedCategory;

  TextEditingController amountController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  // TextEditingController categoryController = TextEditingController();
  ImagePicker _picker = ImagePicker();
  XFile? pickedImage;

  // TextEditingController _dateController = TextEditingController();
  // TextEditingController _amountController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> requestPermissions() async {
    // Request camera permission
    var cameraStatus = await Permission.camera.request();
    // Request photo library permission
    var photoStatus = await Permission.photos.request();

    // Check if permissions were granted
    if (cameraStatus.isGranted && photoStatus.isGranted) {
      // Permissions granted, you can proceed.
    } else {
      // Permissions not granted, handle accordingly (e.g., show an explanation).
    }
  }

  // Function to handle clicking a photo
  Future<void> _handleClickPhoto() async {
    requestPermissions();
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage == null) return;

    final textRecognizer = GoogleVision.instance.textRecognizer();
    final visionImage = GoogleVisionImage.fromFilePath(pickedImage!.path);

    final visionText = await textRecognizer.processImage(visionImage);

    String totalAmount = '';
    String date = '';

    // Iterate through the recognized text to find "Total" and extract the numeric value
    for (TextBlock block in visionText.blocks) {
      for (TextLine line in block.lines) {
        String? lineText = line.text;

        if (lineText?.toLowerCase().contains('total') == true) {
          int totalIndex = lineText!.toLowerCase().indexOf('total');
          // Look for numbers after "Total" even if ':' or '$' is present
          String lineAfterTotal =
              lineText.substring(totalIndex + 'total'.length);

          RegExp totalAmountPattern =
              RegExp(r'[:$₹\s]*?([\d,.]+)', caseSensitive: false);
          Match? totalAmountMatch =
              totalAmountPattern.firstMatch(lineAfterTotal);

          if (totalAmountMatch != null) {
            totalAmount = totalAmountMatch.group(1) ?? '';
            break; // Exit loop once the total amount is found
          }
        } else if (lineText?.toLowerCase().contains('amount') == true) {
          int totalIndex = lineText!.toLowerCase().indexOf('amount');
          // Look for numbers after "Total" even if ':' or '$' is present
          String lineAfterTotal =
              lineText.substring(totalIndex + 'amount'.length);

          RegExp totalAmountPattern =
              RegExp(r'[:$₹\s]*?([\d,.]+)', caseSensitive: false);
          Match? totalAmountMatch =
              totalAmountPattern.firstMatch(lineAfterTotal);

          if (totalAmountMatch != null) {
            totalAmount = totalAmountMatch.group(1) ?? '';
            break; // Exit loop once the total amount is found
          }
        }
      }
    }

    // Use a regular expression to find a date in the format dd/mm/yyyy or dd-mm-yyyy
    RegExp datePattern =
        RegExp(r'(\d{2}[/-]\d{2}[/-]\d{4})', caseSensitive: false);
    Match? dateMatch = datePattern.firstMatch(visionText.text ??
        ''); // Provide a default empty string if visionText.text is null

    date = dateMatch != null ? dateMatch.group(1) ?? '' : 'Date not found';

    setState(() {
      amountController.text = totalAmount;
      dateController.text = date;
    });

    textRecognizer.close();
  }

  // Function to handle uploading a photo
  Future<void> _handleUploadPhoto() async {
    requestPermissions();
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage == null) return;

    final textRecognizer = GoogleVision.instance.textRecognizer();
    final visionImage = GoogleVisionImage.fromFilePath(pickedImage!.path);

    final visionText = await textRecognizer.processImage(visionImage);

    String totalAmount = '';
    String date = '';

    // Iterate through the recognized text to find "Total" and extract the numeric value
    for (TextBlock block in visionText.blocks) {
      for (TextLine line in block.lines) {
        String? lineText = line.text;

        if (lineText?.toLowerCase().contains('total') == true) {
          int totalIndex = lineText!.toLowerCase().indexOf('total');
          // Look for numbers after "Total" even if ':' or '$' is present
          String lineAfterTotal =
              lineText.substring(totalIndex + 'total'.length);

          RegExp totalAmountPattern =
              RegExp(r'[:$₹\s]*?([\d,.]+)', caseSensitive: false);
          Match? totalAmountMatch =
              totalAmountPattern.firstMatch(lineAfterTotal);

          if (totalAmountMatch != null) {
            totalAmount = totalAmountMatch.group(1) ?? '';
            break; // Exit loop once the total amount is found
          }
        } else if (lineText?.toLowerCase().contains('amount') == true) {
          int totalIndex = lineText!.toLowerCase().indexOf('amount');
          // Look for numbers after "Total" even if ':' or '$' is present
          String lineAfterTotal =
              lineText.substring(totalIndex + 'amount'.length);

          RegExp totalAmountPattern =
              RegExp(r'[:$₹\s]*?([\d,.]+)', caseSensitive: false);
          Match? totalAmountMatch =
              totalAmountPattern.firstMatch(lineAfterTotal);

          if (totalAmountMatch != null) {
            totalAmount = totalAmountMatch.group(1) ?? '';
            break; // Exit loop once the total amount is found
          }
        }
      }
    }

    // Use a regular expression to find a date in the format dd/mm/yyyy or dd-mm-yyyy
    RegExp datePattern =
        RegExp(r'(\d{2}[/-]\d{2}[/-]\d{4})', caseSensitive: false);
    Match? dateMatch = datePattern.firstMatch(visionText.text ??
        ''); // Provide a default empty string if visionText.text is null

    date = dateMatch != null ? dateMatch.group(1) ?? '' : 'Date not found';

    setState(() {
      amountController.text = totalAmount;
      dateController.text = date;
    });

    textRecognizer.close();
  }

  Future<void> _handleSubmit() async {
    DateTime date = DateFormat('dd/MM/yyyy').parse(dateController.text);
    print(date);
    String date1 = DateFormat('yyyy-MM-dd').format(date);
    final amount = amountController.text;
    final category = selectedCategory;

    if (date1.isEmpty || amount.isEmpty || category == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Validation Error'),
            content: Text('Please fill in all required fields.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }
    final user =
        FirebaseAuth.instance.currentUser; // Get the current authenticated user

    if (user != null) {
      final userUid = user.uid;

      final DatabaseReference databaseReference =
          FirebaseDatabase.instance.reference();
      final newExpenseRef = databaseReference
          .child('expenses')
          .child('cash')
          .child(userUid)
          .push();

      final expenseData = {
        'date': date1.split(' ')[0] ?? '',
        'amount': amount,
        'category': category,
      };

      await newExpenseRef.set(expenseData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Expense added!'),
        ),
      );
      // Clear the form fields after submitting
      dateController.clear();
      amountController.clear();
      setState(() {
        selectedCategory = null;
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Please Sign In'),
            content: Text(
                'You need to sign in or create an account to add cash expenses.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate to the sign-in or registration screen.
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          // Center the form fields
          children: [
            SizedBox(height: 20),
            Center(
              child: Text(
                "Fill the Cash Expense Details below",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Color(0xff6982c7),
                ),
              ),
            ),
            SizedBox(height: 30),
            Container(
              width: 350,
              decoration: BoxDecoration(
                color: Color(0xffb2f3f3),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: "Amount",
                  prefixIcon:
                      Icon(Icons.attach_money, color: Color(0xff6982c7)),
                  labelStyle: TextStyle(
                    color: Color(0xff6982c7),
                    fontFamily: 'Poppins',
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16.0),
                ),
                keyboardType: TextInputType.number,
                controller: amountController,
                initialValue: scannedData != null &&
                        scannedData!.contains("Scanned Amount:")
                    ? scannedData
                        ?.split("Scanned Amount:")[1]
                        .split("\n")[0]
                        .trim()
                    : null,
              ),
            ),
            SizedBox(height: 30),
            // Container for Date input field with date picker
            Container(
              width: 350,
              decoration: BoxDecoration(
                color: Color(0xffb2f3f3),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: InkWell(
                onTap: () {
                  _selectDate(context);
                  setState(() {
                    dateController.text = _selectedDate != null
                        ? "${_selectedDate!.toLocal()}".split(' ')[0]
                        : 'Select Date';
                  });
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    prefixIcon:
                        Icon(Icons.calendar_today, color: Color(0xff6982c7)),
                    labelStyle: TextStyle(
                      color: Color(0xff6982c7),
                      fontFamily: 'Poppins',
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16.0),
                  ),
                  child: Text(
                    dateController.text,
                    style: TextStyle(
                      color: Color(0xff6982c7),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Container(
              width: 350,
              decoration: BoxDecoration(
                color: Color(0xffb2f3f3),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: DropdownButtonFormField<String>(
                value: selectedCategory, // Set the initial value here
                items: [
                  "Housing",
                  "Transportation",
                  "Food and Dining",
                  "Utilities",
                  "Personal Expense",
                  "Miscellaneous",
                  // Add more category names as needed
                ].map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(
                      category,
                      style: TextStyle(
                        color: Color(0xff6982c7),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    selectedCategory = value; // Update the selected category
                  });
                },
                decoration: InputDecoration(
                  labelText: "Category",
                  prefixIcon: Icon(Icons.category, color: Color(0xff6982c7)),
                  labelStyle: TextStyle(
                    color: Color(0xff6982c7),
                    fontFamily: 'Poppins',
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16.0),
                ),
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _handleClickPhoto,
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Color(0xff6982c7)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  child: Text(
                    "Click a Photo",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                SizedBox(width: 30),
                ElevatedButton(
                  onPressed: _handleUploadPhoto,
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Color(0xff6982c7)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  child: Text(
                    "Upload a Photo",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            // Submit Button
            ElevatedButton(
              onPressed: _handleSubmit,
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                minimumSize: MaterialStateProperty.all(Size(300, 50)),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0xff6982c7)),
              ),
              child: Text(
                'Submit',
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
    );
  }
}

class IncomeTransactionForm extends StatefulWidget {
  @override
  _IncomeTransactionFormState createState() => _IncomeTransactionFormState();
}

class _IncomeTransactionFormState extends State<IncomeTransactionForm> {
  DateTime? _selectedDate;
  TextEditingController _amountController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            Center(
              child: Text(
                "Fill in the Income details below",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff6982c7),
                ),
              ),
            ),
            SizedBox(height: 30),
            Container(
              width: 350,
              decoration: BoxDecoration(
                color: Color(0xffb2f3f3),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: TextFormField(
                controller: _amountController, // Assign the controller
                decoration: InputDecoration(
                  labelText: "Amount",
                  prefixIcon:
                      Icon(Icons.attach_money, color: Color(0xff6982c7)),
                  labelStyle: TextStyle(
                    color: Color(0xff6982c7),
                    fontFamily: 'Poppins',
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16.0),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(height: 30),
            Container(
              width: 350,
              decoration: BoxDecoration(
                color: Color(0xffb2f3f3),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: InkWell(
                onTap: () {
                  _selectDate(context);
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    prefixIcon:
                        Icon(Icons.calendar_today, color: Color(0xff6982c7)),
                    labelStyle: TextStyle(
                      color: Color(0xff6982c7),
                      fontFamily: 'Poppins',
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16.0),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? "${_selectedDate!.toLocal()}".split(' ')[0]
                        : 'Select Date',
                    style: TextStyle(
                      color: Color(0xff6982c7),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Container(
              width: 350,
              decoration: BoxDecoration(
                color: Color(0xffb2f3f3),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: DropdownButtonFormField<String>(
                items: [
                  "Employment Income (Salary or Wages)",
                  "Business Profits",
                  "Investment Income",
                  "Rental Income",
                  // Add more category names as needed
                ].map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(
                      category,
                      style: TextStyle(
                        color: Color(0xff6982c7),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? value) {
                  // Assign the selected value to the controller
                  _categoryController.text = value ?? '';
                },
                decoration: InputDecoration(
                  labelText: "Category",
                  prefixIcon: Icon(Icons.category, color: Color(0xff6982c7)),
                  labelStyle: TextStyle(
                    color: Color(0xff6982c7),
                    fontFamily: 'Poppins',
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16.0),
                ),
                isExpanded: true,
                // Add this property to control the position of the dropdown menu
                // (adjust it as needed)
                dropdownColor: Color(0xffffffff),
              ),
            ),
            SizedBox(height: 30),
            // Submit Button
            ElevatedButton(
              onPressed: () {
                final User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  final DatabaseReference databaseReference =
                      FirebaseDatabase.instance.reference();
                  final DatabaseReference incomeRef =
                      databaseReference.child('income').child(user.uid);

                  final String amount = _amountController.text;
                  final String date =
                      _selectedDate?.toLocal().toString().split(' ')[0] ?? '';
                  final String category = _categoryController.text;

                  if (amount.isNotEmpty &&
                      date.isNotEmpty &&
                      category.isNotEmpty) {
                    final incomeData = {
                      'date': date,
                      'amount': amount,
                      'category': category,
                    };

                    final DatabaseReference newIncomeRef = incomeRef.push();
                    newIncomeRef.set(incomeData);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Income added!'),
                      ),
                    );
                  }
                }
              },
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                minimumSize: MaterialStateProperty.all(Size(300, 50)),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0xff6982c7)),
              ),
              child: Text(
                'Submit',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
