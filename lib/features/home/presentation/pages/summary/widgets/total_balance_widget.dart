import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:paisa/core/common.dart';

class TotalBalanceWidget extends StatefulWidget {
  const TotalBalanceWidget({
    super.key,
    required this.title,
    required this.amount,
  });

  final double amount;
  final String title;

  @override
  State<TotalBalanceWidget> createState() => _TotalBalanceWidgetState();
}

class _TotalBalanceWidgetState extends State<TotalBalanceWidget> {
  bool hidden = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: context.titleMedium?.copyWith(
            color: context.onPrimaryContainer.withOpacity(0.85),
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: () {
            setState(() {
              hidden = !hidden;
            });
          },
          child: Text(
            hidden ? "*****" : widget.amount.toFormateCurrency(context),
            style: context.headlineLarge?.copyWith(
              color: context.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
