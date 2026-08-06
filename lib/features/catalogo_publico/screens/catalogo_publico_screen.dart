// V2

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/core/utils/tenant_slug_resolver.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/catalogo_publico/controllers/catalogo_publico_controller.dart';
import 'package:ventro_app/features/catalogo_publico/models/negocio_publico_model.dart';
import 'package:ventro_app/features/catalogo_publico/widgets/producto_publico_card.dart';
import 'package:ventro_app/features/products/models/categoria_model.dart';
import 'package:ventro_app/features/products/models/producto_model.dart';
import 'package:ventro_app/features/products/models/producto_variante_model.dart';

/// Pantalla del catálogo público — el negocio comparte el link
/// (slug.ventro.com.mx/catalogo) y cualquier visitante, sin cuenta, ve
/// sus productos activos. Layout inspirado en iCloud.com: card del
/// negocio (logo + nombre + contacto) junto a un grid de categorías
/// con ícono y color propios, y debajo los productos filtrados.
/// Sin carrito ni precio: aquí no se vende, solo se muestra — el tap en
/// una variante abrirá un modal de detalle (vendrá después).
class CatalogoPublicoScreen extends StatelessWidget {
  const CatalogoPublicoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final slug = TenantSlugResolver.resolveFromWeb();

    if (slug == null) {
      return const Scaffold(
        body: Center(
          child: Text('No se pudo identificar el negocio.'),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => CatalogoPublicoController(slug: slug)..cargarDatos(),
      child: const _CatalogoPublicoBody(),
    );
  }
}

class _CatalogoPublicoBody extends StatefulWidget {
  const _CatalogoPublicoBody();

