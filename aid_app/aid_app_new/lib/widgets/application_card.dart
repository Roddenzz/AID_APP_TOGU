import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'gradient_button.dart';

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
  }) : super(key: key);

  @override
  State<ApplicationCard> createState() => _ApplicationCardState();
}

class _ApplicationCardState extends State<ApplicationCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;

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
            Text('Категория: ${widget.category}', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            const Text('Прикрепленные файлы: (3)', style: const TextStyle(color: Colors.white)), // Placeholder
            const SizedBox(height: 24),
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
}
