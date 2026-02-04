import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../data/models/student_os_models.dart';
import '../providers/gpa_provider.dart';

class GPAManagerScreen extends StatelessWidget {
  const GPAManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGPASummaryCard(context),
                  SizedBox(height: 32.h),
                  _buildSectionTitle(context, 'ACADEMIC MODULES'),
                  SizedBox(height: 16.h),
                  _buildModulesBySemester(context),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddModuleSheet(context),
        label: const Text('Add Module'),
        icon: const Icon(Icons.add_task_rounded),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120.h,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: EdgeInsets.only(left: 24.w, bottom: 16.h),
        title: Text(
          'GPA & ECTS',
          style: GoogleFonts.outfit(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 24.sp,
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildGPASummaryCard(BuildContext context) {
    return Consumer<GPAProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.secondary, Color(0xFFF43F5E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'German GPA',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    provider.currentGPA.toStringAsFixed(2),
                    style: GoogleFonts.outfit(
                      fontSize: 48.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildSmallStat('Credits', provider.totalCredits.toString()),
                  SizedBox(height: 12.h),
                  _buildSmallStat('Target', '1.0'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSmallStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.6),
            fontSize: 10.sp,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildModulesBySemester(BuildContext context) {
    return Consumer<GPAProvider>(
      builder: (context, provider, child) {
        final grouped = provider.modulesBySemester;
        if (grouped.isEmpty) return const SizedBox();

        return ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: grouped.keys.length,
          itemBuilder: (context, index) {
            final semester = grouped.keys.toList()[index];
            final modules = grouped[semester]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Text(
                    semester,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                ...modules.map((m) => _buildModuleTile(context, m)).toList(),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildModuleTile(BuildContext context, AcademicModule module) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              module.grade?.toStringAsFixed(1) ?? '-',
              style: GoogleFonts.jetBrainsMono(
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.name,
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${module.ects} ECTS',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            module.isCompleted
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked,
            color: module.isCompleted
                ? AppColors.success
                : context.textTertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 11.sp,
        fontWeight: FontWeight.w800,
        color: context.textTertiary,
        letterSpacing: 1.5,
      ),
    );
  }

  void _showAddModuleSheet(BuildContext context) {
    final nameController = TextEditingController();
    final ectsController = TextEditingController();
    final gradeController = TextEditingController();
    final provider = context.read<GPAProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Academic Module',
              style: GoogleFonts.outfit(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24.h),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Module Name'),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ectsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'ECTS'),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: TextField(
                    controller: gradeController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Grade (1.0 - 5.0)',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    provider.addModule(
                      AcademicModule(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text,
                        ects: int.tryParse(ectsController.text) ?? 5,
                        grade: double.tryParse(gradeController.text),
                        semester: 'SoSe 2024',
                        isCompleted: gradeController.text.isNotEmpty,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save Module'),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
          ],
        ),
      ),
    );
  }
}
