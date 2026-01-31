import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/notification_service.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _euroController = TextEditingController();
  final TextEditingController _inrController = TextEditingController();

  double _exchangeRate = 90.45; // Simulated live rate
  bool _isEuroToInr = false; // Default: INR to EUR is false, but wait.
  // Logic:
  // if _isEuroToInr is false, then top input is INR, bottom is EUR.
  // But original code:
  // _buildCurrencyInput(label: 'Euro (€)', enabled: _isEuroToInr)
  // _buildCurrencyInput(label: 'Indian Rupee (₹)', enabled: !_isEuroToInr)
  // So if _isEuroToInr is true, Euro is enabled (input).
  // If _isEuroToInr is false, INR is enabled (input).
  // The user wants Default INR to EURO. So _isEuroToInr should be false initially.

  Timer? _rateTimer;

  @override
  void initState() {
    super.initState();
    // Simulate live updates every 30 seconds
    _rateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _simulateRateChange();
    });
  }

  @override
  void dispose() {
    _rateTimer?.cancel();
    _euroController.dispose();
    _inrController.dispose();
    super.dispose();
  }

  void _simulateRateChange() {
    final random = (DateTime.now().second % 10) / 100.0;
    final newRate = 90.45 + (DateTime.now().second % 2 == 0 ? random : -random);

    if ((newRate - _exchangeRate).abs() > 0.01) {
      setState(() {
        _exchangeRate = newRate;
      });
      _showRateChangeNotification(newRate);
    }
  }

  void _showRateChangeNotification(double newRate) {
    // Show a real system notification that works on lock screen
    NotificationService().showNotification(
      id: 999,
      title: '💱 Currency Update',
      body: 'Live Rate: 1 EUR = ₹${newRate.toStringAsFixed(2)}',
    );

    // Also keep the SnackBar for immediate UI feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '💱 Live Rate Updated: 1 EUR = ₹${newRate.toStringAsFixed(2)}',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.secondary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _convert(String value) {
    if (value.isEmpty) {
      _euroController.clear();
      _inrController.clear();
      return;
    }

    double input = double.tryParse(value) ?? 0;
    if (!_isEuroToInr) {
      // INR to EUR
      _euroController.text = (input / _exchangeRate).toStringAsFixed(2);
    } else {
      // EUR to INR
      _inrController.text = (input * _exchangeRate).toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Currency Converter',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            _buildExchangeRateCard(),
            SizedBox(height: 40.h),
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
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insights_rounded, color: AppColors.primary, size: 20.sp),
          SizedBox(width: 12.w),
          Text(
            '1 EUR = ₹${_exchangeRate.toStringAsFixed(2)}',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              'LIVE',
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }

  Widget _buildCalculatorUI() {
    return Column(
      children: [
        _buildCurrencyInput(
          label: 'Indian Rupee (₹)',
          controller: _inrController,
          enabled: !_isEuroToInr,
          onChanged: _convert,
          icon: Icons.currency_rupee_rounded,
        ),
        SizedBox(height: 24.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.swap_vert_rounded,
            size: 24.sp,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 24.h),
        _buildCurrencyInput(
          label: 'Euro (€)',
          controller: _euroController,
          enabled: _isEuroToInr,
          onChanged: _convert,
          icon: Icons.euro_rounded,
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
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: onChanged,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary),
            hintText: '0.00',
            filled: true,
            fillColor: enabled
                ? Theme.of(context).cardTheme.color
                : Theme.of(context).dividerColor.withOpacity(0.05),
            contentPadding: EdgeInsets.all(20.w),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.r),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.r),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwapButton() {
    return InkWell(
      onTap: () {
        setState(() {
          _isEuroToInr = !_isEuroToInr;
          _euroController.clear();
          _inrController.clear();
        });
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 20.sp),
            SizedBox(width: 12.w),
            Text(
              'Switch Direction',
              style: GoogleFonts.outfit(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
