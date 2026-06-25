import 'package:flutter/material.dart';
import 'package:ventro_app/design_system/vntl.dart';

enum VntlSortDirection { ascending, descending }

/// Definición de una columna de [VntlTable].
class VntlTableColumn<T> {
  final String label;
  final Widget Function(T item) cellBuilder;

  /// Ancho relativo de la columna en modo desktop (flex). Default: 1.
  final int flex;

  /// Alineación del contenido de la celda.
  final Alignment alignment;

  /// Si se provee, esta columna es ordenable. Recibe el item y regresa
  /// el valor comparable usado para el sort (String, num, DateTime, etc).
  final Comparable Function(T item)? sortValue;

  const VntlTableColumn({
    required this.label,
    required this.cellBuilder,
    this.flex = 1,
    this.alignment = Alignment.centerLeft,
    this.sortValue,
  });
}

/// Tabla responsiva: columnas en pantallas anchas, cards apiladas en móvil.
///
/// En móvil, cada fila se renderiza como una card con pares "label: valor"
/// en vez de forzar scroll horizontal, que es mala UX en touch.
///
/// Si alguna columna define [VntlTableColumn.sortValue], su header se vuelve
/// clickeable y la tabla maneja el ordenamiento internamente (no requiere
/// que quien la usa reordene `items` manualmente).
class VntlTable<T> extends StatefulWidget {
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
  State<VntlTable<T>> createState() => _VntlTableState<T>();
}

class _VntlTableState<T> extends State<VntlTable<T>> {
  int? _sortColumnIndex;
  VntlSortDirection _sortDirection = VntlSortDirection.ascending;

  List<T> get _itemsOrdenados {
    if (_sortColumnIndex == null) return widget.items;
    final columna = widget.columns[_sortColumnIndex!];
    final sortValue = columna.sortValue;
    if (sortValue == null) return widget.items;

    final copia = List<T>.from(widget.items);
    copia.sort((a, b) {
      final cmp = sortValue(a).compareTo(sortValue(b));
      return _sortDirection == VntlSortDirection.ascending ? cmp : -cmp;
    });
    return copia;
  }

  void _onHeaderTap(int index) {
    final columna = widget.columns[index];
    if (columna.sortValue == null) return;

    setState(() {
      if (_sortColumnIndex == index) {
        _sortDirection = _sortDirection == VntlSortDirection.ascending
            ? VntlSortDirection.descending
            : VntlSortDirection.ascending;
      } else {
        _sortColumnIndex = index;
        _sortDirection = VntlSortDirection.ascending;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (widget.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: VntlSpacing.xl2),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: VntlSpacing.xl2),
        child: Center(
          child: Text(widget.emptyLabel, style: VntlText.body.copyWith(color: colors.textTertiary)),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < widget.mobileBreakpoint;
        return isMobile ? _buildCards(colors) : _buildTable(colors);
      },
    );
  }

  Widget _buildTable(dynamic colors) {
    final items = _itemsOrdenados;
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
        children: widget.columns.asMap().entries.map((entry) {
          final index = entry.key;
          final col = entry.value;
          final esOrdenable = col.sortValue != null;
          final esActiva = _sortColumnIndex == index;

          return Expanded(
            flex: col.flex,
            child: Align(
              alignment: col.alignment,
              child: GestureDetector(
                onTap: esOrdenable ? () => _onHeaderTap(index) : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      col.label,
                      style: VntlText.labelSmall.copyWith(
                        color: esActiva ? colors.primary : colors.textSecondary,
                      ),
                    ),
                    if (esOrdenable) ...[
                      const SizedBox(width: 2),
                      Icon(
                        !esActiva
                            ? Icons.unfold_more_rounded
                            : _sortDirection == VntlSortDirection.ascending
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                        size: 12,
                        color: esActiva ? colors.primary : colors.textTertiary,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDataRow(dynamic colors, T item) {
    return InkWell(
      onTap: widget.onRowTap != null ? () => widget.onRowTap!(item) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: VntlSpacing.lg, vertical: VntlSpacing.md),
        child: Row(
          children: widget.columns
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
    final items = _itemsOrdenados;
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
            onTap: widget.onRowTap != null ? () => widget.onRowTap!(item) : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.columns.map((col) {
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
