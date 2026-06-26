import 'package:flutter/foundation.dart';
import 'package:ventro_app/features/gastos/models/gasto_model.dart';
import 'package:ventro_app/features/gastos/services/gasto_service.dart';

class GastoController extends ChangeNotifier {
  GastoController({GastoService? service}) : _service = service ?? GastoService();

  final GastoService _service;

  List<GastoModel> gastos = [];

  bool isLoadingGastos = false;
  bool isSaving = false;
  String? errorMessage;

  Future<void> cargarGastos({int? sucursalId}) async {
    isLoadingGastos = true;
    errorMessage = null;
    notifyListeners();
    try {
      gastos = await _service.getGastos(sucursalId: sucursalId);
    } catch (e, st) {
      debugPrint('❌ cargarGastos: $e\n$st');
      errorMessage = 'No se pudieron cargar los gastos';
    } finally {
      isLoadingGastos = false;
      notifyListeners();
    }
  }

  /// Crea un gasto nuevo. Una vez creado, no se puede borrar y solo
  /// admin_empresa/admin_sucursal pueden editarlo (con motivo obligatorio).
  Future<GastoModel?> crearGasto(GastoModel gasto) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();
    try {
      final nuevo = await _service.createGasto(gasto);
      gastos = [nuevo, ...gastos];
      return nuevo;
    } catch (e) {
      debugPrint('❌ crearGasto: $e');
      errorMessage = 'No se pudo registrar el gasto';
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  /// Edita un gasto existente. Requiere motivo — lo exige el backend,
  /// pero la UI debe pedirlo siempre antes de llamar este método.
  Future<GastoModel?> editarGasto(
    int id,
    GastoModel gasto, {
    required String motivo,
  }) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();
    try {
      final actualizado = await _service.updateGasto(id, gasto, motivo: motivo);
      gastos = [
        for (final g in gastos) g.id == id ? actualizado : g,
      ];
      return actualizado;
    } catch (e) {
      debugPrint('❌ editarGasto: $e');
      errorMessage = 'No se pudo editar el gasto';
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
