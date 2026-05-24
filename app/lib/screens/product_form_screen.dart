import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/custom_button.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _referenceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _alertCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  String _type = 'moteur';
  String _vehicleType = 'voiture';
  bool _actif = true;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    if (product != null) {
      _nameCtrl.text = product.nom;
      _referenceCtrl.text = product.reference ?? '';
      _descCtrl.text = product.description ?? '';
      _quantityCtrl.text = product.quantity.toString();
      _alertCtrl.text = product.alertThreshold.toString();
      _priceCtrl.text = product.unitPrice.toString();
      _locationCtrl.text = product.location ?? '';
      _type = product.type;
      _vehicleType = product.vehicleType;
      _actif = product.actif;
    } else {
      _quantityCtrl.text = '1';
      _alertCtrl.text = '5';
      _priceCtrl.text = '0';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _referenceCtrl.dispose();
    _descCtrl.dispose();
    _quantityCtrl.dispose();
    _alertCtrl.dispose();
    _priceCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  String _normalize(String value) {
    return value.trim().replaceAll(' ', '').replaceAll(',', '.');
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label requis';
    return null;
  }

  String? _number(String? value, String label) {
    final required = _required(value, label);
    if (required != null) return required;
    if (double.tryParse(_normalize(value!)) == null) return '$label invalide';
    return null;
  }

  String? _integer(String? value, String label) {
    final required = _required(value, label);
    if (required != null) return required;
    final parsed = int.tryParse(_normalize(value!).split('.').first);
    if (parsed == null || parsed < 0) return '$label invalide';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    final data = {
      'nom': _nameCtrl.text.trim(),
      'reference': _referenceCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'type': _type,
      'vehicle_type': _vehicleType,
      'quantity': int.parse(_normalize(_quantityCtrl.text).split('.').first),
      'alert_threshold':
          int.parse(_normalize(_alertCtrl.text).split('.').first),
      'unit_price': double.parse(_normalize(_priceCtrl.text)),
      'location': _locationCtrl.text.trim(),
      'actif': _actif,
    };

    final products = context.read<ProductProvider>();
    final ok = _isEditing
        ? await products.updateProduct(token, widget.product!.id, data)
        : await products.createProduct(token, data);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? (_isEditing ? 'Piece mise a jour' : 'Piece ajoutee')
            : products.error ?? 'Operation impossible'),
      ),
    );
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier une piece' : 'Ajouter une piece'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Panel(
                  title: 'Identification',
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nom de la piece',
                        prefixIcon: Icon(Icons.build_outlined),
                      ),
                      validator: (value) => _required(value, 'Nom'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _referenceCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Reference interne',
                        prefixIcon: Icon(Icons.qr_code_2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _vehicleType,
                            decoration: const InputDecoration(
                              labelText: 'Vehicule',
                              prefixIcon: Icon(Icons.directions_car_outlined),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'voiture',
                                child: Text('Voiture'),
                              ),
                              DropdownMenuItem(
                                value: 'moto',
                                child: Text('Moto'),
                              ),
                              DropdownMenuItem(
                                value: 'velo',
                                child: Text('Velo'),
                              ),
                              DropdownMenuItem(
                                value: 'camion',
                                child: Text('Camion'),
                              ),
                              DropdownMenuItem(
                                value: 'autre',
                                child: Text('Autre'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _vehicleType = value);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _type,
                            decoration: const InputDecoration(
                              labelText: 'Famille',
                              prefixIcon: Icon(Icons.category_outlined),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'moteur',
                                child: Text('Moteur'),
                              ),
                              DropdownMenuItem(
                                value: 'freinage',
                                child: Text('Freinage'),
                              ),
                              DropdownMenuItem(
                                value: 'suspension',
                                child: Text('Suspension'),
                              ),
                              DropdownMenuItem(
                                value: 'electrique',
                                child: Text('Electrique'),
                              ),
                              DropdownMenuItem(
                                value: 'carrosserie',
                                child: Text('Carrosserie'),
                              ),
                              DropdownMenuItem(
                                value: 'pneu',
                                child: Text('Pneu'),
                              ),
                              DropdownMenuItem(
                                value: 'accessoire',
                                child: Text('Accessoire'),
                              ),
                              DropdownMenuItem(
                                value: 'autre',
                                child: Text('Autre'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) setState(() => _type = value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descCtrl,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.description_outlined),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _Panel(
                  title: 'Stock et vente',
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _quantityCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Quantite',
                              prefixIcon: Icon(Icons.inventory_2_outlined),
                            ),
                            validator: (value) => _integer(value, 'Quantite'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _alertCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Seuil alerte',
                              prefixIcon: Icon(Icons.warning_amber_outlined),
                            ),
                            validator: (value) => _integer(value, 'Seuil'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _priceCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Prix unitaire',
                        suffixText: 'FCFA',
                        prefixIcon: Icon(Icons.payments_outlined),
                      ),
                      validator: (value) => _number(value, 'Prix'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _locationCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Emplacement magasin',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Piece visible'),
                      subtitle: Text(_actif
                          ? 'Disponible pour les employes'
                          : 'Retiree du catalogue'),
                      value: _actif,
                      onChanged: (value) => setState(() => _actif = value),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomButton(
                  label: _isEditing ? 'Enregistrer' : 'Ajouter au stock',
                  icon: _isEditing ? Icons.save_outlined : Icons.add,
                  loading: products.loading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Panel({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
