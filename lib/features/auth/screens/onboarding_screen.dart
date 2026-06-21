import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/auth/controllers/auth_controller.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _employeeController = TextEditingController();
  bool _pinGenerated = false;
  bool _employeeGenerated = false;
  bool _obscurePin = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    _employeeController.dispose();
    super.dispose();
  }

  void _generatePin() {
    final pin = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString().substring(0, 4);
    setState(() {
      _pinController.text = pin;
      _pinGenerated = true;
      _obscurePin = false;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = context.read<AuthController>();
    final success = await controller.completeOnboarding(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim(),
      securityPin: _pinController.text.trim(),
      employeeNumber: _employeeGenerated || _employeeController.text.isEmpty
          ? null
          : _employeeController.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(controller.errorMessage ?? 'Error al guardar el perfil'),
        backgroundColor: context.colors.error,
      ));
      controller.resetStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLoading = context.watch<AuthController>().isLoading;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: context.backgroundGradient),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(VntlSpacing.xl2),
            child: SizedBox(
              width: 420,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: VntlSpacing.xl3),
                    const Text('Completa tu perfil', style: VntlText.h2),
                    const SizedBox(height: VntlSpacing.sm),
                    Text(
                      'Un último paso antes de entrar a tu negocio',
                      style: VntlText.body.copyWith(color: colors.textSecondary),
                    ),
                    const SizedBox(height: VntlSpacing.xl3),
                    VntlCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Datos personales',
                              style: VntlText.label.copyWith(color: colors.textSecondary)),
                          const SizedBox(height: VntlSpacing.lg),
                          Row(
                            children: [
                              Expanded(
                                child: VntlInput(
                                  label: 'Nombre',
                                  hint: 'Ramón',
                                  controller: _firstNameController,
                                  prefixIcon: Icons.person_outline_rounded,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                                ),
                              ),
                              const SizedBox(width: VntlSpacing.md),
                              Expanded(
                                child: VntlInput(
                                  label: 'Apellido',
                                  hint: 'Olivares',
                                  controller: _lastNameController,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: VntlSpacing.lg),
                          VntlInput(
                            label: 'Teléfono',
                            hint: '2721234567',
                            controller: _phoneController,
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Requerido';
                              if (v.length < 10) return 'Mínimo 10 dígitos';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: VntlSpacing.lg),
                    VntlCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Seguridad',
                              style: VntlText.bodyLarge.copyWith(color: colors.textSecondary)),
                          const SizedBox(height: VntlSpacing.xs),
                          Text(
                            'El PIN se usará para autorizar acciones en caja, cobros y operaciones sensibles.',
                            style: VntlText.caption.copyWith(color: colors.textTertiary),
                          ),
                          const SizedBox(height: VntlSpacing.lg),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: VntlInput(
                                  label: 'PIN de seguridad (4 dígitos)',
                                  hint: '••••',
                                  controller: _pinController,
                                  prefixIcon: Icons.pin_outlined,
                                  obscureText: _obscurePin,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4),
                                  ],
                                  suffix: GestureDetector(
                                    onTap: () => setState(() => _obscurePin = !_obscurePin),
                                    child: Icon(
                                      _obscurePin
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: colors.textTertiary,
                                      size: 18,
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Requerido';
                                    if (v.length < 4) return '4 dígitos exactos';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: VntlSpacing.md),
                              VntlButton(
                                label: 'Generar',
                                variant: VntlButtonVariant.ghost,
                                onPressed: _generatePin,
                              ),
                            ],
                          ),
                          if (_pinGenerated)
                            Padding(
                              padding: const EdgeInsets.only(top: VntlSpacing.sm),
                              child: Text(
                                '⚠ Anota tu PIN, no podrás verlo de nuevo.',
                                style: VntlText.caption.copyWith(color: colors.warning),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: VntlSpacing.lg),
                    VntlCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Identificación',
                              style: VntlText.bodyLarge.copyWith(color: colors.textSecondary)),
                          const SizedBox(height: VntlSpacing.xs),
                          Text(
                            'Número de empleado para identificarte en el sistema.',
                            style: VntlText.caption.copyWith(color: colors.textTertiary),
                          ),
                          const SizedBox(height: VntlSpacing.lg),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: VntlInput(
                                  label: 'Número de empleado',
                                  hint: _employeeGenerated
                                      ? 'Se generará automáticamente'
                                      : 'EMP-0001',
                                  controller: _employeeController,
                                  prefixIcon: Icons.badge_outlined,
                                  textInputAction: TextInputAction.done,
                                  enabled: !_employeeGenerated,
                                  onSubmitted: (_) => _submit(),
                                ),
                              ),
                              const SizedBox(width: VntlSpacing.md),
                              VntlButton(
                                label: _employeeGenerated ? 'Manual' : 'Generar',
                                variant: VntlButtonVariant.ghost,
                                onPressed: () => setState(() {
                                  _employeeGenerated = !_employeeGenerated;
                                  if (_employeeGenerated) _employeeController.clear();
                                }),
                              ),
                            ],
                          ),
                          if (_employeeGenerated)
                            Padding(
                              padding: const EdgeInsets.only(top: VntlSpacing.sm),
                              child: Text(
                                'Se asignará EMP-0001 automáticamente.',
                                style: VntlText.caption.copyWith(color: colors.textTertiary),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: VntlSpacing.xl2),
                    VntlButton(
                      label: 'Entrar a mi negocio',
                      fullWidth: true,
                      size: VntlButtonSize.lg,
                      loading: isLoading,
                      onPressed: isLoading ? null : _submit,
                    ),
                    const SizedBox(height: VntlSpacing.xl3),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
