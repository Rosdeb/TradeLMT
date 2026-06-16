import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../components/AppText/appText.dart';
import '../../../../core/utils/app_colour.dart';
import '../providers/dashboard_providers.dart';
import '../screen/dashboard_screen.dart';
import 'iconsButton.dart'; // Add to pubspec.yaml for formatting the chosen date

class ManualProtectionLockPanel extends StatefulWidget {
  const ManualProtectionLockPanel({Key? key}) : super(key: key);

  @override
  State<ManualProtectionLockPanel> createState() => _ManualProtectionLockPanelState();
}

class _ManualProtectionLockPanelState extends State<ManualProtectionLockPanel> {
  // State variables for manual tracking
  DateTime selectedLockDate = DateTime(2026, 6, 12); // Defaults to client's example date
  String selectedDuration = '24 Hours'; // Default active duration configuration
  bool isLockEngaged = false;

  final List<String> lockoutDurations = ['8 Hours', '12 Hours', '24 Hours'];

  // Function to let the user choose a specific custom day to lock out
  Future<void> _pickLockDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedLockDate,
      firstDate: DateTime(2026),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF2ECC71),
              onPrimary: Colors.black,
              surface:Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedLockDate) {
      setState(() {
        selectedLockDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color mintGreen = Color(0xFF2ECC71);
    const Color alertRed = Color(0xFFE74C3C);
    const Color darkCardBg = Color(0xFF161B22);
    const Color borderStroke = Color(0xFF262C36);

    return Expanded(
      child: Container(
        constraints: const BoxConstraints(minHeight: 200), // Height padded slightly to fit target controls safely
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white_bg, // Keeps your pre-configured structural theme token
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Panel Header
            Row(
              children: [
                const Icon(Icons.shield, color: mintGreen),
                const SizedBox(width: 10),
                AppText(
                  "Manual Protection Lock",
                  fontSize: 18,
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
                const Spacer(),
                if (isLockEngaged)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: alertRed.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'LOCKED',
                      style: TextStyle(color: alertRed, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            AppText(
              "Voluntarily restrict account access if you don't feel like trading or want to step away.",
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: Colors.grey,
            ),
            const SizedBox(height: 14),

            // 1. Date Picker Control Component
            Row(
              children: [
                InkWell(
                  onTap: () => _pickLockDate(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 120,
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6E6E9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderStroke),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            DateFormat('dd MMM yyyy').format(selectedLockDate),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    width: double.infinity,
                    child: Consumer(
                      builder: (context, ref, child) {
                        final selectedDuration = ref.watch(weeklylockDurationProvider);
                        // Complete duration list matching client rules (1, 2, 4, 8, 12, 24)
                        final durations = [1, 2, 4, 8, 12, 24];

                        return ListView.separated(
                          physics: ScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: durations.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final duration = durations[index];
                            final isSelected = selectedDuration == duration;

                            return InkWell(
                                onTap: () {
                                  ref.read(weeklylockDurationProvider.notifier).state = duration;
                                },
                                borderRadius: BorderRadius.circular(50),
                                child: Container(
                                  width: 40,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white : const Color(0xFFF5F6F8),
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF2ECC71) : const Color(0xFFE5E7EB),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      if (isSelected)
                                        BoxShadow(
                                          color: const Color(0xFF2ECC71).withValues(alpha: 0.15),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                    ],
                                  ),
                                  child: Center(
                                    child: AppText(
                                      "$duration H",
                                      color: isSelected
                                          ? const Color(0xFF2ECC71)
                                          : const Color(0xFF6B7280),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),



            const SizedBox(height: 14),

            // 3. Action Execution Triggers
            Row(
              children: [

                const TradeLimitCounter1(),
                const SizedBox(width: 12),
                // Weekly Block Action Button
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      selectedDuration = 'Weekly';
                      isLockEngaged = true;
                    });
                  },
                  icon: const Icon(Icons.lock_clock, size: 16, color: Colors.white),
                  label: AppText("Weekly Lock", color: Colors.white, fontSize: 12),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: alertRed,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 12),

                // Confirm/Engage Day Lock Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        isLockEngaged = !isLockEngaged;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: isLockEngaged ? alertRed : mintGreen),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: AppText(
                      isLockEngaged ? "Break Active Lock" : "Engage Manual Lockout",
                      color: isLockEngaged ? alertRed : mintGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TradeLimitCounter1 extends ConsumerWidget {
  const TradeLimitCounter1({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tradeLimit = ref.watch(weeklytradeLimitCountProvider);

    return Row(
      children: [
        CircleIconButton(
          icon: Icons.remove,
          onPressed: () {
            if (tradeLimit > 0) {
              ref.read(weeklytradeLimitCountProvider.notifier).state--;
            }
          },
        ),
        const SizedBox(width: 10),
        AppText(tradeLimit.toString(),color: AppColors.black,),
        const SizedBox(width: 10),
        CircleIconButton(
          icon: Icons.add,
          onPressed: () {
            ref.read(weeklytradeLimitCountProvider.notifier).state++;
          },
        ),
      ],
    );
  }
}