import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:diginexa/data/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constant/Parames/params.dart';
import '../../../core/constant/url.dart';
import '../../../l10n/app_localizations.dart';
import '../screen/widget/router/router.dart';

// Chat message model
class ChatMessage {
  final String text;
  final bool isUser;
  final bool isPlot;
  final bool isTable;
  final List<Map<String, String>>? tableData;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isPlot = false,
    this.isTable = false,
    this.tableData,
  });
}

class AIAnalyticsPage extends StatefulWidget {
  const AIAnalyticsPage({super.key});

  @override
  _AIAnalyticsPageState createState() => _AIAnalyticsPageState();
}

class _AIAnalyticsPageState extends State<AIAnalyticsPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isProcessing = false;
  List<ChatMessage> _chatMessages = [];
  final controller = Get.find<Controller>();

  // Keys for repaint boundary (screenshot per chart)
  final Map<int, GlobalKey> _chartKeys = {};
  final Map<int, GlobalKey> _tableKeys = {};

  final List<String> exampleQuestions = [
    "Expenses by Employees in the last 30 days?",
    "Which month had the most expenses submitted this year?",
    "Top 10 Expenses by Categories?",
    "How many expenses got approved in the last 30 days?",
  ];

  @override
  void initState() {
    super.initState();
    _chatMessages.add(
      ChatMessage(
        text:
            "Welcome to AI Analytics! I can help you analyze your expense data. Ask me anything!",
        isUser: false,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
      controller.checkAiHealth();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> fetchAnalyticsData(String question) async {
    if (question.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
      _chatMessages.add(ChatMessage(text: question, isUser: true));
    });

    try {
      final response = await http.post(
        Uri.parse('${Urls.aiAnalytics}question=${question.trim()}'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'API-key':
              'xkzeri-yqtLSxh6DqV3abO7gqehZtwaZgKt-hbgs1Iok7n51Pc0pK6jzXY2HDIPS1Wd2WCw4BeBauzpIGvC1fhAgW_14E-8847bL2qSgU5EZIU9pi3Kw',
          'Authorization': 'Bearer ${Params.userToken}',
        },
        body: jsonEncode({
          'question': question.trim(),
          'name': 'digiexpense',
          'server': '',
        }),
      );

      if (response.statusCode == 200) {
        final dynamic jsonData = jsonDecode(response.body);
        final String answer = _extractAnswer(jsonData);
        final List<Map<String, String>> tableData = _extractTableData(jsonData);

        setState(() {
          _chatMessages.add(ChatMessage(text: answer, isUser: false));
          if (tableData.isNotEmpty) {
            final tableIndex = _chatMessages.length;
            _tableKeys[tableIndex] = GlobalKey();
            _chatMessages.add(
              ChatMessage(
                text: 'Here is the breakdown:',
                isUser: false,
                isTable: true,
                tableData: tableData,
              ),
            );
            final chartIndex = _chatMessages.length;
            _chartKeys[chartIndex] = GlobalKey();
            _chatMessages.add(
              ChatMessage(
                text: 'Expense Chart',
                isUser: false,
                isPlot: true,
                tableData: tableData,
              ),
            );
          }
        });
      } else {
        setState(() {
          _chatMessages.add(
            ChatMessage(
              text:
                  "Sorry, I couldn't process your request. Please try again.",
              isUser: false,
            ),
          );
        });
      }
    } catch (e) {
      setState(() {
        _chatMessages.add(
          ChatMessage(
            text: "Network error. Please check your connection.",
            isUser: false,
          ),
        );
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  String _extractAnswer(dynamic json) {
    final possibleKeys = ['answer', 'response', 'message', 'text', 'result'];
    for (final key in possibleKeys) {
      if (json.containsKey(key) && json[key] is String) {
        return json[key];
      }
    }
    return "Here's the information you requested:";
  }

  List<Map<String, String>> _extractTableData(dynamic json) {
    List<Map<String, String>> result = [];
    if (json is! Map<String, dynamic>) return result;
    if (!json.containsKey("data") || json["data"] is! Map<String, dynamic>) {
      return result;
    }
    final data = json["data"] as Map<String, dynamic>;
    final columnNames = data.keys.toList();
    final rowCount =
        (data[columnNames.first] as Map<String, dynamic>).length;
    for (int i = 0; i < rowCount; i++) {
      Map<String, String> row = {};
      for (var col in columnNames) {
        final colMap = data[col] as Map<String, dynamic>;
        row[col] = colMap[i.toString()].toString();
      }
      result.add(row);
    }
    return result;
  }

  void _onExamplePressed(String question) {
    _controller.text = question;
    fetchAnalyticsData(question);
  }

  void _onSubmit() {
    final question = _controller.text.trim();
    if (question.isEmpty) return;
    fetchAnalyticsData(question);
    _controller.clear();
  }

  // ✅ Download chart as image to gallery
 Future<void> _downloadChart(GlobalKey key, String fileName) async {
  try {
    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 100));

    final ctx = key.currentContext;
    if (ctx == null) {
      print("Chart not ready");
      return;
    }

    final boundary =
        ctx.findRenderObject() as RenderRepaintBoundary?;

    if (boundary == null) {
      print("Boundary not found");
      return;
    }

    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) return;

    final pngBytes = byteData.buffer.asUint8List();

    // ✅ Save temporarily inside app
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/$fileName.png';

    final file = File(filePath);
    await file.writeAsBytes(pngBytes);

    // ✅ Share (user can save anywhere)
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Expense Chart',
    );

  } catch (e) {
    print("Error: $e");
  }
}

  // ✅ Download table as CSV
  Future<void> _downloadTableAsCSV(
      List<Map<String, String>> data, String fileName) async {
    try {
     
      if (data.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.noDataFound),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final columns = data.first.keys.toList();
      final StringBuffer csv = StringBuffer();

      // Header row
      csv.writeln(columns.join(','));

      // Data rows
      for (final row in data) {
        csv.writeln(columns.map((col) => '"${row[col] ?? ""}"').join(','));
      }

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final String filePath =
          '${directory!.path}/${fileName}_${DateTime.now().millisecondsSinceEpoch}.csv';
      final File file = File(filePath);
      await file.writeAsString(csv.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV saved to $filePath'),
            backgroundColor: const Color(0xFF4A148C),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV download failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<Controller>();

    return WillPopScope(
      onWillPop: () async {
        controller.resetFieldsMileage();
        controller.clearFormFieldsPerdiem();
        Navigator.pushNamed(context, AppRoutes.dashboard_Main);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${AppLocalizations.of(context)!.aiAnalytics} ',
            style: const TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            Obx(() {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: TextButton(
                  onPressed: controller.isAiActive.value
                      ? () {}
                      : null,
                  style: TextButton.styleFrom(
                    foregroundColor: controller.isAiActive.value
                        ? Colors.white
                        : Colors.white54,
                  ),
                  child: controller.isAiLoading.value
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          controller.isAiActive.value ? "Active" : "In Active",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              );
            }),
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFF3E5F5),
              child: Row(
                children: [
                  const Icon(Icons.analytics, color: Color(0xFF4A148C)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.askQuestionPrompt,
                      style: const TextStyle(
                        color: Color(0xFF4A148C),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _chatMessages.length,
                itemBuilder: (context, index) {
                  return _buildChatBubble(_chatMessages[index], index);
                },
              ),
            ),
            _buildInputSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.tryAsking,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: exampleQuestions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(
                      exampleQuestions[index],
                      style: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () =>
                        _onExamplePressed(exampleQuestions[index]),
                    backgroundColor:
                        const Color(0xFF4A148C).withAlpha(30),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText:
                        AppLocalizations.of(context)!.askQuestionPrompt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: _isProcessing
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2),
                            ),
                          )
                        : null,
                  ),
                  onSubmitted: (_) => _onSubmit(),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A148C),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: IconButton(
                  icon: const Icon(Icons.send,
                      color: Colors.white, size: 20),
                  onPressed: _isProcessing ? null : _onSubmit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message, int index) {
    final isUser = message.isUser;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF4A148C),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.analytics,
                  color: Colors.white, size: 18),
            ),
          if (!isUser) const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!message.isPlot && !message.isTable)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFF4A148C)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 16),
                      ),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                  ),
                if (message.isTable && message.tableData != null)
                  _buildTableWithDownload(
                      message.tableData!, index),
                if (message.isPlot && message.tableData != null)
                  _buildChartWithDownload(
                      message.tableData!, index),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.person,
                  color: Colors.white, size: 18),
            ),
        ],
      ),
    );
  }

  // ✅ Table with download CSV button
  Widget _buildTableWithDownload(
      List<Map<String, String>> data, int index) {
    final tableKey = _tableKeys[index] ?? GlobalKey();
    _tableKeys[index] = tableKey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RepaintBoundary(
          key: tableKey,
          child: _buildTable(data),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () =>
                _downloadTableAsCSV(data, 'expense_table'),
            icon: const Icon(Icons.download,
                size: 16, color: Color(0xFF4A148C)),
            label: const Text(
              'Download CSV',
              style: TextStyle(
                  color: Color(0xFF4A148C), fontSize: 12),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              side: const BorderSide(
                  color: Color(0xFF4A148C), width: 0.8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  // ✅ Chart with download PNG button
  Widget _buildChartWithDownload(
      List<Map<String, String>> data, int index) {
    final chartKey = _chartKeys[index] ?? GlobalKey();
    _chartKeys[index] = chartKey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RepaintBoundary(
          key: chartKey,
          child: _buildChart(data),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () =>
                _downloadChart(chartKey, 'expense_chart'),
            icon: const Icon(Icons.download,
                size: 16, color: Color(0xFF4A148C)),
            label: const Text(
              'Download Chart',
              style: TextStyle(
                  color: Color(0xFF4A148C), fontSize: 12),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              side: const BorderSide(
                  color: Color(0xFF4A148C), width: 0.8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  // ✅ Dynamic table builder
  Widget _buildTable(List<Map<String, String>> data) {
    if (data.isEmpty) return const SizedBox.shrink();
    final columns = data.first.keys.toList();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            const Color(0xFF4A148C).withOpacity(0.1),
          ),
          columnSpacing: 20,
          columns: columns
              .map(
                (col) => DataColumn(
                  label: Text(
                    col,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              )
              .toList(),
          rows: data.map((row) {
            return DataRow(
              cells: columns.map((col) {
                return DataCell(
                  SizedBox(
                    width: 130,
                    child: Text(
                      _formatValue(row[col]),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _formatValue(String? value) {
    if (value == null || value.isEmpty) return "";
    final numVal = double.tryParse(value);
    if (numVal != null) return numVal.toStringAsFixed(2);
    // ✅ Format ISO date strings
    if (value.contains('T') && value.contains('-')) {
      try {
        final dt = DateTime.parse(value);
        return '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
      } catch (_) {}
    }
    return value;
  }

  // ✅ Bar chart with proper X and Y axes
  Widget _buildChart(List<Map<String, String>> data) {
    if (data.isEmpty) {
      return Center(
          child: Text(AppLocalizations.of(context)!.noDataFound));
    }

    final columns = data.first.keys.toList();

    String labelCol = columns.firstWhere(
      (col) => data.any((row) => double.tryParse(row[col] ?? '') == null),
      orElse: () => columns.first,
    );

    String valueCol = columns.firstWhere(
      (col) =>
          col != labelCol &&
          data.any((row) => double.tryParse(row[col] ?? '') != null),
      orElse: () => columns.last,
    );

    // ✅ Format labels (shorten ISO dates)
    final labels = data.map((row) {
      final raw = row[labelCol] ?? "";
      if (raw.contains('T') && raw.contains('-')) {
        try {
          final dt = DateTime.parse(raw);
          return '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
        } catch (_) {}
      }
      // Shorten long strings
      return raw.length > 12 ? '${raw.substring(0, 10)}…' : raw;
    }).toList();

    final values = data
        .map((row) => double.tryParse(row[valueCol] ?? "0") ?? 0)
        .toList();

    final maxValue = values.reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Chart title
          Center(
            child: Text(
              '${valueCol} Overview',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF4A148C),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // ✅ Chart with axes
          SizedBox(
            height: 260,
            child: CustomPaint(
              size: const Size(double.infinity, 260),
              painter: AxisBarChartPainter(
                values: values,
                labels: labels,
                maxValue: maxValue,
                barColor: const Color(0xFF4A148C),
                axisColor: Colors.grey.shade600,
                gridColor: Colors.grey.shade200,
                labelColor: const Color(0xFF4A148C),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // ✅ X-axis column label
          Center(
            child: Text(
              labelCol,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Fully rewritten bar chart painter with X and Y axes
class AxisBarChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final double maxValue;
  final Color barColor;
  final Color axisColor;
  final Color gridColor;
  final Color labelColor;

  AxisBarChartPainter({
    required this.values,
    required this.labels,
    required this.maxValue,
    required this.barColor,
    required this.axisColor,
    required this.gridColor,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    // ✅ Layout margins
    const double leftMargin = 52.0;   // Y-axis label space
    const double bottomMargin = 48.0; // X-axis label space
    const double topMargin = 8.0;
    const double rightMargin = 8.0;

    final chartWidth = size.width - leftMargin - rightMargin;
    final chartHeight = size.height - bottomMargin - topMargin;

    final axisPaint = Paint()
      ..color = axisColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final barPaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    // ✅ Draw Y-axis grid lines and labels (5 steps)
    const int ySteps = 5;
    final textPainterY = TextPainter(
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i <= ySteps; i++) {
      final double yValue = maxValue * i / ySteps;
      final double y =
          topMargin + chartHeight - (chartHeight * i / ySteps);

      // Grid line
      canvas.drawLine(
        Offset(leftMargin, y),
        Offset(leftMargin + chartWidth, y),
        i == 0 ? axisPaint : gridPaint,
      );

      // Y label
      final label = yValue >= 1000
          ? '${(yValue / 1000).toStringAsFixed(1)}k'
          : yValue.toStringAsFixed(0);

      textPainterY.text = TextSpan(
        text: label,
        style: TextStyle(
          color: axisColor,
          fontSize: 9,
          fontWeight: FontWeight.w400,
        ),
      );
      textPainterY.layout(maxWidth: leftMargin - 4);
      textPainterY.paint(
        canvas,
        Offset(leftMargin - textPainterY.width - 4, y - 6),
      );
    }

    // ✅ Draw X-axis line
    canvas.drawLine(
      Offset(leftMargin, topMargin + chartHeight),
      Offset(leftMargin + chartWidth, topMargin + chartHeight),
      axisPaint,
    );

    // ✅ Draw Y-axis line
    canvas.drawLine(
      Offset(leftMargin, topMargin),
      Offset(leftMargin, topMargin + chartHeight),
      axisPaint,
    );

    // ✅ Draw bars and X labels
    final int count = values.length;
    final double groupWidth = chartWidth / count;
    final double barWidth = groupWidth * 0.55;

    final textPainterX = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < count; i++) {
      final double x = leftMargin + i * groupWidth + (groupWidth - barWidth) / 2;
      final double barHeight = maxValue > 0
          ? (values[i] / maxValue) * chartHeight
          : 0;
      final double top = topMargin + chartHeight - barHeight;

      // ✅ Bar
      final barRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, top, barWidth, barHeight),
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
      );
      canvas.drawRRect(barRect, barPaint);

      // ✅ Value label on top of bar
      final valLabel = values[i] >= 1000
          ? '${(values[i] / 1000).toStringAsFixed(1)}k'
          : values[i].toStringAsFixed(0);

      textPainterX.text = TextSpan(
        text: valLabel,
        style: TextStyle(
          color: labelColor,
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainterX.layout(maxWidth: groupWidth);
      textPainterX.paint(
        canvas,
        Offset(
          x + barWidth / 2 - textPainterX.width / 2,
          top - textPainterX.height - 2,
        ),
      );

      // ✅ X-axis label (rotated for long text)
      final xLabel = labels[i];
      textPainterX.text = TextSpan(
        text: xLabel,
        style: TextStyle(
          color: axisColor,
          fontSize: 9,
          fontWeight: FontWeight.w400,
        ),
      );
      textPainterX.layout(maxWidth: groupWidth * 1.8);

      canvas.save();
      // Rotate label -30° for readability
      final double labelX =
          x + barWidth / 2;
      final double labelY =
          topMargin + chartHeight + 6;
      canvas.translate(labelX, labelY);
      canvas.rotate(-0.5); // ~28 degrees
      textPainterX.paint(
        canvas,
        Offset(-textPainterX.width / 2, 0),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant AxisBarChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.labels != labels;
}