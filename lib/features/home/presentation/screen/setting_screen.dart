import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:raminups/components/AppText/appText.dart';
import 'package:raminups/components/Ios_effect/iosTapEffect.dart';
import 'package:raminups/core/utils/app_colour.dart';
import 'package:raminups/features/home/presentation/widgets/deletedAccount.dart';

import '../widgets/logout_widgets.dart';
import '../widgets/outlinebutton.dart';
import '../widgets/password_change.dart';
import '../widgets/edit_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dashboard_providers.dart';

// ─────────────────────────────────────────────
//  THEME TOKENS
// ─────────────────────────────────────────────
class _T {
  static const bg = Color(0xFFF5F6FA);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE4E7ED);
  static const p1 = Color(0xFF111827);
  static const p2 = Color(0xFF6B7280);
  static const p3 = Color(0xFF9CA3AF);
  static const blue = Color(0xFF2563EB);
  static const blueBg = Color(0xFFEFF6FF);
  static const green = Color(0xFF16A34A);
  static const greenBg = Color(0xFFDCFCE7);
  static const amber = Color(0xFFD97706);
  static const amberBg = Color(0xFFFEF3C7);
  static const red = Color(0xFFDC2626);
  static const redBg = Color(0xFFFEF2F2);
  static const purple = Color(0xFF7C3AED);
  static const purpleBg = Color(0xFFF5F3FF);
}

class GuardrailsScreen extends StatelessWidget {
  const GuardrailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row 1: Profile + Broker Connections ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ProfileCard(),
                const SizedBox(width: 14),
                const Expanded(child: _BrokerConnections()),
              ],
            ),
            const SizedBox(height: 14),

            // ── Row 2: Subscription + Active Restrictions + Discipline ──
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 220, child: _SubscriptionCard()),
                  const SizedBox(width: 14),
                  const Expanded(child: _ActiveRestrictions()),
                  const SizedBox(width: 14),
                  const Expanded(child: _AccountSettings()),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Row 3: Account Settings + System Info ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(width: 14),
                const Expanded(child: _SystemInfo()),
              ],
            ),
            const SizedBox(height: 14),

            // ── Danger Zone ──
            const _DangerZone(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PROFILE CARD
// ─────────────────────────────────────────────
class _ProfileCard extends ConsumerWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return _Card(
      width: 220,
      child: userProfileAsync.when(
        data: (user) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IosTapEffect(
                  onTap: (){
                    showDialog(
                      context: context,
                      builder: (context) => const EditProfileDialog(),
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: user.avatar != null
                            ? NetworkImage(user.avatar!)
                            : const NetworkImage(
                                "https://static.vecteezy.com/system/resources/thumbnails/005/346/410/small/close-up-portrait-of-smiling-handsome-young-caucasian-man-face-looking-at-camera-on-isolated-light-gray-studio-background-photo.jpg",
                              ),
                      ),
                       Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, color: Colors.white, size: 16),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: _T.p1,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: const TextStyle(color: _T.p2, fontSize: 10.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      _Pill((user.subscription ?? 'STARTER').toUpperCase(), _T.amber, _T.amberBg),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DottedLine(),
            const SizedBox(height: 14),
            _InfoRow('Member Since', user.createdAt.toLocal().toString().split(' ')[0]),
            const SizedBox(height: 8),
            _InfoRow('Role', 'Trader'),
            const SizedBox(height: 8),
            _InfoRow('Status', 'Active'),
          ],
        ),
        loading: () => const _ProfileCardShimmer(),
        error: (err, stack) => SizedBox(
          height: 150,
          child: Center(child: Text('Error loading profile: $err')),
        ),
      ),
    );
  }
}

class _ProfileCardShimmer extends StatelessWidget {
  const _ProfileCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 100, height: 14, color: Colors.grey[200]),
                  const SizedBox(height: 6),
                  Container(width: 140, height: 10, color: Colors.grey[200]),
                  const SizedBox(height: 8),
                  Container(
                    width: 60,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        DottedLine(dashColor: Colors.grey.shade200),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(width: 80, height: 11, color: Colors.grey[200]),
            Container(width: 60, height: 11, color: Colors.grey[200]),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(width: 40, height: 11, color: Colors.grey[200]),
            Container(width: 50, height: 11, color: Colors.grey[200]),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(width: 40, height: 11, color: Colors.grey[200]),
            Container(width: 40, height: 11, color: Colors.grey[200]),
          ],
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      AppText(
        label,
        color: AppColors.textDark,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
      AppText(
        value,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

// ─────────────────────────────────────────────
//  BROKER CONNECTIONS
// ─────────────────────────────────────────────
class _BrokerConnections extends StatelessWidget {
  const _BrokerConnections();

  static const _items = [
    ('Tradovate', 'Futures Execution', true),
    ('Interactive Brokers', 'Global Multi-Asset', true),
    ('TradingView', 'Chart Integration', false),
  ];

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Broker Connections',
                style: TextStyle(
                  color: _T.p1,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Manage Connections',
                  style: TextStyle(color: _T.blue, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._items.map((e) => _BrokerRow(e.$1, e.$2, e.$3)),
        ],
      ),
    );
  }
}

