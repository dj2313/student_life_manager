import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/money_provider.dart';

class LiveCurrencyConverter extends StatefulWidget {
  const LiveCurrencyConverter({super.key});

  @override
  State<LiveCurrencyConverter> createState() => _LiveCurrencyConverterState();
}

class _LiveCurrencyConverterState extends State<LiveCurrencyConverter> {
  String _fromCurrency = 'INR';
  String _toCurrency = 'EUR';
  double _amount = 100.0;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '100');
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MoneyProvider>(
      builder: (context, provider, child) {
        final convertedAmount = provider.convertCurrency(
          _amount,
          _fromCurrency,
          _toCurrency,
        );
        final lastUpdate = provider.lastRateUpdate;
        final isStale = provider.isRatesStale;

        return Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with refresh button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Currency Rates',
                        style: GoogleFonts.outfit(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      if (lastUpdate != null)
                        Text(
                          'Updated: ${_formatTime(lastUpdate)}',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: isStale
                                ? AppColors.error
                                : AppColors.textTertiaryLight,
                          ),
                        ),
                    ],
                  ),
                  InkWell(
                    onTap: provider.isRefreshingRates
                        ? null
                        : () => provider.refreshCurrencyRates(),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: provider.isRefreshingRates
                          ? SizedBox(
                              width: 16.sp,
                              height: 16.sp,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  AppColors.secondary,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.refresh_rounded,
                              size: 20.sp,
                              color: AppColors.secondary,
                            ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Amount input
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '100',
                          hintStyle: GoogleFonts.jetBrainsMono(
                            color: AppColors.textTertiaryLight,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _amount = double.tryParse(value) ?? 100.0;
                          });
                        },
                      ),
                    ),
                    _buildCurrencyDropdown(_fromCurrency, (value) {
                      setState(() => _fromCurrency = value);
                    }, provider),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              // Swap button
              Center(
                child: InkWell(
                  onTap: _swapCurrencies,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.swap_vert_rounded,
                      color: AppColors.primary,
                      size: 24.sp,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Converted amount
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.secondary.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        convertedAmount.toStringAsFixed(2),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                    _buildCurrencyDropdown(_toCurrency, (value) {
                      setState(() => _toCurrency = value);
                    }, provider),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Exchange rate info
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '1 $_fromCurrency = ',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    Text(
                      '${provider.getExchangeRate(_fromCurrency, _toCurrency).toStringAsFixed(4)} $_toCurrency',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrencyDropdown(
    String value,
    Function(String) onChanged,
    MoneyProvider provider,
  ) {
    final currencies = provider.supportedCurrencies;

    // Ensure we have currencies
    if (currencies.isEmpty) {
      return Text(
        value,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.accent,
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: DropdownButton<String>(
        value: currencies.contains(value) ? value : currencies.first,
        underline: const SizedBox(),
        isDense: true,
        icon: Icon(
          Icons.arrow_drop_down_rounded,
          color: AppColors.accent,
          size: 20.sp,
        ),
        dropdownColor: Theme.of(context).cardColor,
        items: currencies.map((String currency) {
          return DropdownMenuItem<String>(
            value: currency,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  provider.getCurrencySymbol(currency),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  currency,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM dd, HH:mm').format(dateTime);
    }
  }
}
