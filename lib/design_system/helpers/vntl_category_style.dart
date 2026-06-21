// lib/design_system/helpers/vntl_category_style.dart

import 'package:flutter/material.dart';
import 'package:ventro_app/design_system/vntl.dart';

class VntlCategoryStyle {
  const VntlCategoryStyle({required this.background, required this.foreground, required this.icon});

  final Color background;
  final Color foreground;
  final IconData icon;

  /// Catálogo curado de íconos seleccionables para categorías.
  /// La clave (string) es lo que se guarda en BD y NUNCA debe cambiar,
  /// aunque se reordene o amplíe la lista — las categorías ya guardadas
  /// dependen de que su clave siga existiendo.
  static const Map<String, IconData> iconos = {
    // Panadería y pastelería
    'cake': Icons.cake_rounded,
    'cookie': Icons.cookie_rounded,
    'bakery': Icons.bakery_dining_rounded,
    'bread': Icons.bakery_dining_outlined,
    'cupcake': Icons.cake_outlined,
    'icecream': Icons.icecream_rounded,
    // Bebidas
    'coffee': Icons.coffee_rounded,
    'local_cafe': Icons.local_cafe_rounded,
    'tea': Icons.emoji_food_beverage_rounded,
    'drink': Icons.liquor_rounded,
    'wine': Icons.wine_bar_rounded,
    'soda': Icons.local_drink_rounded,
    'water': Icons.water_drop_rounded,
    // Comida preparada
    'pizza': Icons.local_pizza_rounded,
    'lunch': Icons.lunch_dining_rounded,
    'meal': Icons.set_meal_rounded,
    'restaurant': Icons.restaurant_rounded,
    'kebab': Icons.kebab_dining_rounded,
    'ramen': Icons.ramen_dining_rounded,
    'rice': Icons.rice_bowl_rounded,
    'fastfood': Icons.fastfood_rounded,
    'breakfast': Icons.brunch_dining_rounded,
    'dinner': Icons.dinner_dining_rounded,
    'tapas': Icons.tapas_rounded,
    // Snacks y abarrotes
    'fruit': Icons.apple_rounded,
    'grocery': Icons.local_grocery_store_rounded,
    'basket': Icons.shopping_basket_rounded,
    'egg': Icons.egg_rounded,
    'grass': Icons.grass_rounded,
    'kitchen': Icons.kitchen_rounded,
    // Negocio / retail
    'store': Icons.storefront_rounded,
    'shop': Icons.shopping_bag_rounded,
    'cart': Icons.shopping_cart_rounded,
    'box': Icons.inventory_2_rounded,
    'gift': Icons.card_giftcard_rounded,
    'tag_price': Icons.sell_rounded,
    'receipt': Icons.receipt_long_rounded,
    'scale': Icons.scale_rounded,
    // Servicios / general
    'cleaning': Icons.cleaning_services_rounded,
    'spa': Icons.spa_rounded,
    'pets': Icons.pets_rounded,
    'flower': Icons.local_florist_rounded,
    'tools': Icons.handyman_rounded,
    'electronics': Icons.devices_rounded,
    'clothing': Icons.checkroom_rounded,
    'book': Icons.menu_book_rounded,
    'toy': Icons.toys_rounded,
    'paint': Icons.palette_rounded,
    // Genéricos
    'tag': Icons.label_rounded,
    'star': Icons.star_rounded,
    'heart': Icons.favorite_rounded,
    'flash': Icons.flash_on_rounded,
    'circle': Icons.circle_rounded,
    'diamond': Icons.diamond_rounded,
  };