class _BrokerRow extends StatelessWidget {
  final String name, sub;
  final bool connected;

  const _BrokerRow(this.name, this.sub, this.connected);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.textWhite,
          boxShadow: [
            BoxShadow(
              color: AppColors.black_border.withValues(alpha: 0.04), // Ultra-soft black
              blurRadius: 12,                                      // Smooth spread
              offset: const Offset(0, 4),                          // Moves shadow slightly downward
            ),
          ],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: _T.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.account_balance,
                color: _T.blue,
                size: 15,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: _T.p1,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(sub, style: const TextStyle(color: _T.p2, fontSize: 10)),
                ],
              ),
            ),
            _Pill(
              connected ? '● CONNECTED' : '● DISCONNECTED',
              connected ? _T.green : _T.p3,
              connected ? _T.greenBg : const Color(0xFFF3F4F6),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SUBSCRIPTION CARD
// ─────────────────────────────────────────────
class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SUBSCRIPTION',
            style: TextStyle(
              color: AppColors.back_icon,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.0,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Premium Plan',
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      AppText(
                        '\$29.00 /',
                        style: TextStyle(color: AppColors.green, fontSize: 10.5,fontWeight: FontWeight.bold),
                      ),
                      AppText(
                        ' monthly',
                        style: TextStyle(color: AppColors.black, fontSize: 12,fontWeight: FontWeight.bold),
                      ),
                    ],
                  )

                ],
              ),
             const Icon(Iconsax.crown_1_copy,color: AppColors.yellow,size: 26,),
            ],
          ),
          const SizedBox(height: 4),
          const AppText(
            'Days left',
            color: AppColors.textDark,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(height: 12),
          const Divider(color: _T.border, height: 1),
          const SizedBox(height: 10),
          _InfoRow('Started', 'Aug 01, 2024'),
          const SizedBox(height: 5),
          _InfoRow('Expires', 'July 01, 2026'),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlineBtn('UPGRADE', _T.blue, onTap: () {}),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: OutlineBtn('CANCEL', _T.red, onTap: () {}),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ACTIVE RESTRICTIONS
// ─────────────────────────────────────────────
class _ActiveRestrictions extends StatelessWidget {
  const _ActiveRestrictions();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active Restrictions',
                style: TextStyle(
                  color: _T.p1,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              _Pill('STATUS: ACTIVE', AppColors.green, AppColors.green),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _RestrictionItem(
                  'Daily Trade Limit',
                  '5 trades',
                  AppColors.white
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _RestrictionItem(
                  'Max Position Size',
                  '\$10,000',
                    AppColors.white
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _RestrictionItem(
                  'Instruments',
                  'Single/Stocks',
                    AppColors.white
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _RestrictionItem('Risk Level', 'Unknown',  AppColors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _T.amberBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _T.amber.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.destructiveRed, size: 15),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Trade limit reached. Account locked',
                    style: TextStyle(
                      color: AppColors.destructiveRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RestrictionItem extends StatelessWidget {
  final String label, value;
  final Color color;

  const _RestrictionItem(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.2),
            offset: Offset(0, 0),
            blurRadius: 2
          ),

        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.black,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style:  TextStyle(
              color: AppColors.black,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  DISCIPLINE STATS
// ─────────────────────────────────────────────
class _DisciplineStats extends StatelessWidget {
  const _DisciplineStats();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trading Discipline Stats',
            style: TextStyle(
              color: _T.p1,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _StatBox('26', 'TOTAL LOSSES', _T.red)),
              const SizedBox(width: 8),
              Expanded(child: _StatBox('32', 'TOTAL WINS', _T.green)),
              const SizedBox(width: 8),
              Expanded(child: _StatBox('12', 'AVG. WIN %', _T.blue)),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: _T.border, height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Hours Spent From Controlling',
                style: TextStyle(color: _T.p2, fontSize: 11),
              ),
              _Pill('104h', _T.blue, _T.blueBg),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value, label;
  final Color color;

  const _StatBox(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _T.p2,
              fontSize: 9,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ACCOUNT SETTINGS
// ─────────────────────────────────────────────
class _AccountSettings extends StatelessWidget {
  const _AccountSettings();

  static const _items = [
    (Icons.lock_outline, 'Change Password', false),
    (Icons.security, 'Two-Factor Authentication', true),
    (Icons.devices, 'Device Management', false),
    (Icons.history, 'Login Sessions', false),
  ];

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Account settings',
            style: TextStyle(
              color: AppColors.black,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          ..._items.map(
            (e) => _SettingRow(icon: e.$1, label: e.$2, active: e.$3,
              onTap: (){
              if (e.$2 == 'Change Password') {
                showDialog(
                  context: context,
                  builder: (context) => const PasswordChangeDialog(),
                );
              } else {
                // Handle other row routing modules here
              }
            },),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _SettingRow({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  State<_SettingRow> createState() => _SettingRowState();
}

class _SettingRowState extends State<_SettingRow> {
  bool _hovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        // Resolves spring scale up back to neutral on successful release
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.border.withValues(alpha: 0.4) : Colors.white,
            borderRadius: BorderRadius.circular(7),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: _T.p2, size: 16),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.label,
                  style: const TextStyle(color: _T.p1, fontSize: 12),
                ),
              ),
              if (widget.active) _Pill('ACTIVE', _T.green, _T.greenBg),
              if (!widget.active)
                const Icon(Icons.chevron_right, color: _T.p3, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SYSTEM INFO
// ─────────────────────────────────────────────
class _SystemInfo extends StatelessWidget {
  const _SystemInfo();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Information',
            style: TextStyle(
              color: _T.p1,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SysItem('OS', 'Windows 11 (Premium Workstation)'),
              ),
              const SizedBox(width: 14),
              Expanded(child: _SysItem('Version', 'V12.0-stable')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _SysItem('Last Login', 'Today, 08:22 AM')),
              const SizedBox(width: 14),
              Expanded(
                child: _SysItem('Account Type', 'Professional Trader (Active)'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SysItem extends StatelessWidget {
  final String label, value;

  const _SysItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _T.bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _T.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _T.p3,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: _T.p1,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  DANGER ZONE
// ─────────────────────────────────────────────
class _DangerZone extends StatelessWidget {
  const _DangerZone();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white_bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.white_bg.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.09),
            blurRadius: 2,
            offset: Offset(0, 1)
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: _T.red, size: 16),
              const SizedBox(width: 7),
              const AppText(
                'Danger Zone',
                  color: AppColors.red,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DangerAction(
                  onTap: (){

                  },
                  icon: Icons.block_rounded,
                  title: 'Reset All Restrictions',
                  desc: '''Align all active locks & trade limits. Action can't be undone.''',
                  color: _T.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DangerAction(
                  onTap: (){
                    showDeleteDialog(context);
                  },
                  icon: Icons.delete_forever,
                  title: 'Delete Account',
                  desc: 'Permanently removes profile and all trading history.',
                  color: AppColors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DangerAction(
                  onTap: (){
                    showLogoutDialog(context);
                  },
                  icon: Icons.logout,
                  title: 'Logout',
                  desc: 'Disconnects all sessions and returns to login screen.',
                  color: AppColors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  void showLogoutDialog (BuildContext context){
    showDialog(
      barrierColor: AppColors.textDark.withValues(alpha: 0.4),
      context: context,
      builder: (context) => LogoutDialog(),
    );
  }


  void showDeleteDialog (BuildContext context){
    showDialog(
      barrierColor: AppColors.textDark.withValues(alpha: 0.4),
      context: context,
      builder: (context) => DeletedAccount(),
    );
  }

}

class _DangerAction extends StatefulWidget {
  final IconData icon;
  final String title, desc;
  final Color color;
  final VoidCallback onTap;

  const _DangerAction({
    required this.icon,
    required this.title,
    required this.desc,
    required this.onTap,
    required this.color,
  });

  @override
  State<_DangerAction> createState() => _DangerActionState();
}

class _DangerActionState extends State<_DangerAction> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: IosTapEffect(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _hovered
                ? widget.color.withValues(alpha:0.08)
                : widget.color.withValues(alpha:0.04),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.color.withValues(alpha:_hovered ? 0.4 : 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: widget.color, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: widget.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.desc,
                      style: const TextStyle(
                        color: _T.p2,
                        fontSize: 10.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED WIDGETS
// ─────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  final double? width;

  const _Card({required this.child, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _T.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _T.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color fg, bg;

  const _Pill(this.label, this.fg, this.bg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        //color: AppColors.textDark.withValues(alpha: 0.80),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.black_border.withValues(alpha: 0.28), width: 0.8),
      ),
      child: AppText(
        label,
        color: fg,
        fontSize: 8,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
