import 'package:convenient_test_dev/convenient_test_dev.dart';
import 'package:convenient_test_example/home_page.dart';
import 'package:convenient_test_example/main.dart' as app;
import 'package:convenient_test_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  convenientTestMain(MyConvenientTestSlot(), () {
    group('simple test group', () {
      tTestWidgets('choose some fruits', (t) async {
        await t.get(HomePageMark.fetchFruits).tap();
        await t.get(find.text('HomePage')).should(findsOneWidget);
        await t.get(find.text('You chose nothing')).should(findsOneWidget);

        await t.get(find.text('Cherry')).tap();
        await t.get(find.text('You chose: Cherry')).should(findsOneWidget);

        await t.tester.scrollUntilVisible(find.text('Orange'), 100);
        await t.get(find.text('Orange')).tap();
        await t.get(find.text('You chose: Cherry, Orange')).should(findsOneWidget);

        await t.get(HomePageMark.fab).tap();
        await t.get(find.text('HomePage')).should(findsNothing);
        await t.get(find.text('SecondPage')).should(findsOneWidget);
        await t.get(find.text('See fruits: Cherry, Orange')).should(findsOneWidget);

        await t.pageBack();
        await t.get(find.text('HomePage')).should(findsOneWidget);
      });

      tTestWidgets('deliberately failing test', (t) async {
        expect(1, 0, reason: 'this expect should deliberately fail');
      });

      tTestWidgets('deliberately flaky test', (t) async {
        final shouldFailThisTime = !_deliberatelyFlakyTestHasRun;
        _deliberatelyFlakyTestHasRun = true;

        await t.get(HomePageMark.fetchFruits).tap();

        if (shouldFailThisTime) {
          await t.get(find.text('NotExistString')).should(findsOneWidget);
        } else {
          await t.get(find.text('Apple')).should(findsOneWidget);
        }
      });

      // TODO only for #138 debugging, should comment out later
      tTestWidgets('deliberately test that takes forever', (t) async {
        while (true) {
          print('call pumpAndSettle');
          await t.pumpAndSettle();
          print('call delay');
          await Future.delayed(const Duration(seconds: 2));
        }
      });

      tTestWidgets('navigation', (t) async {
        await t.visit('/second');
        await t.get(find.text('HomePage')).should(findsNothing);
        await t.get(find.text('SecondPage')).should(findsOneWidget);

        await t.pageBack();
        await t.get(find.text('HomePage')).should(findsOneWidget);
        await t.get(find.text('SecondPage')).should(findsNothing);
      });

      tTestWidgets('custom logging and snapshotting', (t) async {
        // suppose you do something normal...
        await t.get(find.text('HomePage')).should(findsOneWidget);

        // then you want to log and snapshot
        final log = t.log('HELLO', 'Just a demonstration of custom logging');
        await log.snapshot();
      });

      tTestWidgets('custom commands', (t) async {
        await t.myCustomCommand();
      });

      tTestWidgets('sections', (t) async {
        t.section('sample section one');

        // do something
        await t.get(find.text('HomePage')).should(findsOneWidget);

        t.section('sample section two');

        // do something
        await t.get(find.text('HomePage')).should(findsOneWidget);
      });

      tTestWidgets('timer page', (t) async {
        await t.visit('/timer');

        for (var iter = 0; iter < 5; ++iter) {
          final log = t.log('HELLO', 'Wait a second to have a look (#$iter)');
          await log.snapshot(name: 'before');

          final stopwatch = Stopwatch()..start();
          while (stopwatch.elapsed < const Duration(seconds: 1)) {
            await t.tester.pump();
          }

          await log.snapshot(name: 'after');
        }

        await t.pageBack();
      });
    });

    group('some other test group', () {
      tTestWidgets('empty test', (t) async {});

      group('sample sub-group', () {
        tTestWidgets('another empty test', (t) async {});

        group('sample sub-sub-group', () {
          tTestWidgets('yet another empty test', (t) async {});
        });
      });
    });
  });
}

var _deliberatelyFlakyTestHasRun = false;

class MyConvenientTestSlot extends ConvenientTestSlot {
  @override
  Future<void> appMain(AppMainExecuteMode mode) async => app.main();

  @override
  BuildContext? getNavContext(ConvenientTest t) => MyApp.navigatorKey.currentContext;
}

extension on ConvenientTest {
  Future<void> myCustomCommand() async {
    // Do anything you like... This is just a normal function
    debugPrint('Hello, world!');
  }
}
