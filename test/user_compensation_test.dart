import 'package:flutter_test/flutter_test.dart';
import 'package:drop/features/admin/presentation/widgets/compensation_fields.dart';
import 'package:drop/features/auth/data/models/user_model.dart';
import 'package:drop/features/profile/data/models/profile_model.dart';

/// Compensation slice (2026-07-02): salary/payment fields on `users/{uid}`.
/// Admin-only: salaryAmount / salaryType / paymentMethod. Self-editable:
/// paymentNumber (the employee's own salary-receiving number).
void main() {
  group('UserModel compensation fields', () {
    test('round-trip through fromMap → toEntity', () {
      final model = UserModel.fromMap({
        'uid': 'u1',
        'email': 'a@b.com',
        'salaryAmount': 4500,
        'salaryType': 'monthly',
        'paymentMethod': 'wallet',
        'paymentNumber': '+201000000000',
      });
      final entity = model.toEntity();
      expect(entity.salaryAmount, 4500.0);
      expect(entity.salaryType, 'monthly');
      expect(entity.paymentMethod, 'wallet');
      expect(entity.paymentNumber, '+201000000000');
    });

    test('legacy doc without compensation parses to nulls', () {
      final model = UserModel.fromMap({'uid': 'u1', 'email': 'a@b.com'});
      expect(model.salaryAmount, isNull);
      expect(model.salaryType, isNull);
      expect(model.paymentMethod, isNull);
      expect(model.paymentNumber, isNull);
    });

    test('toMap excludes compensation (routine writes cannot clobber it)', () {
      final model = UserModel.fromMap({
        'uid': 'u1',
        'email': 'a@b.com',
        'salaryAmount': 4500,
        'paymentNumber': '+201000000000',
      });
      final map = model.toMap();
      expect(map.containsKey('salaryAmount'), isFalse);
      expect(map.containsKey('salaryType'), isFalse);
      expect(map.containsKey('paymentMethod'), isFalse);
      expect(map.containsKey('paymentNumber'), isFalse);
    });
  });

  group('ProfileModel self-service payroll field', () {
    test('editMap writes paymentNumber only when provided', () {
      final withNumber = ProfileModel.editMap(paymentNumber: '+201');
      expect(withNumber['paymentNumber'], '+201');
      final without = ProfileModel.editMap(fullName: 'Ada');
      expect(without.containsKey('paymentNumber'), isFalse);
    });

    test('fromMap reads address / emergencyContact / paymentNumber', () {
      final entity = ProfileModel.fromMap({
        'uid': 'u1',
        'email': 'a@b.com',
        'address': 'Cairo',
        'emergencyContact': 'Mona · +2010',
        'paymentNumber': '+201000000000',
      }).toEntity();
      expect(entity.address, 'Cairo');
      expect(entity.emergencyContact, 'Mona · +2010');
      expect(entity.paymentNumber, '+201000000000');
    });
  });

  group('salarySummary', () {
    test('formats whole amounts without decimals + type label', () {
      expect(salarySummary(4500, 'monthly'), '4500 · Monthly');
      expect(salarySummary(120.5, 'daily'), '120.5 · Daily');
      expect(salarySummary(4500, null), '4500');
      expect(salarySummary(null, 'monthly'), isNull);
    });

    test('validateSalaryAmount accepts empty / numeric, rejects junk', () {
      expect(validateSalaryAmount(''), isNull);
      expect(validateSalaryAmount(null), isNull);
      expect(validateSalaryAmount('4500'), isNull);
      expect(validateSalaryAmount('120.5'), isNull);
      expect(validateSalaryAmount('12.3.4'), isNotNull);
      expect(validateSalaryAmount('-5'), isNotNull);
    });
  });
}
