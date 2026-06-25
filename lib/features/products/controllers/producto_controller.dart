import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:ventro_app/features/products/models/categoria_model.dart';
import 'package:ventro_app/features/products/models/producto_model.dart';
import 'package:ventro_app/features/products/models/producto_variante_imagen_model.dart';
import 'package:ventro_app/features/products/models/producto_variante_model.dart';
import 'package:ventro_app/features/products/models/variantes_inactivas_page.dart';
import 'package:ventro_app/features/products/services/producto_service.dart';

class ProductoController extends ChangeNotifier {
  ProductoController({ProductoService? service}) : _service = service ?? ProductoService();

  final ProductoService _service;

  List<ProductoModel> productos = [];
  List<CategoriaModel> categorias = [];

  bool isLoadingProductos = false;
  bool isLoadingCategorias = false;
  bool isSaving = false;
  String? errorMessage;

  // ─── Variantes inactivas ────────────────────────────────────────────────
  List<VarianteInactiva> variantesInactivas = [];
  bool isLoadingInactivas = false;
  bool isReactivando = false;
  int _paginaInactivas = 1;
  bool hayMasInactivas = true;
  String? errorInactivas;

  Future<void> cargarProductos() async {
    isLoadingProductos = true;
    errorMessage = null;
    notifyListeners();
    try {
      productos = await _service.getProductos();
    } catch (e, st) {
      debugPrint('❌ cargarProductos: $e\n$st');
      errorMessage = 'No se pudieron cargar los productos';
    } finally {
      isLoadingProductos = false;
      notifyListeners();
    }
  }

  Future<ProductoVarianteModel?> obtenerVariante(int productoId, int varianteId) async {
    try {
      final v = await _service.getVariante(productoId, varianteId);
      debugPrint('🟢 obtenerVariante allow_online=${v.allowOnline}');
      return v;
    } catch (e) {
      debugPrint('❌ obtenerVariante: $e');
      return null;
    }
  }

  Future<void> cargarCategorias() async {
    isLoadingCategorias = true;
    notifyListeners();
    try {
      categorias = await _service.getCategorias();
    } catch (e, st) {
      debugPrint('❌ cargarCategorias: $e\n$st');
      errorMessage = 'No se pudieron cargar las categorías';
    } finally {
      isLoadingCategorias = false;
      notifyListeners();
    }
  }

  Future<CategoriaModel?> crearCategoria(
    String nombre, {
    String? descripcion,
    String? icono,
    String? color,
  }) async {
    try {
      final nueva = await _service.createCategoria(
        nombre: nombre,
        descripcion: descripcion,
        icono: icono,
        color: color,
      );
      categorias = [...categorias, nueva];
      notifyListeners();
      return nueva;
    } catch (e) {
      debugPrint('❌ crearCategoria: $e');
      errorMessage = 'No se pudo crear la categoría';
      notifyListeners();
      return null;
    }
  }

