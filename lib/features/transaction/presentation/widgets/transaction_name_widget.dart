import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:paisa/core/common.dart';
import 'package:paisa/core/common_enum.dart';
import 'package:paisa/core/widgets/paisa_widget.dart';
import 'package:paisa/features/transaction/data/model/transaction_model.dart';
import 'package:paisa/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:paisa/main.dart';

class TransactionNameWidget extends StatelessWidget {
  const TransactionNameWidget({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      buildWhen: (oldState, newState) => newState is ChangeTransactionTypeState,
      builder: (context, state) {
        String hintName = TransactionType.expense.hintName(context);
        if (state is ChangeTransactionTypeState) {
          hintName = state.transactionType.hintName(context);
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: PaisaTextFormField(
            maxLines: 1,
            controller: controller,
            hintText: hintName,
            inputFormatters: [
              FilteringTextInputFormatter.singleLineFormatter,
            ],
            validator: (value) {
              if (value!.isNotEmpty) {
                return null;
              } else {
                return context.loc.validName;
              }
            },
            onChanged: (value) =>
                context.read<TransactionBloc>().expenseName = value,
          ),
        );
      },
    );
  }
}

class TransactionNameWidgetV2 extends StatelessWidget {
  const TransactionNameWidgetV2({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      buildWhen: (oldState, newState) => newState is ChangeTransactionTypeState,
      builder: (context, state) {
        String hintName = TransactionType.expense.hintName(context);
        if (state is ChangeTransactionTypeState) {
          hintName = state.transactionType.hintName(context);
        }
        return ValueListenableBuilder(
          valueListenable: getIt<Box<TransactionModel>>().listenable(),
          builder: (context, value, __) {
            final Set<String> names = value.values.map((e) => e.name).toSet();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: NameAutoSuggest(
                names: names,
                controller: controller,
                hintText: hintName,
              ),
            );
          },
        );
      },
    );
  }
}

class NameAutoSuggest extends StatefulWidget {
  const NameAutoSuggest({
    super.key,
    required this.names,
    required this.controller,
    required this.hintText,
  });

  final TextEditingController controller;
  final String hintText;
  final Set<String> names;

  @override
  State<NameAutoSuggest> createState() => _NameAutoSuggestState();
}

class _NameAutoSuggestState extends State<NameAutoSuggest> {
  List<String> _suggestions = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PaisaTextFormField(
          controller: widget.controller,
          maxLines: 1,
          hintText: widget.hintText,
          inputFormatters: [
            FilteringTextInputFormatter.singleLineFormatter,
          ],
          validator: (value) {
            if (value!.isNotEmpty) {
              return null;
            } else {
              return context.loc.validName;
            }
          },
          onChanged: (value) {
            setState(() {
              _suggestions = widget.names
                  .where((name) =>
                      name.toLowerCase().contains(value.toLowerCase()))
                  .toList();
            });
            context.read<TransactionBloc>().expenseName = value;
          },
        ),
        if (_suggestions.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Container(
            constraints: BoxConstraints(
              maxHeight: 200.h,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: context.primary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_suggestions[index]),
                  onTap: () {
                    setState(() {
                      widget.controller.text = _suggestions[index];
                      context.read<TransactionBloc>().expenseName =
                          _suggestions[index];
                      _suggestions.clear();
                    });
                  },
                );
              },
            ),
          ),
        ]
      ],
    );
  }
}
