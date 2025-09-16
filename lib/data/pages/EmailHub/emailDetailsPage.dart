import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:digi_xpense/core/comman/widgets/pageLoaders.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:digi_xpense/data/models.dart';
import 'package:open_filex/open_filex.dart';

import '../../../l10n/app_localizations.dart';

class EmailDetailPage extends StatefulWidget {
  final ForwardedEmail email;

  const EmailDetailPage({Key? key, required this.email}) : super(key: key);

  @override
  State<EmailDetailPage> createState() => _EmailDetailPageState();
}

class _EmailDetailPageState extends State<EmailDetailPage> {
  final RxList<MailAttachment> attachments = <MailAttachment>[].obs;
  final controller = Get.put(Controller());

  @override
  void initState() {
    super.initState();
    if (widget.email.documentAttachments != null &&
        widget.email.documentAttachments.isNotEmpty) {
      attachments.assignAll(widget.email.documentAttachments);
    }
  }

  bool _isImageFile(String fileExtension) {
    if (fileExtension.isEmpty) return false;
    final ext = fileExtension.toLowerCase();
    return ext == '.png' ||
        ext == '.jpg' ||
        ext == '.jpeg' ||
        ext == '.gif' ||
        ext == '.webp';
  }

  Future<bool> _validateImageBytes(Uint8List bytes) async {
    try {
      if (bytes.isEmpty || bytes.lengthInBytes < 8) return false;

      bool isPng = bytes.length > 8 &&
          bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47;
      bool isJpeg = bytes.length > 2 && bytes[0] == 0xFF && bytes[1] == 0xD8;
      bool isWebP = bytes.length > 12 &&
          bytes[0] == 0x52 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x46 &&
          bytes[8] == 0x57 &&
          bytes[9] == 0x45 &&
          bytes[10] == 0x42 &&
          bytes[11] == 0x50;

      if (!isPng && !isJpeg && !isWebP) return false;

      await ui.instantiateImageCodec(bytes);
      return true;
    } catch (e) {
      debugPrint('Image validation failed: $e');
      return false;
    }
  }