  /// Crea o actualiza un producto junto con sus variantes en un solo flujo.
  /// Las variantes con id == 0 se crean; las que ya traen id se actualizan.
  Future<ProductoModel?> guardarProductoConVariantes({
    ProductoModel? productoExistente,
    required String nombre,
    String? descripcion,
    required int categoriaId,
    required bool tieneVariantes,
    required List<ProductoVarianteModel> variantes,
  }) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();
    try {
      if (productoExistente == null) {
        final productoFinal = await _service.createProducto(
          nombre: nombre,
          categoriaId: categoriaId,
          descripcion: descripcion,
          tieneVariantes: tieneVariantes,
          variantes: variantes,
        );
        productos = [...productos, productoFinal];
        return productoFinal;
      }

      final productoActualizado = await _service.updateProducto(
        productoExistente.id,
        ProductoModel(
          id: productoExistente.id,
          categoriaId: categoriaId,
          nombre: nombre,
          descripcion: descripcion,
          activo: productoExistente.activo,
          tieneVariantes: tieneVariantes,
        ),
      );

      final variantesFinales = <ProductoVarianteModel>[];
      for (final v in variantes) {
        if (v.id == 0) {
          final stockInicial = v.stocksIniciales.isEmpty ? 0 : v.stocksIniciales.first.cantidad;
          final creada = await _service.createVariante(
            productoExistente.id,
            v,
            stock: stockInicial,
          );
          variantesFinales.add(creada);
        } else {
          final actualizada = await _service.updateVariante(
            productoExistente.id,
            v.id,
            v,
          );
          variantesFinales.add(actualizada);
        }
      }

      final productoFinal = ProductoModel(
        id: productoActualizado.id,
        categoriaId: productoActualizado.categoriaId,
        nombre: productoActualizado.nombre,
        descripcion: productoActualizado.descripcion,
        activo: productoActualizado.activo,
        tieneVariantes: productoActualizado.tieneVariantes,
        categoria: productoActualizado.categoria,
        variantes: variantesFinales,
      );

      final index = productos.indexWhere((p) => p.id == productoFinal.id);
      if (index >= 0) {
        productos[index] = productoFinal;
      } else {
        productos = [...productos, productoFinal];
      }
      return productoFinal;
    } catch (e) {
      debugPrint('❌ guardarProducto: $e');
      errorMessage = 'No se pudo guardar el producto';
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> eliminarProducto(int id) async {
    try {
      await _service.deleteProducto(id);
      productos = productos.where((p) => p.id != id).toList();
      notifyListeners();
      return true;
    } catch (_) {
      errorMessage = 'No se pudo eliminar el producto';
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarVariante(int productoId, int varianteId) async {
    try {
      await _service.deleteVariante(productoId, varianteId);
      final index = productos.indexWhere((p) => p.id == productoId);
      if (index >= 0) {
        final actual = productos[index];
        productos[index] = ProductoModel(
          id: actual.id,
          categoriaId: actual.categoriaId,
          nombre: actual.nombre,
          descripcion: actual.descripcion,
          activo: actual.activo,
          categoria: actual.categoria,
          variantes: actual.variantes.where((v) => v.id != varianteId).toList(),
        );
        notifyListeners();
      }
      return true;
    } catch (_) {
      errorMessage = 'No se pudo eliminar la variante';
      notifyListeners();
      return false;
    }
  }

  Future<ProductoVarianteImagenModel?> subirImagenVariante(
    int productoId,
    int varianteId,
    Uint8List bytes,
    String filename,
  ) async {
    try {
      return await _service.subirImagenVariante(productoId, varianteId, bytes, filename);
    } catch (e) {
      debugPrint('❌ subirImagenVariante: $e');
      if (e is DioException) {
        debugPrint('❌ response data: ${e.response?.data}');
      }
      errorMessage = 'No se pudo subir la imagen';
      notifyListeners();
      return null;
    }
  }

  Future<bool> eliminarImagenVariante(int productoId, int varianteId, int imagenId) async {
    try {
      await _service.eliminarImagenVariante(productoId, varianteId, imagenId);
      return true;
    } catch (e) {
      debugPrint('❌ eliminarImagenVariante: $e');
      return false;
    }
  }

  Future<ProductoVarianteModel?> actualizarVarianteDirecto(
    int productoId,
    int varianteId,
    ProductoVarianteModel variante,
  ) async {
    try {
      final actualizada = await _service.updateVariante(productoId, varianteId, variante);

      final index = productos.indexWhere((p) => p.id == productoId);
      if (index >= 0) {
        final actual = productos[index];
        final variantesActualizadas = [
          for (final v in actual.variantes) v.id == varianteId ? actualizada : v,
        ];
        productos[index] = ProductoModel(
          id: actual.id,
          categoriaId: actual.categoriaId,
          nombre: actual.nombre,
          descripcion: actual.descripcion,
          activo: actual.activo,
          tieneVariantes: actual.tieneVariantes,
          categoria: actual.categoria,
          variantes: variantesActualizadas,
        );
        notifyListeners();
      }
      return actualizada;
    } catch (e) {
      debugPrint('❌ actualizarVarianteDirecto: $e');
      errorMessage = 'No se pudo guardar la variante';
      notifyListeners();
      return null;
    }
  }

  Future<ProductoVarianteModel?> crearVarianteDirecto(
    int productoId,
    ProductoVarianteModel variante,
  ) async {
    try {
      final stock = variante.stocksIniciales.isEmpty ? 0 : variante.stocksIniciales.first.cantidad;
      final creada = await _service.createVariante(productoId, variante, stock: stock);

      final index = productos.indexWhere((p) => p.id == productoId);
      if (index >= 0) {
        final actual = productos[index];
        productos[index] = ProductoModel(
          id: actual.id,
          categoriaId: actual.categoriaId,
          nombre: actual.nombre,
          descripcion: actual.descripcion,
          activo: actual.activo,
          tieneVariantes: actual.tieneVariantes,
          categoria: actual.categoria,
          variantes: [...actual.variantes, creada],
        );
        notifyListeners();
      }
      return creada;
    } catch (e) {
      debugPrint('❌ crearVarianteDirecto: $e');
      errorMessage = 'No se pudo crear la variante';
      notifyListeners();
      return null;
    }
  }

  Future<bool> actualizarCategoria(
    int id, {
    required String nombre,
    String? descripcion,
    String? icono,
    String? color,
  }) async {
    try {
      final actualizada = await _service.updateCategoria(
        id,
        nombre: nombre,
        descripcion: descripcion,
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
      errorMessage = 'No se pudo actualizar la categoría';
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
      errorMessage = 'No se pudo eliminar la categoría';
      notifyListeners();
      return false;
    }
  }

  // ─── Variantes inactivas ────────────────────────────────────────────────

  /// Carga la primera página de variantes inactivas. Reinicia la paginación
  /// y reemplaza la lista actual — úsalo al entrar a la pantalla o al buscar.
  Future<void> cargarVariantesInactivas({String? search}) async {
    isLoadingInactivas = true;
    errorInactivas = null;
    _paginaInactivas = 1;
    notifyListeners();
    try {
      final pagina = await _service.getVariantesInactivas(page: 1, search: search);
      variantesInactivas = pagina.items;
      hayMasInactivas = pagina.hasMore;
    } catch (e, st) {
      debugPrint('❌ cargarVariantesInactivas: $e\n$st');
      errorInactivas = 'No se pudieron cargar las variantes inactivas';
    } finally {
      isLoadingInactivas = false;
      notifyListeners();
    }
  }

  /// Carga la siguiente página y la agrega al final de la lista actual
  /// (scroll infinito / "cargar más").
  Future<void> cargarMasVariantesInactivas({String? search}) async {
    if (!hayMasInactivas || isLoadingInactivas) return;
    isLoadingInactivas = true;
    notifyListeners();
    try {
      final siguiente = _paginaInactivas + 1;
      final pagina = await _service.getVariantesInactivas(page: siguiente, search: search);
      variantesInactivas = [...variantesInactivas, ...pagina.items];
      hayMasInactivas = pagina.hasMore;
      _paginaInactivas = siguiente;
    } catch (e, st) {
      debugPrint('❌ cargarMasVariantesInactivas: $e\n$st');
      errorInactivas = 'No se pudieron cargar más variantes';
    } finally {
      isLoadingInactivas = false;
      notifyListeners();
    }
  }

  /// Reactiva una variante (activo = true), la quita de la lista local
  /// de inactivas, y la inserta en el producto correspondiente dentro de
  /// `productos` si ese producto ya está cargado en memoria.
  /// Devuelve la variante actualizada, o null si falló.
  Future<ProductoVarianteModel?> reactivarVariante(int productoId, int varianteId) async {
    isReactivando = true;
    notifyListeners();
    try {
      final reactivada = await _service.reactivarVariante(productoId, varianteId);

      variantesInactivas = variantesInactivas.where((v) => v.variante.id != varianteId).toList();

      final index = productos.indexWhere((p) => p.id == productoId);
      if (index >= 0) {
        final actual = productos[index];
        final yaExiste = actual.variantes.any((v) => v.id == varianteId);
        final variantesActualizadas = yaExiste
            ? [
                for (final v in actual.variantes) v.id == varianteId ? reactivada : v,
              ]
            : [...actual.variantes, reactivada];

        productos[index] = ProductoModel(
          id: actual.id,
          categoriaId: actual.categoriaId,
          nombre: actual.nombre,
          descripcion: actual.descripcion,
          activo: actual.activo,
          tieneVariantes: actual.tieneVariantes,
          categoria: actual.categoria,
          variantes: variantesActualizadas,
        );
      }

      return reactivada;
    } catch (e) {
      debugPrint('❌ reactivarVariante: $e');
      errorInactivas = 'No se pudo reactivar la variante';
      return null;
    } finally {
      isReactivando = false;
      notifyListeners();
    }
  }
}
