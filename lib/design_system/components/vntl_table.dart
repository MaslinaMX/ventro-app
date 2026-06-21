import 'package:flutter/material.dart';
import 'package:ventro_app/design_system/vntl.dart';

/// Definición de una columna de [VntlTable].
class VntlTableColumn<T> {
  final String label;
  final Widget Function(T item) cellBuilder;

  /// Ancho relativo de la columna en modo desktop (flex). Default: 1.
  final int flex;

  /// Alineación del contenido de la celda.
  final Alignment alignment;

  const VntlTableColumn({
    required this.label,
    required this.cellBuilder,
    this.flex = 1,
    this.alignment = Alignment.centerLeft,
  });
}

/// Tabla responsiva: columnas en pantallas anchas, cards apiladas en móvil.
///
/// En móvil, cada fila se renderiza como una card con pares "label: valor"
/// en vez de forzar scroll horizontal, que es mala UX en touch.
class VntlTable<T> extends StatelessWidget {
  final List<VntlTableColumn<T>> columns;
  final List<T> items;
  final String emptyLabel;
  final bool isLoading;
  final double mobileBreakpoint;
  final void Function(T item)? onRowTap;

  const VntlTable({
    super.key,
    required this.columns,
    required this.items,
    this.emptyLabel = 'Sin datos',
    this.isLoading = false,
    this.mobileBreakpoint = 700,
    this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: VntlSpacing.xl2),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: VntlSpacing.xl2),
        child: Center(
          child: Text(emptyLabel, style: VntlText.body.copyWith(color: colors.textTertiary)),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < mobileBreakpoint;
        return isMobile ? _buildCards(colors) : _buildTable(colors);
      },
    );
  }

  Widget _buildTable(dynamic colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: VntlRadius.lgBorderRadius,
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Column(
        children: [
          _buildHeaderRow(colors),
          Divider(color: colors.border, height: 0.5),
          ...items.asMap().entries.map((entry) {
            final isLast = entry.key == items.length - 1;
            return Column(
              children: [
                _buildDataRow(colors, entry.value),
                if (!isLast) Divider(color: colors.border, height: 0.5),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(dynamic colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: VntlSpacing.lg, vertical: VntlSpacing.md),
      child: Row(
        children: columns
            .map(
              (col) => Expanded(
                flex: col.flex,
                child: Align(
                  alignment: col.alignment,
                  child: Text(
                    col.label,
                    style: VntlText.labelSmall.copyWith(color: colors.textSecondary),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildDataRow(dynamic colors, T item) {
    return InkWell(
      onTap: onRowTap != null ? () => onRowTap!(item) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: VntlSpacing.lg, vertical: VntlSpacing.md),
        child: Row(
          children: columns
              .map(
                (col) => Expanded(
                  flex: col.flex,
                  child: Align(
                    alignment: col.alignment,
                    child: col.cellBuilder(item),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildCards(dynamic colors) {
    return Column(
      children: items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: VntlSpacing.sm),
          padding: const EdgeInsets.all(VntlSpacing.lg),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: VntlRadius.lgBorderRadius,
            border: Border.all(color: colors.border, width: 0.5),
          ),
          child: InkWell(
            onTap: onRowTap != null ? () => onRowTap!(item) : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: columns.map((col) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: VntlSpacing.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 110,
                        child: Text(
                          col.label,
                          style: VntlText.labelSmall.copyWith(color: colors.textSecondary),
                        ),
                      ),
                      Expanded(child: col.cellBuilder(item)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      }).toList(),
    );
  }
}
