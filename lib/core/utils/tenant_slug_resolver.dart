import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// Extrae el slug del tenant a partir del subdominio actual en Flutter web
/// (ej. cielo-reposteria.ventro.com.mx → "cielo-reposteria"). Espejo del
/// mismo criterio que usa InitializeTenancyBySubdomain en el backend, pero
/// aquí solo para identificar qué slug mandar en el header X-Tenant-Slug —
/// la resolución real del tenant sigue viviendo en el API.
///
/// En dev (mismo criterio que Env: !kReleaseMode) agrega fallback para
/// subdominios locales (acme.localhost) y ?tenant=slug en localhost puro,
/// espejando el fallback que ya existe en InitializeTenancyBySlugHeader.
class TenantSlugResolver {
  static const String _baseDomain = 'ventro.com.mx';
  static const List<String> _reservados = ['api', 'app', 'www'];
  static const List<String> _sufijosLocal = ['.localhost', '.test', '.local', '.lan'];

  static String? resolveFromWeb() {
    final host = web.window.location.hostname.toLowerCase();

    final slugProd = _extraerSlug(host, _baseDomain);
    if (slugProd != null) return slugProd;

    if (!kReleaseMode) {
      final slugLocal = _resolveFromLocalHost(host);
      if (slugLocal != null) return slugLocal;

      final slugQuery = _resolveFromQuery();
      if (slugQuery != null) return slugQuery;
    }

    return null;
  }

  static String? _extraerSlug(String host, String baseDomain) {
    final sufijo = '.$baseDomain';
    if (!host.endsWith(sufijo)) return null;

    final slug = host.substring(0, host.length - sufijo.length);
    if (slug.isEmpty || _reservados.contains(slug)) return null;

    return slug;
  }

  static String? _resolveFromLocalHost(String host) {
    for (final sufijo in _sufijosLocal) {
      if (!host.endsWith(sufijo)) continue;

      final slug = host.substring(0, host.length - sufijo.length);
      if (slug.isNotEmpty && !_reservados.contains(slug)) return slug;
    }
    return null;
  }

  static String? _resolveFromQuery() {
    final query = web.window.location.search;
    if (query.isEmpty) return null;

    final params = Uri.splitQueryString(query.replaceFirst('?', ''));
    final tenant = params['tenant'];

    return (tenant != null && tenant.isNotEmpty) ? tenant.toLowerCase() : null;
  }
}
