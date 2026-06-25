import 'package:ventro_app/features/products/models/producto_model.dart';
import 'package:ventro_app/features/products/models/producto_variante_model.dart';

/// Una línea del carrito: una variante específica + la cantidad elegida.
/// El producto padre se guarda solo para mostrar su nombre junto al de la
/// variante (ej. "Café - Chico"), no se usa para ningún cálculo.
class CarritoItemModel {
  final ProductoVarianteModel variante;
  final ProductoModel productoPadre;
  final int cantidad;

  const CarritoItemModel({
    required this.variante,
    required this.productoPadre,
    required this.cantidad,
  });

  String get nombreCompleto => '${productoPadre.nombre} - ${variante.nombre}';

  double get subtotal => variante.precioFinal * cantidad;

  CarritoItemModel copyWith({int? cantidad}) {
    return CarritoItemModel(
      variante: variante,
      productoPadre: productoPadre,
      cantidad: cantidad ?? this.cantidad,
    );
  }
}
