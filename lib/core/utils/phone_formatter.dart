import 'package:flutter/services.dart';

/// Formatea un teléfono mexicano de 10 dígitos como "xxx xxx xxxx" mientras
/// el usuario escribe. Ignora cualquier caracter no numérico que llegue
/// (pegado de texto con guiones/paréntesis, etc.) y limita a 10 dígitos.
///
/// Uso: VntlInput(controller: _telefonoCtrl, inputFormatters: [PhoneInputFormatter()])
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitos = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limitados = digitos.length > 10 ? digitos.substring(0, 10) : digitos;

    final formateado = _formatear(limitados);

    return TextEditingValue(
      text: formateado,
      selection: TextSelection.collapsed(offset: formateado.length),
    );
  }

  String _formatear(String digitos) {
    final buffer = StringBuffer();

    for (int i = 0; i < digitos.length; i++) {
      if (i == 3 || i == 6) buffer.write(' ');
      buffer.write(digitos[i]);
    }

    return buffer.toString();
  }
}

/// Quita los espacios de formato, dejando solo los dígitos — usar antes
/// de mandar el teléfono al backend (ej. "cielo.telefono.replaceAll..." no
/// hace falta si usas esto: PhoneInputFormatter.soloDigitos(texto)).
extension PhoneDigitsX on String {
  String get soloDigitosTelefono => replaceAll(RegExp(r'\D'), '');
}
