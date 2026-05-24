import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import 'product_form_screen.dart';
import 'sale_request_form_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer cette piece ?'),
        content: Text('Cette action supprimera "${product.nom}" du stock.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB03A2E),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final token = context.read<AuthProvider>().token!;
    final ok = await context.read<ProductProvider>().deleteProduct(
          token,
          product.id,
        );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Piece supprimee' : 'Suppression impossible'),
      ),
    );
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<ProductProvider>();
    final accent =
        product.isLowStock ? const Color(0xFFF97316) : const Color(0xFF1A3A5C);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiche stock'),
        actions: [
          if (auth.isAdmin)
            IconButton(
              tooltip: 'Modifier',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductFormScreen(product: product),
                  ),
                );
                if (context.mounted) Navigator.pop(context);
              },
            ),
          if (auth.isAdmin)
            IconButton(
              tooltip: 'Supprimer',
              icon: const Icon(Icons.delete_outline),
              onPressed: provider.loading ? null : () => _delete(context),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0A2540),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Tag(text: product.vehicleLabel, color: accent),
                    _Tag(
                        text: product.typeLabel,
                        color: const Color(0xFFF97316)),
                    if (!product.actif)
                      const _Tag(text: 'Retiree', color: Color(0xFFB03A2E)),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  product.nom,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if ((product.reference ?? '').isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Ref. ${product.reference}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.inventory_2_outlined,
                  title: 'Quantite',
                  value: '${product.quantity}',
                  color: accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoTile(
                  icon: Icons.warning_amber_outlined,
                  title: 'Seuil',
                  value: '${product.alertThreshold}',
                  color: const Color(0xFFF97316),
                ),
              ),
            ],
          ),
          _InfoTile(
            icon: Icons.payments_outlined,
            title: 'Prix unitaire',
            value: product.priceFormatted,
            color: const Color(0xFF1A3A5C),
          ),
          _InfoTile(
            icon: Icons.location_on_outlined,
            title: 'Emplacement',
            value: product.location ?? 'Non renseigne',
            color: const Color(0xFF1A3A5C),
          ),
          if ((product.description ?? '').isNotEmpty)
            _InfoTile(
              icon: Icons.description_outlined,
              title: 'Description',
              value: product.description!,
              color: const Color(0xFF1A3A5C),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: auth.isAdmin
              ? FilledButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductFormScreen(product: product),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Modifier le stock'),
                )
              : FilledButton.icon(
                  onPressed: product.quantity <= 0
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SaleRequestFormScreen(product: product),
                            ),
                          ),
                  icon: const Icon(Icons.point_of_sale_outlined),
                  label: const Text('Signaler une vente'),
                ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;

  const _Tag({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
