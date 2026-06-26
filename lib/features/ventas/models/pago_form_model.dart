import 'package:flutter/material.dart';
import 'package:ventro_app/features/metodos_pago/models/metodo_pago_model.dart';

class PagoFormModel {
  final MetodoPagoModel metodoPago;
  double monto;
  String referencia;
  final TextEditingController montoCtrl;
  final TextEditingController referenciaCtrl;
  final TextEditingController recibidoCtrl;

  PagoFormModel({
    required this.metodoPago,
    required this.monto,
    this.referencia = '',
  })  : montoCtrl = TextEditingController(text: monto.toStringAsFixed(2)),
        referenciaCtrl = TextEditingController(),
        recibidoCtrl = TextEditingController(text: monto.toStringAsFixed(2));

  void dispose() {
    montoCtrl.dispose();
    referenciaCtrl.dispose();
    recibidoCtrl.dispose();
  }

  /// true si este pago es en efectivo, por nombre del método.
  /// Efectivo es el único método donde aplica "recibido > monto" con cambio.
  bool get esEfectivo => metodoPago.nombre.toLowerCase() == 'efectivo';

  Map<String, dynamic> toPayload() {
    return {
      'metodo_pago_id': metodoPago.id,
      'monto': monto,
      if (referencia.isNotEmpty) 'referencia': referencia,
    };
  }
}
