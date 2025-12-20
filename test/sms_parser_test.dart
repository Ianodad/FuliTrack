import 'package:flutter_test/flutter_test.dart';
import 'package:fulitrack/services/sms_parser.dart';
import 'package:fulitrack/models/models.dart';

void main() {
  group('SmsParser', () {
    group('isFulizaMessage', () {
      test('should return true for Fuliza loan messages', () {
        const message = 'SD38YVVQ1A Confirmed. Fuliza M-PESA amount is Ksh 1443.39. '
            'Interest charged Ksh 14.44. '
            'Total Fuliza M-PESA outstanding amount is Ksh 1457.83 due on 03/05/24.';

        expect(SmsParser.isFulizaMessage(message), isTrue);
      });

      test('should return true for Fuliza repayment messages', () {
        const message = 'SD36YYPUQM Confirmed. Ksh 1689.12 from your M-PESA has been used '
            'to fully pay your outstanding Fuliza M-PESA. '
            'Available Fuliza M-PESA limit is Ksh 3000.00.';

        expect(SmsParser.isFulizaMessage(message), isTrue);
      });

      test('should return false for non-Fuliza M-PESA messages', () {
        const message = 'QA12345678 Confirmed. Ksh 500.00 sent to John Doe 0712345678.';

        expect(SmsParser.isFulizaMessage(message), isFalse);
      });

      test('should return false for random messages', () {
        const message = 'Your package has been shipped!';

        expect(SmsParser.isFulizaMessage(message), isFalse);
      });
    });

    group('parse - Loan with Interest', () {
      test('should parse standard Fuliza loan message', () {
        const message = 'SD38YVVQ1A Confirmed. Fuliza M-PESA amount is Ksh 1443.39. '
            'Interest charged Ksh 14.44. '
            'Total Fuliza M-PESA outstanding amount is Ksh 1457.83 due on 03/05/24.';

        final smsDate = DateTime(2024, 5, 3);
        final result = SmsParser.parse(message, smsDate);

        expect(result.isFulizaMessage, isTrue);
        expect(result.events.length, equals(2)); // loan + interest
        expect(result.error, isNull);

        // Check loan event
        final loan = result.events.firstWhere((e) => e.type == FulizaEventType.loan);
        expect(loan.amount, equals(1443.39));
        expect(loan.reference, equals('SD38YVVQ1A'));
        expect(loan.outstandingBalance, equals(1457.83));
        expect(loan.dueDate, equals(DateTime(2024, 5, 3)));

        // Check interest event
        final interest = result.events.firstWhere((e) => e.type == FulizaEventType.interest);
        expect(interest.amount, equals(14.44));
        expect(interest.reference, equals('SD38YVVQ1A_INT'));
      });

      test('should parse another loan message format', () {
        const message = 'SD39YWO6ZD Confirmed. Fuliza M-PESA amount is Ksh 229.00. '
            'Interest charged Ksh 2.29. '
            'Total Fuliza M-PESA outstanding amount is Ksh 1689.12 due on 03/05/24.';

        final smsDate = DateTime(2024, 5, 3);
        final result = SmsParser.parse(message, smsDate);

        expect(result.isFulizaMessage, isTrue);
        expect(result.events.length, equals(2));

        final loan = result.events.firstWhere((e) => e.type == FulizaEventType.loan);
        expect(loan.amount, equals(229.00));

        final interest = result.events.firstWhere((e) => e.type == FulizaEventType.interest);
        expect(interest.amount, equals(2.29));
      });

      test('should parse message with comma in amount', () {
        const message = 'SD38YVVQ1A Confirmed. Fuliza M-PESA amount is Ksh 1,443.39. '
            'Interest charged Ksh 14.44. '
            'Total Fuliza M-PESA outstanding amount is Ksh 1,457.83 due on 03/05/24.';

        final smsDate = DateTime(2024, 5, 3);
        final result = SmsParser.parse(message, smsDate);

        expect(result.isFulizaMessage, isTrue);
        final loan = result.events.firstWhere((e) => e.type == FulizaEventType.loan);
        expect(loan.amount, equals(1443.39));
      });
    });

    group('parse - Full Repayment', () {
      test('should parse full repayment message', () {
        const message = 'SD36YYPUQM Confirmed. Ksh 1689.12 from your M-PESA has been used '
            'to fully pay your outstanding Fuliza M-PESA. '
            'Available Fuliza M-PESA limit is Ksh 3000.00.';

        final smsDate = DateTime(2024, 5, 3);
        final result = SmsParser.parse(message, smsDate);

        expect(result.isFulizaMessage, isTrue);
        expect(result.events.length, equals(1));
        expect(result.error, isNull);

        final repayment = result.events.first;
        expect(repayment.type, equals(FulizaEventType.repayment));
        expect(repayment.amount, equals(1689.12));
        expect(repayment.reference, equals('SD36YYPUQM'));
        expect(repayment.outstandingBalance, equals(0));
      });

      test('should parse repayment with comma in amount', () {
        const message = 'SD36YYPUQM Confirmed. Ksh 10,689.12 from your M-PESA has been used '
            'to fully pay your outstanding Fuliza M-PESA. '
            'Available Fuliza M-PESA limit is Ksh 15,000.00.';

        final smsDate = DateTime(2024, 5, 3);
        final result = SmsParser.parse(message, smsDate);

        expect(result.isFulizaMessage, isTrue);
        final repayment = result.events.first;
        expect(repayment.amount, equals(10689.12));
      });
    });

    group('parse - Small amounts', () {
      test('should parse small Fuliza loan', () {
        const message = 'SD65BKD1YV Confirmed. Fuliza M-PESA amount is Ksh 140.12. '
            'Interest charged Ksh 1.41. '
            'Total Fuliza M-PESA outstanding amount is Ksh 141.53 due on 06/05/24.';

        final smsDate = DateTime(2024, 5, 6);
        final result = SmsParser.parse(message, smsDate);

        expect(result.isFulizaMessage, isTrue);
        expect(result.events.length, equals(2));

        final loan = result.events.firstWhere((e) => e.type == FulizaEventType.loan);
        expect(loan.amount, equals(140.12));

        final interest = result.events.firstWhere((e) => e.type == FulizaEventType.interest);
        expect(interest.amount, equals(1.41));
      });
    });

    group('parse - Edge cases', () {
      test('should return not Fuliza for empty message', () {
        const message = '';
        final result = SmsParser.parse(message, DateTime.now());

        expect(result.isFulizaMessage, isFalse);
        expect(result.events, isEmpty);
      });

      test('should handle message with extra whitespace', () {
        const message = 'SD38YVVQ1A   Confirmed.   Fuliza M-PESA amount is Ksh 1443.39. '
            'Interest charged Ksh 14.44. '
            'Total Fuliza M-PESA outstanding amount is Ksh 1457.83 due on 03/05/24.';

        final result = SmsParser.parse(message, DateTime(2024, 5, 3));
        expect(result.isFulizaMessage, isTrue);
        expect(result.events.length, equals(2));
      });

      test('should handle message with line breaks', () {
        const message = '''SD38YVVQ1A Confirmed. Fuliza M-PESA amount is Ksh 1443.39.
Interest charged Ksh 14.44.
Total Fuliza M-PESA outstanding amount is Ksh 1457.83
due on 03/05/24.''';

        final result = SmsParser.parse(message, DateTime(2024, 5, 3));
        expect(result.isFulizaMessage, isTrue);
        expect(result.events.length, equals(2));
      });
    });

    group('parseMultiple', () {
      test('should parse multiple messages and deduplicate', () {
        final messages = [
          SmsData(
            body: 'SD38YVVQ1A Confirmed. Fuliza M-PESA amount is Ksh 1443.39. '
                'Interest charged Ksh 14.44. '
                'Total Fuliza M-PESA outstanding amount is Ksh 1457.83 due on 03/05/24.',
            date: DateTime(2024, 5, 3),
          ),
          SmsData(
            body: 'SD36YYPUQM Confirmed. Ksh 1689.12 from your M-PESA has been used '
                'to fully pay your outstanding Fuliza M-PESA. '
                'Available Fuliza M-PESA limit is Ksh 3000.00.',
            date: DateTime(2024, 5, 3),
          ),
        ];

        final events = SmsParser.parseMultiple(messages);

        expect(events.length, equals(3)); // 2 from first (loan + interest) + 1 repayment
      });

      test('should ignore duplicate references', () {
        final messages = [
          SmsData(
            body: 'SD38YVVQ1A Confirmed. Fuliza M-PESA amount is Ksh 1443.39. '
                'Interest charged Ksh 14.44. '
                'Total Fuliza M-PESA outstanding amount is Ksh 1457.83 due on 03/05/24.',
            date: DateTime(2024, 5, 3),
          ),
          SmsData(
            body: 'SD38YVVQ1A Confirmed. Fuliza M-PESA amount is Ksh 1443.39. '
                'Interest charged Ksh 14.44. '
                'Total Fuliza M-PESA outstanding amount is Ksh 1457.83 due on 03/05/24.',
            date: DateTime(2024, 5, 3),
          ),
        ];

        final events = SmsParser.parseMultiple(messages);

        // Should only have 2 events (one loan, one interest) not 4
        expect(events.length, equals(2));
      });

      test('should filter out non-Fuliza messages', () {
        final messages = [
          SmsData(
            body: 'SD38YVVQ1A Confirmed. Fuliza M-PESA amount is Ksh 1443.39. '
                'Interest charged Ksh 14.44. '
                'Total Fuliza M-PESA outstanding amount is Ksh 1457.83 due on 03/05/24.',
            date: DateTime(2024, 5, 3),
          ),
          SmsData(
            body: 'QA12345678 Confirmed. Ksh 500.00 sent to John Doe.',
            date: DateTime(2024, 5, 3),
          ),
          SmsData(
            body: 'Your OTP is 123456',
            date: DateTime(2024, 5, 3),
          ),
        ];

        final events = SmsParser.parseMultiple(messages);

        expect(events.length, equals(2)); // Only events from first message
      });
    });

    group('Period keys', () {
      test('should generate correct monthly period key', () {
        const message = 'SD38YVVQ1A Confirmed. Fuliza M-PESA amount is Ksh 1443.39. '
            'Interest charged Ksh 14.44. '
            'Total Fuliza M-PESA outstanding amount is Ksh 1457.83 due on 03/05/24.';

        final smsDate = DateTime(2024, 5, 3);
        final result = SmsParser.parse(message, smsDate);

        expect(result.events.first.periodKey, equals('2024-05'));
      });

      test('should handle December date correctly', () {
        const message = 'SD38YVVQ1A Confirmed. Fuliza M-PESA amount is Ksh 100.00. '
            'Interest charged Ksh 1.00. '
            'Total Fuliza M-PESA outstanding amount is Ksh 101.00 due on 25/12/24.';

        final smsDate = DateTime(2024, 12, 25);
        final result = SmsParser.parse(message, smsDate);

        expect(result.events.first.periodKey, equals('2024-12'));
      });
    });
  });
}
