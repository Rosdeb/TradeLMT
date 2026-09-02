import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../components/AppText/appText.dart';
import '../../../../core/utils/app_colour.dart';
import '../providers/dashboard_providers.dart';
import 'iconsButton.dart';

class ManualProtectionLockPanel extends StatefulWidget {
  const ManualProtectionLockPanel({super.key});

  @override
  State<ManualProtectionLockPanel> createState() =>
      _ManualProtectionLockPanelState();
}

class _ManualProtectionLockPanelState extends State<ManualProtectionLockPanel> {
  DateTime selectedLockDate = DateTime.now();
  bool isLockEngaged = false;

  Future<void> _pickLockDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedLockDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2ECC71),
              onPrimary: Colors.white,
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

    return Expanded(
      child: Container(
        constraints: const BoxConstraints(minHeight: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white_bg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: mintGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.shield_moon,
                    color: mintGreen,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                AppText(
                  "Manual Protection",
                  fontSize: 15,
                  color: AppColors.textDark,
                  fontWeight: FontWeight.bold,
                ),
                const Spacer(),
                if (isLockEngaged)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: alertRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'LOCKED',
                      style: TextStyle(
                        color: alertRed,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            AppText(
              "Voluntarily restrict account access if you don't feel like trading or want to step away.",
              fontWeight: FontWeight.w400,
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 12),

            // Pickers Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        "Lock Date",
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: isLockEngaged
                            ? null
                            : () => _pickLockDate(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 34,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isLockEngaged
                                ? const Color(0xFFF1F5F9)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  DateFormat(
                                    'dd MMM yyyy',
                                  ).format(selectedLockDate),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isLockEngaged
                                        ? Colors.grey.shade500
                                        : Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey.shade600,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      "Weekly Limit",
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(height: 6),
                    TradeLimitCounter1(isLocked: isLockEngaged),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Lockout Duration
            AppText(
              "Lockout Duration",
              fontSize: 12,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 34,
              width: double.infinity,
              child: Consumer(
                builder: (context, ref, child) {
                  final selectedDuration = ref.watch(
                    weeklylockDurationProvider,
                  );
                  final durations = [1, 2, 4, 8, 12, 24];

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: durations.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final duration = durations[index];
                      final isSelected = selectedDuration == duration;

                      return InkWell(
                        onTap: isLockEngaged
                            ? null
                            : () {
                                ref.read(weeklylockDurationProvider.notifier,).state = duration;
                              },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 36,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? mintGreen.withValues(alpha: 0.1)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? mintGreen
                                  : const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: AppText(
                              "$duration H",
                              color: isSelected
                                  ? mintGreen
                                  : const Color(0xFF000000),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isLockEngaged
                        ? null
                        : () {
                            setState(() {
                              isLockEngaged = true;
                            });
                          },
                    icon: const Icon(
                      Icons.lock_clock,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: AppText(
                      "Weekly Lock",
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: alertRed,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: isLockEngaged ? 0 : 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        isLockEngaged = !isLockEngaged;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isLockEngaged ? alertRed : mintGreen,
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: isLockEngaged
                          ? alertRed.withValues(alpha: 0.05)
                          : mintGreen.withValues(alpha: 0.05),
                    ),
                    child: AppText(
                      isLockEngaged ? "Break Lock" : "Engage Lockout",
                      color: isLockEngaged ? alertRed : mintGreen,
                      fontSize: 11,
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
  final bool isLocked;

  const TradeLimitCounter1({super.key, required this.isLocked});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tradeLimit = ref.watch(weeklytradeLimitCountProvider);

    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isLocked ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleIconButton(
            icon: Icons.remove,
            onPressed: isLocked
                ? () {}
                : () {
                    if (tradeLimit > 0) {
                      ref.read(weeklytradeLimitCountProvider.notifier).state--;
                    }
                  },
          ),
          Container(
            width: 34,
            alignment: Alignment.center,
            child: AppText(
              tradeLimit.toString(),
              color: isLocked ? Colors.grey.shade500 : AppColors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          CircleIconButton(
            icon: Icons.add,
            onPressed: isLocked
                ? () {}
                : () {
                    ref.read(weeklytradeLimitCountProvider.notifier).state++;
                  },
          ),
        ],
      ),
    );
  }
}
