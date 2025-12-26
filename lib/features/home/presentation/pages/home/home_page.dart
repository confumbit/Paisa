import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:home_widget/home_widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:paisa/core/common.dart';
import 'package:paisa/core/widgets/mult_value_listenable_builder.dart';
import 'package:paisa/features/account/data/model/account_model.dart';
import 'package:paisa/features/account/domain/entities/account_entity.dart';
import 'package:paisa/features/category/data/model/category_model.dart';
import 'package:paisa/features/category/domain/entities/category.dart';
import 'package:paisa/features/home/presentation/controller/summary_controller.dart';
import 'package:paisa/features/transaction/data/model/transaction_model.dart';
import 'package:paisa/features/transaction/domain/entities/transaction_entity.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:paisa/core/common_enum.dart';
import 'package:paisa/core/widgets/paisa_widget.dart';
import 'package:paisa/features/home/presentation/pages/home/home_cubit.dart';
import 'package:paisa/features/home/presentation/widgets/home_desktop_widget.dart';
import 'package:paisa/features/home/presentation/widgets/home_mobile_widget.dart';
import 'package:paisa/features/home/presentation/widgets/home_tablet_widget.dart';
import 'package:paisa/features/home/presentation/widgets/variable_size_fab.dart';
import 'package:paisa/main.dart';

final destinations = [
  Destination(
    pageType: PageType.home,
    icon: const Icon(Icons.home_outlined),
    selectedIcon: const Icon(Icons.home_rounded),
  ),
  Destination(
    pageType: PageType.accounts,
    icon: const Icon(Icons.credit_card_outlined),
    selectedIcon: const Icon(Icons.credit_card),
  ),
  Destination(
    pageType: PageType.debts,
    icon: Icon(MdiIcons.accountCashOutline),
    selectedIcon: Icon(MdiIcons.accountCash),
  ),
  Destination(
    pageType: PageType.overview,
    icon: Icon(MdiIcons.sortVariant),
    selectedIcon: Icon(MdiIcons.sortVariant),
  ),
  Destination(
    pageType: PageType.category,
    icon: const Icon(Icons.category_outlined),
    selectedIcon: const Icon(Icons.category),
  ),
  Destination(
    pageType: PageType.budget,
    icon: Icon(MdiIcons.timetable),
    selectedIcon: Icon(MdiIcons.timetable),
  ),
  Destination(
    pageType: PageType.recurring,
    icon: Icon(MdiIcons.cashSync),
    selectedIcon: Icon(MdiIcons.cashSync),
  ),
  if (kDebugMode)
    Destination(
      pageType: PageType.goals,
      icon: Icon(MdiIcons.cashSync),
      selectedIcon: Icon(MdiIcons.cashSync),
    ),
];

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Widget actionButton = HomeFloatingActionButtonWidget(
      summaryController: getIt<SummaryController>(),
    );
    return MultiValueListenableBuilder(
      valueListenable: [
        getIt<Box<TransactionModel>>().listenable(),
        getIt<Box<AccountModel>>().listenable(),
        getIt<Box<CategoryModel>>().listenable()
      ],
      builder: (BuildContext context, List<dynamic> values, Widget? child) {
        final List<TransactionModel> transactionModels =
            values[0].values.toList();
        final List<AccountModel> accountModels = values[1].values.toList();
        final List<CategoryModel> categoryModels = values[2].values.toList();
        final List<TransactionEntity> transactions =
            transactionModels.excludeAccounts();
        final List<AccountEntity> accounts = accountModels.toEntities();
        final List<CategoryEntity> categories = categoryModels.toEntities();

        _updateHomeScreenWidget(
          context,
          transactions: transactions,
          accounts: accounts,
        );

        return MultiProvider(
          providers: [
            Provider.value(value: transactions),
            Provider.value(value: accounts),
            Provider.value(value: categories),
          ],
          child: PaisaAnnotatedRegionWidget(
            color: context.surfaceContainer,
            child: PopScope(
              canPop: context.read<HomeCubit>().state.index != 0,
              onPopInvoked: (didPop) {
                if (didPop) {
                  context.read<HomeCubit>().setCurrentIndex(0);
                }
              },
              child: ScreenTypeLayout.builder(
                mobile: (p0) => HomeMobileWidget(
                  floatingActionButton: actionButton,
                  destinations: destinations,
                ),
                tablet: (p0) => HomeTabletWidget(
                  floatingActionButton: actionButton,
                  destinations: destinations,
                ),
                desktop: (p0) => HomeDesktopWidget(
                  floatingActionButton: actionButton,
                  destinations: destinations,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class Destination {
  Destination({
    required this.pageType,
    required this.icon,
    required this.selectedIcon,
  });

  final Icon icon;
  final PageType pageType;
  final Icon selectedIcon;
}

Future<void> _updateHomeScreenWidget(
  BuildContext context, {
  required List<TransactionEntity> transactions,
  required List<AccountEntity> accounts,
}) async {
  final int primaryContainer =
      Theme.of(context).colorScheme.primaryContainer.value;
  final int bgColor = Color(primaryContainer).value;

  final double totalExpenses = transactions.totalExpense;
  final double totalIncome = transactions.totalIncome;
  final double totalInitialBalance = accounts.fold(
      0, (previousValue, element) => previousValue + element.amount);
  final double totalExpenseBalance =
      totalIncome - totalExpenses + totalInitialBalance;
  final String totalExpensesFormatted =
      totalExpenses.toFormateCurrency(context);
  final String totalIncomeFormatted = totalIncome.toFormateCurrency(context);
  final String totalExpenseBalanceFormatted =
      totalExpenseBalance.toFormateCurrency(context);
  await HomeWidget.saveWidgetData('bgColor', chopToJavaInt(bgColor));

  if (context.mounted) {
    final Widget lineChart = Material(
      color: context.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  Text(
                    'Total Balance',
                    style: GoogleFonts.outfit(fontSize: 16),
                  ),
                  Text(
                    totalExpenseBalanceFormatted,
                    style: GoogleFonts.outfit(fontSize: 24.sp),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.green.withOpacity(0.24),
                        ),
                        padding: EdgeInsets.all(8.0.w),
                        margin: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.south_west,
                          color: Colors.green,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Income',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              totalIncomeFormatted,
                              style: GoogleFonts.outfit(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.red.withOpacity(0.24),
                        ),
                        padding: EdgeInsets.all(8.0.w),
                        margin: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.north_east,
                          color: Colors.red,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Expense',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                            Text(
                              totalExpensesFormatted,
                              style: GoogleFonts.outfit(fontSize: 18.sp),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    await HomeWidget.renderFlutterWidget(
      lineChart,
      key: 'lineChart',
      logicalSize: const Size(520, 550),
    );
    await HomeWidget.updateWidget(
      name: 'Paisa',
      iOSName: 'PaisaHomeWidgetReceiver',
      androidName: 'PaisaHomeWidgetReceiver',
      qualifiedAndroidName: 'dev.hemanths.paisa.glance.PaisaHomeWidgetReceiver',
    );
  }
}

int chopToJavaInt(int result) {
  while (result > pow(2, 31)) {
    result = result - pow(2, 32).toInt();
  }
  return result;
}
