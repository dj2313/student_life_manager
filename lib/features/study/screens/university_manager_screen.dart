import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/study_provider.dart';

class UniversityManagerScreen extends StatelessWidget {
  final String uniType; // 'Public' or 'Private' or 'Language'

  const UniversityManagerScreen({super.key, required this.uniType});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudyProvider>(
      builder: (context, provider, child) {
        final universities = provider.getUniversitiesByType(uniType);

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 20.sp,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              '$uniType Universities',
              style: GoogleFonts.outfit(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          body: ListView(
            padding: EdgeInsets.all(24.w),
            children: [
              _buildInfoCard(context),
              SizedBox(height: 24.h),
              if (universities.isEmpty)
                _buildEmptyState(context)
              else
                ...universities.map(
                  (uni) => _buildUniversityCard(context, uni, provider),
                ),
              SizedBox(height: 100.h),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddUniversityDialog(context, provider),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              'Add University',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final descriptions = {
      'Public':
          'Public universities in Germany offer high-quality education with low or no tuition fees.',
      'Private':
          'Private universities offer specialized programs with smaller class sizes.',
      'Language':
          'Language schools and institutions for learning German and other languages.',
    };

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.accent.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.primary,
            size: 24.sp,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              descriptions[uniType] ?? '',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: AppColors.textSecondaryLight,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 60.h),
        child: Column(
          children: [
            Icon(
              Icons.school_outlined,
              size: 64.sp,
              color: AppColors.textTertiaryLight.withOpacity(0.3),
            ),
            SizedBox(height: 16.h),
            Text(
              'No universities added yet',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                color: AppColors.textSecondaryLight,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Tap the + button to add one',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: AppColors.textTertiaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUniversityCard(
    BuildContext context,
    Map<String, dynamic> uni,
    StudyProvider provider,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.account_balance_rounded,
                  color: AppColors.secondary,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      uni['name'] ?? '',
                      style: GoogleFonts.outfit(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (uni['location'] != null)
                      Text(
                        uni['location'],
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                ),
                onPressed: () =>
                    _showDeleteDialog(context, provider, uni['id']),
              ),
            ],
          ),
          if (uni['program'] != null) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                uni['program'],
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
          if (uni['notes'] != null && uni['notes'].isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              uni['notes'],
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: AppColors.textSecondaryLight,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddUniversityDialog(BuildContext context, StudyProvider provider) {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final programController = TextEditingController();
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Text(
              'Add University',
              style: GoogleFonts.outfit(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24.h),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'University Name',
                        hintText: 'e.g., TU Berlin',
                        prefixIcon: Icon(Icons.school_rounded),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        hintText: 'e.g., Berlin, Germany',
                        prefixIcon: Icon(Icons.location_on_rounded),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      controller: programController,
                      decoration: const InputDecoration(
                        labelText: 'Program/Course',
                        hintText: 'e.g., Computer Science',
                        prefixIcon: Icon(Icons.book_rounded),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        hintText: 'Any additional information...',
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    provider.addUniversity(
                      type: uniType,
                      name: nameController.text,
                      location: locationController.text,
                      program: programController.text,
                      notes: notesController.text,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add University'),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16.h),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    StudyProvider provider,
    String id,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete University?'),
        content: const Text(
          'Are you sure you want to remove this university from your list?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteUniversity(id);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
