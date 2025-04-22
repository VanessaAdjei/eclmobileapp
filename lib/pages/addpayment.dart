import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Cart.dart';
import 'auth_service.dart';
import 'bottomnav.dart';

class AddPaymentPage extends StatefulWidget {
  @override
  _AddPaymentPageState createState() => _AddPaymentPageState();
}

class _AddPaymentPageState extends State<AddPaymentPage> {
  String? _selectedPaymentMethod;
  String? _selectedMoMoProvider;
  List<Map<String, String>> _paymentMethods = [];
  final TextEditingController _momoNumberController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserPhoneNumber();
    _loadPaymentMethods();
  }

  Future<void> _loadUserPhoneNumber() async {
    final phoneNumber = await AuthService.getUserPhoneNumber();
    if (phoneNumber != null) {
      _momoNumberController.text = phoneNumber;
    }
  }

  Future<void> _loadPaymentMethods() async {
    final prefs = await SharedPreferences.getInstance();
    final paymentMethodsJson = prefs.getStringList('paymentMethods') ?? [];
    print('Loaded payment methods: $paymentMethodsJson');
    setState(() {
      _paymentMethods = paymentMethodsJson
          .map((method) => Map<String, String>.from(json.decode(method)))
          .toList();
    });
  }


  Future<void> _savePaymentMethods() async {
    final prefs = await SharedPreferences.getInstance();
    final paymentMethodsJson =
    _paymentMethods.map((method) => json.encode(method)).toList();
    await prefs.setStringList('paymentMethods', paymentMethodsJson);
  }

  void _savePaymentMethod() {
    if (_selectedPaymentMethod == 'MoMo' &&
        _selectedMoMoProvider != null &&
        _momoNumberController.text.isNotEmpty) {
      _paymentMethods.add({
        'type': 'MoMo',
        'provider': _selectedMoMoProvider!,
        'number': _momoNumberController.text,
      });
    } else if (_selectedPaymentMethod == 'Card' &&
        _cardNumberController.text.isNotEmpty &&
        _expiryDateController.text.isNotEmpty &&
        _cvvController.text.isNotEmpty) {
      _paymentMethods.add({
        'type': 'Card',
        'number': _cardNumberController.text,
        'expiry': _expiryDateController.text,
        'cvv': _cvvController.text,
      });
    }
    _savePaymentMethods();
    setState(() => _clearForm());
  }

  void _clearForm() {
    _selectedPaymentMethod = null;
    _selectedMoMoProvider = null;
    _momoNumberController.clear();
    _cardNumberController.clear();
    _expiryDateController.clear();
    _cvvController.clear();
  }

  void _deletePaymentMethod(int index) {
    setState(() {
      _paymentMethods.removeAt(index);
    });
    _savePaymentMethods();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Payment',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Cart()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset('assets/images/payment.png', height: 200),
              ),
              SizedBox(height: 10),
              if (_paymentMethods.isNotEmpty) _buildSavedPaymentMethods(),
              _buildPaymentForm(),
              SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: _savePaymentMethod,
                  child: Text('Save Payment Method'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding:
                    EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }

  Widget _buildSavedPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Payment Methods:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _paymentMethods.length,
          itemBuilder: (context, index) {
            final method = _paymentMethods[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(
                  method['type'] == 'MoMo'
                      ? 'MoMo - ${method['provider']}'
                      : 'Card - **** ${method['number']!.substring(method['number']!.length - 4)}',
                ),
                subtitle: Text(method['number']!),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deletePaymentMethod(index),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPaymentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add a Payment Method:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        _buildDropdown(
          'Payment Method',
          _selectedPaymentMethod,
          ['MoMo', 'Card'],
              (value) => setState(() => _selectedPaymentMethod = value),
        ),
        SizedBox(height: 10),
        if (_selectedPaymentMethod == 'MoMo') ...[
          _buildDropdown(
            'MoMo Provider',
            _selectedMoMoProvider,
            ['Telecel', 'MTN', 'AirtelTigo'],
                (value) => setState(() => _selectedMoMoProvider = value),
          ),
          _buildTextField('MoMo Number', _momoNumberController),
        ],
        if (_selectedPaymentMethod == 'Card') ...[
          _buildTextField('Card Number', _cardNumberController),
          _buildTextField('Expiry Date (MM/YY)', _expiryDateController),
          _buildTextField('CVV', _cvvController, obscureText: true),
        ],
      ],
    );
  }

  Widget _buildDropdown(
      String label,
      String? value,
      List<String> items,
      ValueChanged<String?> onChanged,
      ) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(border: OutlineInputBorder(), labelText: label),
      value: value,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(border: OutlineInputBorder(), labelText: label),
        obscureText: obscureText,
      ),
    );
  }
}
