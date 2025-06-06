import 'package:digi_xpense/core/constant/Parames/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:photo_view/photo_view.dart';
import 'package:image_picker/image_picker.dart';

class ExpenseCreationForm extends StatefulWidget {
  const ExpenseCreationForm({super.key});

  @override
  State<ExpenseCreationForm> createState() => _ExpenseCreationFormState();
}

class _ExpenseCreationFormState extends State<ExpenseCreationForm> {
  int _currentStep = 0;
  int _itemizeCount = 1;
  int _selectedItemizeIndex = 0;
  int _selectedCategoryIndex = -1;

  final PageController _pageController = PageController();

  final List<String> _titles = ["Payment Info", "Itemize", "Expense Details"];

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _addItemize() {
    if (_itemizeCount < 5) {
      setState(() {
        _itemizeCount++;
        _selectedItemizeIndex = _itemizeCount - 1;
      });
    }
  }

  Widget _buildStep(int index) {
    final isActive = index == _currentStep;
    final isCompleted = index < _currentStep;

    return Column(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: isActive
              ? Colors.orange
              : isCompleted
                  ? Colors.orange
                  : Colors.grey,
          child: Text(
            '${index + 1}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _titles[index],
          style: TextStyle(
            fontSize: 12,
            color: isActive || isCompleted ? Colors.orange : Colors.black45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int segmentIndex) {
    final isCompleted = segmentIndex < _currentStep;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18.0), // adjust as needed
        child: Container(
          height: 2,
          width: 50,
          color: isCompleted ? Colors.orange : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: [
        _buildStep(0),
        _buildStepLine(0),
        _buildStep(1),
        _buildStepLine(1),
        _buildStep(2),
      ],
    );
  }

  Widget _buildItemizeCircles() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _itemizeCount,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedItemizeIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedItemizeIndex = index;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: isSelected ? Colors.orange : Colors.grey,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Itemize',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemizePage() {
    return DefaultTabController(
      length: _itemizeCount,
      initialIndex: _selectedItemizeIndex,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            onTap: (index) {
              setState(() {
                _selectedItemizeIndex = index;
              });
            },
            tabs: List.generate(
              _itemizeCount,
              (index) => Tab(text: "Itemize ${index + 1}"),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: TabBarView(
              children: List.generate(
                _itemizeCount,
                (index) => Center(child: ExpenseCreateForm2(context)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormPage(String title) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("3-Step Form")),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildProgressBar(),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const ExpenseCreationFormStep1(),
                _buildItemizePage(),
                const CreateExpensePage(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            if (_currentStep > 0)
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _currentStep--;
                    _pageController.animateToPage(
                      _currentStep,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                label: const Text(
                  'Back',
                  style: TextStyle(color: Colors.black),
                ),
              )
            else
              const SizedBox(), // Empty space if back is not shown

            const Spacer(),

            ElevatedButton(
              onPressed: _nextStep,
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.gradientEnd,
                side: const BorderSide(color: AppColors.gradientEnd),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                _currentStep == 2 ? 'Finish' : 'Next',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget ExpenseCreateForm2(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Project *",
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Select',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Paid For *"),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildCategoryButton(
                      0, "Travel", Colors.green, Icons.directions_walk),
                  _buildCategoryButton(
                      1, "Hotels", Colors.blueAccent, Icons.hotel),
                  _buildCategoryButton(
                      2, "Food", Colors.purpleAccent, Icons.restaurant),
                  _buildCategoryButton(
                      3, "Transport", Colors.amber, Icons.directions_car),
                  _buildCategoryButton(
                      4, "Taxi", Colors.deepOrange, Icons.local_taxi),
                  _buildCategoryButton(
                      5, "Bills", Colors.deepPurple, Icons.receipt_long),
                  _buildCategoryButton(
                      6, "Shopping", Colors.grey.shade300, Icons.shopping_cart,
                      textColor: Colors.black),
                  _buildCategoryButton(
                      7, "Events", Colors.red.shade700, Icons.event),
                  _buildCategoryButton(
                      8, "Others", Colors.pink.shade200, Icons.more_horiz),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildTextInput("Comments")),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextInput("Unit *")),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextInput("Quantity *")),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextInput("Unit Amount *")),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextInput("Line Amount *")),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextInput("Line Amount in INR *")),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(child: Text("Line Amount *")),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _addItemize,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.gradientEnd),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.add, color: AppColors.gradientEnd),
                    label: const Text(
                      'Itemize',
                      style: TextStyle(color: AppColors.gradientEnd),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(
      int index, String label, Color color, IconData icon,
      {Color textColor = Colors.white}) {
    final isSelected = _selectedCategoryIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryIndex = index;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: textColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
        ),
        const SizedBox(height: 8),
        TextField(
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: const TextStyle(color: Colors.black),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Colors.black), // ← Black border
            ),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: Colors.black), // ← Black border
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                  color: Colors.black, width: 2), // ← Black border on focus
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}

class ExpenseCreationFormStep1 extends StatefulWidget {
  const ExpenseCreationFormStep1({super.key});

  @override
  State<ExpenseCreationFormStep1> createState() =>
      _ExpenseCreationFormStep1State();
}

