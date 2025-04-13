import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:paisa/features/account/domain/entities/account_entity.dart';
import 'package:paisa/features/transaction/domain/entities/transaction_entity.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:paisa/core/common.dart';
import 'package:paisa/core/common_enum.dart';
import 'package:paisa/config/routes.dart';
import 'package:paisa/core/theme/custom_color.dart';
import 'package:paisa/core/widgets/paisa_widget.dart';

class AccountCardV2 extends StatefulWidget {
  const AccountCardV2({
    super.key,
    required this.account,
    required this.transactions,
  });

  final AccountEntity account;
  final List<TransactionEntity> transactions;

  @override
  State<AccountCardV2> createState() => _AccountCardV2State();
}

class _AccountCardV2State extends State<AccountCardV2>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  bool hidden = true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ColorScheme colorScheme =
        ColorScheme.fromSeed(seedColor: Color(widget.account.color));
    final Color color = colorScheme.primaryContainer;
    final Color onPrimary = colorScheme.onPrimaryContainer;

    final double totalExpense =
        widget.transactions.totalAccountExpense(widget.account.superId!);
    final double totalIncome =
        widget.transactions.totalAccountIncome(widget.account.superId!);
    final double balance =
        ((totalIncome - totalExpense) + widget.account.amount);

    final String income = totalIncome.toFormateCurrency(context);
    final String expense = totalExpense.toFormateCurrency(context);
    final String totalBalance = balance.toFormateCurrency(context);
    return Container(
      padding: const EdgeInsets.all(8.0),
      height: 242,
      child: PaisaFilledCard(
        color: color,
        child: InkWell(
          onTap: () async {
            TransactionsByAccountPageData(id: widget.account.superId!)
                .push(context);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                horizontalTitleGap: 0,
                trailing: Icon(
                  widget.account.cardType.icon,
                  color: onPrimary,
                ),
                title: Text(
                  widget.account.name,
                  style: context.bodyMedium?.copyWith(
                    color: onPrimary,
                  ),
                ),
                subtitle: Text(
                  widget.account.bankName,
                  style: context.bodyMedium?.copyWith(
                    color: onPrimary.withOpacity(0.5),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    hidden = !hidden;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    hidden ? "*****" : totalBalance,
                    style: context.headlineSmall?.copyWith(
                      color: onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  context.loc.thisMonth,
                  style: context.titleMedium?.copyWith(
                    color: onPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ThisMonthTransactionWidget(
                      type: TransactionType.income,
                      content: income,
                      color: onPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ThisMonthTransactionWidget(
                      type: TransactionType.expense,
                      color: onPrimary,
                      content: expense,
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class ThisMonthTransactionWidget extends StatelessWidget {
  const ThisMonthTransactionWidget({
    super.key,
    required this.type,
    required this.content,
    required this.color,
  });

  final Color color;
  final String content;
  final TransactionType type;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: type == TransactionType.income ? '▼' : '▲',
              style: context.bodyMedium?.copyWith(
                color: type == TransactionType.income
                    ? Theme.of(context).extension<CustomColors>()!.green
                    : Theme.of(context).extension<CustomColors>()!.red,
              ),
              children: [
                TextSpan(
                  text: type == TransactionType.expense
                      ? context.loc.expense
                      : context.loc.income,
                  style: context.bodyMedium?.copyWith(
                    color: color.withOpacity(0.85),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: context.titleMedium?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class AccountCard extends StatelessWidget {
  const AccountCard({
    super.key,
    this.onDelete,
    this.onTap,
    required this.account,
    required this.transactions,
  });

  final AccountEntity account;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final List<TransactionEntity> transactions;

  @override
  Widget build(BuildContext context) {
    final String bankName = account.bankName;
    final String cardHolder = account.name;
    final AccountType cardType = account.cardType;
    final double totalExpense =
        transactions.totalAccountExpense(account.superId!);
    final double totalIncome =
        transactions.totalAccountIncome(account.superId!);
    final double balance = ((totalIncome - totalExpense) + account.amount);
    final String income = totalIncome.toFormateCurrency(context),
        expense = totalExpense.toFormateCurrency(context),
        totalBalance = balance.toFormateCurrency(context);
    return ScreenTypeLayout.builder(
      mobile: (p0) => MobileAccountCard(
        bankName: bankName,
        cardHolder: cardHolder,
        totalBalance: totalBalance,
        cardType: cardType,
        onDelete: onDelete,
        onTap: onTap,
        expense: expense,
        income: income,
      ),
      tablet: (p0) => TabletAccountCard(
        bankName: bankName,
        cardHolder: cardHolder,
        cardNumber: totalBalance,
        cardType: cardType,
        onDelete: onDelete,
        onTap: onTap,
        expense: expense,
        income: income,
      ),
      desktop: (p0) => DesktopAccountCard(
        bankName: bankName,
        cardHolder: cardHolder,
        cardNumber: totalBalance,
        cardType: cardType,
        onDelete: onDelete,
        onTap: onTap,
        expense: expense,
        income: income,
      ),
    );
  }
}

class MobileAccountCard extends StatelessWidget {
  const MobileAccountCard({
    super.key,
    required this.totalBalance,
    required this.cardHolder,
    required this.bankName,
    required this.cardType,
    this.onDelete,
    this.onTap,
    required this.income,
    required this.expense,
  });

  final String bankName;
  final String cardHolder;
  final AccountType cardType;
  final String income, expense;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final String totalBalance;

  @override
  GestureDetector build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GlassmorphicContainer(
          height: 256.h,
          width: MediaQuery.of(context).size.width,
          borderRadius: 24,
          blur: 25,
          alignment: Alignment.bottomCenter,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.titleMedium!.color!.withOpacity(0.1),
              context.titleMedium!.color!.withOpacity(0.05),
            ],
            stops: const [0.1, 1],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.titleMedium!.color!.withOpacity(0.5),
              context.titleMedium!.color!.withOpacity(0.5),
            ],
          ),
          border: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ListTile(
                minVerticalPadding: 10,
                title: Text(bankName),
                subtitle: Text(cardHolder),
                leading: Icon(cardType.icon),
                trailing: onDelete != null
                    ? GestureDetector(
                        onTap: onDelete,
                        child: Icon(
                          Icons.delete,
                          color: context.onSurface,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              ListTile(
                minVerticalPadding: 10,
                title: Text(
                  context.loc.totalBalance,
                  style: context.bodyMedium,
                ),
                subtitle: Text(
                  totalBalance,
                  style: context.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: AccountSummaryTail(
                      title: context.loc.income,
                      subtitle: income,
                    ),
                  ),
                  Expanded(
                    child: AccountSummaryTail(
                      title: context.loc.expense,
                      subtitle: expense,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AccountSummaryTail extends StatelessWidget {
  const AccountSummaryTail({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String subtitle;
  final String title;

  @override
  ListTile build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(
        title,
        style: context.bodyMedium?.copyWith(
          color: Theme.of(context)
              .colorScheme
              .onSecondaryContainer
              .withOpacity(0.75),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: context.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class TabletAccountCard extends StatelessWidget {
  const TabletAccountCard({
    super.key,
    required this.cardNumber,
    required this.cardHolder,
    required this.bankName,
    required this.cardType,
    this.onDelete,
    this.onTap,
    required this.income,
    required this.expense,
  });

  final String bankName;
  final String cardHolder;
  final String cardNumber;
  final AccountType cardType;
  final String income, expense;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  @override
  GestureDetector build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GlassmorphicContainer(
          height: 260,
          width: MediaQuery.of(context).size.width / 2,
          borderRadius: 24,
          blur: 20,
          alignment: Alignment.bottomCenter,
          border: 2,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.titleMedium!.color!.withOpacity(0.1),
              context.titleMedium!.color!.withOpacity(0.05),
            ],
            stops: const [0.1, 1],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.titleMedium!.color!.withOpacity(0.5),
              context.titleMedium!.color!.withOpacity(0.5),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ListTile(
                title: Text(bankName.toUpperCase()),
                subtitle: Text(cardHolder.toUpperCase()),
                leading: Icon(cardType.icon),
                trailing: onDelete != null
                    ? GestureDetector(
                        onTap: onDelete,
                        child: Icon(
                          Icons.delete,
                          color: context.onSurface,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.loc.totalBalance,
                          style: context.titleSmall,
                        ),
                        Text(
                          cardNumber,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  bottom: 16.0,
                  right: 16.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.loc.income,
                            style: context.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer
                                  .withOpacity(0.75),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            income,
                            style: context.titleMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.loc.expense,
                            style: context.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer
                                  .withOpacity(0.75),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            expense,
                            style: context.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DesktopAccountCard extends StatelessWidget {
  const DesktopAccountCard({
    super.key,
    required this.cardNumber,
    required this.cardHolder,
    required this.bankName,
    required this.cardType,
    this.onDelete,
    this.onTap,
    required this.income,
    required this.expense,
  });

  final String bankName;
  final String cardHolder;
  final String cardNumber;
  final AccountType cardType;
  final String income, expense;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  @override
  GestureDetector build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GlassmorphicContainer(
          height: 240,
          width: MediaQuery.of(context).size.width / 2,
          borderRadius: 24,
          blur: 10,
          alignment: Alignment.bottomCenter,
          border: 2,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.titleMedium!.color!.withOpacity(0.1),
              context.titleMedium!.color!.withOpacity(0.05),
            ],
            stops: const [0.1, 1],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.titleMedium!.color!.withOpacity(0.5),
              context.titleMedium!.color!.withOpacity(0.5),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ListTile(
                horizontalTitleGap: 0,
                title: Text(bankName.toUpperCase()),
                subtitle: Text(cardHolder.toUpperCase()),
                leading: Icon(cardType.icon),
                trailing: onDelete != null
                    ? GestureDetector(
                        onTap: onDelete,
                        child: Icon(
                          Icons.delete,
                          color: context.onSurface,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.loc.totalBalance),
                        Text(
                          cardNumber,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  bottom: 16.0,
                  right: 16.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.loc.income,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer
                                      .withOpacity(0.75),
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            income,
                            style: context.titleSmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.loc.expense,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer
                                      .withOpacity(0.75),
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            expense,
                            style: context.titleSmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
