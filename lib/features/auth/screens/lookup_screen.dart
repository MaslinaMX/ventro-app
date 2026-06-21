import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ventro_app/design_system/vntl.dart';
import 'package:ventro_app/features/auth/controllers/auth_controller.dart';

class LookupScreen extends StatefulWidget {
  const LookupScreen({super.key});

  @override
  State<LookupScreen> createState() => _LookupScreenState();
}

class _LookupScreenState extends State<LookupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args['email'] != null) {
        _emailController.text = args['email'];
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = context.read<AuthController>();
    final result = await controller.lookup(_emailController.text.trim());
    if (!mounted) return;
    if (result != null) {
      Navigator.pushNamed(context, '/login', arguments: {
        'email': _emailController.text.trim(),
        'tenant_id': result['tenant_id'],
        'empresa': result['empresa'],
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(controller.errorMessage ?? 'No encontramos una cuenta con ese correo'),
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
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        children: [
                          Icon(Icons.arrow_back_rounded, color: colors.textSecondary, size: 20),
                          const SizedBox(width: VntlSpacing.sm),
                          Text('Regresar',
                              style: VntlText.body.copyWith(color: colors.textSecondary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: VntlSpacing.xl3),
                    const Text('Bienvenido de vuelta', style: VntlText.h2),
                    const SizedBox(height: VntlSpacing.sm),
                    Text(
                      'Ingresa tu correo para encontrar tu cuenta',
                      style: VntlText.body.copyWith(color: colors.textSecondary),
                    ),
                    const SizedBox(height: VntlSpacing.xl3),
                    VntlCard(
                      child: Column(
                        children: [
                          VntlInput(
                            label: 'Correo electrónico',
                            hint: 'correo@negocio.com',
                            controller: _emailController,
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _submit(),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Ingresa tu correo';
                              if (!v.contains('@')) return 'Correo inválido';
                              return null;
                            },
                          ),
                          const SizedBox(height: VntlSpacing.xl2),
                          VntlButton(
                            label: 'Continuar',
                            fullWidth: true,
                            size: VntlButtonSize.lg,
                            loading: isLoading,
                            onPressed: isLoading ? null : _submit,
                          ),
                        ],
                      ),
                    ),
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
