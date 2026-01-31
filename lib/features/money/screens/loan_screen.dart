import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/money_provider.dart';
import '../../../data/models/loan.dart';

class LoanScreen extends StatelessWidget {
  const LoanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MoneyProvider>(
      builder: (context, provider, child) {
        final activeLoans = provider.loans
            .where((l) => l.status == 'active')
            .toList();
        final completedLoans = provider.loans
            .where((l) => l.status == 'completed')
            .toList();
        final textColor = Theme.of(context).colorScheme.primary;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: textColor,
                size: 20.sp,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Loan Management',
              style: GoogleFonts.outfit(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            actions: [
              // Currency selector
              Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: DropdownButton<String>(
                    value: provider.selectedCurrency,
                    underline: const SizedBox(),
                    isDense: true,
                    icon: Icon(
                      Icons.arrow_drop_down_rounded,
                      color: AppColors.secondary,
                      size: 20.sp,
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                    items: provider.supportedCurrencies.take(8).map((
                      String currency,
                    ) {
                      return DropdownMenuItem<String>(
                        value: currency,
                        child: Text(
                          '${provider.getCurrencySymbol(currency)} $currency',
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        provider.setSelectedCurrency(newValue);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: EdgeInsets.all(24.w),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildSectionTitle(context, 'ACTIVE LOANS'),
              SizedBox(height: 16.h),
              if (activeLoans.isEmpty)
                _buildEmptyState(context, 'No active loans')
              else
                ...activeLoans.map(
                  (loan) => _buildLoanCard(context, loan, provider),
                ),

              SizedBox(height: 32.h),
              _buildSectionTitle(context, 'COMPLETED'),
              SizedBox(height: 16.h),
              if (completedLoans.isEmpty)
                _buildEmptyState(context, 'No completed loans')
              else
                ...completedLoans.map(
                  (loan) => _buildLoanCard(context, loan, provider),
                ),
              SizedBox(height: 100.h),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddLoanDialog(context, provider),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 11.sp,
        fontWeight: FontWeight.w800,
        color: AppColors.textTertiaryLight,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          children: [
            Icon(
              Icons.handshake_outlined,
              size: 48.sp,
              color: AppColors.textTertiaryLight.withOpacity(0.3),
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              style: GoogleFonts.inter(color: AppColors.textSecondaryLight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanCard(
    BuildContext context,
    Loan loan,
    MoneyProvider provider,
  ) {
    final cardColor = Theme.of(context).cardTheme.color;
    final textColor = Theme.of(context).colorScheme.primary;
    final isCompleted = loan.status == 'completed';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1.2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.secondary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_circle_outline_rounded
                      : Icons.handshake_outlined,
                  color: isCompleted ? AppColors.success : AppColors.secondary,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loan.personName,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'Due: ${DateFormat('MMM dd, yyyy').format(loan.dueDate)}',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${provider.getCurrencySymbol(provider.selectedCurrency)}${loan.remaining.toStringAsFixed(0)}',
                    style: GoogleFonts.outfit(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? AppColors.success : textColor,
                    ),
                  ),
                  Text(
                    'of ${provider.getCurrencySymbol(provider.selectedCurrency)}${loan.amount.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (!isCompleted) ...[
            SizedBox(height: 20.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: 1 - (loan.remaining / loan.amount),
                minHeight: 6.h,
                backgroundColor: textColor.withOpacity(0.05),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.secondary,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () =>
                      _showAddPaymentDialog(context, loan, provider),
                  icon: const Icon(Icons.payment_rounded, size: 16),
                  label: Text(
                    'Pay Back',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  void _showAddLoanDialog(BuildContext context, MoneyProvider provider) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    DateTime dueDate = DateTime.now().add(const Duration(days: 30));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Track New Loan',
                style: GoogleFonts.outfit(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24.h),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(dueDate),
                    );
                    if (time != null) {
                      setState(() {
                        dueDate = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event_rounded,
                        size: 16.sp,
                        color: AppColors.secondary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Due: ${DateFormat('MMM dd, yyyy - HH:mm').format(dueDate)}',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Person Name',
                  hintText: 'Who?',
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText:
                      'Total Amount (${provider.getCurrencySymbol(provider.selectedCurrency)})',
                  hintText: '0.00',
                ),
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        amountController.text.isNotEmpty) {
                      final amount =
                          double.tryParse(amountController.text) ?? 0;
                      provider.addLoan(
                        Loan(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          personName: nameController.text,
                          amount: amount,
                          remaining: amount,
                          status: 'active',
                          dueDate: dueDate,
                          createdAt: DateTime.now(),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save Loan'),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddPaymentDialog(
    BuildContext context,
    Loan loan,
    MoneyProvider provider,
  ) {
    final amountController = TextEditingController();
    DateTime paymentDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Payment',
                style: GoogleFonts.outfit(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Paying back to ${loan.personName}',
                style: GoogleFonts.inter(color: AppColors.textSecondaryLight),
              ),
              SizedBox(height: 24.h),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: paymentDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(paymentDate),
                    );
                    if (time != null) {
                      setState(() {
                        paymentDate = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 16.sp,
                        color: AppColors.secondary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Date: ${DateFormat('MMM dd, HH:mm').format(paymentDate)}',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText:
                      'Repayment Amount (${provider.getCurrencySymbol(provider.selectedCurrency)})',
                  hintText: '0.00',
                ),
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text) ?? 0;
                    if (amount > 0) {
                      provider.updateLoanPayment(loan.id, amount);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Confirm Repayment'),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
            ],
          ),
        ),
      ),
    );
  }
}
