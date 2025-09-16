import 'package:digi_xpense/data/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:digi_xpense/core/constant/Parames/params.dart';

import '../../../../../core/comman/widgets/pageLoaders.dart';
import '../../../../../core/constant/url.dart';
import '../../../../../l10n/app_localizations.dart';

class ExpensePaginationPage extends StatefulWidget {
  const ExpensePaginationPage({super.key});

  @override
  State<ExpensePaginationPage> createState() => _ExpensePaginationPageState();
}

class _ExpensePaginationPageState extends State<ExpensePaginationPage> {
  List<Map<String, dynamic>> expenseDetails = [];
  List<String> expenseIds = [];
  List<String> selectedFromLocal = [];
  List<String> finalFilteredList = [];
  // Stores parsed ActivityLog items from API
  List<ExpenseHistory> activityLog = [];

  int currentPageStartIndex = 0;
  int selectedIndex = 0;
  final int pageSize = 5;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSelectedTables();
    _loadExpenseIds();
  }

  Future<void> _loadSelectedTables() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('selectedTables') ?? [];

    debugPrint("📦 Stored selected tables: $stored");

    List<String> filtered = [];
    if (stored.contains("DocumentAttachments"))
      filtered.add("DocumentAttachments");
    if (stored.contains("AccountingDistributions"))
      filtered.add("AccountingDistributions");
    if (stored.contains("CSHHeaderExpensecategorycustomfieldvalues")) {
      filtered.add("CSHHeaderExpensecategorycustomfieldvalues");
    }

    setState(() {
      selectedFromLocal = stored;
    });
  }

  Future<void> _loadExpenseIds() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? storedIds = prefs.getStringList('expenseIds');
    storedIds ??= List.generate(17, (i) => "EXP-${i + 1001}");
    await prefs.setStringList('expenseIds', storedIds);

    setState(() {
      expenseIds = storedIds!;
    });
    if (expenseIds.isNotEmpty) {
      // optional: set selectedIndex to 0
      setState(() {
        selectedIndex = 0;
      });
      _fetchExpenseData(expenseIds[0]);
    }
  }

  Future<void> _fetchExpenseData(String expenseId) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final url = Uri.parse(
        '${Urls.baseURL}/api/v1/reports/expensereport/misreports'
        '?transactionid=$expenseId&trackingcontext=ExpenseRequisition',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Params.userToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          final expense = Map<String, dynamic>.from(data.first);

          setState(() {
            expenseDetails = [expense];

            // Parse and store ActivityLog data
            activityLog = (expense['ActivityLog'] as List<dynamic>? ?? [])
                .map((log) => ExpenseHistory.fromJson(log))
                .toList();
          });
        }

        if (data is List && data.isNotEmpty) {
          final List<Map<String, dynamic>> expenses =
              data.map((e) => Map<String, dynamic>.from(e)).toList();

          setState(() {
            expenseDetails = expenses;
          });

          debugPrint("✅ API Data fetched for $expenseId");
        } else {
          setState(() {
            errorMessage = "No expense data found.";
          });
        }
      } else {
        setState(() {
          errorMessage = "Failed to load data (HTTP ${response.statusCode})";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _printAllExpenses(List<String> expenseIds) async {
    if (expenseIds.isEmpty) {
      debugPrint("⚠ No expense IDs provided");
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final logoBytes = await rootBundle
          .load('assets/Logo.jpg')
          .then((data) => data.buffer.asUint8List());
      final pdf = pw.Document();

      // Collect all expense widgets to render in MultiPage
      List<pw.Widget> reportWidgets = [];

      for (String expenseId in expenseIds) {
        final url = Uri.parse(
          '${Urls.baseURL}/api/v1/reports/expensereport/misreports'
          '?transactionid=$expenseId&trackingcontext=ExpenseRequisition',
        );

        final response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${Params.userToken}',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data is List && data.isNotEmpty) {
            final expense = Map<String, dynamic>.from(data.first);

            // Parse ActivityLog for this expense
            final logs = (expense['ActivityLog'] as List<dynamic>? ?? [])
                .map((log) => ExpenseHistory.fromJson(log))
                .toList();

            // Append expense report widget for MultiPage
            reportWidgets.add(
              _buildExpenseContainerViewPdf(
                expense,
                selectedFromLocal,
                logs,
                logoBytes,
              ),
            );
            // Spacer and divider between reports
            reportWidgets.add(pw.SizedBox(height: 30));
            reportWidgets.add(pw.Divider());
          }
        } else {
          debugPrint(
            "⚠ Failed to fetch expense $expenseId (HTTP ${response.statusCode})",
          );
        }
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) => reportWidgets,
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      debugPrint("❌ Error printing all expenses: $e");
      setState(() {
        errorMessage = "Error: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Future<void> _printAllReports(List<Map<String, dynamic>> allExpenses) async {
  //   if (allExpenses.isEmpty) return;

  //   final logoBytes = await rootBundle
  //       .load('assets/Logo.jpg')
  //       .then((data) => data.buffer.asUint8List());

  //   final pdf = pw.Document();

  //   pdf.addPage(
  //     pw.MultiPage(
  //       pageFormat: PdfPageFormat.a4,
  //       build: (pw.Context context) {
  //         List<pw.Widget> children = [];
  //         for (int i = 0; i < allExpenses.length; i++) {
  //           final expense = allExpenses[i];
  //           final logs = (expense['ActivityLog'] as List<dynamic>? ?? [])
  //               .map((log) => ExpenseHistory(
  //                     eventType: log['EventType'] ?? '',
  //                     notes: log['Notes'] ?? '',
  //                     userName: log['CreatedBy'] ?? '',
  //                     createdDate:
  //                         DateTime.tryParse(log['CreatedDatetime'] ?? '') ??
  //                             DateTime.now(),
  //                   ))
  //               .toList();

  //           children.add(
  //             _buildExpenseContainerViewPdf(
  //               expense,
  //               selectedFromLocal,
  //               logs,
  //               logoBytes,
  //             ),
  //           );
  //           if (i < allExpenses.length - 1) {
  //             children.add(pw.SizedBox(height: 30));
  //             children.add(pw.Divider());
  //           }
  //         }
  //         return children;
  //       },
  //     ),
  //   );

  //   await Printing.layoutPdf(
  //     onLayout: (PdfPageFormat format) async => pdf.save(),
  //   );
  // }

  void _onPageButtonClick(int index) {
    setState(() {
      selectedIndex = index;
    });
    _fetchExpenseData(expenseIds[index]);
    debugPrint("🔹 Clicked index: $index → ExpenseId: ${expenseIds[index]}");
  }

  pw.Widget _buildTimelineItemPdf(ExpenseHistory item, bool isLast) {
    print("activityLog${item.eventType}");

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // pw.Column(
        //   children: [
        //     pw.Text('✓',
        //         style: const pw.TextStyle(color: PdfColors.blue, fontSize: 20)),
        //     if (!isLast)
        //       pw.Container(width: 2, height: 40, color: PdfColors.grey300),
        //   ],
        // ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: pw.Container(
            margin: const pw.EdgeInsets.symmetric(vertical: 8),
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey600, width: 0.5),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(item.eventType,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(item.notes),
                pw.SizedBox(height: 6),
                pw.Text(
                  '${AppLocalizations.of(context)!.submittedOn} ${DateFormat('dd/MM/yyyy').format(item.createdDate)}',
                  style: const pw.TextStyle(color: PdfColors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _printCurrentReport() async {
    if (expenseDetails.isEmpty) {
      debugPrint("⚠ No expense data to print");
      return;
    }

    final expense = expenseDetails.first;

    // Load the logo as bytes
    final logoBytes = await rootBundle
        .load('assets/Logo.jpg')
        .then((data) => data.buffer.asUint8List());

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          // Your entire template, split into widgets
          _buildExpenseContainerViewPdf(
            expense,
            selectedFromLocal,
            activityLog,
            logoBytes,
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  void _nextPage() {
    if (currentPageStartIndex + pageSize < expenseIds.length) {
      setState(() {
        currentPageStartIndex += pageSize;
      });
    }
  }

  void _prevPage() {
    if (currentPageStartIndex - pageSize >= 0) {
      setState(() {
        currentPageStartIndex -= pageSize;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int endIndex = (currentPageStartIndex + pageSize > expenseIds.length)
        ? expenseIds.length
        : currentPageStartIndex + pageSize;

    List<int> visibleIndexes = List.generate(
        endIndex - currentPageStartIndex, (i) => i + currentPageStartIndex);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.reports,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        // actions: [
        //   IconButton(
        //       onPressed: _loadExpenseIds, icon: const Icon(Icons.refresh)),
        //   IconButton(
        //       onPressed: _printCurrentReport,
        //       icon: const Icon(Icons.picture_as_pdf)),
        // ],
      ),
      body: isLoading
          ? const Center(child: SkeletonLoaderPage())
          : errorMessage != null
              ? Center(
                  child: Text(errorMessage!,
                      style: const TextStyle(color: Colors.red)))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      /// Top Menu Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _printCurrentReport,
                            icon: const Icon(Icons.print),
                            label:  Text(AppLocalizations.of(context)!.print),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _printAllExpenses(expenseIds),
                            icon: const Icon(Icons.print),
                            label:  Text(AppLocalizations.of(context)!.printAll),
                          ),
                        ],
                      ),
                      const Divider(thickness: 1, height: 30),

                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, size: 20),
                            onPressed:
                                currentPageStartIndex > 0 ? _prevPage : null,
                          ),
                          ...visibleIndexes.map((index) {
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(35, 35),
                                backgroundColor: selectedIndex == index
                                    ? Colors.blue
                                    : Colors.grey[300],
                                foregroundColor: selectedIndex == index
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              onPressed: () => _onPageButtonClick(index),
                              child: Text("${index + 1}",
                                  style: const TextStyle(fontSize: 12)),
                            );
                          }).toList(),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward, size: 20),
                            onPressed:
                                endIndex < expenseIds.length ? _nextPage : null,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// Expense Details Container
                      if (expenseDetails.isNotEmpty)
                        Expanded(
                          child: SingleChildScrollView(
                            child: _buildExpenseContainer(expenseDetails.first),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  bool isImageFile(String fileExtension) {
    final imageExtensions = [
      '.png',
      '.jpg',
      '.jpeg',
      '.gif',
      '.bmp',
      '.webp',
      '.tiff'
    ];
    return imageExtensions.contains(fileExtension.toLowerCase());
  }

// Function to check if file is a PDF
  bool isPdfFile(String fileExtension) {
    return fileExtension.toLowerCase() == '.pdf';
  }

  Widget _buildExpenseContainer(Map<String, dynamic> expense) {
    final expenseTrans = (expense['ExpenseTrans'] as List<dynamic>? ?? []);
    final documentAttachments =
        (expense['DocumentAttachments'] as List<dynamic>? ?? []);

    double totalTransAmount = 0.0;
    for (var line in expenseTrans) {
      totalTransAmount += (line['LineAmountTrans'] as num?)?.toDouble() ?? 0.0;
    }

    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return '';
      try {
        final dt = DateTime.parse(dateStr);
        return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
      } catch (_) {
        return dateStr;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // color: Colors.blue[50],
        border: Border.all(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Top logo
          Center(
            child: Image.asset('assets/Logo.jpg', height: 94),
          ),
          const SizedBox(height: 30),

          /// Summary fields
          Text(
              "${AppLocalizations.of(context)!.expenseId}: ${expense['ExpenseId'] ?? ''}",
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(
              "${AppLocalizations.of(context)!.employeeId}: ${expense['EmployeeId'] ?? ''}"),
          Text(
              "${AppLocalizations.of(context)!.totalAmountTrans}: ${expense['TotalAmountTrans'] ?? ''}"),
          Text(
              "${AppLocalizations.of(context)!.totalAmountReporting}: ${expense['TotalAmountReporting'] ?? ''}"),
          Text(
              "${AppLocalizations.of(context)!.approvalStatus}: ${expense['ApprovalStatus'] ?? ''}"),
          Text(
              "${AppLocalizations.of(context)!.expenseType}: ${expense['ExpenseType'] ?? ''}"),
          Text(
              "${AppLocalizations.of(context)!.expenseStatus}: ${expense['ExpenseStatus'] ?? ''}"),
          Text(
              "${AppLocalizations.of(context)!.currencyCode}: ${expense['Currency'] ?? ''}"),
          Text(
              "${AppLocalizations.of(context)!.reportingCurrency}: ${expense['Currency'] ?? ''}"),
          Text(
              "${AppLocalizations.of(context)!.projectId}: ${expense['ProjectId'] ?? ''}"),
          Text(
              "${AppLocalizations.of(context)!.receiptDate}: ${formatDate(expense['ReceiptDate'] as String?)}"),
          Text(
              "${AppLocalizations.of(context)!.source}: ${expense['Source'] ?? ''}"),

          const SizedBox(height: 20),
          Text(AppLocalizations.of(context)!.expenseReport,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),

          /// ExpenseTrans section (only if selected in local)
          if (selectedFromLocal.contains("ExpenseTrans")) ...[
            const SizedBox(height: 20),
            Text(AppLocalizations.of(context)!.expenseTrans,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ...expenseTrans.asMap().entries.map((entry) {
              final idx = entry.key;
              final trans = entry.value as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  "${AppLocalizations.of(context)!.lineNumber}: ${idx + 1}\n"
                  "${AppLocalizations.of(context)!.expenseCategoryId}: ${trans['ExpenseCategoryId'] ?? ''}\n"
                  "${AppLocalizations.of(context)!.uomId}: ${trans['UomId'] ?? ''}\n"
                  "${AppLocalizations.of(context)!.quantity}: ${trans['Quantity']}\n"
                  "${AppLocalizations.of(context)!.unitPriceTrans}: ${trans['UnitPriceTrans']}\n"
                  "${AppLocalizations.of(context)!.lineAmountTrans}: ${trans['LineAmountTrans']}",
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
            const SizedBox(height: 10),
            Text(
                "${AppLocalizations.of(context)!.totalTransAmount}: ${totalTransAmount.toStringAsFixed(2)}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],

          /// DocumentAttachments section
          if (selectedFromLocal.contains("DocumentAttachments") &&
              documentAttachments.isNotEmpty) ...[
            const SizedBox(height: 30),
            Text(AppLocalizations.of(context)!.documentAttachments,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ...documentAttachments.map((attachment) {
              final att = attachment as Map<String, dynamic>;
              final base64Data = att['base64Data'] as String? ?? '';
              final fileExtension = att['FileExtension'] as String? ?? '';
              final name = att['name'] as String? ?? '';
              final type = att['type'] as String? ?? '';

              if (isImageFile(fileExtension) && base64Data.isNotEmpty) {
                try {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Image.memory(
                        base64Decode(base64Data),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                } catch (e) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${AppLocalizations.of(context)!.name}: $name",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("${AppLocalizations.of(context)!.type}: $type"),
                      Text(
                          "${AppLocalizations.of(context)!.format}: $fileExtension"),
                      Text(
                          "${AppLocalizations.of(context)!.errorLoadingImage}: $e",
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 20),
                    ],
                  );
                }
              }
              // PDF Files
              else if (isPdfFile(fileExtension)) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${AppLocalizations.of(context)!.name}: $name",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("${AppLocalizations.of(context)!.type}: $type"),
                    Text(
                        "${AppLocalizations.of(context)!.format}: $fileExtension"),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.picture_as_pdf,
                            color: Colors.red, size: 40),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppLocalizations.of(context)!.pdfDocument,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              } else {
                // Other file types
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${AppLocalizations.of(context)!.name}: $name",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("${AppLocalizations.of(context)!.type}: $type"),
                    Text(
                        "${AppLocalizations.of(context)!.format}: $fileExtension"),
                    if (base64Data.isEmpty)
                      Text(AppLocalizations.of(context)!.noPreviewAvailable,
                          style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 20),
                  ],
                );
              }
            }).toList(),
          ],

          /// Activity log section
          if (selectedFromLocal.contains("ActivityLog") &&
              activityLog.isNotEmpty) ...[
            const SizedBox(height: 30),
            const Text("  ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ...activityLog.asMap().entries.map((logEntry) {
              final idx = logEntry.key;
              final item = logEntry.value;
              final isLast = idx == activityLog.length - 1;
              return _buildTimelineItem(item, isLast);
            }).toList(),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildExpenseContainerViewPdf(
    Map<String, dynamic> expense,
    List<String> selectedFromLocal,
    List<ExpenseHistory> activityLog,
    Uint8List? logoBytes,
  ) {
    final expenseTrans = (expense['ExpenseTrans'] as List<dynamic>? ?? []);
    final documentAttachments =
        (expense['DocumentAttachments'] as List<dynamic>? ?? []);

    double totalTransAmount = 0.0;
    for (var line in expenseTrans) {
      totalTransAmount += (line['LineAmountTrans'] as num?)?.toDouble() ?? 0.0;
    }

    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return '';
      try {
        final dt = DateTime.parse(dateStr);
        return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
      } catch (_) {
        return dateStr;
      }
    }

    // Function to check if file is an image
    bool isImageFile(String fileExtension) {
      final imageExtensions = [
        '.png',
        '.jpg',
        '.jpeg',
        '.gif',
        '.bmp',
        '.webp',
        '.tiff'
      ];
      return imageExtensions.contains(fileExtension.toLowerCase());
    }

    // Function to check if file is a PDF
    bool isPdfFile(String fileExtension) {
      return fileExtension.toLowerCase() == '.pdf';
    }

    final loc = AppLocalizations.of(context)!;
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        border: pw.Border.all(color: PdfColors.blue, width: 2),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          /// Top logo
          if (logoBytes != null)
            pw.Center(child: pw.Image(pw.MemoryImage(logoBytes), height: 94)),
          pw.SizedBox(height: 30),

          /// Summary fields

          pw.Text("${loc.expenseId}: ${expense['ExpenseId'] ?? ''}",
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
          pw.Text("${loc.employeeId}: ${expense['EmployeeId'] ?? ''}"),
          pw.Text(
              "${loc.totalAmountTrans}: ${expense['TotalAmountTrans'] ?? ''}"),
          pw.Text(
              "${loc.totalAmountReporting}: ${expense['TotalAmountReporting'] ?? ''}"),
          pw.Text("${loc.approvalStatus}: ${expense['ApprovalStatus'] ?? ''}"),
          pw.Text("${loc.expenseType}: ${expense['ExpenseType'] ?? ''}"),
          pw.Text("${loc.expenseStatus}: ${expense['ExpenseStatus'] ?? ''}"),
          pw.Text("${loc.currencyCode}: ${expense['Currency'] ?? ''}"),
          pw.Text("${loc.reportingCurrency}: ${expense['Currency'] ?? ''}"),
          pw.Text("${loc.projectId}: ${expense['ProjectId'] ?? ''}"),
          pw.Text(
              "${loc.receiptDate}: ${formatDate(expense['ReceiptDate'] as String?)}"),
          pw.Text("${loc.source}: ${expense['Source'] ?? ''}"),

          pw.SizedBox(height: 20),
          pw.Text(loc.expenseReport,
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 20)),

// ExpenseTrans
          if (selectedFromLocal.contains("ExpenseTrans")) ...[
            pw.SizedBox(height: 20),
            pw.Text(loc.expenseTrans,
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
            ...expenseTrans.asMap().entries.map((entry) {
              final idx = entry.key;
              final trans = entry.value as Map<String, dynamic>;
              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Text(
                  "${loc.lineNumber}: ${idx + 1}\n"
                  "${loc.expenseCategoryId}: ${trans['ExpenseCategoryId'] ?? ''}\n"
                  "${loc.uomId}: ${trans['UomId'] ?? ''}\n"
                  "${loc.quantity}: ${trans['Quantity']}\n"
                  "${loc.unitPriceTrans}: ${trans['UnitPriceTrans']}\n"
                  "${loc.lineAmountTrans}: ${trans['LineAmountTrans']}",
                  style: const pw.TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
            pw.SizedBox(height: 10),
            pw.Text(
                "${loc.totalTransAmount}: ${totalTransAmount.toStringAsFixed(2)}",
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
          ],

// Document Attachments
          if (selectedFromLocal.contains("DocumentAttachments") &&
              documentAttachments.isNotEmpty) ...[
            pw.SizedBox(height: 30),
            pw.Text(loc.documentAttachments,
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
            ...documentAttachments.map((attachment) {
              final att = attachment as Map<String, dynamic>;
              final base64Data = att['base64Data'] as String? ?? '';
              final fileExtension = att['FileExtension'] as String? ?? '';
              final name = att['name'] as String? ?? '';
              final type = att['type'] as String? ?? '';

              if (isImageFile(fileExtension) && base64Data.isNotEmpty) {
                try {
                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(height: 10),
                      pw.Image(
                        pw.MemoryImage(base64Decode(base64Data)),
                        height: 200,
                      ),
                      pw.SizedBox(height: 20),
                    ],
                  );
                } catch (e) {
                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("${loc.name}: $name",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text("${loc.type}: $type"),
                      pw.Text("${loc.format}: $fileExtension"),
                      pw.Text("${loc.errorLoadingImage}: $e"),
                      pw.SizedBox(height: 20),
                    ],
                  );
                }
              } else if (isPdfFile(fileExtension)) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("${loc.name}: $name",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text("${loc.type}: $type"),
                    pw.Text("${loc.format}: $fileExtension"),
                    pw.Text(loc.pdfDocument),
                    pw.SizedBox(height: 20),
                  ],
                );
              } else {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("${loc.name}: $name",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text("${loc.type}: $type"),
                    pw.Text("${loc.format}: $fileExtension"),
                    pw.SizedBox(height: 20),
                  ],
                );
              }
            }).toList(),
          ],

          /// Activity log section
          if (selectedFromLocal.contains("ActivityLog") &&
              activityLog.isNotEmpty) ...[
            pw.SizedBox(height: 30),
            pw.Text("Activity Log",
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
            ...activityLog.asMap().entries.map((logEntry) {
              final idx = logEntry.key;
              final item = logEntry.value;
              final isLast = idx == activityLog.length - 1;
              return _buildTimelineItemPdf(item, isLast);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineItem(ExpenseHistory item, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.blue),
            if (!isLast)
              Container(width: 2, height: 100, color: Colors.blue.shade300),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.eventType,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(item.notes),
                  const SizedBox(height: 6),
                  Text(
                    '${AppLocalizations.of(context)!.submittedOn} ${DateFormat('dd/MM/yyyy').format(item.createdDate)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
