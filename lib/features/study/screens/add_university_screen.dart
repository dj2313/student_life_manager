import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../core/constants/app_colors.dart';
import '../providers/study_provider.dart';
import '../../../data/models/university.dart';
import 'package:uuid/uuid.dart';

class AddUniversityScreen extends StatefulWidget {
  final String? initialType;
  const AddUniversityScreen({super.key, this.initialType});

  @override
  State<AddUniversityScreen> createState() => _AddUniversityScreenState();
}

class _AddUniversityScreenState extends State<AddUniversityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _courseController = TextEditingController();
  final _durationController = TextEditingController();
  final _feesController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  String _uniType = 'Public';

  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _uniType = widget.initialType ?? 'Public';
    _speech = stt.SpeechToText();
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _nameController.text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final university = University(
        id: const Uuid().v4(),
        name: _nameController.text,
        type: _uniType,
        course: _courseController.text,
        duration: _durationController.text,
        tuitionFees: double.tryParse(_feesController.text) ?? 0.0,
        location: _locationController.text,
        notes: _notesController.text,
        status: 'Interested',
      );

      Provider.of<StudyProvider>(
        context,
        listen: false,
      ).addUniversity(university);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Add University',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'University Details',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textTertiaryLight,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 16.h),
              _buildTypeSelector(),
              SizedBox(height: 24.h),
              _buildTextField(
                label: 'University Name',
                controller: _nameController,
                hint: 'e.g. Technical University of Munich',
                icon: Icons.school_outlined,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: _isListening ? AppColors.error : AppColors.primary,
                  ),
                  onPressed: _listen,
                ),
                validator: (v) => v!.isEmpty ? 'Name is required' : null,
              ),
              SizedBox(height: 20.h),
              _buildTextField(
                label: 'Course / Major',
                controller: _courseController,
                hint: 'e.g. MSc Data Science',
                icon: Icons.book_outlined,
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Duration',
                      controller: _durationController,
                      hint: 'e.g. 2 Years',
                      icon: Icons.timer_outlined,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildTextField(
                      label: 'Tuition Fees (€)',
                      controller: _feesController,
                      hint: 'e.g. 1500',
                      icon: Icons.euro_symbol_rounded,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              _buildTextField(
                label: 'Location',
                controller: _locationController,
                hint: 'e.g. Munich, Germany',
                icon: Icons.location_on_outlined,
              ),
              SizedBox(height: 20.h),
              _buildTextField(
                label: 'Notes',
                controller: _notesController,
                hint: 'Application deadlines, requirements...',
                icon: Icons.notes_rounded,
                maxLines: 3,
              ),
              SizedBox(height: 40.h),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildTypeButton('Public', Icons.account_balance_rounded),
        ),
        SizedBox(width: 16.w),
        Expanded(child: _buildTypeButton('Private', Icons.business_rounded)),
      ],
    );
  }

  Widget _buildTypeButton(String type, IconData icon) {
    final isSelected = _uniType == type;
    final color = type == 'Public' ? AppColors.primary : AppColors.accent;

    return GestureDetector(
      onTap: () => setState(() => _uniType = type),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected ? color : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? color
                : Theme.of(context).dividerColor.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : color, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              type,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    required IconData icon,
    Widget? suffixIcon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
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
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Theme.of(context).cardTheme.color,
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

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 60.h,
      child: ElevatedButton(
        onPressed: _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          elevation: 0,
        ),
        child: Text(
          'Add University',
          style: GoogleFonts.outfit(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
