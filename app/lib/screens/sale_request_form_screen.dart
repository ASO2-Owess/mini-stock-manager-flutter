import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/sale_request_provider.dart';
import '../widgets/custom_button.dart';

class SaleRequestFormScreen extends StatefulWidget {
  final Product product;

  const SaleRequestFormScreen({
    super.key,
    required this.product,
  });

  @override
  State<SaleRequestFormScreen> createState() => _SaleRequestFormScreenState();
}

class _SaleRequestFormScreenState extends State<SaleRequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityCtrl = TextEditingController(text: '1');
  final _clientCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _clientCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    final ok = await context.read<SaleRequestProvider>().create(
          token,
          productId: widget.product.id,
          quantity: int.parse(_quantityCtrl.text),
          clientName: _clientCtrl.text.trim(),
          note: _noteCtrl.text.trim(),
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Vente signalee a l administrateur'
            : 'Signalement impossible'),
      ),
    );
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SaleRequestProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Signaler une vente')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0A2540),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.nom,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.product.quantity} disponible(s) - ${widget.product.priceFormatted}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _quantityCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantite vendue',
                        prefixIcon: Icon(Icons.remove_shopping_cart_outlined),
                      ),
                      validator: (value) {
                        final quantity = int.tryParse(value ?? '');
                        if (quantity == null || quantity <= 0) {
                          return 'Quantite invalide';
                        }
                        if (quantity > widget.product.quantity) {
                          return 'Stock insuffisant';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _clientCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Client ou reference vente',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _noteCtrl,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Note magasinier',
                        prefixIcon: Icon(Icons.notes_outlined),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      label: 'Envoyer a l admin',
                      icon: Icons.send_outlined,
                      loading: provider.loading,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
