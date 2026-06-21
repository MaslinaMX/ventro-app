import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/account/controllers/account_controller.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      context.read<AccountController>().load();
    }
  }

  Future<void> _confirmCancel() async {
    final colors = context.colors;
    final confirmed = await VntlModal.show<bool>(
      context,
      title: 'Cancelar suscripción',
      subtitle: '¿Estás seguro? Esta acción no se puede deshacer.',
      width: 440,
      content: Text(
        'Al cancelar se detendrán los cobros futuros. Tus datos no se eliminarán de inmediato.',
        style: VntlText.body.copyWith(color: colors.textSecondary),
      ),
      actions: [
        VntlButton(
          label: 'Mantener suscripción',
          variant: VntlButtonVariant.ghost,
          onPressed: () => Navigator.pop(context, false),
        ),
        VntlButton(
          label: 'Cancelar suscripción',
          variant: VntlButtonVariant.danger,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
    if (confirmed == true) {
      // TODO: implementar cancelación
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: context.backgroundGradient),
        child: Column(
          children: [
            VntlAppBar(
              title: 'Cuenta',
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back_rounded, color: colors.textSecondary, size: 20),
              ),
            ),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final ctrl = context.watch<AccountController>();
    final colors = context.colors;

    if (ctrl.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (ctrl.status == AccountStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: colors.error),
            const SizedBox(height: VntlSpacing.lg),
            Text(ctrl.errorMessage ?? 'Error',
                style: VntlText.body.copyWith(color: colors.textSecondary)),
            const SizedBox(height: VntlSpacing.lg),
            VntlButton(
              label: 'Reintentar',
              onPressed: () => context.read<AccountController>().load(),
            ),
          ],
        ),
      );
    }

    final account = ctrl.account;
    if (account == null) return const SizedBox.shrink();
    final sub = account.subscription;

    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(VntlSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Banner trial ────────────────────────────────────────────
            if (sub.isTrial) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: VntlSpacing.lg,
                  vertical: VntlSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: sub.daysLeft <= 3 ? colors.errorSurface : colors.primarySurface,
                  borderRadius: VntlRadius.mdBorderRadius,
                  border: Border.all(
                    color: sub.daysLeft <= 3
                        ? colors.error.withValues(alpha: 0.3)
                        : colors.primary.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      sub.daysLeft <= 3 ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                      color: sub.daysLeft <= 3 ? colors.error : colors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: VntlSpacing.md),
                    Text(
                      sub.daysLeft == 0
                          ? 'Tu periodo de prueba ha vencido'
                          : 'Faltan ${sub.daysLeft} día${sub.daysLeft == 1 ? '' : 's'} para tu pago',
                      style: VntlText.label.copyWith(
                        color: sub.daysLeft <= 3 ? colors.error : colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: VntlSpacing.xl),
            ],

            // ─── Información contractual ─────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(VntlSpacing.xl),
              decoration: BoxDecoration(
                color: colors.glassSurface,
                borderRadius: VntlRadius.lgBorderRadius,
                border: Border.all(color: colors.border, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Información contractual', style: VntlText.h4),
                  const SizedBox(height: VntlSpacing.xl),
                  Row(
                    children: [
                      Expanded(child: _infoCell(context, 'Titular', account.owner.name ?? 'N/A')),
                      Expanded(child: _infoCell(context, 'Fecha de alta', account.createdAt)),
                      Expanded(
                        child: _infoCell(
                          context,
                          'Dominio',
                          account.tenant.slug != null
                              ? '${account.tenant.slug}.ventro.com.mx'
                              : 'N/A',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: VntlSpacing.lg),

            // ─── Resumen + Planes ────────────────────────────────────────
            LayoutBuilder(
              builder: (context, constraints) {
                final twoColumns = constraints.maxWidth >= 700;
                final resumen = Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(VntlSpacing.xl),
                  decoration: BoxDecoration(
                    color: colors.glassSurface,
                    borderRadius: VntlRadius.lgBorderRadius,
                    border: Border.all(color: colors.border, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Resumen', style: VntlText.h4),
                      const SizedBox(height: VntlSpacing.sm),
                      Text(
                        'Estado general de tu cuenta',
                        style: VntlText.caption.copyWith(color: colors.textTertiary),
                      ),
                      const SizedBox(height: VntlSpacing.lg),
                      _statusRow(context, 'Estado', sub.planLabel,
                          sub.isTrial ? colors.warning : colors.success),
                      const SizedBox(height: VntlSpacing.sm),
                      _statusRow(
                        context,
                        'Vence',
                        sub.trialEndsAt ?? sub.nextBillingAt ?? 'N/A',
                        colors.textSecondary,
                      ),
                      const SizedBox(height: VntlSpacing.sm),
                      _statusRow(
                        context,
                        'Días restantes',
                        '${sub.daysLeft}',
                        sub.daysLeft <= 3 ? colors.error : colors.textSecondary,
                      ),
                    ],
                  ),
                );

                final planes = Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(VntlSpacing.xl),
                  decoration: BoxDecoration(
                    color: colors.glassSurface,
                    borderRadius: VntlRadius.lgBorderRadius,
                    border: Border.all(color: colors.border, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Planes y tarifas', style: VntlText.h4),
                      const SizedBox(height: VntlSpacing.xl),
                      Row(
                        children: [
                          Expanded(child: _infoCell(context, 'Plan', sub.planLabel)),
                          Expanded(
                            child: _infoCell(
                              context,
                              'Tarifa base',
                              '\$${sub.basePrice.toStringAsFixed(2)} / ${sub.periodLabel}',
                              valueColor: colors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: VntlSpacing.lg),
                      _infoCell(
                        context,
                        'Incluye',
                        '${sub.includedBranches} sucursal${sub.includedBranches == 1 ? '' : 'es'}',
                      ),
                      if (sub.extraBranches > 0) ...[
                        const SizedBox(height: VntlSpacing.lg),
                        Divider(color: colors.border, height: 0.5),
                        const SizedBox(height: VntlSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                              child: _infoCell(
                                context,
                                'Sucursales activas',
                                '${sub.includedBranches + sub.extraBranches}',
                              ),
                            ),
                            Expanded(
                              child: _infoCell(
                                context,
                                'Sucursales adicionales',
                                '${sub.extraBranches}',
                              ),
                            ),
                            Expanded(
                              child: _infoCell(
                                context,
                                'Costo adicional',
                                '\$${sub.extraBranchCost.toStringAsFixed(2)} MXN',
                                valueColor: colors.warning,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: VntlSpacing.lg),
                        Divider(color: colors.border, height: 0.5),
                        const SizedBox(height: VntlSpacing.lg),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total mensual',
                                style: VntlText.label.copyWith(color: colors.textSecondary)),
                            Text(
                              '\$${sub.totalMonthly.toStringAsFixed(2)} MXN',
                              style: VntlText.h4.copyWith(color: colors.primary),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );

                if (twoColumns) {
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: resumen),
                        const SizedBox(width: VntlSpacing.lg),
                        Expanded(child: planes),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    resumen,
                    const SizedBox(height: VntlSpacing.lg),
                    planes,
                  ],
                );
              },
            ),

            const SizedBox(height: VntlSpacing.lg),

            // ─── Facturación + Método de pago ────────────────────────────
            LayoutBuilder(
              builder: (context, constraints) {
                final twoColumns = constraints.maxWidth >= 700;
                final billing = account.billing;
                final pm = account.paymentMethod;

                final statusColor = billing.isBlocked
                    ? colors.error
                    : billing.status == 'past_due'
                        ? colors.warning
                        : colors.success;
                final statusLabel = billing.isBlocked
                    ? 'Bloqueada'
                    : billing.status == 'past_due'
                        ? 'Pago pendiente'
                        : 'Al corriente';

                final facturacion = Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(VntlSpacing.xl),
                  decoration: BoxDecoration(
                    color: colors.glassSurface,
                    borderRadius: VntlRadius.lgBorderRadius,
                    border: Border.all(color: colors.border, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Facturación', style: VntlText.h4),
                      const SizedBox(height: VntlSpacing.xl),
                      _infoCell(context, 'Estado de pago', statusLabel, valueColor: statusColor),
                      const SizedBox(height: VntlSpacing.lg),
                      _infoCell(context, 'Próximo cargo', billing.nextCharge),
                    ],
                  ),
                );

                final metodoPago = Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(VntlSpacing.xl),
                  decoration: BoxDecoration(
                    color: colors.glassSurface,
                    borderRadius: VntlRadius.lgBorderRadius,
                    border: Border.all(color: colors.border, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Método de pago', style: VntlText.h4),
                      const SizedBox(height: VntlSpacing.xl),
                      if (!pm.hasSpei)
                        Text(
                          'Sin método de pago registrado',
                          style: VntlText.body.copyWith(color: colors.textSecondary),
                        )
                      else ...[
                        Row(
                          children: [
                            Expanded(child: _infoCell(context, 'Método', 'Transferencia SPEI')),
                            Expanded(child: _infoCell(context, 'Banco', pm.bank ?? 'N/A')),
                          ],
                        ),
                        const SizedBox(height: VntlSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                                child: _infoCell(context, 'Beneficiario', pm.beneficiary ?? 'N/A')),
                            Expanded(
                                child: _infoCell(context, 'Referencia', pm.reference ?? 'N/A')),
                          ],
                        ),
                        const SizedBox(height: VntlSpacing.lg),
                        _infoCell(context, 'CLABE', pm.clabe ?? 'N/A'),
                      ],
                      const SizedBox(height: VntlSpacing.xl),
                      VntlButton(
                        label: pm.hasSpei ? 'Actualizar pago' : 'Registrar pago',
                        variant: VntlButtonVariant.secondary,
                        icon: Icons.payment_rounded,
                        onPressed: () {
                          // TODO
                        },
                      ),
                    ],
                  ),
                );

                if (twoColumns) {
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: facturacion),
                        const SizedBox(width: VntlSpacing.lg),
                        Expanded(child: metodoPago),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    facturacion,
                    const SizedBox(height: VntlSpacing.lg),
                    metodoPago,
                  ],
                );
              },
            ),

            const SizedBox(height: VntlSpacing.lg),

            // ─── Cancelación ─────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(VntlSpacing.xl),
              decoration: BoxDecoration(
                color: colors.glassSurface,
                borderRadius: VntlRadius.lgBorderRadius,
                border: Border.all(color: colors.border, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cancelación', style: VntlText.h4),
                  const SizedBox(height: VntlSpacing.xl),
                  if (account.cancellation.cancelledAt != null)
                    _infoCell(
                      context,
                      'Cuenta cancelada el',
                      account.cancellation.cancelledAt!,
                      valueColor: colors.error,
                    )
                  else ...[
                    Text(
                      'Al cancelar, se detienen cobros futuros. No se eliminan datos de forma inmediata.',
                      style: VntlText.body.copyWith(color: colors.textSecondary),
                    ),
                    const SizedBox(height: VntlSpacing.xl),
                    VntlButton(
                      label: 'Cancelar suscripción',
                      variant: VntlButtonVariant.danger,
                      onPressed: _confirmCancel,
                      fullWidth: false,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: VntlSpacing.xl),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  Widget _infoCell(BuildContext context, String label, String value, {Color? valueColor}) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: VntlText.caption.copyWith(color: colors.textTertiary)),
        const SizedBox(height: VntlSpacing.xs),
        Text(value, style: VntlText.label.copyWith(color: valueColor ?? colors.textPrimary)),
      ],
    );
  }

  Widget _statusRow(BuildContext context, String label, String value, Color color) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: VntlSpacing.md,
        vertical: VntlSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.glassSurface,
        borderRadius: VntlRadius.mdBorderRadius,
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Text(
        '$label: $value',
        style: VntlText.label.copyWith(color: color),
      ),
    );
  }
}
