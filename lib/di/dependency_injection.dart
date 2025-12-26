import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_widget/home_widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:paisa/core/common_enum.dart';
import 'package:paisa/features/account/data/data_sources/account_data_source.dart';
import 'package:paisa/features/account/data/model/account_model.dart';
import 'package:paisa/features/category/data/data_sources/category_data_source.dart';
import 'package:paisa/features/category/data/model/category_model.dart';
import 'package:paisa/features/debit/data/data_sources/debit_local_data_source_impl.dart';
import 'package:paisa/features/debit/data/models/debit_model.dart';
import 'package:paisa/features/transaction/data/data_sources/local/transaction_data_manager.dart';
import 'package:paisa/features/transaction/data/model/transaction_model.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:injectable/injectable.dart';
import 'package:paisa/main.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:paisa/config/routes.dart';
import 'package:paisa/di/dependency_injection.config.dart';
import 'package:paisa/di/module/hive_module.dart';

@InjectableInit(
  asExtension: false,
  preferRelativeImports: true,
  throwOnMissingDependencies: true,
)
Future<GetIt> configInjector(
  GetIt getIt, {
  String? env,
  EnvironmentFilter? environmentFilter,
}) async {
  usePathUrlStrategy();
  await HiveAdapters().initHive();
  if (TargetPlatform.android == defaultTargetPlatform) {
    await FlutterDisplayMode.setHighRefreshRate();
  }
  if (TargetPlatform.android == defaultTargetPlatform ||
      TargetPlatform.iOS == defaultTargetPlatform) {
    initAppShortcuts();
  }
  if (Platform.isIOS) {
    HomeWidget.setAppGroupId('group.PaisaHomeScreenWidgetGroup');
  }

  return init(
    getIt,
    environmentFilter: environmentFilter,
    environment: env,
  );
}

Future<void> initAppShortcuts() async {
  const QuickActions quickActions = QuickActions();
  await quickActions.initialize((String shortcutType) {
    goRouter.go(const LandingPageData().location);
    goRouter.push(TransactionPageData(
      transactionType: shortcutType == 'ic_expense'
          ? TransactionType.expense
          : shortcutType == 'ic_income'
              ? TransactionType.income
              : shortcutType == 'ic_transfer'
                  ? TransactionType.transfer
                  : TransactionType.income,
    ).location);
  });
  await quickActions.setShortcutItems([
    const ShortcutItem(
      type: 'ic_income',
      localizedTitle: 'Income',
      icon: 'ic_income',
    ),
    const ShortcutItem(
      type: 'ic_expense',
      localizedTitle: 'Expense',
      icon: 'ic_expense',
    ),
    const ShortcutItem(
      type: 'ic_transfer',
      localizedTitle: 'Transfer',
      icon: 'ic_transfer',
    ),
  ]);
}

void addDummyData() async {
  final accountDataSource = getIt<AccountDataSource>();
  final categoryDataSource = getIt<CategoryDataSource>();
  final transactionDataSource = getIt<TransactionDataSource>();
  final debtDataSource = getIt<DebtDataSource>();

  await debtDataSource.clear();
  await accountDataSource.clear();
  await categoryDataSource.clear();
  await transactionDataSource.clear();

  List<String> names = [
    'Home & Living',
    'Health & Wellness',
    'Technology & Gadgets',
    'Food & Dining',
    'Travel & Adventure',
    'Fashion & Accessories',
    'Education & Learning',
    'Entertainment & Media',
    'Finance & Investments',
    'Sports & Fitness'
  ];

  List<String> banks = [
    'Global Trust Bank',
    // 'Unity Financial',
    // 'Apex Bank',
    // 'Mercury Savings & Loan',
    // 'Crescent Credit Union',
    // 'Orion Bank',
    // 'Pinnacle Finance Group',
    // 'Zenith Bank',
    // 'Nova Bank',
    // 'Infinity Banking Corp',
  ];

  for (int i = 0; i < banks.length; i++) {
    await accountDataSource.add(
      AccountModel(
        bankName: banks[i],
        name: 'Holder name $i',
        cardType: AccountType.values[Random().nextInt(3)],
        color:
            Colors.primaries[Random().nextInt(Colors.primaries.length)].value,
      ),
    );
  }
  for (int i = 0; i < names.length; i++) {
    await categoryDataSource.add(
      CategoryModel(
        name: names[i],
        color:
            Colors.primaries[Random().nextInt(Colors.primaries.length)].value,
        icon: MdiIcons.getIcons()[Random().nextInt(MdiIcons.getIcons().length)]
            .codePoint,
        categoryType: CategoryType.values[Random().nextInt(2)],
      ),
    );
  }
  final random = Random();
  final startDate = DateTime(2024);
  final endDate = DateTime.now();
  List<String> goals = [
    'Buy Car',
    'Travel Europe',
    'Buy Bike',
    'Buy House',
    'Buy Laptop',
    'Buy Phone',
    'Buy Camera',
    'Buy TV',
    'Buy AC'
  ];
  for (int i = 0; i < goals.length; i++) {
    await debtDataSource.add(
      DebtModel(
        debtType: DebitType.goal,
        name: goals[i],
        amount: Random().nextDouble() * 100000,
        superId: Random().nextInt(10),
        icon: MdiIcons.getIcons()[Random().nextInt(MdiIcons.getIcons().length)]
            .codePoint,
        isCompleted: Random().nextBool(),
        startDateTime: startDate,
        expiryDateTime: endDate.add(Duration(days: Random().nextInt(100))),
        color:
            Colors.primaries[Random().nextInt(Colors.primaries.length)].value,
        description: 'Description $i',
      ),
    );
  }

  for (int i = 0; i < 10; i++) {
    final TransactionType type = [
      TransactionType.expense,
      TransactionType.income,
    ][Random().nextInt(2)];
    int accountId = Random().nextInt(banks.length);
    final result = categoryDataSource.categories().where((element) {
      if (type == TransactionType.income) {
        return element.categoryType == CategoryType.income;
      } else {
        return element.categoryType == CategoryType.expense;
      }
    });
    int categoryId = Random().nextInt(result.length);

    final difference = endDate.difference(startDate).inDays;
    final randomDay = random.nextInt(difference);
    final randomDate = startDate.add(Duration(days: randomDay));
    await transactionDataSource.add(TransactionModel(
      name: names[Random().nextInt(names.length)],
      time: randomDate,
      accountId: accountId,
      categoryId: result.elementAt(categoryId).superId!,
      currency: Random().nextDouble() * 100000,
      type: type,
    ));
  }
}
