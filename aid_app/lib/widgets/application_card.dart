import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../models/application_attachment.dart';
import '../utils/app_colors.dart';

class ApplicationCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String status;
  final String createdDate;
  final VoidCallback onExpand;
  final bool isExpanded;
  final String? amount;
  final String category;
  final Function() onApprove;
  final Function() onReject;
  final List<ApplicationAttachment> attachments;
  final String? signatureData;

  const ApplicationCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.createdDate,
    required this.onExpand,
    this.isExpanded = false,
    this.amount,
    required this.category,
    required this.onApprove,
    required this.onReject,
    this.attachments = const [],
    this.signatureData,
  }) : super(key: key);

  @override
  State<ApplicationCard> createState() => _ApplicationCardState();
}

class _ApplicationCardState extends State<ApplicationCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _sizeAnimation = CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn);
    if (widget.isExpanded) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(ApplicationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      widget.isExpanded ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getStatusColor() {
    switch (widget.status.toLowerCase()) {
      case 'approved': return AppColors.success;
      case 'rejected': return AppColors.error;
      case 'inreview': return AppColors.warning;
      default: return AppColors.cyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.white.withOpacity(0.2)),
            ),
            child: InkWell(
              onTap: widget.onExpand,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(statusColor),
                    const SizedBox(height: 12),
                    _buildFooter(),
                    if (widget.attachments.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _buildAttachmentBadges(),
                    ],
                    _buildExpandableContent(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentBadges() {
    final preview = widget.attachments.take(3).toList();
    final overflow = widget.attachments.length - preview.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Прикрепленные документы',
          style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            ...preview.map(
              (attachment) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.attachment_rounded, size: 14, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      attachment.name,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            if (overflow > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Text(
                  '+ ещё $overflow',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader(Color statusColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.status,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.createdDate, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5))),
        if (widget.amount != null)
          Text(widget.amount!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.success)),
        Icon(
          widget.isExpanded ? Icons.expand_less : Icons.expand_more,
          color: Colors.white.withOpacity(0.7),
        )
      ],
    );
  }

  Widget _buildExpandableContent() {
    return SizeTransition(
      sizeFactor: _sizeAnimation,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(color: AppColors.lightGray, thickness: 0.2),
            const SizedBox(height: 16),
            Text(
              'Категория обращения',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              widget.category,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            if (widget.attachments.isNotEmpty) ...[
              _buildAttachmentsSection(),
              const SizedBox(height: 20),
            ],
            if (_hasSignature) ...[
              _buildSignaturePreview(),
              const SizedBox(height: 20),
            ],
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onReject,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                    child: const Text('Отклонить'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onApprove,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                    child: const Text('Одобрить'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Прикрепленные документы',
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
        ),
        const SizedBox(height: 12),
        ...widget.attachments.map((attachment) {
          final metaParts = <String>[];
          if ((attachment.mimeType ?? '').isNotEmpty) {
            metaParts.add(attachment.mimeType!);
          }
          final sizeBytes = _estimateAttachmentSize(attachment);
          if (sizeBytes != null) {
            metaParts.add(_formatFileSize(sizeBytes));
          }
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.insert_drive_file_outlined, color: AppColors.cyan, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attachment.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (metaParts.isNotEmpty)
                        Text(
                          metaParts.join(' • '),
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _isSaving ? null : () => _saveAttachment(attachment),
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Скачать'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
  bool get _hasSignature => (widget.signatureData ?? '').isNotEmpty;

  Widget _buildSignaturePreview() {
    final signatureBytes = _decodeSignature();
    if (signatureBytes == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Подпись студента',
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
        ),
        const SizedBox(height: 12),
        Container(
          height: 160,
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Center(
              child: Image.memory(
                signatureBytes,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveAttachment(ApplicationAttachment attachment) async {
    setState(() => _isSaving = true);
    try {
      final directory = await _resolveDownloadDirectory();
      final sanitizedName =
          attachment.name.isEmpty ? 'attachment_${DateTime.now().millisecondsSinceEpoch}' : attachment.name;
      final file = File('${directory.path}${Platform.pathSeparator}$sanitizedName');
      await file.writeAsBytes(attachment.bytes, flush: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Файл "${attachment.name}" успешно сохранен в ${directory.path}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось сохранить файл "${attachment.name}": $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<Directory> _resolveDownloadDirectory() async {
    try {
      final downloads = await getDownloadsDirectory();
      if (downloads != null) return downloads;
    } catch (_) {}
    return getApplicationDocumentsDirectory();
  }

  Uint8List? _decodeSignature() {
    final raw = widget.signatureData;
    if (raw == null || raw.isEmpty) return null;
    try {
      return base64Decode(raw);
    } catch (_) {
      return null;
    }
  }

  int? _estimateAttachmentSize(ApplicationAttachment attachment) {
    if (attachment.dataBase64 != null) {
      // Base64 string length is about 4/3 of the original binary size
      // (plus padding, which we ignore for estimation)
      return (attachment.dataBase64!.length * 0.75).round();
    }
    return null;
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }
}
