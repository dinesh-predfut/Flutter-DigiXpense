import 'dart:convert';

import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../models.dart';

class GeneralExpenseDashboard extends StatefulWidget {
  const GeneralExpenseDashboard({super.key});

  @override
  State<GeneralExpenseDashboard> createState() =>
      _GeneralExpenseDashboardState();
}

class _GeneralExpenseDashboardState extends State<GeneralExpenseDashboard> {
  double _dragOffset = 0;
  final double _maxDragExtent = 600;
  final Controller controller = Controller();
  List<Item> _items = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _dragOffset = MediaQuery.of(context).size.height * 0.3;

        // controller.isLoading = false;
      });
    });
    final List<Map<String, dynamic>> dummyData = [
      {
        "id": "ADV01",
        "title": "ADV01",
        "subtitle": "Wholesale Internet",
        "date": "12-12-2024",
        "imageUrl":
            "https://t4.ftcdn.net/jpg/05/80/35/79/240_F_580357914_Efhj3cxxoIO9H79qIKftgX6V5aX203W1.jpg", // placeholder image
        "amount": 230,
        "reported": false,
      },
      {
        "id": "ADV08",
        "title": "ADV08",
        "subtitle": "Wholesale Internet",
        "date": "12-12-2024",
        "imageUrl":
            "https://t4.ftcdn.net/jpg/05/80/35/79/240_F_580357914_Efhj3cxxoIO9H79qIKftgX6V5aX203W1.jpg",
        "amount": 230,
        "reported": false,
      },
      {
        "id": "ADV02",
        "title": "ADV02",
        "subtitle": "Wholesale Internet",
        "date": "12-12-2024",
        "imageUrl":
            "https://t4.ftcdn.net/jpg/05/80/35/79/240_F_580357914_Efhj3cxxoIO9H79qIKftgX6V5aX203W1.jpg",
        "amount": 150,
        "reported": true,
      },
      {
        "id": "ADV02",
        "title": "ADV02",
        "subtitle": "Wholesale Internet",
        "date": "12-12-2024",
        "imageUrl":
            "https://t4.ftcdn.net/jpg/05/80/35/79/240_F_580357914_Efhj3cxxoIO9H79qIKftgX6V5aX203W1.jpg",
        "amount": 150,
        "reported": true,
      },
      {
        "id": "ADV02",
        "title": "ADV02",
        "subtitle": "Wholesale Internet",
        "date": "12-12-2024",
        "imageUrl":
            "https://t4.ftcdn.net/jpg/05/80/35/79/240_F_580357914_Efhj3cxxoIO9H79qIKftgX6V5aX203W1.jpg",
        "amount": 150,
        "reported": true,
      },
      {
        "id": "ADV02",
        "title": "ADV02",
        "subtitle": "Wholesale Internet",
        "date": "12-12-2024",
        "imageUrl":
            "https://t4.ftcdn.net/jpg/05/80/35/79/240_F_580357914_Efhj3cxxoIO9H79qIKftgX6V5aX203W1.jpg",
        "amount": 150,
        "reported": true,
      },
      // …add as many as you like…
    ];

    // Map them into your Item class:
    setState(() {
      _items = dummyData.map((e) => Item.fromJson(e)).toList();
    });
  }

  Future<void> _fetchItems() async {
    final resp =
        await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
    final List data = json.decode(resp.body);
    setState(() {
      _items = data.map((e) => Item.fromJson(e)).toList();
    });
  }

  Future<void> _deleteItem(String id) async {
    final resp = await http
        .delete(Uri.parse('https://jsonplaceholder.typicode.com/posts/$id'));
    if (resp.statusCode == 200) {
      setState(() => _items.removeWhere((i) => i.id == id));
    } else {
      // handle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete item.')),
      );
    }
  }

  void _viewItem(Item item) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: Text('View ${item.title}')),
        body: Center(child: Text('Details for ${item.title}')),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final List<String> pages = ["1", "2", "3", "4"];
    final List<Map<String, dynamic>> languages = [
      {
        'locale': const Locale('en', 'US'),
        'name': 'English',
        'flag': 'assets/flags/uk.png',
      },
      {
        'locale': const Locale('fr', 'FR'),
        'name': 'français',
        'flag': 'assets/flags/fr.png',
      },
      {
        'locale': const Locale('ar', 'AE'),
        'name': 'عربي',
        'flag': 'assets/flags/ar.png',
      },
      {
        'locale': const Locale('zh', 'CN'),
        'name': '中文',
        'flag': 'assets/flags/cn.png',
      },
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            // Top Content in scroll view
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 130,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/Vector.png'),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                            padding: const EdgeInsets.fromLTRB(10, 40, 10, 20),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  children: [
                                    /// LEFT SIDE
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Welcome to',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 8),
                                          ),
                                          const SizedBox(height: 4),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: Image.asset(
                                              'assets/XpenseWhite.png',
                                              width: 150,
                                              height: 40,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    /// RIGHT SIDE
                                    Wrap(
                                      spacing: 2,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.start,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.notifications,
                                              color: Colors.white),
                                          onPressed: () {
                                            print('Notification bell pressed');
                                          },
                                        ),
                                        DropdownButtonHideUnderline(
                                          child: DropdownButton<
                                              Map<String, dynamic>>(
                                            dropdownColor: Colors.white,
                                            icon: const Icon(Icons.language,
                                                color: Colors.white),
                                            onChanged: (value) {
                                              if (value != null) {
                                                Get.updateLocale(
                                                    value['locale']);
                                              }
                                            },
                                            items: languages.map((lang) {
                                              return DropdownMenuItem<
                                                  Map<String, dynamic>>(
                                                value: lang,
                                                child: Row(
                                                  children: [
                                                    Image.asset(
                                                      lang['flag'],
                                                      width: 24,
                                                      height: 24,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      lang['name'],
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pushNamed(context,
                                                AppRoutes.personalInfo);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 2),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Image.asset(
                                                'assets/image.png',
                                                width: 40,
                                                height: 40,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _balanceCard('Total Balance to Spend by category',
                                'Rs.23000'),
                            _balanceCard('Total Balance to Spend by category',
                                'Rs.23000'),
                            _balanceCard('Total Balance to Spend by category',
                                'Rs.23000'),
                            _balanceCard('Total Balance to Spend by category',
                                'Rs.23000'),
                          ],
                        ),
                      ),
                      const SizedBox(
                          // flex: 4, // 80%
                          child: TextField(
                        // controller: _controller,
                        // onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ),

            // List View - not scrollable inside scroll view
            SizedBox(
              height:
                  MediaQuery.of(context).size.height * 0.4, // adjust as needed
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _items.length,
                itemBuilder: (ctx, idx) {
                  final item = _items[idx];
                  return Dismissible(
                    key: ValueKey(item.id),
                    background: _buildSwipeActionLeft(),
                    secondaryBackground: _buildSwipeActionRight(),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        _viewItem(item);
                        return false;
                      } else {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete?'),
                            content: Text('Delete "${item.title}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) {
                          await _deleteItem(item.id);
                          return true;
                        }
                        return false;
                      }
                    },
                    child: _buildCard(item),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _balanceCard(String title, String amount) {
    return Container(
      width: 230,
      height: 110,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(86, 86, 121, 1),
            Color.fromRGBO(41, 41, 102, 1.0),
            Color.fromRGBO(41, 41, 102, 0.493)
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.wallet, color: Colors.white, weight: 70),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          const SizedBox(height: 5),
          Text(amount,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ],
      ),
    );
  }
}

Widget _buildSwipeActionLeft() {
  return Container(
    alignment: Alignment.centerLeft,
    color: Colors.blue.shade100,
    padding: const EdgeInsets.only(left: 20),
    child: const Row(
      children: [
        Icon(Icons.remove_red_eye, color: Colors.blue),
        SizedBox(width: 8),
        Text('View',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

Widget _buildSwipeActionRight() {
  return Container(
    alignment: Alignment.centerRight,
    color: Colors.red.shade300,
    padding: const EdgeInsets.only(right: 20),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Delete',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        SizedBox(width: 8),
        Icon(Icons.delete, color: Colors.white),
      ],
    ),
  );
}

Widget _buildCard(Item item) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(item.imageUrl,
            width: 56, height: 56, fit: BoxFit.cover),
      ),
      title:
          Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.subtitle),
          Text(item.date,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          if (!item.reported)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Un Reported',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
        ],
      ),
      trailing: Text('\$${item.amount.toStringAsFixed(0)}',
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
    ),
  );
}
