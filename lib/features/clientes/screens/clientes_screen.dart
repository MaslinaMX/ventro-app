import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/clientes/controllers/clientes_controller.dart';
import 'package:ventro_app/features/clientes/models/cliente_model.dart';
import 'package:ventro_app/features/clientes/screens/cliente_detalle_screen.dart';
import 'package:ventro_app/features/clientes/screens/cliente_form_screen.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  late final ClientesController _controller;
  final _busquedaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = ClientesController();
    _controller.cargarClientes();
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _abrirFormulario(BuildContext context, [ClienteModel? cliente]) async {
    final guardado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ClienteFormScreen(cliente: cliente)),
    );
    if (guardado == true) {
      _controller.cargarClientes();
    }
  }

  Future<void> _confirmarEliminar(BuildContext context, ClienteModel cliente) async {
    final confirmado = await VntlDialog.confirm(
      context,
      title: 'Eliminar cliente',
      message: '¿Eliminar a "${cliente.nombre}"? Esta acción no se puede deshacer.',
      confirmLabel: 'Eliminar',
      destructive: true,
    );
    if (confirmado != true) return;

    final error = await _controller.eliminarCliente(cliente.id);
    if (!context.mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(gradient: context.backgroundGradient),
          child: Consumer<ClientesController>(
            builder: (context, ctrl, _) {
              return Padding(
                padding: const EdgeInsets.all(VntlSpacing.xl3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Clientes', style: VntlText.h2),
                              const SizedBox(height: VntlSpacing.xs),
                              Text(
                                'Gestión clientes y contactos.',
                                style: VntlText.body.copyWith(color: colors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        VntlButton(
                          label: 'Nuevo cliente',
                          icon: Icons.person_add_rounded,
                          fullWidth: false,
                          size: VntlButtonSize.sm,
                          onPressed: () => _abrirFormulario(context),
                        ),
                      ],
                    ),
                    SizedBox(height: VntlSpacing.xl2),
                    VntlInput(
                      hint: 'Buscar por nombre, RFC, teléfono o correo...',
                      controller: _busquedaCtrl,
                      prefixIcon: Icons.search_rounded,
                      onChanged: ctrl.buscar,
                    ),
                    const SizedBox(height: VntlSpacing.lg),
                    if (ctrl.status == ClientesStatus.error)
                      Padding(
                        padding: const EdgeInsets.only(bottom: VntlSpacing.md),
                        child: Text(
                          ctrl.errorMessage ?? 'No se pudieron cargar los clientes.',
                          style: VntlText.body.copyWith(color: colors.error),
                        ),
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: VntlTable<ClienteModel>(
                          isLoading: ctrl.isLoading,
                          emptyLabel: 'Sin clientes registrados',
                          items: ctrl.clientes,
                          onRowTap: (cliente) => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ClienteDetalleScreen(clienteId: cliente.id)),
                          ),
                          columns: [
                            VntlTableColumn<ClienteModel>(
                              label: 'Nombre',
                              flex: 3,
                              sortValue: (c) => c.nombre,
                              cellBuilder: (c) => Text(
                                c.nombre,
                                style: VntlText.body.copyWith(
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            VntlTableColumn<ClienteModel>(
                              label: 'Tipo',
                              flex: 2,
                              cellBuilder: (c) => Text(
                                c.tipo.label,
                                style: VntlText.body.copyWith(color: colors.textSecondary),
                              ),
                            ),
                            VntlTableColumn<ClienteModel>(
                              label: 'Teléfono',
                              flex: 2,
                              cellBuilder: (c) => Text(
                                c.telefono ?? '—',
                                style: VntlText.body.copyWith(color: colors.textSecondary),
                              ),
                            ),
                            VntlTableColumn<ClienteModel>(
                              label: 'RFC',
                              flex: 2,
                              sortValue: (c) => c.rfc ?? '',
                              cellBuilder: (c) => Text(
                                c.rfc ?? '—',
                                style: VntlText.body.copyWith(color: colors.textSecondary),
                              ),
                            ),
                            VntlTableColumn<ClienteModel>(
                              label: 'Estado',
                              flex: 1,
                              cellBuilder: (c) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: c.activo ? colors.successSurface : colors.errorSurface,
                                  borderRadius: VntlRadius.smBorderRadius,
                                ),
                                child: Text(
                                  c.activo ? 'Activo' : 'Inactivo',
                                  style: VntlText.caption.copyWith(
                                    color: c.activo ? colors.success : colors.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            VntlTableColumn<ClienteModel>(
                              label: '',
                              flex: 1,
                              alignment: Alignment.centerRight,
                              cellBuilder: (c) => Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit_outlined, color: colors.textSecondary),
                                    tooltip: 'Editar',
                                    onPressed: () => _abrirFormulario(context, c),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline_rounded, color: colors.error),
                                    tooltip: 'Eliminar',
                                    onPressed: () => _confirmarEliminar(context, c),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
