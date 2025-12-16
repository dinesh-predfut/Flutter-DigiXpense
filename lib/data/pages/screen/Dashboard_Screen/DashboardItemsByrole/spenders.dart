import 'dart:io' show File;
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';


import 'package:digi_xpense/core/comman/widgets/pageLoaders.dart';
import 'package:digi_xpense/data/models.dart'
    show DashboardDataItem, WidgetDataResponse, ChartDataPoint, DashboardByRole, ProjectExpensebycategory;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart' hide PdfDocument;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:get/get.dart';
import '../../../../service.dart';



class SpendersDashboardPage extends StatefulWidget {
  final String role;

  const SpendersDashboardPage({
    Key? key,
    required this.role,
  }) : super(key: key);

  @override
  State<SpendersDashboardPage> createState() => _SpendersDashboardPageState();
}

class _SpendersDashboardPageState extends State<SpendersDashboardPage> {
          final Controller controller = Controller();

    @override
  void initState() {
    super.initState();
    controller.loadSpendersDashboards(widget.role);
  }
  @override
  Widget build(BuildContext context) {
  

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title:  Text("${widget.role} Dashboard" ,style: TextStyle(fontSize: 16),),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            //  onPressed: () =>{}
            onPressed: () => controller.openExportSelection(context,widget.role),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: SkeletonLoaderPage());
        }

       final widgetsList = controller.getSpendersWidgetsForCurrentRole(widget.role);

        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Role selector
              Row(
                children: [
                  const Text('Role: '),
                  const SizedBox(width: 8),
                
                  const Spacer(),
                  // Search (optional)
                  Expanded(
                    flex: 2,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Horizontal scroll area (widgets)
              // SizedBox(
              //   height: 280,
              //   child: Obx(() {
              //     if (controller.isLoadingWidgets.value) {
              //       return const Center(child: CircularProgressIndicator());
              //     }

              //     final wizards = widgetsList;
              //     if (wizards.isEmpty) {
              //       return const Center(child: Text('No widgets for this role'));
              //     }

              //     return SingleChildScrollView(
              //       scrollDirection: Axis.horizontal,
              //       child: Column(
              //         children: wizards.map((wizardItem) {
              //           final keyName = wizardItem.widgetName ?? '';
              //           final gKey = controller.widgetRenderKeys.putIfAbsent(keyName, () => GlobalKey());
              //           final widgetData = controller.getSpendersWidgetData(wizardItem.widgetName ?? '');
              //           final widgetType = controller.getSpendersWidgetType(wizardItem.widgetName ?? '');

              //           return Padding(
              //             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              //             child: SpendersDynamicWidget(
              //               item: wizardItem,
              //               data: widgetData,
              //               widgetType: widgetType,
              //               captureKey: gKey,
                           
              //             ),
              //           );
              //         }).toList(),
              //       ),
              //     );
              //   }),
              // ),

              const SizedBox(height: 16),

              // Optionally you can place a grid/list of the widgets in single column below
              Expanded(
                child: ListView.builder(
                  itemCount: widgetsList.length,
                  itemBuilder: (context, idx) {
                    final item = widgetsList[idx];
                    final keyName = item.widgetName ?? '';
                    final gKey = controller.widgetRenderKeys.putIfAbsent(keyName, () => GlobalKey());
                    final widgetData = controller.getSpendersWidgetData(item.widgetName ?? '');
                    final widgetType = controller.getWidgetType(item.widgetName ?? '');
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: SpendersDynamicWidget(
                        item: item,
                        data: widgetData,
                        widgetType: widgetType,
                        captureKey: gKey,
                        currentRoel:widget.role
                        
                      ),
                    );
                  },
                ),
              ),
              
            ],
          ),
        );
      }),
    );
  }
}

class SpendersDynamicWidget extends StatelessWidget {
  final DashboardByRole item;
  final WidgetDataResponse? data;
  final String widgetType;
    final String currentRoel;
  final GlobalKey captureKey;
  final Controller controller = Controller();