  @override
  State<_CatalogoPublicoBody> createState() => _CatalogoPublicoBodyState();
}

class _CatalogoPublicoBodyState extends State<_CatalogoPublicoBody> {
  final _busquedaCtrl = TextEditingController();

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  void _abrirDetalle(BuildContext context, ProductoModel producto, ProductoVarianteModel variante) {
    VntlModal.show<void>(
      context,
      title: producto.nombre,
      subtitle: variante.nombre,
      width: 420,
      content: _ProductoDetalleModalContent(producto: producto, variante: variante),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ctrl = context.watch<CatalogoPublicoController>();
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900.0;

    if (ctrl.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (ctrl.status == CatalogoPublicoStatus.error) {
      return Scaffold(
        body: Center(
          child: Text(
            ctrl.errorMessage ?? 'No se pudo cargar el catálogo.',
            style: VntlText.body.copyWith(color: colors.textSecondary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: context.backgroundGradient),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CatalogoAppBar(isMobile: isMobile),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: Padding(
                          padding: EdgeInsets.all(isMobile ? VntlSpacing.md : VntlSpacing.xl),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              isMobile
                                  ? Column(
                                      children: [
                                        _NegocioInfoCard(negocio: ctrl.negocio),
                                        const SizedBox(height: VntlSpacing.md),
                                        _CategoriasGridCard(
                                          categorias: ctrl.categorias,
                                          seleccionadaId: ctrl.categoriaSeleccionadaId,
                                          onSeleccionar: ctrl.filtrarPorCategoria,
                                          isMobile: true,
                                        ),
                                      ],
                                    )
                                  : IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: _NegocioInfoCard(negocio: ctrl.negocio),
                                          ),
                                          const SizedBox(width: VntlSpacing.md),
                                          Expanded(
                                            flex: 3,
                                            child: _CategoriasGridCard(
                                              categorias: ctrl.categorias,
                                              seleccionadaId: ctrl.categoriaSeleccionadaId,
                                              onSeleccionar: ctrl.filtrarPorCategoria,
                                              isMobile: false,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                              const SizedBox(height: VntlSpacing.lg),
                              VntlInput(
                                hint: 'Buscar producto...',
                                controller: _busquedaCtrl,
                                prefixIcon: Icons.search_rounded,
                                onChanged: ctrl.buscar,
                              ),
                              const SizedBox(height: VntlSpacing.lg),
                              ctrl.variantesVisibles.isEmpty
                                  ? Padding(
                                      padding:
                                          const EdgeInsets.symmetric(vertical: VntlSpacing.xl5),
                                      child: Center(
                                        child: Text(
                                          'Sin productos para mostrar',
                                          style: VntlText.body.copyWith(
                                            color: colors.textTertiary,
                                          ),
                                        ),
                                      ),
                                    )
                                  : GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.only(bottom: VntlSpacing.xl2),
                                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: isMobile ? 200 : 233,
                                        mainAxisSpacing: VntlSpacing.md,
                                        crossAxisSpacing: VntlSpacing.md,
                                        childAspectRatio: isMobile ? 0.82 : 0.87,
                                      ),
                                      itemCount: ctrl.variantesVisibles.length,
                                      itemBuilder: (context, index) {
                                        final item = ctrl.variantesVisibles[index];
                                        return ProductoPublicoCard(
                                          variante: item.variante,
                                          producto: item.producto,
                                          onTap: () => _abrirDetalle(
                                            context,
                                            item.producto,
                                            item.variante,
                                          ),
                                        );
                                      },
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const _CatalogoFooter(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CatalogoAppBar extends StatelessWidget {
  final bool isMobile;

  const _CatalogoAppBar({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? VntlSpacing.lg : VntlSpacing.xl,
        vertical: VntlSpacing.md,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.border, width: 0.5)),
      ),
      child: Text(
        'Ventro',
        style: VntlText.h4.copyWith(color: colors.textPrimary, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _CatalogoFooter extends StatelessWidget {
  const _CatalogoFooter();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final anio = DateTime.now().year;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: VntlSpacing.xl, vertical: VntlSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border, width: 0.5)),
      ),
      child: Text(
        'Copyright © $anio Ventro. Todos los derechos reservados.',
        textAlign: TextAlign.center,
        style: VntlText.caption.copyWith(color: colors.textTertiary),
      ),
    );
  }
}

/// Card izquierda estilo iCloud (donde iCloud muestra "RO" + nombre +
/// email): logo del negocio, nombre, y contacto directo debajo (sin
/// modal — visible de una vez, como pidió Ramón).
class _NegocioInfoCard extends StatelessWidget {
  final NegocioPublicoModel? negocio;

  const _NegocioInfoCard({required this.negocio});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final n = negocio;

    return VntlCard(
      variant: VntlCardVariant.solid,
      padding: const EdgeInsets.all(VntlSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: colors.glassSurface,
              borderRadius: VntlRadius.lgBorderRadius,
              border: Border.all(color: colors.border, width: 0.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: n?.logo != null
                ? Image.network(
                    n!.logo!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.storefront_rounded,
                      color: colors.textTertiary,
                      size: 40,
                    ),
                  )
                : Icon(Icons.storefront_rounded, color: colors.textTertiary, size: 40),
          ),
          const SizedBox(height: VntlSpacing.md),
          Text(
            n?.nombre ?? '',
            textAlign: TextAlign.center,
            style: VntlText.h3.copyWith(color: colors.textPrimary),
          ),
          if (n?.contacto != null) ...[
            const SizedBox(height: VntlSpacing.md),
            _ContactoInfo(contacto: n!.contacto!),
          ],
        ],
      ),
    );
  }
}

class _ContactoInfo extends StatelessWidget {
  final ContactoNegocioModel contacto;

  const _ContactoInfo({required this.contacto});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final c = contacto;

    final filas = <Widget>[];

    void agregarFila(IconData icono, String? valor) {
      if (valor == null || valor.isEmpty) return;
      filas.add(Padding(
        padding: const EdgeInsets.only(top: VntlSpacing.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, size: 14, color: colors.textTertiary),
            const SizedBox(width: VntlSpacing.xs),
            Flexible(
              child: Text(
                valor,
                textAlign: TextAlign.left,
                style: VntlText.caption.copyWith(color: colors.textSecondary),
              ),
            ),
          ],
        ),
      ));
    }

    final direccionCompleta =
        [c.direccion, c.ciudad, c.estado].where((v) => v != null && v.isNotEmpty).join(', ');

    agregarFila(
        Icons.location_on_outlined, direccionCompleta.isNotEmpty ? direccionCompleta : null);
    agregarFila(Icons.phone_outlined, c.telefono);
    agregarFila(Icons.language_rounded, c.sitioWeb);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: filas,
    );
  }
}

/// Grid de categorías estilo iCloud (íconos coloridos tipo Mail, Fotos,
/// Notas...). Cada tile usa VntlCategoryStyle.forCategoria para su
/// ícono y color reales — mismos tokens que usa el resto de Ventro.
class _CategoriasGridCard extends StatelessWidget {
  final List<CategoriaModel> categorias;
  final int? seleccionadaId;
  final ValueChanged<int?> onSeleccionar;
  final bool isMobile;

