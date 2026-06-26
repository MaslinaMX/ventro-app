import 'package:flutter/foundation.dart';
import 'package:ventro_app/features/gastos/models/categoria_gasto_model.dart';
import 'package:ventro_app/features/gastos/services/categoria_gasto_service.dart';

class CategoriaGastoController extends ChangeNotifier {
  CategoriaGastoController({CategoriaGastoService? service})
      : _service = service ?? CategoriaGastoService();

  final CategoriaGastoService _service;

  List<CategoriaGastoModel> categorias = [];

  bool isLoadingCategorias = false;
  bool isSaving = false;
  String? errorMessage;

  Future<void> cargarCategorias() async {
    isLoadingCategorias = true;
    errorMessage = null;
    notifyListeners();
    try {
      categorias = await _service.getCategorias();
    } catch (e, st) {
      debugPrint('❌ cargarCategorias: $e\n$st');
      errorMessage = 'No se pudieron cargar las categorías de gasto';
    } finally {
      isLoadingCategorias = false;
      notifyListeners();
    }
  }

  Future<CategoriaGastoModel?> crearCategoria(
    String nombre, {
    String? icono,
    String? color,
  }) async {
    isSaving = true;
    notifyListeners();
    try {
      final nueva = await _service.createCategoria(
        nombre: nombre,
        icono: icono,
        color: color,
      );
      categorias = [...categorias, nueva];
      return nueva;
    } catch (e) {
      debugPrint('❌ crearCategoria: $e');
      errorMessage = 'No se pudo crear la categoría de gasto';
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> actualizarCategoria(
    int id, {
    required String nombre,
    String? icono,
    String? color,
  }) async {
    try {
      final actualizada = await _service.updateCategoria(
        id,
        nombre: nombre,
        icono: icono,
        color: color,
      );
      categorias = [
        for (final c in categorias) c.id == id ? actualizada : c,
      ];
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ actualizarCategoria: $e');
      errorMessage = 'No se pudo actualizar la categoría de gasto';
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarCategoria(int id) async {
    try {
      await _service.deleteCategoria(id);
      categorias = categorias.where((c) => c.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ eliminarCategoria: $e');
      errorMessage = 'No se pudo eliminar la categoría de gasto';
      notifyListeners();
      return false;
    }
  }
}
