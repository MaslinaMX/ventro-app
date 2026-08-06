// V1

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:ventro_app/features/catalogo_publico/models/negocio_publico_model.dart';
import 'package:ventro_app/features/products/models/categoria_model.dart';
import 'package:ventro_app/features/products/models/producto_model.dart';
import 'package:ventro_app/features/products/models/producto_variante_model.dart';
import 'package:ventro_app/features/catalogo_publico/services/catalogo_publico_service.dart';

enum CatalogoPublicoStatus { idle, loading, success, error }

/// Controller del catálogo público — mismo patrón de filtros (búsqueda,
/// categoría) que VentaController, pero sin carrito, sin stock, y sin
/// depender de sesión/sucursal. El tenant se identifica por `slug`, que
/// debe conocerse antes de instanciar (extraído del subdominio en web,
/// o del deep link en la app nativa).
class CatalogoPublicoController extends ChangeNotifier {
  final CatalogoPublicoService _service = CatalogoPublicoService();

  final String slug;

  CatalogoPublicoController({required this.slug});

  CatalogoPublicoStatus _status = CatalogoPublicoStatus.idle;
  String? _errorMessage;
  List<ProductoModel> _productos = [];
  NegocioPublicoModel? _negocio;

  int? _categoriaSeleccionadaId; // null = "Todas"
  String _busqueda = '';

  CatalogoPublicoStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == CatalogoPublicoStatus.loading;
  int? get categoriaSeleccionadaId => _categoriaSeleccionadaId;
  String get busqueda => _busqueda;
  NegocioPublicoModel? get negocio => _negocio;

  /// Categorías derivadas de los productos ya cargados (no hay endpoint
  /// aparte de categorías en el catálogo público).
  List<CategoriaModel> get categorias {
    final vistas = <int, CategoriaModel>{};
    for (final producto in _productos) {
      final categoria = producto.categoria;
      if (categoria == null) continue;
      vistas[categoria.id] = categoria;
    }
    return vistas.values.toList();
  }

  /// Lista plana de variantes visibles, ya filtradas por categoría y
  /// búsqueda — mismo shape que VentaController.variantesVisibles para
  /// poder reusar ProductoGridCard sin cambios.
  List<({ProductoVarianteModel variante, ProductoModel producto})> get variantesVisibles {
    final resultado = <({ProductoVarianteModel variante, ProductoModel producto})>[];

    for (final producto in _productos) {
      if (_categoriaSeleccionadaId != null && producto.categoriaId != _categoriaSeleccionadaId) {
        continue;
      }

      for (final variante in producto.variantes) {
        if (_busqueda.isNotEmpty) {
          final q = _busqueda.toLowerCase();
          final matchNombre = producto.nombre.toLowerCase().contains(q) ||
              variante.nombre.toLowerCase().contains(q);
          if (!matchNombre) continue;
        }

        resultado.add((variante: variante, producto: producto));
      }
    }

    return resultado;
  }

  Future<void> cargarDatos() async {
    _status = CatalogoPublicoStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final resultados = await Future.wait([
        _service.getProductos(slug),
        _service.getNegocio(slug),
      ]);
      _productos = resultados[0] as List<ProductoModel>;
      _negocio = resultados[1] as NegocioPublicoModel;
      _status = CatalogoPublicoStatus.success;
    } on DioException catch (e) {
      _status = CatalogoPublicoStatus.error;
      _errorMessage = _parseError(e);
    } catch (e) {
      _status = CatalogoPublicoStatus.error;
      _errorMessage = 'Error inesperado al cargar el catálogo';
    }
    notifyListeners();
  }

  void filtrarPorCategoria(int? categoriaId) {
    _categoriaSeleccionadaId = categoriaId;
    notifyListeners();
  }

  void buscar(String query) {
    _busqueda = query;
    notifyListeners();
  }

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final message = data['message'];
      if (message != null) return message.toString();
    }
    return 'Error de conexión. Intenta de nuevo.';
  }
}
