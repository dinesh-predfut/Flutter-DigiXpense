import 'dart:async';
import 'package:digi_xpense/core/comman/widgets/languageDropdown.dart';
import 'package:digi_xpense/data/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constant/Parames/colors.dart';
import '../../../service.dart';
import '../widget/router/router.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double _dragOffset = 200; // Initial height of the draggable panel
  final double _minDragExtent = 100; // Minimum height
  final double _maxDragExtent =
      MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height *
          0.7; // Maximum height
  final Controller controller = Controller();

  @override
  void initState() {
    super.initState();
    controller.digiSessionId = const Uuid().v4();
    if (!controller.isInitialized.value) {
      Timer(const Duration(seconds: 2), () {
        controller.fetchChartData();
        controller.fetchExpensesByProjects();
        controller.fetchAndReplaceValue();
        controller.currencyDropDown();
        controller.fetchNotifications();
        controller.getPersonalDetails(context);
        controller.configuration();
        controller.getUserPref();
        if (controller.profileImage.value == null) {
          controller.getProfilePicture();
        }
        controller.isInitialized.value = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    print("unreadCount${controller.unreadCount.value}");

    return WillPopScope(
        onWillPop: () async {
          // controller.isEnable.value = false;
          // controller.isLoadingGE1.value = false;
          Navigator.pushNamed(context, AppRoutes.signin);
          return true;
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF7F7F7),
          body: Column(
            children: [
              // Main content that will scroll
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Your existing header and content widgets...
                      Stack(
                        children: [
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const LanguageDropdown(),
                                    Stack(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.notifications,
                                              color: Colors.white),
                                          onPressed: () {
                                            Navigator.pushNamed(context,
                                                AppRoutes.notification);
                                          },
                                        ),
                                        Obx(() {
                                          final unreadCount = controller
                                              .unreadNotifications.length;
                                          if (unreadCount == 0)
                                            return const SizedBox.shrink();
                                          return Positioned(
                                            right: 6,
                                            top: 6,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              constraints: const BoxConstraints(
                                                minWidth: 18,
                                                minHeight: 18,
                                              ),
                                              child: Text(
                                                '$unreadCount',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                    const SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, AppRoutes.personalInfo);
                                      },
                                      child: Obx(() => Container(
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
                                              child: controller
                                                      .isImageLoading.value
                                                  ? const SizedBox(
                                                      width: 40,
                                                      height: 40,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2,
                                                      ),
                                                    )
                                                  : controller.profileImage
                                                              .value !=
                                                          null
                                                      ? Image.file(
                                                          controller
                                                              .profileImage
                                                              .value!,
                                                          width: 40,
                                                          height: 40,
                                                          fit: BoxFit.cover,
                                                        )
                                                      : const Icon(
                                                          Icons.person,
                                                          size: 40,
                                                          color: Colors.white,
                                                        ),
                                            ),
                                          )),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'Top 5 Spenders in my Team',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ),
                              SizedBox(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      Obx(() {
                                        if (controller.isUploading.value) {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                        return Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.9,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: Colors.blue.shade50,
                                          ),
                                          child: SfCartesianChart(
                                            title: const ChartTitle(
                                                text:
                                                    "Bar Chart - Project Expenses"),
                                            primaryXAxis: const CategoryAxis(),
                                            primaryYAxis: NumericAxis(
                                              numberFormat:
                                                  NumberFormat.compact(),
                                            ),
                                            series: <CartesianSeries>[
                                              ColumnSeries<ProjectExpense,
                                                  String>(
                                                dataSource:
                                                    controller.projectExpenses,
                                                xValueMapper:
                                                    (ProjectExpense project,
                                                            _) =>
                                                        project.x,
                                                yValueMapper:
                                                    (ProjectExpense project,
                                                            _) =>
                                                        project.y,
                                                dataLabelSettings:
                                                    const DataLabelSettings(
                                                        isVisible: true),
                                                color: Colors.blue,
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                      Obx(() {
                                        if (controller.isUploading.value) {
                                          // 🔄 Show loader while data is uploading
                                          return Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.9,
                                            height:
                                                300, // 👈 Add height for loader container
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: Colors.black.withOpacity(
                                                  0.3), // semi-transparent background
                                            ),
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.green,
                                              ),
                                            ),
                                          );
                                        }

                                        // ✅ Show Line Chart when data is ready
                                        return Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.9,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: Colors.green.shade50,
                                          ),
                                          child: SfCartesianChart(
                                            title: const ChartTitle(
                                              text:
                                                  "Line Chart - Project Expenses",
                                            ),
                                            primaryXAxis: const CategoryAxis(
                                              labelRotation: 45,
                                              labelStyle: TextStyle(
                                                fontSize: 6,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            primaryYAxis: NumericAxis(
                                              numberFormat:
                                                  NumberFormat.compact(),
                                              labelStyle: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            tooltipBehavior:
                                                TooltipBehavior(enable: true),
                                            series: <CartesianSeries>[
                                              LineSeries<ProjectData, String>(
                                                dataSource:
                                                    controller.chartData,
                                                xValueMapper:
                                                    (ProjectData project, _) =>
                                                        project.x,
                                                yValueMapper:
                                                    (ProjectData project, _) =>
                                                        project.y,
                                                markerSettings:
                                                    const MarkerSettings(
                                                        isVisible: true),
                                                color: Colors.green,
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                      Obx(() {
                                        if (controller.isUploading.value) {
                                          return Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.8,
                                            height: 320,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                            ),
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.green,
                                              ),
                                            ),
                                          );
                                        }
                                        return Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          height: 320,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: Colors.red.shade50,
                                          ),
                                          child: SfRadialGauge(
                                            title: const GaugeTitle(
                                              text: "Total Expense",
                                              textStyle: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            axes: <RadialAxis>[
                                              RadialAxis(
                                                minimum: 0,
                                                maximum: controller
                                                        .expenseChartvalue *
                                                    2,
                                                axisLabelStyle:
                                                    const GaugeTextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                                pointers: <GaugePointer>[
                                                  NeedlePointer(
                                                    value: controller
                                                        .expenseChartvalue,
                                                    enableAnimation: true,
                                                  ),
                                                ],
                                                ranges: <GaugeRange>[
                                                  GaugeRange(
                                                    startValue: 0,
                                                    endValue: controller
                                                            .expenseChartvalue *
                                                        0.4,
                                                    color: Colors.green,
                                                  ),
                                                  GaugeRange(
                                                    startValue: controller
                                                            .expenseChartvalue *
                                                        0.4,
                                                    endValue: controller
                                                            .expenseChartvalue *
                                                        0.8,
                                                    color: Colors.orange,
                                                  ),
                                                  GaugeRange(
                                                    startValue: controller
                                                            .expenseChartvalue *
                                                        0.8,
                                                    endValue: controller
                                                        .expenseChartvalue,
                                                    color: Colors.red,
                                                  ),
                                                ],
                                                annotations: <GaugeAnnotation>[
                                                  GaugeAnnotation(
                                                    widget: Text(
                                                      '₹${controller.expenseChartvalue.toStringAsFixed(0)}',
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    angle: 90,
                                                    positionFactor: 0.5,
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        );
                                      })
                                    ],
                                  ),
                                ),
                              ),
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
                      const SizedBox(
                          height: 20), // Space before the draggable panel
                    ],
                  ),
                ),
              ),

              // Draggable panel at the bottom
              GestureDetector(
                  onVerticalDragUpdate: (details) {
                    setState(() {
                      _dragOffset = (_dragOffset - details.delta.dy)
                          .clamp(_minDragExtent, _maxDragExtent);
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: _dragOffset,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(30))),
                    child: Column(
                      // Now this is correct
                      children: [
                        // Drag handle
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Container(
                              width: 50,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ),
                        // Transaction list content
                        Expanded(child: _transactionList()),
                      ],
                    ),
                  ))
            ],
          ),
        ));
  }

  // Rest of your helper methods (_balanceCard, _mostUsedButton, _transactionList) remain the same...
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

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.green,
            child: Icon(Icons.currency_rupee, color: Colors.white),
          ),
          title: Text('Expense Id: ${tx['id']}'),
          subtitle: Text(tx['date']!),
          trailing: Text('Rs.${tx['amount']}'),
        );
      },
    );
  }
}