  /// Tags en español por clave, usados para la búsqueda. Una clave puede
  /// tener varios sinónimos; la búsqueda hace match parcial sobre cualquiera.
  static const Map<String, List<String>> _tags = {
    'cake': ['pastel', 'tarta', 'cumpleaños'],
    'cookie': ['galleta', 'galletas'],
    'bakery': ['panadería', 'pan dulce', 'horneado'],
    'bread': ['pan', 'baguette', 'bolillo'],
    'cupcake': ['cupcake', 'panque', 'muffin'],
    'icecream': ['helado', 'paleta', 'nieve'],
    'coffee': ['café', 'cafetería', 'espresso'],
    'local_cafe': ['café', 'taza', 'cafetería'],
    'tea': ['té', 'bebida caliente', 'chocolate caliente'],
    'drink': ['bebida', 'alcohol', 'coctel', 'licor'],
    'wine': ['vino', 'copa', 'cava'],
    'soda': ['refresco', 'soda', 'gaseosa'],
    'water': ['agua', 'hidratación'],
    'pizza': ['pizza', 'rebanada'],
    'lunch': ['comida', 'hamburguesa', 'almuerzo'],
    'meal': ['platillo', 'pescado', 'mariscos'],
    'restaurant': ['restaurante', 'cubiertos', 'comida'],
    'kebab': ['antojito', 'taco', 'kebab', 'comida rápida'],
    'ramen': ['ramen', 'sopa', 'fideos'],
    'rice': ['arroz', 'bowl'],
    'fastfood': ['comida rápida', 'hamburguesa', 'papas'],
    'breakfast': ['desayuno', 'brunch'],
    'dinner': ['cena', 'plato'],
    'tapas': ['tapas', 'botana', 'aperitivo'],
    'fruit': ['fruta', 'manzana', 'snack'],
    'grocery': ['abarrotes', 'tienda', 'supermercado'],
    'basket': ['canasta', 'mercado', 'compras'],
    'egg': ['huevo', 'desayuno'],
    'grass': ['verdura', 'ensalada', 'vegetales'],
    'kitchen': ['cocina', 'utensilios'],
    'store': ['tienda', 'local', 'negocio'],
    'shop': ['tienda', 'bolsa', 'compras'],
    'cart': ['carrito', 'compras', 'pedido'],
    'box': ['caja', 'inventario', 'paquete'],
    'gift': ['regalo', 'obsequio'],
    'tag_price': ['precio', 'oferta', 'etiqueta de precio'],
    'receipt': ['recibo', 'ticket', 'factura'],
    'scale': ['báscula', 'peso', 'granel'],
    'cleaning': ['limpieza', 'servicio'],
    'spa': ['spa', 'belleza', 'relajación'],
    'pets': ['mascotas', 'animales', 'perro', 'gato'],
    'flower': ['flores', 'florería', 'planta'],
    'tools': ['herramientas', 'ferretería', 'reparación'],
    'electronics': ['electrónica', 'tecnología', 'dispositivos'],
    'clothing': ['ropa', 'vestimenta', 'moda'],
    'book': ['libro', 'papelería', 'lectura'],
    'toy': ['juguete', 'niños'],
    'paint': ['pintura', 'arte', 'color'],
    'tag': ['etiqueta', 'genérico'],
    'star': ['estrella', 'destacado', 'favorito'],
    'heart': ['corazón', 'favorito'],
    'flash': ['rápido', 'express', 'destello'],
    'circle': ['círculo', 'punto'],
    'diamond': ['diamante', 'premium', 'joya'],
  };

  /// Busca íconos cuya clave o tags coincidan parcialmente con [query].
  /// Si [query] está vacío, regresa el catálogo completo en orden.
  static List<MapEntry<String, IconData>> buscar(String query) {
    final entries = iconos.entries.toList();
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return entries;

    return entries.where((e) {
      if (e.key.toLowerCase().contains(q)) return true;
      final tags = _tags[e.key] ?? const [];
      return tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

  /// Paleta curada de colores seleccionables para categorías (hex).
  static const List<String> colores = [
    '#6C5CE7',
    '#00B894',
    '#E17055',
    '#FDCB6E',
    '#0984E3',
    '#E84393',
    '#D63031',
    '#636E72',
  ];

  static Color _hexToColor(String hex) {
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }

  static VntlCategoryStyle forCategoria(
    BuildContext context,
    int? categoriaId, {
    String? iconoKey,
    String? colorHex,
  }) {
    final colors = context.colors;

    if (categoriaId == null) {
      return VntlCategoryStyle(
        background: colors.primarySurface,
        foreground: colors.primary,
        icon: Icons.inventory_2_rounded,
      );
    }

    if (iconoKey != null && colorHex != null && iconos.containsKey(iconoKey)) {
      final base = _hexToColor(colorHex);
      return VntlCategoryStyle(
        background: base.withValues(alpha: 0.18),
        foreground: base,
        icon: iconos[iconoKey]!,
      );
    }

    final paleta = <(Color, Color)>[
      (colors.primarySurface, colors.primary),
      (colors.accentSurface, colors.accent),
      (colors.successSurface, colors.success),
      (colors.warningSurface, colors.warning),
      (colors.infoSurface, colors.info),
      (colors.errorSurface, colors.error),
    ];
    final iconosFallback = iconos.values.toList();

    final index = categoriaId % paleta.length;
    final iconoIndex = categoriaId % iconosFallback.length;
    final (bg, fg) = paleta[index];

    return VntlCategoryStyle(background: bg, foreground: fg, icon: iconosFallback[iconoIndex]);
  }
}
