import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/home_provider.dart';
import '../../../data/models/ticket.dart';
import '../../notes/screens/notes_screen.dart';
import './location_screen.dart';
import './support_screen.dart';
import '../../../core/providers/navigation_provider.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context, homeProvider),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildVisaStatusCard(context, homeProvider),
                      SizedBox(height: 32.h),
                      _buildQuickAccessSection(context),
                      SizedBox(height: 32.h),
                      _buildTicketsSection(context, homeProvider),
                      SizedBox(height: 120.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context, HomeProvider provider) {
    return SliverAppBar(
      expandedHeight: 120.h,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 60.h, 24.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Guten Tag,',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                provider.userName,
                style: GoogleFonts.outfit(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 16.w, top: 8.h),
          child: CircleAvatar(
            radius: 20.r,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(
              Icons.person_outline,
              color: AppColors.primary,
              size: 20.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisaStatusCard(BuildContext context, HomeProvider provider) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF2A3A4E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Residence Permit',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  provider.visaStatus,
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            '${provider.visaDaysRemaining} Days Left',
            style: GoogleFonts.outfit(
              fontSize: 32.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: provider.visaDaysRemaining / 90,
              minHeight: 6.h,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'QUICK ACCESS',
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textTertiaryLight,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildQuickTile(
                  context,
                  Icons.location_on_outlined,
                  'Location',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LocationScreen(),
                      ),
                    );
                  },
                ),
                _buildQuickTile(context, Icons.note_alt_outlined, 'Notes', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotesScreen(),
                    ),
                  );
                }),
                _buildQuickTile(
                  context,
                  Icons.help_outline_rounded,
                  'Support',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SupportScreen(),
                      ),
                    );
                  },
                ),
                _buildQuickTile(
                  context,
                  Icons.settings_outlined,
                  'Settings',
                  () {
                    navProvider.setIndex(4);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickTile(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketsSection(BuildContext context, HomeProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Tickets',
              style: GoogleFonts.outfit(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            Text(
              'View All',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        ...provider.activeTickets.map(
          (ticket) => _buildTicketCard(context, ticket),
        ),
      ],
    );
  }

  Widget _buildTicketCard(BuildContext context, Ticket ticket) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderLight, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              ticket.type == 'Train'
                  ? Icons.train_outlined
                  : Icons.directions_bus_outlined,
              color: AppColors.accent,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.route,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '${ticket.ticketNumber} • ${ticket.time}',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.qr_code_2_rounded,
            size: 32,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
