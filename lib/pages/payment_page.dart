import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'bottomnav.dart';
import 'cartprovider.dart';
import 'homepage.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedPaymentMethod = 'Mobile Money';
  bool savePaymentMethod = false;

  final List<Map<String, dynamic>> paymentMethods = [
    {
      'name': 'Mobile Money',
      'icon': Icons.phone_android,
      'description': 'Pay with MTN, Vodafone, or AirtelTigo',
    },
    {
      'name': 'Card',
      'icon': Icons.credit_card,
      'description': 'Pay with a debit/credit card',
    },
    {
      'name': 'Cash on Delivery',
      'icon': Icons.money,
      'description': 'Pay when you receive your order',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.green.shade700,
                centerTitle: true,
                leading:IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                automaticallyImplyLeading: false,
              ),

              Expanded(
                child: Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPaymentMethods(),
                          const SizedBox(height: 20),
                          _buildSavePaymentToggle(),
                          const SizedBox(height: 20),
                          _buildOrderSummary(cart),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              onPressed: () {
                                cart.clearCart();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const OrderConfirmationPage(),
                                  ),
                                      (route) => false,
                                );
                              },
                              child: const Text(
                                'CONTINUE TO PAYMENT',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Positioned Progress Indicator at Top
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: _buildProgressIndicator(),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }


  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildProgressStep("Delivery", isActive: false),
          _buildArrow(),
          _buildProgressStep("Payment", isActive: true),
          _buildArrow(),
          _buildProgressStep("Confirmation", isActive: false),
        ],
      ),
    );
  }

  Widget _buildProgressStep(String text, {bool isActive = false}) {
    return Column(
      children: [
        Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 2,
          width: 50,
          color: isActive ? Colors.white : Colors.grey[300],
        ),
      ],
    );
  }

  Widget _buildArrow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Icon(
        Icons.arrow_forward,
        color: Colors.grey[400],
        size: 20,
      ),
    );
  }



  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PAYMENT METHOD',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        ...paymentMethods.map((method) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: RadioListTile<String>(
              title: Row(
                children: [
                  Icon(method['icon'], color: Colors.green),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        method['description'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              value: method['name'],
              groupValue: selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value!;
                });
              },
              activeColor: Colors.green,
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSavePaymentToggle() {
    return Row(
      children: [
        Checkbox(
          value: savePaymentMethod,
          onChanged: (value) {
            setState(() {
              savePaymentMethod = value!;
            });
          },
          activeColor: Colors.green,
        ),
        const Text('Save this payment method for future purchases'),
      ],
    );
  }

  Widget _buildOrderSummary(CartProvider cart) {
    final subtotal = cart.calculateSubtotal();
    // Assume delivery fee is passed from previous page or calculated
    final deliveryFee = 5.00; // Replace with actual value
    final total = subtotal + deliveryFee;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ORDER SUMMARY',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Subtotal', subtotal),
          _buildSummaryRow('Delivery Fee', deliveryFee),
          const Divider(),
          _buildSummaryRow('TOTAL', total, isHighlighted: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '₵${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }
}

class OrderConfirmationPage extends StatelessWidget {
  const OrderConfirmationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text(
              'Order Confirmed!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your order has been placed successfully',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  HomePage(),
                  ),
                      (route) => false,
                );
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }
}