class _ExpenseCreationFormStep1State extends State<ExpenseCreationFormStep1> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  String? _paidTo;
  String? _paidWith;
  bool _isLoading = false;

  final List<String> _payees = [
    'Amazon',
    'Office Supplies Inc.',
    'Utility Company',
    'Travel Agency',
    'Other Vendor'
  ];

  final List<String> _paymentMethods = [
    'UPI',
    'Debit Card',
    'Credit Card',
    'Bank Transfer',
    'Cash',
    'Others'
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, dynamic> requestBody = {
        'requestDate': _selectedDate?.toIso8601String(),
        'paidTo': _paidTo,
        'paidWith': _paidWith,
      };

      final response = await http.post(
        Uri.parse('https://your-api-endpoint.com/expenses'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense created successfully!')),
        );
        // Reset form
        _formKey.currentState!.reset();
        setState(() {
          _selectedDate = null;
          _paidTo = null;
          _paidWith = null;
        });
      } else {
        // Error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Request Date *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null
                            ? 'Select date'
                            : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                        style: TextStyle(
                          color: _selectedDate == null
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                      const Icon(Icons.calendar_today, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Paid To *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                hint: const Text('Select'),
                value: _paidTo,
                items: _payees.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _paidTo = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a payee';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Paid With *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Column(
                children: _paymentMethods
                    .asMap()
                    .map((index, method) {
                      List<Color> colors = [
                        Colors.red.shade100,
                        Colors.green.shade100,
                        Colors.blue.shade100,
                        Colors.orange.shade100,
                      ];

                      List<IconData> icons = [
                        Icons.credit_card,
                        Icons.money,
                        Icons.payment,
                        Icons.account_balance_wallet,
                      ];

                      return MapEntry(
                        index,
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: colors[index % colors.length],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: RadioListTile<String>(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(icons[index % icons.length],
                                    color: Colors.black),
                                const SizedBox(width: 10),
                                Text(
                                  method,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                            value: method,
                            groupValue: _paidWith,
                            onChanged: (String? value) {
                              setState(() {
                                _paidWith = value;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            tileColor: Colors.transparent,
                          ),
                        ),
                      );
                    })
                    .values
                    .toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateExpensePage extends StatefulWidget {
  const CreateExpensePage({super.key});

  @override
  _CreateExpensePageState createState() => _CreateExpensePageState();
}

class _CreateExpensePageState extends State<CreateExpensePage> {
  File? _imageFile;
  final PhotoViewController _photoViewController = PhotoViewController();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      _cropImage(File(pickedFile.path));
    }
  }

  Future<void> _cropImage(File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Edit Image',
          toolbarColor: Colors.deepPurple,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: Colors.deepPurple,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Edit Image'),
      ],
    );

    if (croppedFile != null) {
      setState(() => _imageFile = File(croppedFile.path));
    }
  }

  void _zoomIn() {
    _photoViewController.scale = _photoViewController.scale! * 1.2;
  }

  void _zoomOut() {
    _photoViewController.scale = _photoViewController.scale! / 1.2;
  }

  void _deleteImage() {
    setState(() {
      _imageFile = null;
    });
  }

  Widget _buildImageArea() {
    return GestureDetector(
      onTap: () => _pickImage(ImageSource.gallery),
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
        ),
        child: _imageFile == null
            ? const Center(child: Text('Tap to Upload the Document'))
            : Stack(
                children: [
                  PhotoView(
                    controller: _photoViewController,
                    imageProvider: FileImage(_imageFile!),
                    backgroundDecoration:
                        const BoxDecoration(color: Colors.transparent),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 3.0,
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Column(
                      children: [
                        FloatingActionButton.small(
                          heroTag: "zoom_in",
                          onPressed: _zoomIn,
                          child: const Icon(Icons.zoom_in),
                          backgroundColor: Colors.deepPurple,
                        ),
                        const SizedBox(height: 8),
                        FloatingActionButton.small(
                          heroTag: "zoom_out",
                          onPressed: _zoomOut,
                          child: const Icon(Icons.zoom_out),
                          backgroundColor: Colors.deepPurple,
                        ),
                        const SizedBox(height: 8),
                        FloatingActionButton.small(
                          heroTag: "edit",
                          onPressed: () => _cropImage(_imageFile!),
                          child: const Icon(Icons.edit),
                          backgroundColor: Colors.deepPurple,
                        ),
                        const SizedBox(height: 8),
                        FloatingActionButton.small(
                          heroTag: "delete",
                          onPressed: _deleteImage,
                          child: const Icon(Icons.delete),
                          backgroundColor: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _photoViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Create Expense')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildImageArea(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.upload_file),
                      label: const Text("Upload"),
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Capture"),
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                  ],
                ),
                   const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Paid Amount
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            
                            decoration: const InputDecoration(
                              labelText: 'Paid Amount *',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: '230',
                          ),
                        ),
                        
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Text('INR',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Rate *',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: '1',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Amount in INR
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Amount in INR *',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: '230',
                    ),
                    const SizedBox(height: 30),

                    // Policy Violations Header
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Policy Violations',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'Check Policies',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Policy Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Policy 1001',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.check, color: Colors.green),
                              SizedBox(width: 8),
                              Expanded(
                                  child: Text("Expense Amount Under Limit")),
                            ],
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.check, color: Colors.green),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Receipt Required Amount :Amount  in any expense\nRecorded Should have a receipt",
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.close, color: Colors.red),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "if description has been made mandatory by the Admin for all expense",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.orange),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "An expense that has expired is Considered a Policy",
                                  style: TextStyle(color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Buttons
                    Center(
                      child: Column(
                        children: [
                          SizedBox(
                            width: 200,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                // backgroundColor:
                                //     const LinearGradient(colors: [Colors.indigo, Colors.blueAccent])
                                //         .createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 48.0))
                                //         .withAlpha(255),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              onPressed: () {},
                              child: const Text("Submit"),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurpleAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                onPressed: () {},
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  child: Text("Save"),
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                onPressed: () {},
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  child: Text("Cancel",
                                      style: TextStyle(letterSpacing: 1.5)),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