  const _CategoriasGridCard({
    required this.categorias,
    required this.seleccionadaId,
    required this.onSeleccionar,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _CategoriaTile(
        label: 'Todas',
        selected: seleccionadaId == null,
        onTap: () => onSeleccionar(null),
      ),
      ...categorias.map((cat) => _CategoriaTile(
            label: cat.nombre,
            selected: seleccionadaId == cat.id,
            onTap: () => onSeleccionar(cat.id),
            categoria: cat,
          )),
    ];

    return VntlCard(
      variant: VntlCardVariant.solid,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? VntlSpacing.md : VntlSpacing.lg,
        vertical: VntlSpacing.lg,
      ),
      child: isMobile
          ? SizedBox(
              height: 88,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 0; i < tiles.length; i++) ...[
                            if (i > 0) const SizedBox(width: VntlSpacing.md),
                            tiles[i],
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          : Wrap(
              alignment: WrapAlignment.start,
              spacing: VntlSpacing.md,
              runSpacing: VntlSpacing.md,
              children: tiles,
            ),
    );
  }
}

class _CategoriaTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final CategoriaModel? categoria;

  const _CategoriaTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.categoria,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final style = categoria != null
        ? VntlCategoryStyle.forCategoria(
            context,
            categoria!.id,
            iconoKey: categoria!.icono,
            colorHex: categoria!.color,
          )
        : VntlCategoryStyle(
            background: colors.primarySurface,
            foreground: colors.primary,
            icon: Icons.apps_rounded,
          );

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: style.background,
                borderRadius: VntlRadius.mdBorderRadius,
                border: Border.all(
                  color: selected ? style.foreground : Colors.transparent,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Icon(style.icon, color: style.foreground, size: 26),
            ),
            const SizedBox(height: VntlSpacing.xs),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: VntlText.caption.copyWith(
                color: selected ? style.foreground : colors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Contenido del modal de detalle de producto — imagen, nombre, variante,
/// y descripción (si el producto tiene una capturada). Sin precio.
class _ProductoDetalleModalContent extends StatelessWidget {
  final ProductoModel producto;
  final ProductoVarianteModel variante;

  const _ProductoDetalleModalContent({required this.producto, required this.variante});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final imagen = variante.imagenPrincipal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: VntlRadius.mdBorderRadius,
          child: AspectRatio(
            aspectRatio: 1.4,
            child: imagen != null
                ? Image.network(imagen.path, fit: BoxFit.cover)
                : Container(
                    color: colors.surfaceSecondary,
                    alignment: Alignment.center,
                    child: Icon(Icons.inventory_2_rounded, size: 40, color: colors.textTertiary),
                  ),
          ),
        ),
        const SizedBox(height: VntlSpacing.lg),
        if (producto.descripcion != null && producto.descripcion!.isNotEmpty)
          Text(
            producto.descripcion!,
            style: VntlText.body.copyWith(color: colors.textSecondary),
          )
        else
          Text(
            'Este producto no tiene una descripción disponible.',
            style: VntlText.body.copyWith(color: colors.textTertiary),
          ),
      ],
    );
  }
}
