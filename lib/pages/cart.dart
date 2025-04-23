import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eclapp/pages/homepage.dart';
import 'package:eclapp/pages/signinpage.dart';
import 'auth_service.dart';
import 'bottomnav.dart';
import 'cartprovider.dart';
import 'delivery_page.dart';


class Cart extends StatefulWidget {
  const Cart({Key? key}) : super(key: key);

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  String deliveryOption = 'Delivery';

  String? selectedRegion;
  String? selectedCity;
  String? selectedTown;
  double deliveryFee = 0.00;

  TextEditingController addressController = TextEditingController();


  @override
  void initState() {
    super.initState();
  }


  void showTopSnackBar(BuildContext context, String message, {Duration? duration}) {
    final overlay = Overlay.of(context);

    late final OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 50,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green[900],
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration ?? const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  Map<String, Map<String, Map<String, double>>> locationFees = {
    'Greater Accra': {
      'Accra': {'Madina': 5.00, 'Osu': 6.50},
      'Tema': {'Community 1': 6.00, 'Community 2': 7.00},
    },
    'Ashanti': {
      'Kumasi': {'Adum': 4.50, 'Asokwa': 5.50, 'Ahodwo': 6.00},
      'Ejisu': {'Ejisu Town': 5.00, 'Besease': 5.50},
    },
    'Western': {
      'Takoradi': {'Market Circle': 4.00, 'Anaji': 5.00, 'Effia': 6.00},
    },
  };

  List<String> regions = ['Greater Accra', 'Ashanti', 'Western'];
  Map<String, List<String>> cities = {
    'Greater Accra': ['Accra', 'Tema'],
    'Ashanti': ['Kumasi'],
    'Western': ['Takoradi'],
  };

  Map<String, List<String>> towns = {
    'Accra': ['Madina', 'Osu'],
    'Tema': ['Community 1', 'Community 2'],
    'Kumasi': ['Adum', 'Asokwa'],
    'Takoradi': ['Market Circle', 'Anaji'],
  };

  List<String> pickupLocations = ['Madina Mall', 'Accra Mall', 'Kumasi City Mall', 'Takoradi Mall'];



  void _handleDeliveryOptionChange(String option) {
    setState(() {
      deliveryOption = option;
      if (option == 'Pickup') {
        selectedRegion = null;
        selectedCity = null;
        selectedTown = null;
        deliveryFee = 0.00;
      }
    });
  }


  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    if (!isLoggedIn && context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen(returnTo: '/cart')),
      );
    }
  }
  void _handleCheckout(BuildContext context) {
    if (context.read<CartProvider>().cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Your cart is empty!")),
      );
      return;
    }

    context.read<CartProvider>().purchaseItems();

    Future.delayed(Duration(milliseconds: 500), () {
      context.read<CartProvider>().clearCart();
    });

    showTopSnackBar(context, 'Purchase Successful');
  }





  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Your Cart'),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(30),
              child: _buildProgressIndicator(),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: cart.cartItems.isEmpty
                    ? _buildEmptyCart()
                    : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: cart.cartItems.length,
                  itemBuilder: (context, index) => _buildCartItem(cart, index),
                ),
              ),
              _buildStickyCheckoutBar(cart),
            ],
          ),
        );
      },
    );
  }


  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildProgressStep('Cart', isActive: true),
          _buildProgressStep('Delivery', isActive: false),
          _buildProgressStep('Payment', isActive: false),
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
            color: isActive ? Colors.green : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 2,
          width: 50,
          color: isActive ? Colors.green : Colors.grey[300],
        ),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Your cart is empty',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartProvider cart, int index) {
    final item = cart.cartItems[index];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              image: DecorationImage(
                image: NetworkImage(item.image.startsWith('http')
                    ? item.image
                    : 'https://eclcommerce.ernestchemists.com.gh/storage/${item.image}'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Product Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₵${item.price.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.green[700]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Quantity controls
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: () {
                                if (item.quantity > 1) {
                                  cart.updateQuantity(index, item.quantity - 1);
                                } else {
                                  cart.removeFromCart(index);
                                }
                              },
                            ),
                            Text(item.quantity.toString()),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: () => cart.updateQuantity(index, item.quantity + 1),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => cart.removeFromCart(index),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyCheckoutBar(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Promo Code Field
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter promo code',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {}, // Add promo code logic
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                ),
                child: const Text('APPLY'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Delivery Options
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'DELIVERY OPTION:',
                style: TextStyle(fontSize: 10),
              ),
              const SizedBox(width: 1),
              Expanded(
                child: ChoiceChip(
                  label: const Text(
                    'Home Delivery',
                    style: TextStyle(fontSize: 12),
                  ),
                  selected: deliveryOption == 'Delivery',
                  onSelected: (selected) => _handleDeliveryOptionChange('Delivery'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Text(
                    'Pickup Station',
                    style: TextStyle(fontSize: 12),
                  ),
                  selected: deliveryOption == 'Pickup',
                  onSelected: (selected) => _handleDeliveryOptionChange('Pickup'),
                ),
              ),
            ],
          )
,
          const SizedBox(height: 12),

          // Order Summary
          _buildOrderSummary(cart),
          const SizedBox(height: 12),

          // Checkout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
    onPressed: () {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const DeliveryPage()),
    );
    },
              child: const Text('PROCEED TO CHECKOUT'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cart) {
    final subtotal = cart.calculateSubtotal();
    final total = subtotal + (deliveryOption == 'Delivery' ? deliveryFee : 0);

    return Column(
      children: [
        _buildSummaryRow('Subtotal', subtotal),
        _buildSummaryRow('Delivery Fee',
          deliveryOption == 'Delivery' ? deliveryFee : 0,
          isHighlighted: false,
        ),
        const Divider(),
        _buildSummaryRow('TOTAL', total, isHighlighted: true),
      ],
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



  Widget _buildCheckoutSection(CartProvider cart) {
    List<String> pickupLocations = [
      'Madina Mall',
      'Accra Mall',
      'Kumasi City Mall',
      'Takoradi Mall',
    ];


    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Shipping:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              _buildRadioButton('Delivery'),
              _buildRadioButton('Pickup'),
            ],
          ),

          // **Delivery Address or Pickup Location**
          if (deliveryOption == 'Delivery') ...[
            _buildRegionDropdown(),
            _buildCityDropdown(),
            _buildTownDropdown(),
          ] else ...[
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Pickup Location'),
              value: selectedTown,
              items: pickupLocations.map((location) {
                return DropdownMenuItem(value: location, child: Text(location, style: const TextStyle(fontSize: 14)));
              }).toList(),
              onChanged: (value) => setState(() => selectedTown = value),
            ),
          ],

          const SizedBox(height: 5),

          _buildPriceDetails(cart),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _handleCheckout(context),
              child: const Text('Checkout', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }




  Widget _buildRadioButton(String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: deliveryOption,
          onChanged: (newValue) => _handleDeliveryOptionChange(newValue!),
        ),
        Text(value),
      ],
    );
  }


  Widget _buildAddressField() {
    return TextField(
      controller: addressController,
      decoration: InputDecoration(
        labelText: 'Enter your address',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }

  Widget _buildPriceDetails(CartProvider cart) {
    double subtotal = cart.calculateSubtotal();
    double total = subtotal + (deliveryOption == 'Delivery' ? deliveryFee : 0.00);

    return Column(
      children: [
        _buildPriceRow('Subtotal', subtotal),
        if (deliveryOption == 'Delivery' && selectedTown != null)
          _buildPriceRow('Delivery Fee', deliveryFee, color: Colors.grey.shade800),
        _buildPriceRow('Total', total, isBold: true, color: Colors.green.shade800),
      ],
    );
  }



  Widget _buildPriceRow(String label, double amount, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.w600)),
        Text('\₵${amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
      ],
    );
  }

  Widget _buildRegionDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: 'Select Region'),
      value: selectedRegion,
      items: regions.map((region) {
        return DropdownMenuItem(value: region, child: Text(region));
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedRegion = value;
          selectedCity = null;
          selectedTown = null;
        });
      },
    );
  }


  Widget _buildCityDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: 'Select City'),
      value: selectedCity,
      items: (selectedRegion != null && cities.containsKey(selectedRegion))
          ? cities[selectedRegion]!.map((city) {
        return DropdownMenuItem(value: city, child: Text(city));
      }).toList()
          : [],
      onChanged: (value) {
        setState(() {
          selectedCity = value;
          selectedTown = null;
        });
      },
    );
  }


  Widget _buildTownDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: 'Select Town'),
      value: selectedTown,
      items: (selectedCity != null && towns.containsKey(selectedCity))
          ? towns[selectedCity]!.map((town) {
        return DropdownMenuItem(value: town, child: Text(town));
      }).toList()
          : [],
      onChanged: (value) {
        setState(() {
          selectedTown = value;
          if (selectedRegion != null && selectedCity != null && selectedTown != null) {
            deliveryFee = locationFees[selectedRegion]?[selectedCity]?[selectedTown] ?? 0.00;
          }
        });
      },

    );
  }





}
