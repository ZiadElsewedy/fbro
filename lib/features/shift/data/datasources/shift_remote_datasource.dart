import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fbro/core/constants/app_constants.dart';
import 'package:fbro/core/errors/exceptions.dart';
import 'package:fbro/features/shift/data/models/shift_model.dart';

abstract class ShiftRemoteDataSource {
  Future<List<ShiftModel>> getAllShifts();
  Future<List<ShiftModel>> getShiftsByBranch(String branchId);
  Future<ShiftModel?> getShift(String shiftId);
  Future<ShiftModel?> getEmployeeShift(String employeeId);
  Future<ShiftModel> createShift(ShiftModel shift);
  Future<void> updateShift(ShiftModel shift);
  Future<void> deleteShift(String shiftId);
  Future<void> assignEmployee({
    required String shiftId,
    required String? employeeId,
  });
}

class ShiftRemoteDataSourceImpl implements ShiftRemoteDataSource {
  final FirebaseFirestore _firestore;

  ShiftRemoteDataSourceImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> get _shifts =>
      _firestore.collection(AppConstants.shiftsCollection);

  @override
  Future<List<ShiftModel>> getAllShifts() async {
    try {
      final snap = await _shifts.get();
      return snap.docs
          .map((d) => ShiftModel.fromMap(d.data(), id: d.id))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to load shifts.');
    }
  }

  @override
  Future<List<ShiftModel>> getShiftsByBranch(String branchId) async {
    try {
      final snap = await _shifts.where('branchId', isEqualTo: branchId).get();
      return snap.docs
          .map((d) => ShiftModel.fromMap(d.data(), id: d.id))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to load branch shifts.');
    }
  }

  @override
  Future<ShiftModel?> getShift(String shiftId) async {
    try {
      final doc = await _shifts.doc(shiftId).get();
      if (!doc.exists || doc.data() == null) return null;
      return ShiftModel.fromMap(doc.data()!, id: doc.id);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to load shift.');
    }
  }

  @override
  Future<ShiftModel?> getEmployeeShift(String employeeId) async {
    try {
      final snap = await _shifts
          .where('employeeId', isEqualTo: employeeId)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      final d = snap.docs.first;
      return ShiftModel.fromMap(d.data(), id: d.id);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to load your shift.');
    }
  }

  @override
  Future<ShiftModel> createShift(ShiftModel shift) async {
    try {
      final docRef = _shifts.doc();
      final created = shift.copyWithId(docRef.id);
      await docRef.set({
        ...created.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return created;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to create shift.');
    }
  }

  @override
  Future<void> updateShift(ShiftModel shift) async {
    try {
      await _shifts.doc(shift.id).set({
        ...shift.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update shift.');
    }
  }

  @override
  Future<void> deleteShift(String shiftId) async {
    try {
      await _shifts.doc(shiftId).delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete shift.');
    }
  }

  @override
  Future<void> assignEmployee({
    required String shiftId,
    required String? employeeId,
  }) async {
    try {
      await _shifts.doc(shiftId).set({
        'employeeId': employeeId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to assign employee.');
    }
  }
}
