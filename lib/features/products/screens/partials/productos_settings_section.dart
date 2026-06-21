import 'package:flutter/material.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/products/screens/partials/categorias_settings_section.dart';

class ProductosSettingsSection extends StatefulWidget {
  const ProductosSettingsSection({super.key});

  @override
  State<ProductosSettingsSection> createState() => _ProductosSettingsSectionState();
}

class _ProductosSettingsSectionState extends State<ProductosSettingsSection> {
  String? _subSeccion;

  static const _opciones = [
    _ProductosOption(
      key: 'categorias',
      label: 'Categorías',
      description: 'Organiza tus productos y personaliza su color e ícon para mayor control visual',
      icon: Icons.category_rounded,
    ),
    _ProductosOption(
      key: 'alertas_stock',
      label: 'Alertas de stock',
      description: 'Define cuándo avisarte que un producto está por agotarse',
      icon: Icons.notifications_active_rounded,
    ),
  ];

  Widget _buildSubSeccion() {
    switch (_subSeccion) {
      case 'categorias':
        return const CategoriasSettingsSection();
      case 'alertas_stock':
        return const _ProximamentePlaceholder(
          icon: Icons.notifications_active_rounded,
          titulo: 'Alertas de stock',
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (_subSeccion != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(VntlSpacing.xl, VntlSpacing.lg, VntlSpacing.xl, 0),
            child: GestureDetector(
              onTap: () => setState(() => _subSeccion = null),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_rounded, size: 16, color: colors.textSecondary),
                  const SizedBox(width: VntlSpacing.xs),
                  Text('Productos', style: VntlText.label.copyWith(color: colors.textSecondary)),
                ],
              ),
            ),
          ),
          Expanded(child: _buildSubSeccion()),
        ],
      );
    }

    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(VntlSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Productos', style: VntlText.h3),
              const SizedBox(height: VntlSpacing.sm),
              Text(
                'Configura cómo se organizan y gestionan tus productos',
                style: VntlText.body.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: VntlSpacing.xl),
              LayoutBuilder(
                builder: (context, constraints) {
                  const anchoMinimo = 220.0;
                  final columnas = (constraints.maxWidth / anchoMinimo).floor().clamp(1, 4);
                  final ancho =
                      (constraints.maxWidth - (VntlSpacing.md * (columnas - 1))) / columnas;

                  return Wrap(
                    spacing: VntlSpacing.md,
                    runSpacing: VntlSpacing.md,
                    children: [
                      for (final opcion in _opciones)
                        SizedBox(
                          width: ancho,
                          child: _ProductosOptionCard(
                            opcion: opcion,
                            onTap: () => setState(() => _subSeccion = opcion.key),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductosOptionCard extends StatelessWidget {
  const _ProductosOptionCard({required this.opcion, required this.onTap});

  final _ProductosOption opcion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: Colors.transparent,
      borderRadius: VntlRadius.lgBorderRadius,
      child: InkWell(
        borderRadius: VntlRadius.lgBorderRadius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(VntlSpacing.lg),
          decoration: BoxDecoration(
            color: colors.glassSurface,
            borderRadius: VntlRadius.lgBorderRadius,
            border: Border.all(color: colors.border, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.primarySurface,
                  borderRadius: VntlRadius.mdBorderRadius,
                ),
                child: Icon(opcion.icon, color: colors.primary, size: 20),
              ),
              const SizedBox(height: VntlSpacing.md),
              Text(opcion.label, style: VntlText.label),
              const SizedBox(height: VntlSpacing.xs),
              Text(
                opcion.description,
                style: VntlText.caption.copyWith(color: colors.textTertiary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProximamentePlaceholder extends StatelessWidget {
  const _ProximamentePlaceholder({required this.icon, required this.titulo});

  final IconData icon;
  final String titulo;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: colors.textTertiary),
          const SizedBox(height: VntlSpacing.lg),
          Text(titulo, style: VntlText.h3),
          const SizedBox(height: VntlSpacing.sm),
          Text('Próximamente', style: VntlText.body.copyWith(color: colors.textSecondary)),
        ],
      ),
    );
  }
}

class _ProductosOption {
  const _ProductosOption({
    required this.key,
    required this.label,
    required this.description,
    required this.icon,
  });

  final String key;
  final String label;
  final String description;
  final IconData icon;
}
