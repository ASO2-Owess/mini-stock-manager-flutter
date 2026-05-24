import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/sale_request_provider.dart';

class SaleRequestsScreen extends StatefulWidget {
  const SaleRequestsScreen({super.key});

  @override
  State<SaleRequestsScreen> createState() => _SaleRequestsScreenState();
}

class _SaleRequestsScreenState extends State<SaleRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      await context.read<SaleRequestProvider>().load(token);
    }
  }

  Future<void> _process(int id, bool approve) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    final sales = context.read<SaleRequestProvider>();
    final products = context.read<ProductProvider>();
    final ok = approve
        ? await sales.approve(token, id)
        : await sales.reject(token, id);

    if (!mounted) return;
    if (ok) {
      await products.loadProducts(token);
      if (!mounted) return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? (approve ? 'Vente validee' : 'Demande refusee')
            : sales.error ?? 'Action impossible'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final sales = context.watch<SaleRequestProvider>();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF0A2540),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.point_of_sale_outlined,
                  color: Color(0xFFF97316),
                  size: 34,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.isAdmin ? 'Demandes de vente' : 'Mes ventes',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        auth.isAdmin
                            ? '${sales.pendingCount} en attente de validation'
                            : 'Suivi des ventes envoyees a l admin',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (sales.loading)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (sales.error != null)
            _Message(message: sales.error!)
          else if (sales.requests.isEmpty)
            const _Message(message: 'Aucune demande pour le moment')
          else
            for (final request in sales.requests) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            request.product.nom,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        _StatusChip(status: request.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Quantite: ${request.quantity} - ${request.user?.displayName ?? 'Utilisateur'}',
                      style: const TextStyle(color: Color(0xFF4B5563)),
                    ),
                    if ((request.clientName ?? '').isNotEmpty)
                      Text(
                        'Client: ${request.clientName}',
                        style: const TextStyle(color: Color(0xFF4B5563)),
                      ),
                    if ((request.note ?? '').isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(request.note!),
                    ],
                    if (auth.isAdmin && request.status == 'pending') ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _process(request.id, false),
                              icon: const Icon(Icons.close),
                              label: const Text('Refuser'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => _process(request.id, true),
                              icon: const Icon(Icons.check),
                              label: const Text('Valider'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'approved' => const Color(0xFF1E8449),
      'rejected' => const Color(0xFFB03A2E),
      _ => const Color(0xFFF97316),
    };
    final label = switch (status) {
      'approved' => 'Validee',
      'rejected' => 'Refusee',
      _ => 'En attente',
    };

    return Chip(
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.12),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w800),
    );
  }
}

class _Message extends StatelessWidget {
  final String message;

  const _Message({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFF97316)),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
