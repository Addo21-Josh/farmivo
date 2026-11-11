import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:farmivo/core/money/money.dart';
import 'package:farmivo/core/validators/input_validators.dart';
import 'package:farmivo/core/errors/database_exception_mapper.dart';
import 'package:farmivo/core/errors/failures.dart';
import 'package:farmivo/core/utils/app_logger.dart';
import 'package:logger/logger.dart';

void main() {
  group('Money Parsing & Precision Integer Math', () {
    test(
      'Parses various currency strings and symbols accurately without double drift',
      () {
        final m1 = Money.parse('GH₵ 1,250.50');
        expect(m1.minorUnits, BigInt.from(125050));
        expect(m1.toMajor(), 1250.50);

        final m2 = Money.parse(r'$100.20', currency: 'USD');
        expect(m2.minorUnits, BigInt.from(10020));
        expect(m2.currency, 'USD');

        final m3 = Money.parse('₦ 5,000', currency: 'NGN');
        expect(m3.minorUnits, BigInt.from(500000));

        final m4 = Money.parse('(50.00)'); // Accounting negative
        expect(m4.minorUnits, BigInt.from(-5000));
        expect(m4.isNegative, isTrue);

        final m5 = Money.parse('-GH₵ 25.50');
        expect(m5.minorUnits, BigInt.from(-2550));

        final m6 = Money.parse('0.5'); // Single fractional digit (50 pesewas)
        expect(m6.minorUnits, BigInt.from(50));

        final m7 = Money.parse('10.555'); // Rounding third decimal
        expect(m7.minorUnits, BigInt.from(1056));
      },
    );

    test('tryParse returns null on invalid strings', () {
      expect(Money.tryParse('abc'), isNull);
      expect(Money.tryParse(''), isNull);
      expect(Money.tryParse('   '), isNull);
      expect(Money.tryParse('12.34.56'), isNull);
    });

    test(
      'multiplyInt and divideInt operate purely in BigInt integer space',
      () {
        final base = Money.fromMajor(100); // 10,000 pesewas
        final multiplied = base.multiplyInt(3);
        expect(multiplied.minorUnits, BigInt.from(30000));

        final divided = multiplied.divideInt(3);
        expect(divided.minorUnits, BigInt.from(10000));

        // Test rounding half-away-from-zero: 100 minor units / 3 = 33.333 -> 33
        final small = Money(BigInt.from(100));
        expect(small.divideInt(3).minorUnits, BigInt.from(33));

        // 100 minor units / 6 = 16.666 -> 17
        expect(small.divideInt(6).minorUnits, BigInt.from(17));
      },
    );
  });

  group('InputValidators with Money.tryParse', () {
    test('Validates monetary input formatting', () {
      expect(InputValidators.monetaryAmount('GH₵ 1,200.00'), isNull);
      expect(InputValidators.monetaryAmount('500'), isNull);
      expect(InputValidators.monetaryAmount('0', allowZero: true), isNull);
      expect(
        InputValidators.monetaryAmount('0', allowZero: false),
        contains('greater than zero'),
      );
      expect(
        InputValidators.monetaryAmount('-100'),
        contains('cannot be negative'),
      );
      expect(
        InputValidators.monetaryAmount('invalid'),
        contains('valid monetary amount'),
      );
    });
  });

  group('DatabaseExceptionMapper Tests', () {
    test('Maps foreign key violation to polite message', () {
      final exception = SqliteException(
        787,
        'FOREIGN KEY constraint failed',
        null,
        'INSERT INTO projects...',
      );

      final failure = DatabaseExceptionMapper.map(exception);
      expect(failure, isA<DatabaseFailure>());
      expect(failure.message, contains('other records currently link to it'));
      expect(failure.code, 'FOREIGN_KEY_VIOLATION');
    });

    test('Maps unique constraint violation to polite message', () {
      final exception = SqliteException(
        2067,
        'UNIQUE constraint failed: farms.name',
        null,
        'INSERT INTO farms...',
      );

      final failure = DatabaseExceptionMapper.map(exception);
      expect(failure, isA<DatabaseFailure>());
      expect(failure.message, contains('already exists'));
      expect(failure.code, 'UNIQUE_CONSTRAINT_VIOLATION');
    });

    test('runSafe executes block and catches low-level exceptions', () async {
      expect(
        () => DatabaseExceptionMapper.runSafe<void>(() async {
          throw SqliteException(5, 'database is locked');
        }),
        throwsA(isA<DatabaseFailure>()),
      );
    });
  });

  group('RotatingFileOutput Disk Logging', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('farmivo_log_test');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('Rotates log file when size threshold is reached', () {
      final logFile = File('${tempDir.path}/test.log');
      final output = RotatingFileOutput(
        file: logFile,
        maxBytes: 100, // Small 100 bytes limit to force rotation
        maxRotatedFiles: 3,
      );

      // Write first batch of logs (<100 bytes)
      output.output(
        OutputEvent(LogEvent(Level.info, 'Line 1 short'), ['Line 1 short']),
      );
      expect(logFile.existsSync(), isTrue);

      // Write large batch exceeding 100 bytes to trigger rotation
      final longPayload = 'A' * 200;
      output.output(
        OutputEvent(LogEvent(Level.info, longPayload), [longPayload]),
      );

      // Trigger another write; the previous file should have been rotated to test.1.log
      output.output(
        OutputEvent(LogEvent(Level.info, 'Next line after rotation'), [
          'Next line after rotation',
        ]),
      );

      final rotatedFile = File('${tempDir.path}/test.1.log');
      expect(rotatedFile.existsSync(), isTrue);
    });
  });
}
