import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../services/payment_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _isLoading = true;
  double _balance = 0.0;
  List<dynamic> _methods = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWalletData();
  }

  Future<void> _fetchWalletData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final balanceResult = await PaymentService.getWalletBalance();
    final methodsResult = await PaymentService.getPaymentMethods();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (balanceResult['success'] == true) {
          _balance = double.tryParse(balanceResult['data']['balance'].toString()) ?? 0.0;
        } else {
          _error = balanceResult['message'];
        }

        if (methodsResult['success'] == true) {
          _methods = methodsResult['data'] ?? [];
        }
      });
    }
  }

  Future<void> _addFunds() async {
    if (_methods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a payment method first')),
      );
      return;
    }

    final methodId = _methods.first['provider_method_id'];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    final result = await PaymentService.addFunds(50.0, methodId); // Mock adding $50
    if (!mounted) return;

    Navigator.pop(context); // Close dialog

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added \$50.00 to wallet')),
      );
      _fetchWalletData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to add funds')),
      );
    }
  }

  Future<void> _addPaymentMethod() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    // Mock adding a card
    final date = DateTime.now().millisecondsSinceEpoch.toString();
    final result = await PaymentService.addPaymentMethod(
      'tok_${date.substring(date.length - 6)}',
      (1000 + (DateTime.now().millisecond * 3)).toString().substring(0, 4),
      'Visa'
    );
    
    if (!mounted) return;
    Navigator.pop(context);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment method added successfully')),
      );
      _fetchWalletData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to add method')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Wallet & Payments', style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark)),
        backgroundColor: isDark ? AppTheme.backgroundDark : Colors.white,
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppTheme.textDark),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: TextStyle(color: isDark ? Colors.red[300] : Colors.red)))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Balance Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryGreen, AppTheme.primaryGreen.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                        ]
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Available Balance', style: TextStyle(color: Colors.white70, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('\$${_balance.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _addFunds,
                            icon: const Icon(Icons.add, color: Colors.green),
                            label: const Text('Add \$50 (Mock)', style: TextStyle(color: Colors.green)),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Payment Methods Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Payment Methods',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.textDark),
                        ),
                        TextButton(
                          onPressed: _addPaymentMethod,
                          child: Text('+ Add New', style: TextStyle(color: AppTheme.primaryGreen)),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    _methods.isEmpty
                        ? Text('No payment methods added.', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _methods.length,
                            itemBuilder: (context, index) {
                              final method = _methods[index];
                              return Card(
                                color: isDark ? AppTheme.cardDark : Colors.white,
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: Icon(Icons.credit_card, color: AppTheme.primaryGreen, size: 32),
                                  title: Text('${method['brand']} •••• ${method['last4']}', 
                                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600)
                                  ),
                                  subtitle: method['is_default'] == true 
                                    ? Text('Default', style: TextStyle(color: AppTheme.primaryGreen))
                                    : null,
                                ),
                              );
                            },
                          ),
                  ],
                ),
    );
  }
}