   SpendersDynamicWidget({
    Key? key,
    required this.item,
    required this.data,
    required this.widgetType,
    required this.captureKey, required this.currentRoel,
   
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Each widget is wrapped in RepaintBoundary so it can be captured as image
    controller.fetchSpendersWidgetData(item,currentRoel);
    return RepaintBoundary(
      key: captureKey,
      child: Container(
        width: 260,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.widgetLabel ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 18),
                    onPressed: () async {
                      await controller.fetchSpendersWidgetData(item,currentRoel);
                      // force UI update
                      controller.widgetDataCache[item.widgetName ?? ''];
                      controller.update();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (data == null) {
      return Center(
        child: ElevatedButton(
          onPressed: () async {
            await controller.fetchSpendersWidgetData(item,currentRoel);
          },
          child:  Text('Load Data'),
        ),
      );
    }
      print("chdd${controller.getWidgetType(item.widgetName ?? '')}");

    switch (controller.getWidgetType(item.widgetName ?? '')) {
      case 'LineChart':
        return _buildLineChart();
      case 'BarChart':
        return _buildBarChart();
      case 'PieChart':
        return _buildPieChart();
      case 'DonutChart':
        return _buildDonutChart();
      case 'SummaryBox':
        return _buildSummary();
      case 'Table':
        return _buildTable();
        case 'ExpenseTable':
        return _buildTable();
         case 'MultiBarChart':
        return _buildMultiBarChart();
      default:
        return _buildGeneric();
    }
  }

  Widget _buildLineChart() {
    final points = controller.convertSpendersChartPoints(data!);
    if (points.isEmpty) return const Center(child: Text('No data'));

     return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SfCartesianChart(
         primaryXAxis: const CategoryAxis(
          labelRotation: 25,
          labelStyle: TextStyle(fontSize: 5),
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          labelIntersectAction: AxisLabelIntersectAction.hide,
        ),
        primaryYAxis: NumericAxis(
          numberFormat: NumberFormat.compact(),
          labelStyle: const TextStyle(fontSize: 8),
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
     
        series: <LineSeries<ChartDataPoint, String>>[
          LineSeries<ChartDataPoint, String>(
            dataSource: points,
            xValueMapper: (p, _) => p.x,
            yValueMapper: (p, _) => p.y,
            markerSettings: const MarkerSettings(isVisible: true),
          ),
        ],
      ),
    );
  }
Widget _buildMultiBarChart() {
 final multiSeries =controller.convertMultiSeriesChart(data!.raw);
  if (multiSeries.isEmpty) {
    return const Center(child: Text("No chart data"));
  }

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: SfCartesianChart(
      legend: Legend(isVisible: true),
      // tooltipBehavior: TooltipBehavior(enable: true),
      primaryXAxis: CategoryAxis(
        labelRotation: 25,
        labelStyle: const TextStyle(fontSize: 8),
      ),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat.compact(),
        labelStyle: const TextStyle(fontSize: 9),
      ),
      series: multiSeries,
    ),
  );
}


  Widget _buildBarChart() {
    final points = controller.convertSpendersChartPoints(data!);
    if (points.isEmpty) return const Center(child: Text('No data'));
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SfCartesianChart(
       primaryXAxis: const CategoryAxis(
          labelRotation: 25,
          labelStyle: TextStyle(fontSize: 5),
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          labelIntersectAction: AxisLabelIntersectAction.hide,
        ),
        primaryYAxis: NumericAxis(
          numberFormat: NumberFormat.compact(),
          labelStyle: const TextStyle(fontSize: 8),
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <ColumnSeries<ChartDataPoint, String>>[
          ColumnSeries<ChartDataPoint, String>(
            dataSource: points,
            xValueMapper: (p, _) => p.x,
            yValueMapper: (p, _) => p.y,
            pointColorMapper: (_, __) =>
                Colors.primaries[__ % Colors.primaries.length].shade300,
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(fontSize: 8),
            ),
      )],
      ),
       
    );
  }

Widget _buildPieChart() {
  final points = controller.convertSpendersChartPoints(data!);
  if (points.isEmpty) return const Center(child: Text('No data'));
  return Padding(
  padding: const EdgeInsets.all(8.0),
  child: SfCircularChart(
    tooltipBehavior: TooltipBehavior(
      enable: true,
      textStyle: const TextStyle(fontSize: 9),
    ),

    series: <PieSeries<ChartDataPoint, String>>[
      PieSeries<ChartDataPoint, String>(
        dataSource: points,
        xValueMapper: (p, _) => p.x,
        yValueMapper: (p, _) => p.y,

        dataLabelSettings: const DataLabelSettings(
          isVisible: true,
          textStyle: TextStyle(fontSize: 8), // Reduced label font
        ),
      ),
    ],
  ),
);
}


