import 'package:flutter/material.dart';
import '../utils/helpers.dart'; // Adjust as per your project structure

class PaymentDialog extends StatefulWidget {
  final String title;
  final String buttonText;
  final double minAmount;
  final void Function(String upiId, double amount) onConfirm;
  final int? amount;

  const PaymentDialog({
    super.key,
    required this.title,
    required this.buttonText,
    required this.minAmount,
    required this.onConfirm,
    this.amount,
  });

  /// 🔹 Call this method to open the dialog from anywhere
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String buttonText,
    required double minAmount,
    required void Function(String upiId, double amount) onConfirm,
    int? amount,
  }) {
    return showDialog(
      context: context,
      builder: (_) => PaymentDialog(
        title: title,
        buttonText: buttonText,
        minAmount: minAmount,
        onConfirm: onConfirm,
        amount: amount,
      ),
    );
  }

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _upiController;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _upiController = TextEditingController();
    _amountController = TextEditingController(
      text: widget.amount != null
          ? widget.amount.toString()
          : widget.minAmount.toString(),
    );
  }

  @override
  void dispose() {
    _upiController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 16),
                UiHelpers.customTextField(
                  context,
                  hintText: "UPI ID",
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                  controller: _upiController,

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your UPI ID';
                    }
                    if (!value.contains('@')) {
                      return 'Enter valid UPI ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                UiHelpers.customTextField(
                  context,
                  hintText: "Enter Amount",
                  prefixIcon: const Icon(Icons.currency_rupee),
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  enabled: widget.amount == null,
                  validator: (value) {
                    final amount = double.tryParse(value ?? '');
                    if (value == null || value.isEmpty) {
                      return 'Enter amount';
                    }
                    if (amount == null || amount < widget.minAmount) {
                      return 'Minimum ₹${widget.minAmount.toInt()}';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Minimum ₹${widget.minAmount.toInt()}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.onConfirm(
                            _upiController.text.trim(),
                            double.parse(_amountController.text.trim()),
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: Text(widget.buttonText),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
