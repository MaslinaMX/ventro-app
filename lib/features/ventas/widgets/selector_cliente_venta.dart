import 'package:flutter/material.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/clientes/models/cliente_model.dart';
import 'package:ventro_app/features/clientes/screens/cliente_form_screen.dart';
import 'package:ventro_app/features/clientes/services/cliente_service.dart';

class ClienteSeleccionado {
  const ClienteSeleccionado({this.id, this.nombre});

  /// null = "Público en general"
  final int? id;
  final String? nombre;
}

Future<ClienteSeleccionado?> abrirSelectorClienteVenta(BuildContext context) {
  return VntlModal.show<ClienteSeleccionado>(
    context,
    title: '¿A nombre de quién es la venta?',
    width: 440,
    showClose: false, // se obliga a elegir una opción
    content: const _SelectorClienteContent(),
  );
}

class _SelectorClienteContent extends StatefulWidget {
  const _SelectorClienteContent();

  @override
  State<_SelectorClienteContent> createState() => _SelectorClienteContentState();
}

class _SelectorClienteContentState extends State<_SelectorClienteContent> {
  final _service = ClienteService();
  final _busquedaCtrl = TextEditingController();

  List<ClienteModel> _todos = [];
  List<ClienteModel> _filtrados = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    try {
      final clientes = await _service.getClientes(activo: true);
      if (!mounted) return;
      setState(() {
        _todos = clientes;
        _filtrados = clientes;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar los clientes';
        _cargando = false;
      });
    }
  }

  void _filtrar(String query) {
    final q = query.toLowerCase();
    setState(() {
      _filtrados = q.isEmpty
          ? _todos
          : _todos.where((c) {
              return c.nombre.toLowerCase().contains(q) ||
                  (c.telefono?.contains(q) ?? false) ||
                  (c.rfc?.toLowerCase().contains(q) ?? false);
            }).toList();
    });
  }

  Future<void> _agregarCliente(BuildContext context) async {
    final creado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const ClienteFormScreen()),
    );
    if (creado == true) {
      await _cargar(); // recarga la lista para que aparezca el nuevo cliente
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Público en general ────────────────────────────────────────
        Material(
          color: Colors.transparent,
          borderRadius: VntlRadius.mdBorderRadius,
          child: InkWell(
            borderRadius: VntlRadius.mdBorderRadius,
            onTap: () => Navigator.pop(context, const ClienteSeleccionado()),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: VntlSpacing.md,
                vertical: VntlSpacing.md,
              ),
              decoration: BoxDecoration(
                color: colors.primarySurface,
                borderRadius: VntlRadius.mdBorderRadius,
                border: Border.all(color: colors.primary, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.storefront_rounded, color: colors.primary, size: 20),
                  const SizedBox(width: VntlSpacing.sm),
                  Expanded(
                    child: Text(
                      'Público en general',
                      style: VntlText.label.copyWith(color: colors.primary),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: colors.primary, size: 18),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: VntlSpacing.lg),
        Divider(color: colors.border, height: 0.5),
        const SizedBox(height: VntlSpacing.lg),
        Row(
          children: [
            Expanded(
              child: VntlInput(
                hint: 'Buscar cliente por nombre, teléfono o RFC...',
                controller: _busquedaCtrl,
                prefixIcon: Icons.search_rounded,
                onChanged: _filtrar,
              ),
            ),
            const SizedBox(width: VntlSpacing.sm),
            Material(
              color: Colors.transparent,
              borderRadius: VntlRadius.mdBorderRadius,
              child: InkWell(
                borderRadius: VntlRadius.mdBorderRadius,
                onTap: () => _agregarCliente(context),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.primarySurface,
                    borderRadius: VntlRadius.mdBorderRadius,
                    border: Border.all(color: colors.primary, width: 0.5),
                  ),
                  child: Icon(Icons.person_add_alt_rounded, color: colors.primary, size: 20),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: VntlSpacing.md),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 320),
          child: _cargando
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: VntlSpacing.xl),
                  child: Center(child: CircularProgressIndicator()),
                )
              : _error != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: VntlSpacing.lg),
                      child: Text(_error!, style: VntlText.body.copyWith(color: colors.error)),
                    )
                  : _filtrados.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: VntlSpacing.lg),
                          child: Text(
                            'Sin clientes registrados',
                            style: VntlText.body.copyWith(color: colors.textTertiary),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _filtrados.length,
                          itemBuilder: (_, i) {
                            final cliente = _filtrados[i];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(cliente.nombre, style: VntlText.body),
                              subtitle: cliente.telefono != null
                                  ? Text(
                                      cliente.telefono!,
                                      style: VntlText.caption.copyWith(color: colors.textTertiary),
                                    )
                                  : null,
                              onTap: () => Navigator.pop(
                                context,
                                ClienteSeleccionado(id: cliente.id, nombre: cliente.nombre),
                              ),
                            );
                          },
                        ),
        ),
      ],
    );
  }
}