  Widget _buildDonutChart() {
    final points = controller.convertSpendersChartPoints(data!);
    if (points.isEmpty) return const Center(child: Text('No data'));
    return SfCircularChart(
      legend: Legend(isVisible: true),
      series: <DoughnutSeries>[
        DoughnutSeries<ChartDataPoint, String>(
          dataSource: points,
          xValueMapper: (p, _) => p.x,
          yValueMapper: (p, _) => p.y,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    final value = data!.getSingleValue();
    final formatted = NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(value);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 36, color: Colors.blue),
          const SizedBox(height: 8),
          Text(formatted, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(item.widgetLabel ?? ''),
        ],
      ),
    );
  }

Widget _buildTable() {
  print("listlist");

  final headers = [
    "ExpenseId",
    "EmployeeName",
    "ExpenseStatus",
    "ApprovalStatus",
    "TotalAmountTrans",
    "Currency",
    "MerchantName",
    "ExpenseCategoryId",
    "PaymentMethod",
    "ReceiptDate",
    "CreatedDatetime",
  ];

  return Obx(() {
    final list = controller.getAllListGExpense;
print("listlist$list");
    if (list.isEmpty) {
      return const Center(child: Text("No draft expenses found"));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          headingRowColor:
              MaterialStateProperty.all(Colors.grey.shade300),
          columns: headers
              .map(
                (h) => DataColumn(
                  label: Text(
                    h,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
              .toList(),
          rows: list.map<DataRow>((row) {
            return DataRow(
              cells: headers.map((h) {
                var value = row[h];

                // Format timestamps
                if ((h == "ReceiptDate" || h == "CreatedDatetime") &&
                    value != null &&
                    value is int) {
                  value = controller.formattedDate(value);
                }

                return DataCell(
                  Text(value?.toString() ?? ""),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  });
}



  Widget _buildGeneric() {
    final points = controller.convertSpendersChartPoints(data!);
    return Center(child: Text('Data points: ${points.length}'));
  }
  
}


class SpendersExportSelector extends StatefulWidget {
  final List<DashboardByRole> widgets;
  final Future<void> Function(List<DashboardByRole>) onExportSelected;

  const SpendersExportSelector({
    Key? key,
    required this.widgets,
    required this.onExportSelected,
  }) : super(key: key);

  @override
  _SpendersExportSelectorState createState() => _SpendersExportSelectorState();
}

class _SpendersExportSelectorState extends State<SpendersExportSelector> {
  final selected = <DashboardByRole>{};
  final controller = Get.put(Controller());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(12),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            const Text(
              'Select widgets to export',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: widget.widgets.map((w) {
                  final label = w.widgetLabel ?? w.widgetName ?? 'Widget';
                  return CheckboxListTile(
                    title: Text(label),
                    value: selected.contains(w),
                    onChanged: (v) {
                      setState(() {
                        if (v == true)
                          selected.add(w);
                        else
                          selected.remove(w);
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    child: const Text('Export Selected'),
                    onPressed: selected.isEmpty
                        ? null
                        : () async {
                            await widget.onExportSelected(selected.toList());
                            // if (mounted) Navigator.pop(context);
                          },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: controller.isExporting.value
                      ? null
                      : () async {
                          controller.isExporting.value = true;
                          try {
                            await widget.onExportSelected(widget.widgets);
                            // if (mounted) Navigator.pop(context);
                          } finally {
                            controller.isExporting.value = false;
                          }
                        },
                  child: Obx(() =>
                    controller.isExporting.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Export All'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
class FullScreenLoader extends StatelessWidget {
  final String message;
  
  const FullScreenLoader({
    Key? key,
    this.message = 'Please wait, we are exporting the data...',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated loader
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
                  Icon(
                    Icons.picture_as_pdf,
                    size: 30,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Title
              Text(
                'Exporting to PDF',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              
              const SizedBox(height: 10),
              
              // Message
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Status text
              Obx(() {
                final exportController = Get.find<Controller>();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "Please Wait we are exporting the data ",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                );
              }),
              
              const SizedBox(height: 10),
              
              // Subtext
              Text(
                'This may take a few moments...',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class SpendersExportService {
  /// MAIN EXPORT CALL
  static Future<void> exportWidgetsToPdfDynamic(
    List<MapEntry<DashboardByRole, GlobalKey>> itemsWithKeys,
    {Function(String)? onStatusUpdate}
  ) async {
    onStatusUpdate?.call('Initializing PDF document...');
    
    final PdfDocument document = PdfDocument();
    int currentWidget = 0;
    int totalWidgets = itemsWithKeys.length;

    try {
      onStatusUpdate?.call('Pre-rendering all widgets...');
      // First ensure all widgets are properly rendered
      await _preRenderAllWidgets(itemsWithKeys);

      for (final entry in itemsWithKeys) {
        currentWidget++;
        final widgetItem = entry.key;
        final key = entry.value;

        onStatusUpdate?.call('Processing widget $currentWidget of $totalWidgets...');
        
        // Force widget to become visible & painted
        await _ensureWidgetPainted(key);

        onStatusUpdate?.call('Capturing screenshot...');
        final bytes = await _capturePngFromKey(key);
        
        if (bytes == null) {
          onStatusUpdate?.call('Failed to capture ${widgetItem.widgetName}');
          print("Failed to capture ${widgetItem.widgetName}");
          final page = document.pages.add();
          page.graphics.drawString(
            "Failed to capture ${widgetItem.widgetName}",
            PdfStandardFont(PdfFontFamily.helvetica, 14),
            bounds: const Rect.fromLTWH(20, 20, 500, 40),
          );
          continue;
        }

        onStatusUpdate?.call('Adding to PDF...');
        final page = document.pages.add();
        final PdfBitmap bitmap = PdfBitmap(bytes);
        
        // Calculate aspect ratio and fit the image to page
        final pageWidth = page.size.width;
        final pageHeight = page.size.height;
        final imageWidth = bitmap.width.toDouble();
        final imageHeight = bitmap.height.toDouble();
        
        // Maintain aspect ratio while fitting to page
        final scale = min(
          (pageWidth - 40) / imageWidth, 
          (pageHeight - 40) / imageHeight
        );
        
        final scaledWidth = imageWidth * scale;
        final scaledHeight = imageHeight * scale;
        final x = (pageWidth - scaledWidth) / 2;
        final y = (pageHeight - scaledHeight) / 2;
        
        page.graphics.drawImage(
          bitmap, 
          Rect.fromLTWH(x, y, scaledWidth, scaledHeight)
        );
        
        // Add widget name as caption
        page.graphics.drawString(
          widgetItem.widgetLabel ?? widgetItem.widgetName ?? 'Widget',
          PdfStandardFont(PdfFontFamily.helvetica, 12),
          bounds: Rect.fromLTWH(x, y - 25, scaledWidth, 20),
        );
      }

      onStatusUpdate?.call('Saving PDF document...');
      final outputBytes = await document.save();
      document.dispose();

      onStatusUpdate?.call('Writing to file...');
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/dashboard_export_${DateTime.now().millisecondsSinceEpoch}.pdf');

      await file.writeAsBytes(outputBytes, flush: true);
      
      onStatusUpdate?.call('Opening PDF...');
      await OpenFilex.open(file.path);
      
    } catch (e) {
      onStatusUpdate?.call('Export failed: $e');
      print("Export failed: $e");
      rethrow;
    }
  }

  /// Pre-render all widgets to ensure they're ready for capture
  static Future<void> _preRenderAllWidgets(
      List<MapEntry<DashboardByRole, GlobalKey>> itemsWithKeys) async {
    for (final entry in itemsWithKeys) {
      final key = entry.value;
      final context = key.currentContext;
      if (context != null) {
        // Force build and layout
        context.findRenderObject()?.markNeedsLayout();
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }
    
    // Wait for all layouts to complete
    await Future.delayed(const Duration(milliseconds: 300));
  }

  static Future<void> _ensureWidgetPainted(GlobalKey key) async {
    final context = key.currentContext;
    if (context == null) return;

    // Scroll widget into view if inside a scrollable
    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // Force a rebuild and wait for rendering
    context.findRenderObject()?.markNeedsPaint();
    await Future.delayed(const Duration(milliseconds: 300));
  }

  static Future<Uint8List?> _capturePngFromKey(GlobalKey key) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) return null;

      // Check if the widget needs painting
      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 200));
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final byteData =
          await image.toByteData(format: ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("Capture failed: $e");
      return null;
    }
  }
}
