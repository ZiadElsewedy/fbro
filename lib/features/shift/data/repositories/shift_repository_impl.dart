import 'package:fbro/core/errors/exceptions.dart';
import 'package:fbro/core/errors/failures.dart';
import 'package:fbro/features/shift/data/datasources/shift_remote_datasource.dart';
import 'package:fbro/features/shift/data/models/shift_model.dart';
import 'package:fbro/features/shift/domain/entities/shift_entity.dart';
import 'package:fbro/features/shift/domain/repositories/shift_repository.dart';

class ShiftRepositoryImpl implements ShiftRepository {
  final ShiftRemoteDataSource _remote;

  ShiftRepositoryImpl(this._remote);

  @override
  Future<List<ShiftEntity>> getAllShifts() async {
    try {
      final models = await _remote.getAllShifts();
      return models.map((m) => m.toEntity()).toList();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<List<ShiftEntity>> getShiftsByBranch(String branchId) async {
    try {
      final models = await _remote.getShiftsByBranch(branchId);
      return models.map((m) => m.toEntity()).toList();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<ShiftEntity?> getShift(String shiftId) async {
    try {
      final model = await _remote.getShift(shiftId);
      return model?.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<ShiftEntity?> getEmployeeShift(String employeeId) async {
    try {
      final model = await _remote.getEmployeeShift(employeeId);
      return model?.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<ShiftEntity> createShift(ShiftEntity shift) async {
    try {
      final created = await _remote.createShift(ShiftModel.fromEntity(shift));
      return created.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> updateShift(ShiftEntity shift) async {
    try {
      await _remote.updateShift(ShiftModel.fromEntity(shift));
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> deleteShift(String shiftId) async {
    try {
      await _remote.deleteShift(shiftId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> assignEmployee({
    required String shiftId,
    required String? employeeId,
  }) async {
    try {
      await _remote.assignEmployee(shiftId: shiftId, employeeId: employeeId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
