import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _euroController = TextEditingController();
  final TextEditingController _inrController = TextEditingController();
  
  double _exchangeRate = 90.45; // Fixed rate for now
  bool _isEuroToInr = true;

  void _convert(String value) {
    if (value.isEmpty) {
      if (_isEuroToInr) {
        _inrController.clear();
      } else {
        _euroController.clear();
      }
      return;
    }

    double input = double.tryParse(value) ?? 0;
    if (_isEuroToInr) {
      _inrController.text = (input * _exchangeRate).toStringAsFixed(2);
    } else {
      _euroController.text = (input / _exchangeRate).toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Calculator'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.paddingLG.w),
        child: Column(
          children: [
            _buildExchangeRateCard(),
            SizedBox(height: 30.h),
            _buildCalculatorUI(),
            SizedBox(height: 40.h),
            _buildSwapButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildExchangeRateCard() {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMD.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusLG.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary),
          SizedBox(width: 10.w),
          Text(
            '1 EUR = ₹$_exchangeRate',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            '(Live)',
            style: TextStyle(fontSize: 12.sp, color: AppColors.success),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorUI() {
    return Column(
      children: [
        _buildCurrencyInput(
          label: 'Euro (€)',
          controller: _euroController,
          enabled: _isEuroToInr,
          onChanged: _convert,
          icon: Icons.euro,
        ),
        SizedBox(height: 20.h),
        Icon(Icons.unfold_more, size: 30.sp, color: AppColors.primary),
        SizedBox(height: 20.h),
        _buildCurrencyInput(
          label: 'Indian Rupee (₹)',
          controller: _inrController,
          enabled: !_isEuroToInr,
          onChanged: _convert,
          icon: Icons.currency_rupee,
        ),
      ],
    );
  }

  Widget _buildCurrencyInput({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    required Function(String) onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: onChanged,
          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary),
            hintText: '0.00',
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMD.r),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwapButton() {
    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          _isEuroToInr = !_isEuroToInr;
          _euroController.clear();
          _inrController.clear();
        });
      },
      icon: const Icon(Icons.swap_vert),
      label: const Text('Swap Direction'),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 50.h),
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD.r),
        ),
      ),
    );
  }
}
