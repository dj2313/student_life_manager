import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/tasks_provider.dart';
import '../../../core/utils/context_extensions.dart';
import './calendar_screen.dart';
import '../../../data/models/todo.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String _voiceText = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initSpeech();
  }

  void _initSpeech() async {
    await _speechToText.initialize();
    setState(() {});
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize(
        onStatus: (status) => debugPrint('onStatus: $status'),
        onError: (errorNotification) =>
            debugPrint('onError: $errorNotification'),
      );
      if (available) {
        context.hapticClick();
        setState(() => _isListening = true);
        _speechToText.listen(
          onResult: (result) {
            setState(() {
              _voiceText = result.recognizedWords;
              if (result.finalResult) {
                _isListening = false;
                _showVoiceAddTaskDialog(_voiceText);
              }
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speechToText.stop();
    }
  }

  void _showVoiceAddTaskDialog(String text) {
    if (text.isEmpty) return;
    final provider = Provider.of<TasksProvider>(context, listen: false);
    provider.addTask(
      Todo(
        id: const Uuid().v4(),
        title: text,
        priority: 'high',
        dueDate: DateTime.now(),
        category: 'Personal',
        createdAt: DateTime.now(),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task added: $text'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TasksProvider>(
      builder: (context, tasksProvider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(context),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCompletionStatus(context, tasksProvider)
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.1, end: 0),
                        SizedBox(height: 32.h),
                        _buildCategoryFilter(context, tasksProvider)
                            .animate()
                            .fadeIn(delay: 200.ms)
                            .slideX(begin: 0.1, end: 0),
                        SizedBox(height: 24.h),
                        _buildTabBar(context).animate().fadeIn(delay: 400.ms),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
                SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTaskListView(
                        context,
                        tasksProvider.todayTasks,
                        tasksProvider,
                      ),
                      _buildTaskListView(
                        context,
                        tasksProvider.tomorrowTasks,
                        tasksProvider,
                      ),
                      _buildTaskListView(
                        context,
                        tasksProvider.weekTasks,
                        tasksProvider,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: 'voice',
                onPressed: _listen,
                backgroundColor: _isListening
                    ? AppColors.error
                    : AppColors.secondary,
                child: Icon(
                  _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.only(bottom: 80.h),
                child: FloatingActionButton(
                  heroTag: 'add',
                  onPressed: () =>
                      _showAddTaskBottomSheet(context, tasksProvider),
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Objectives',
        style: GoogleFonts.outfit(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.calendar_month_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CalendarScreen()),
          ),
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildCompletionStatus(BuildContext context, TasksProvider provider) {
    final textColor = Theme.of(context).colorScheme.primary;
    final ratio = provider.totalCount > 0
        ? provider.completedCount / provider.totalCount
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Velocity',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: AppColors.textSecondaryLight,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${provider.completedCount}/${provider.totalCount}',
              style: GoogleFonts.outfit(
                fontSize: 48.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            if (_isListening)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: Row(
                    children: [
                      ...List.generate(
                        3,
                        (index) =>
                            Container(
                                  width: 3.w,
                                  height: 12.h,
                                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    borderRadius: BorderRadius.circular(2.r),
                                  ),
                                )
                                .animate(
                                  onPlay: (controller) =>
                                      controller.repeat(reverse: true),
                                )
                                .scaleY(
                                  begin: 0.5,
                                  end: 1.5,
                                  duration: (300 + (index * 100)).ms,
                                  curve: Curves.easeInOut,
                                ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Listening: $_voiceText...',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: AppColors.secondary,
                            fontStyle: FontStyle.italic,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 12.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6.h,
            backgroundColor: textColor.withOpacity(0.05),
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter(BuildContext context, TasksProvider provider) {
    final categories = ['All', 'Study', 'Money', 'Personal', 'Govt'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CATEGORIES',
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textTertiaryLight,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 36.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = provider.selectedCategoryFilter == cat;
              return GestureDetector(
                onTap: () => provider.setCategoryFilter(cat),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Theme.of(context).dividerColor,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    cat,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return TabBar(
      controller: _tabController,
      indicatorWeight: 3,
      indicatorColor: AppColors.secondary,
      indicatorSize: TabBarIndicatorSize.label,
      labelColor: Theme.of(context).colorScheme.primary,
      unselectedLabelColor: AppColors.textTertiaryLight,
      labelStyle: GoogleFonts.outfit(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.outfit(
        fontSize: 15.sp,
        fontWeight: FontWeight.w400,
      ),
      tabs: const [
        Tab(text: 'Today'),
        Tab(text: 'Tomorrow'),
        Tab(text: 'Week'),
      ],
    );
  }

  Widget _buildTaskListView(
    BuildContext context,
    List<Todo> tasks,
    TasksProvider provider,
  ) {
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          'No tasks available',
          style: GoogleFonts.inter(color: AppColors.textSecondaryLight),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      itemCount: tasks.length,
      itemBuilder: (context, index) =>
          _buildTaskCard(context, tasks[index], provider)
              .animate()
              .fadeIn(delay: (index * 50).ms, duration: 300.ms)
              .slideY(begin: 0.05, end: 0),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    Todo task,
    TasksProvider provider,
  ) {
    final cardColor = Theme.of(context).cardTheme.color;
    final textColor = Theme.of(context).colorScheme.primary;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Checkbox(
            value: task.completed,
            onChanged: (_) => provider.toggleTaskStatus(task.id),
            activeColor: AppColors.success,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: task.completed ? Colors.grey : textColor,
                          decoration: task.completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    if (task.isRecurring)
                      Icon(
                        Icons.cached_rounded,
                        size: 14.sp,
                        color: AppColors.secondary,
                      ),
                    if (task.shouldNotify)
                      Padding(
                        padding: EdgeInsets.only(left: 4.w),
                        child: Icon(
                          Icons.notifications_active_rounded,
                          size: 14.sp,
                          color: AppColors.secondary,
                        ),
                      ),
                  ],
                ),
                Text(
                  '${task.category} • ${DateFormat('HH:mm').format(task.dueDate)}',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: AppColors.textSecondaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.timer_outlined,
              size: 20.sp,
              color: AppColors.secondary,
            ),
            onPressed: () => _showPomodoroDialog(context, task, provider),
          ),
        ],
      ),
    );
  }

  void _showPomodoroDialog(
    BuildContext context,
    Todo task,
    TasksProvider provider,
  ) {
    int secondsRemaining = 1500; // 25 minutes
    Timer? timer;
    bool isRunning = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          void startTimer() {
            timer = Timer.periodic(const Duration(seconds: 1), (t) {
              if (secondsRemaining > 0) {
                setState(() => secondsRemaining--);
              } else {
                t.cancel();
                provider.incrementPomodoro(task.id);
                Navigator.pop(context);
              }
            });
            setState(() => isRunning = true);
          }

          void pauseTimer() {
            timer?.cancel();
            setState(() => isRunning = false);
          }

          String formatTime(int seconds) {
            int mins = seconds ~/ 60;
            int secs = seconds % 60;
            return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
          }

          return AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.r),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'WORK MODE',
                  style: GoogleFonts.outfit(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  task.title,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),
                Text(
                  formatTime(secondsRemaining),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 48.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 32.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        isRunning
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_filled_rounded,
                        size: 64.sp,
                        color: AppColors.primary,
                      ),
                      onPressed: isRunning ? pauseTimer : startTimer,
                    ),
                    SizedBox(width: 20.w),
                    IconButton(
                      icon: Icon(
                        Icons.stop_circle_outlined,
                        size: 48.sp,
                        color: AppColors.error,
                      ),
                      onPressed: () {
                        timer?.cancel();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddTaskBottomSheet(BuildContext context, TasksProvider provider) {
    final titleController = TextEditingController();
    String selectedCategory = 'Study';
    bool isRecurring = false;
    bool shouldNotify = false;
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Create New Objective',
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
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedDate),
                    );
                    if (time != null) {
                      setModalState(() {
                        selectedDate = DateTime(
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
                        DateFormat('MMM dd, HH:mm').format(selectedDate),
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
                controller: titleController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'What needs to be done?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: ['Study', 'Money', 'Personal', 'Govt']
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setModalState(() => selectedCategory = v!),
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Column(
                    children: [
                      Text(
                        'Notify Me',
                        style: GoogleFonts.inter(fontSize: 10.sp),
                      ),
                      Switch(
                        value: shouldNotify,
                        onChanged: (v) => setModalState(() => shouldNotify = v),
                        activeThumbColor: AppColors.secondary,
                      ),
                    ],
                  ),
                  SizedBox(width: 16.w),
                  Column(
                    children: [
                      Text(
                        'Recurring',
                        style: GoogleFonts.inter(fontSize: 10.sp),
                      ),
                      Switch(
                        value: isRecurring,
                        onChanged: (v) => setModalState(() => isRecurring = v),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      provider.addTask(
                        Todo(
                          id: const Uuid().v4(),
                          title: titleController.text,
                          priority: 'high',
                          dueDate: selectedDate,
                          category: selectedCategory,
                          createdAt: DateTime.now(),
                          isRecurring: isRecurring,
                          shouldNotify: shouldNotify,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add Objective'),
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
