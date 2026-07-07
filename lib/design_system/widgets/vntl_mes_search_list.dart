import 'package:flutter/material.dart';
import 'package:ventro_app/design_system/vntl.dart';

const List<String> _kNombresMeses = [
  'Enero',
  'Febrero',
  'Marzo',
  'Abril',
  'Mayo',
  'Junio',
  'Julio',
  'Agosto',
  'Septiembre',
  'Octubre',
  'Noviembre',
  'Diciembre',
];

/// Un mes seleccionable en formato 'YYYY-MM' con su etiqueta legible.
class VntlMesOption {
  final String value; // 'YYYY-MM'
  final String label; // ej. 'Julio 2026'

  const VntlMesOption({required this.value, required this.label});
}

/// Genera los últimos [cantidad] meses (incluyendo el actual), del más
/// reciente al más antiguo. Útil para poblar selectores de "mes" en
/// listados de ventas, movimientos, cortes, etc.
List<VntlMesOption> generarUltimosMeses({int cantidad = 12}) {
  final ahora = DateTime.now();
  return List.generate(cantidad, (i) {
    final fecha = DateTime(ahora.year, ahora.month - i, 1);
    final valor = '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}';
    return VntlMesOption(value: valor, label: '${_kNombresMeses[fecha.month - 1]} ${fecha.year}');
  });
}

/// Lista buscable de meses para usar dentro de un [VntlModal].
///
/// Al seleccionar un mes, hace `Navigator.pop(context, mes.value)`.
/// Si [incluirTodas] es true (default), se agrega una opción extra al
/// inicio que regresa `'TODOS'` como sentinela de "todas las fechas".
class VntlMesSearchList extends StatelessWidget {
  const VntlMesSearchList({
    super.key,
    required this.meses,
    this.incluirTodas = true,
    this.labelTodas = 'Todas las fechas',
  });

  final List<VntlMesOption> meses;
  final bool incluirTodas;
  final String labelTodas;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (incluirTodas) ...[
          ListTile(
            leading: Icon(Icons.all_inclusive_rounded, color: colors.textSecondary),
            title: Text(labelTodas, style: VntlText.body),
            onTap: () => Navigator.pop(context, 'TODOS'),
          ),
          Divider(color: colors.border, height: 0.5),
        ],
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 320),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: meses.length,
            itemBuilder: (_, i) {
              final m = meses[i];
              return ListTile(
                title: Text(m.label, style: VntlText.body),
                onTap: () => Navigator.pop(context, m.value),
              );
            },
          ),
        ),
      ],
    );
  }
}
