import 'package:flutter_test/flutter_test.dart';
import 'package:fbro/core/enums/broadcast_audience.dart';
import 'package:fbro/core/enums/user_role.dart';
import 'package:fbro/features/communications/data/models/broadcast_model.dart';
import 'package:fbro/features/communications/domain/entities/broadcast_entity.dart';

/// Verifies the Communications Center broadcast model round-trips through
/// Firestore serialization, and that the all-branches sentinel (`branchId == ''`)
/// — which keeps a branch member's `whereIn: [branch, '']` query provably safe —
/// is mapped correctly in both directions.
void main() {
  group('BroadcastModel serialization', () {
    test('toMap writes the persisted fields (no createdAt — server-set)', () {
      final map = const BroadcastModel(
        id: 'b1',
        title: 'Stock count',
        message: 'Count the back room before close.',
        senderId: 'u1',
        senderName: 'Ziad',
        senderRole: UserRole.manager,
        audience: BroadcastAudience.branch,
        branchId: 'branch-7',
      ).toMap();

      expect(map['id'], 'b1');
      expect(map['title'], 'Stock count');
      expect(map['message'], 'Count the back room before close.');
      expect(map['senderId'], 'u1');
      expect(map['senderName'], 'Ziad');
      expect(map['senderRole'], 'manager');
      expect(map['audience'], 'branch');
      expect(map['branchId'], 'branch-7');
      expect(map.containsKey('createdAt'), isFalse);
    });

    test('fromEntity stores an all-branches broadcast with the "" sentinel', () {
      final model = BroadcastModel.fromEntity(const BroadcastEntity(
        id: 'b2',
        title: 'Holiday hours',
        message: 'All stores open late this week.',
        senderId: 'admin-1',
        senderName: 'HQ',
        senderRole: UserRole.admin,
        audience: BroadcastAudience.allBranches,
        branchId: null,
      ));

      expect(model.audience, BroadcastAudience.allBranches);
      expect(model.branchId, '');
      expect(model.toMap()['branchId'], '');
    });

    test('fromEntity keeps the branch id for a branch-scoped broadcast', () {
      final model = BroadcastModel.fromEntity(const BroadcastEntity(
        id: 'b3',
        title: 't',
        message: 'm',
        senderId: 'u',
        senderName: 'n',
        audience: BroadcastAudience.branch,
        branchId: 'branch-3',
      ));

      expect(model.branchId, 'branch-3');
    });

    test('fromMap parses enums and maps the "" sentinel back to a null branch',
        () {
      final entity = BroadcastModel.fromMap(const {
        'title': 'Welcome',
        'message': 'Hello team',
        'senderId': 'admin-1',
        'senderName': 'HQ',
        'senderRole': 'admin',
        'audience': 'allBranches',
        'branchId': '',
      }, id: 'b4').toEntity();

      expect(entity.id, 'b4');
      expect(entity.senderRole, UserRole.admin);
      expect(entity.audience, BroadcastAudience.allBranches);
      expect(entity.isBranchScoped, isFalse);
      expect(entity.branchId, isNull);
    });

    test('fromMap is back-compatible with a malformed / partial document', () {
      final entity = BroadcastModel.fromMap(const {}).toEntity();

      expect(entity.title, '');
      expect(entity.message, '');
      expect(entity.senderId, '');
      // Unknown/missing role never escalates; unknown audience is the widest.
      expect(entity.senderRole, UserRole.employee);
      expect(entity.audience, BroadcastAudience.allBranches);
      expect(entity.branchId, isNull);
      expect(entity.createdAt, isNull);
    });

    test('a branch-scoped entity → model → map keeps audience + branch aligned',
        () {
      final map = BroadcastModel.fromEntity(const BroadcastEntity(
        id: 'b5',
        title: 't',
        message: 'm',
        senderId: 'u',
        senderName: 'n',
        senderRole: UserRole.manager,
        audience: BroadcastAudience.branch,
        branchId: 'branch-9',
      )).toMap();

      expect(map['audience'], 'branch');
      expect(map['branchId'], 'branch-9');
    });
  });
}
