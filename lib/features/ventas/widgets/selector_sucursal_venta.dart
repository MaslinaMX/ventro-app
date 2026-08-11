import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/settings/models/sucursal_model.dart';
import 'package:ventro_app/features/settings/services/settings_service.dart';
import 'package:ventro_app/features/ventas/controllers/venta_controller.dart';

class SelectorSucursalVenta extends StatefulWidget {
  const SelectorSucursalVenta({super.key});

  @override
  State<SelectorSucursalVenta> createState() => _SelectorSucursalVentaState();
}

class _SelectorSucursalVentaState extends State<SelectorSucursalVenta> {
  bool _loading = true;
  List<SucursalModel> _sucursales = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final list = await SettingsService().getSucursales();
      if (!mounted) return;

      if (list.length == 1) {
        // Solo hay una sucursal: se selecciona sola, sin mostrar el selector.
        context.read<VentaController>().seleccionarSucursal(list.first.id);
        return;
      }

      setState(() {
        _sucursales = list;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_sucursales.isEmpty) {
      return Center(
        child: Text(
          'No hay sucursales configuradas.',
          style: VntlText.body.copyWith(color: colors.textSecondary),
        ),
      );
    }

    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(VntlSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selecciona una sucursal', style: VntlText.h3),
            const SizedBox(height: VntlSpacing.xs),
            Text(
              'Elige la sucursal desde la que vas a vender',
              style: VntlText.body.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: VntlSpacing.xl),
            Wrap(
              spacing: VntlSpacing.md,
              runSpacing: VntlSpacing.md,
              children: _sucursales
                  .map((s) => _SucursalCard(
                        nombre: s.nombre,
                        onTap: () => context.read<VentaController>().seleccionarSucursal(s.id),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SucursalCard extends StatelessWidget {
  final String nombre;
  final VoidCallback onTap;
  const _SucursalCard({required this.nombre, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(VntlSpacing.lg),
        decoration: BoxDecoration(
          color: colors.glassSurface,
          borderRadius: VntlRadius.lgBorderRadius,
          border: Border.all(color: colors.border, width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.store_rounded, color: colors.primary),
            const SizedBox(width: VntlSpacing.md),
            Expanded(child: Text(nombre, style: VntlText.h4)),
          ],
        ),
      ),
    );
  }
}
