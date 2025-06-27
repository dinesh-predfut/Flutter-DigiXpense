import 'package:digi_xpense/core/comman/widgets/languageDropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/constant/Parames/colors.dart';
// import 'package:google_fonts/google_fonts.dart';
import '../../../service.dart';
import '../widget/router/router.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double _dragOffset = 0;
  final double _maxDragExtent = 600;
  final Controller controller = Controller();

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _dragOffset = MediaQuery.of(context).size.height * 0.3;
        // controller.isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final List<String> pages = ["1", "2", "3", "4"];
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      // Text(loc?.welcome ?? 'Welcome'),
                      Container(
                        width: double.infinity,
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
                        padding: const EdgeInsets.fromLTRB(10, 40, 20, 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // const SizedBox(width: 5),
                            Flexible(
                              child: Column(
                                children: [
                                  const Text(
                                    'Welcome to',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 8),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      'assets/XpenseWhite.png',
                                      width: 100,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const LanguageDropdown(),
                                IconButton(
                                  icon: const Icon(Icons.notifications,
                                      color: Colors.white),
                                  onPressed: () {
                                    // Handle bell press here
                                    print('Notification bell pressed');
                                  },
                                ),

                                // Profile Picture (Rounded)
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, AppRoutes.personalInfo);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(
                                        2), // Thickness of the border
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white, // Border color
                                        width: 2, // Border width
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
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
                        ),
                      ),

                      // Positioned profile image and bell icon
                    ],
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _balanceCard(
                              'Total Balance to Spend by category', 'Rs.23000'),
                          _balanceCard(
                              'Total Balance to Spend by category', 'Rs.23000'),
                          _balanceCard(
                              'Total Balance to Spend by category', 'Rs.23000'),
                          _balanceCard(
                              'Total Balance to Spend by category', 'Rs.23000'),
                        ],
                      )),
                  const SizedBox(height: 30),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _mostUsedButton(Icons.money, 'Expense', () {
                            print('Button Pressed');
                          }),
                          const SizedBox(width: 20),
                          _mostUsedButton(Icons.verified, 'Approvals', () {
                            print('Button Pressed');
                          }),
                          const SizedBox(width: 20),
                          _mostUsedButton(Icons.mail, 'Mail', () {
                            print('Button Pressed');
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(15),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Top 5 Spenders in my Team',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                              height: 100,
                              child: Center(
                                  child: Text('[Bar Chart Placeholder]'))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Transaction',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Week')
                      ],
                    ),
                  ),
                  const SizedBox(height: 190),
                ],
              ),
            ),
          ),
          if (_dragOffset > 0)
            Positioned(
              top: size.height - _dragOffset,
              left: 0,
              right: 0,
              height: _dragOffset,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: _transactionList(),
              ),
            ),
          Positioned(
            bottom: _dragOffset + 30 > size.height ? 100 : _dragOffset - 60,
            left: (size.width / 2) - 25,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                setState(() {
                  _dragOffset = (_dragOffset - details.delta.dy)
                      .clamp(0.0, _maxDragExtent);
                });
              },
              child: const Icon(Icons.keyboard_arrow_up,
                  size: 50, color: Colors.indigo),
            ),
          ),
        ],
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

  Widget _mostUsedButton(IconData icon, String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 120,
        height: 40,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF93C5FD), Color(0xFF60A5FA)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _transactionList() {
    final List<Map<String, String>> transactions = [
      {"id": "FD23001", "amount": "230.00", "date": "13 Oct 2021"},
      {"id": "231", "amount": "390.00", "date": "11 Oct 2021"},
      {"id": "Per Diem", "amount": "121.00", "date": "10 Oct 2021"},
      {"id": "He2211", "amount": "143.00", "date": "08 Oct 2021"},
    ];

    return Column(
      children: transactions.map((tx) {
        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.green,
            child: Icon(Icons.currency_rupee, color: Colors.white),
          ),
          title: Text('Expense Id: ${tx['id']}'),
          subtitle: Text(tx['date']!),
          trailing: Text('Rs.${tx['amount']}'),
        );
      }).toList(),
    );
  }
}
