import 'package:flutter/material.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/settings/models/sucursal_model.dart';

/// Lista buscable de sucursales para usar dentro de un [VntlModal].
///
/// Al seleccionar una sucursal, hace `Navigator.pop(context, sucursal.id)`.
/// Si [incluirTodas] es true, se agrega una opción extra al inicio que
/// regresa `-1` como sentinela de "todas las sucursales".
class VntlSucursalSearchList extends StatefulWidget {
  final List<SucursalModel> sucursales;
  final bool incluirTodas;
  final String labelTodas;

  const VntlSucursalSearchList({
    super.key,
    required this.sucursales,
    this.incluirTodas = false,
    this.labelTodas = 'Todas las sucursales',
  });

  @override
  State<VntlSucursalSearchList> createState() => _VntlSucursalSearchListState();
}

class _VntlSucursalSearchListState extends State<VntlSucursalSearchList> {
  final _searchController = TextEditingController();
  late List<SucursalModel> _filtradas;

  @override
  void initState() {
    super.initState();
    _filtradas = widget.sucursales;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filtrar(String query) {
    setState(() {
      _filtradas = widget.sucursales
          .where((s) => s.nombre.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VntlInput(
          hint: 'Buscar sucursal...',
          autofocus: true,
          controller: _searchController,
          prefixIcon: Icons.search,
          onChanged: _filtrar,
        ),
        const SizedBox(height: VntlSpacing.md),
        if (widget.incluirTodas) ...[
          ListTile(
            leading: Icon(Icons.apps_rounded, color: colors.textSecondary),
            title: Text(widget.labelTodas, style: VntlText.body),
            onTap: () => Navigator.pop(context, -1),
          ),
          Divider(color: colors.border, height: 0.5),
        ],
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 320),
          child: _filtradas.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(VntlSpacing.lg),
                  child: Text(
                    'Sin resultados',
                    style: VntlText.body.copyWith(color: colors.textTertiary),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filtradas.length,
                  itemBuilder: (_, i) {
                    final item = _filtradas[i];
                    return ListTile(
                      title: Text(item.nombre, style: VntlText.body),
                      onTap: () => Navigator.pop(context, item.id),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