  Future<Uint8List?> _decodeImageData(String base64Data) async {
    try {
      String base64String =
          base64Data.replaceAll(RegExp(r'^data:image/[^;]+;base64,'), '');
      base64String = base64String.replaceAll(RegExp(r'\s'), '');

      final padding = base64String.length % 4;
      if (padding != 0) {
        base64String += '=' * (4 - padding);
      }

      if (!RegExp(r'^[a-zA-Z0-9+/]+={0,2}$').hasMatch(base64String)) {
        return null;
      }

      final bytes = base64Decode(base64String);
      if (bytes.isEmpty || bytes.lengthInBytes < 8) return null;

      return bytes;
    } catch (e) {
      debugPrint('Base64 decode error: $e');
      return null;
    }
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildMemoryImage(Uint8List bytes) {
    return FutureBuilder<bool>(
      future: _validateImageBytes(bytes),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        if (snapshot.hasError || !snapshot.data!) {
          return _buildAttachmentErrorWidget('Invalid image');
        }

        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          frameBuilder: (context, child, frame, _) {
            return frame == null ? _buildLoadingWidget() : child;
          },
          errorBuilder: (_, __, ___) =>
              _buildAttachmentErrorWidget('Display error'),
        );
      },
    );
  }

  void _showFullImage(BuildContext context, Uint8List bytes) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: FutureBuilder<bool>(
          future: _validateImageBytes(bytes),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.data!) {
              return Center(
                  child: _buildAttachmentErrorWidget('Cannot display image'));
            }

            return InteractiveViewer(
              child: Image.memory(
                bytes,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Center(
                  child: _buildAttachmentErrorWidget('Display error'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openPdf(BuildContext context, MailAttachment attachment) async {
    try {
      final bytes = base64Decode(attachment.base64Data);
      final tempDir = await getTemporaryDirectory();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${attachment.name}';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      final result = await OpenFilex.open(file.path);

      if (result.type != ResultType.done) {
        if (await canLaunch(file.path)) {
          await launch(file.path);
        } else {
          _showPdfErrorDialog(context);
        }
      }
    } catch (e) {
      debugPrint('PDF opening error: $e');
      _showPdfErrorDialog(context);
    }
  }

  void _showPdfErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:  Text( AppLocalizations.of(context)!.pdfViewerNotFound),
        content:  Text( AppLocalizations.of(context)!.noAppToViewPdf),
        actions: [
          TextButton(
            child:  Text( AppLocalizations.of(context)!.ok),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child:  Text( AppLocalizations.of(context)!.getPdfReader),
            onPressed: () => _launchPdfReaderStore(context),
          ),
        ],
      ),
    );
  }

  Future<void> _launchPdfReaderStore(BuildContext context) async {
    const playStoreUrl = 'https://play.google.com/store/search?q=pdf%20reader';
    if (await canLaunch(playStoreUrl)) {
      await launch(playStoreUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open app store')),
      );
    }
  }

  Widget _buildPdfAttachment(BuildContext context, MailAttachment attachment) {
    return GestureDetector(
      onTap: () => _openPdf(context, attachment),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf, size: 30, color: Colors.red),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                attachment.name,
                style: const TextStyle(fontSize: 10),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentErrorWidget(String error) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 24),
          const SizedBox(height: 4),
          Text(
            error.length > 15 ? '${error.substring(0, 15)}...' : error,
            style: const TextStyle(fontSize: 10, color: Colors.red),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildNonImageAttachment(MailAttachment attachment) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.insert_drive_file, size: 30, color: Colors.grey),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              attachment.name,
              style: const TextStyle(fontSize: 10),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(BuildContext context, Uint8List bytes, String name) {
    return GestureDetector(
      onTap: () => _showFullImage(context, bytes),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildMemoryImage(bytes),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                name,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentItem(BuildContext context, MailAttachment attachment) {
    final ext = attachment.fileExtension.toLowerCase();

    if (ext == '.pdf') {
      return _buildPdfAttachment(context, attachment);
    } else if (_isImageFile(ext)) {
      return FutureBuilder<Uint8List?>(
        future: _decodeImageData(attachment.base64Data),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingWidget();
          }
          if (snapshot.hasError || snapshot.data == null) {
            return _buildAttachmentErrorWidget('Image error');
          }
          return _buildImageWidget(context, snapshot.data!, attachment.name);
        },
      );
    } else {
      return _buildNonImageAttachment(attachment);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: const Color.fromARGB(255, 11, 1, 61),
        appBar: AppBar(
          // backgroundColor: Colors.transparent,
          title:  Text(
             AppLocalizations.of(context)!.preview,
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
                icon: const Icon(Icons.share_rounded), onPressed: () => {
                    controller.fetchSecificExpenseItem(
                                    context, widget.email.refRecId,true)
                }),
          ],
        ),
        body: Obx(() {
          return controller.isLoadingGE2.value
              ? const SkeletonLoaderPage()
              : Card(
                 
                  
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // Navigator.pushNamed(context, AppRoutes.formCashAdvanceRequest);
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: widget.email.emailStatus ==
                                          "SuccessfullyProcessed"
                                      ? Colors.green
                                      : widget.email.emailStatus == "InProgress"
                                          ? Colors.red
                                          : widget.email.emailStatus == "Unprocessed"
                                              ? Colors.orange
                                              : Colors.blue.shade800,
                                  shadowColor: Colors.black.withOpacity(0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                                child: Text(
                                  widget.email.emailStatus == "SuccessfullyProcessed"
                                      ? "Processed"
                                      : widget.email.emailStatus,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ]),
                        const SizedBox(height: 10),
                        Text(
                          "${AppLocalizations.of(context)!.from}${widget.email.forwardedEmail}",
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.email.subject,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        if (widget.email.emailBody.isNotEmpty)
                          Html(
                            data: widget.email.emailBody,
                            style: {
                              "body": Style(
                                fontSize: FontSize(16),
                                lineHeight: LineHeight(1.5),
                              ),
                            },
                          ),
                        Obx(() {
                          if (attachments.isEmpty) return const SizedBox();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                               Text(
                               AppLocalizations.of(context)!.attachments,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: attachments
                                    .map((attachment) => _buildAttachmentItem(
                                        context, attachment))
                                    .toList(),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ));
        }));
  }
}
