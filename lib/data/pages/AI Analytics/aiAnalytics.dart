import 'package:digi_xpense/data/service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

  final List<String> exampleQuestions = [
    "Expenses by Employees in the last 30 days?",
    "Which month had the most expenses submitted this year?",
    "Top 10 Expenses by Categories?",
    "How many expenses got approved in the last 30 days?"
  ];

  @override
  void initState() {
    super.initState();
    _chatMessages.add(ChatMessage(
      text:
          "Welcome to AI Analytics! I can help you analyze your expense data. Ask me anything!",
      isUser: false,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
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
        body: jsonEncode(
            {'question': question.trim(), 'name': 'digiexpense', 'server': ''}),
      );

      if (response.statusCode == 200) {
        final dynamic jsonData = jsonDecode(response.body);
        final String answer = _extractAnswer(jsonData);
        final List<Map<String, String>> tableData = _extractTableData(jsonData);

        setState(() {
          _chatMessages.add(ChatMessage(text: answer, isUser: false));

          if (tableData.isNotEmpty) {
            _chatMessages.add(ChatMessage(
              text: 'Here is the breakdown:',
              isUser: false,
              isTable: true,
              tableData: tableData,
            ));

            _chatMessages.add(ChatMessage(
              text: 'Expense Chart',
              isUser: false,
              isPlot: true,
              tableData: tableData,
            ));
          }
        });
      } else {
        setState(() {
          _chatMessages.add(ChatMessage(
            text: "Sorry, I couldn't process your request. Please try again.",
            isUser: false,
          ));
        });
      }
    } catch (e) {
      setState(() {
        _chatMessages.add(ChatMessage(
          text: "Network error. Please check your connection.",
          isUser: false,
        ));
      });
    } finally {
      setState(() {
        _isProcessing = false;
        _scrollToBottom();
      });
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

  /// ✅ Generic extractor: works with any dataset
  List<Map<String, String>> _extractTableData(dynamic json) {
    List<Map<String, String>> result = [];

    if (json is! Map<String, dynamic>) return result;
    if (!json.containsKey("data") || json["data"] is! Map<String, dynamic>) {
      return result;
    }

    final data = json["data"] as Map<String, dynamic>;
    final columnNames = data.keys.toList();

    final rowCount = (data[columnNames.first] as Map<String, dynamic>).length;

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

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(Controller());

    return WillPopScope(
        onWillPop: () async {
          controller.resetFieldsMileage();
          controller.clearFormFieldsPerdiem();
          Navigator.pushNamed(context, AppRoutes.dashboard_Main);

          return true; // allow back navigation
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.aiAnalytics,
                style: const TextStyle(color: Colors.white)),
            // backgroundColor: const Color(0xFF4A148C),
            iconTheme: const IconThemeData(color: Colors.white),
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
                    return _buildChatBubble(_chatMessages[index]);
                  },
                ),
              ),
              _buildInputSection(context),
            ],
          ),
        ));
  }

  Widget _buildInputSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.tryAsking,
            style: TextStyle(fontSize: 14),
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
                    label: Text(exampleQuestions[index],
                        style: const TextStyle(fontSize: 12)),
                    onPressed: () => _onExamplePressed(exampleQuestions[index]),
                    backgroundColor: const Color(0xFF4A148C).withAlpha(30),
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
                    hintText: AppLocalizations.of(context)!.askQuestionPrompt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    // filled: true,
                    // fillColor: Colors.white,
                    suffixIcon: _isProcessing
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
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
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  onPressed: _isProcessing ? null : _onSubmit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
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
              child: const Icon(Icons.analytics, color: Colors.white, size: 18),
            ),
          if (!isUser) const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!message.isPlot && !message.isTable)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          isUser ? const Color(0xFF4A148C) : Colors.grey[100],
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
                  _buildTable(message.tableData!),
                if (message.isPlot && message.tableData != null)
                  _buildChart(message.tableData!),
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
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
        ],
      ),
    );
  }

  /// ✅ Dynamic table builder
  Widget _buildTable(List<Map<String, String>> data) {
    if (data.isEmpty) return const SizedBox.shrink();

    final columns = data.first.keys.toList();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DataTable(
        headingRowColor:
            MaterialStateProperty.all(const Color(0xFF4A148C).withOpacity(0.1)),
        columnSpacing: 20,
        columns: columns
            .map((col) => DataColumn(
                  label: Text(col,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ))
            .toList(),
        rows: data.map((row) {
          return DataRow(
            cells:
                columns.map((col) => DataCell(Text(row[col] ?? ""))).toList(),
          );
        }).toList(),
      ),
    );
  }

  /// ✅ Always bar chart
  Widget _buildChart(List<Map<String, String>> data) {
    if (data.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noDataFound));
    }

    final columns = data.first.keys.toList();

    // First string column = labels (X axis)
    String? labelCol = columns.firstWhere(
      (col) => data.any((row) => double.tryParse(row[col] ?? '') == null),
      orElse: () => columns.first,
    );

    // First numeric column = values (Y axis)
    String? valueCol = columns.firstWhere(
      (col) => data.any((row) => double.tryParse(row[col] ?? '') != null),
      orElse: () => columns.last,
    );

    final labels = data.map((row) => row[labelCol!] ?? "").toList();
    final values =
        data.map((row) => double.tryParse(row[valueCol!] ?? "0") ?? 0).toList();

    return Container(
      height: 280,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            "Last ${values.length} Expense Transactions",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: CustomPaint(
              size: const Size(double.infinity, 220),
              painter: BarChartPainter(values, labels),
            ),
          ),
        ],
      ),
    );
  }
}

/// ✅ Custom painter for bar chart
class BarChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;

  BarChartPainter(this.values, this.labels);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFF4A148C)
      ..style = PaintingStyle.fill;

    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final barWidth = size.width / (values.length * 1.5);

    final textStyle = TextStyle(color: Colors.cyanAccent[700], fontSize: 5);
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < values.length; i++) {
      final x = i * (barWidth * 1.5) + barWidth / 2;
      final barHeight = (values[i] / maxVal) * size.height;

      final rect = Rect.fromLTWH(
        x,
        size.height - barHeight,
        barWidth,
        barHeight,
      );
      canvas.drawRect(rect, paint);

      // Draw label under bar
      textPainter.text = TextSpan(text: labels[i], style: textStyle);
      textPainter.layout(maxWidth: barWidth * 2);
      textPainter.paint(canvas, Offset(x - barWidth / 2, size.height + 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
