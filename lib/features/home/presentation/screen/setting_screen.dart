import 'package:flutter/material.dart';
// ─────────────────────────────────────────────
//  THEME TOKENS
// ─────────────────────────────────────────────
class _T {
  static const bg       = Color(0xFFF5F6FA);
  static const card     = Color(0xFFFFFFFF);
  static const border   = Color(0xFFE4E7ED);
  static const p1       = Color(0xFF111827);
  static const p2       = Color(0xFF6B7280);
  static const p3       = Color(0xFF9CA3AF);
  static const blue     = Color(0xFF2563EB);
  static const blueBg   = Color(0xFFEFF6FF);
  static const green    = Color(0xFF16A34A);
  static const greenBg  = Color(0xFFDCFCE7);
  static const amber    = Color(0xFFD97706);
  static const amberBg  = Color(0xFFFEF3C7);
  static const red      = Color(0xFFDC2626);
  static const redBg    = Color(0xFFFEF2F2);
  static const purple   = Color(0xFF7C3AED);
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
                  const Expanded(child: _DisciplineStats()),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Row 3: Account Settings + System Info ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 220, child: _AccountSettings()),
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
class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: _T.blue.withOpacity(0.15),
                child: const Icon(Icons.person, color: _T.blue, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rosdab Koch',
                        style: TextStyle(
                            color: _T.p1,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                    const SizedBox(height: 2),
                    const Text('rosdab@gmail.com',
                        style: TextStyle(color: _T.p2, fontSize: 10.5)),
                    const SizedBox(height: 6),
                    _Pill('PREMIUM PRO', _T.amber, _T.amberBg),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: _T.border, height: 1),
          const SizedBox(height: 12),
          _InfoRow('Member Since', 'Jan 2024'),
          const SizedBox(height: 6),
          _InfoRow('Role', 'Profiles'),
          const SizedBox(height: 6),
          _InfoRow('IDFK', 'India'),
        ],
      ),
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
      Text(label, style: const TextStyle(color: _T.p2, fontSize: 11)),
      Text(value,
          style: const TextStyle(
              color: _T.p1, fontSize: 11, fontWeight: FontWeight.w600)),
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
              const Text('Broker Connections',
                  style: TextStyle(
                      color: _T.p1,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: const Text('Manage Connections',
                    style: TextStyle(color: _T.blue, fontSize: 11)),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _T.bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _T.border),
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
              child: const Icon(Icons.account_balance, color: _T.blue, size: 15),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          color: _T.p1,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  Text(sub,
                      style: const TextStyle(color: _T.p2, fontSize: 10)),
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
          const Text('SUBSCRIPTION',
              style: TextStyle(
                  color: _T.p3,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Premium Plan',
                      style: TextStyle(
                          color: _T.p1,
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                  SizedBox(height: 2),
                  Text('\$29.00 / monthly',
                      style: TextStyle(color: _T.p2, fontSize: 10.5)),
                ],
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _T.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('21',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('DAYS LEFT',
              style: TextStyle(
                  color: _T.p3, fontSize: 9, letterSpacing: 0.6)),
          const SizedBox(height: 12),
          const Divider(color: _T.border, height: 1),
          const SizedBox(height: 10),
          _InfoRow('Started', 'Aug 01, 2024'),
          const SizedBox(height: 5),
          _InfoRow('Expires', 'July 01, 2026'),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: _OutlineBtn('UPGRADE', _T.blue, onTap: () {}),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: _OutlineBtn('CANCEL', _T.red, onTap: () {}),
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
              const Text('Active Restrictions',
                  style: TextStyle(
                      color: _T.p1,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
              _Pill('STATUS: ACTIVE', _T.amber, _T.amberBg),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _RestrictionItem(
                      'Daily Trade Limit', '5 trades', _T.red)),
              const SizedBox(width: 10),
              Expanded(
                  child: _RestrictionItem(
                      'Max Position Size', '\$10,000', _T.amber)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: _RestrictionItem(
                      'Instruments', 'Single/Stocks', _T.blue)),
              const SizedBox(width: 10),
              Expanded(
                  child: _RestrictionItem('Risk Level', 'Unknown', _T.purple)),
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
                Icon(Icons.warning_amber_rounded,
                    color: _T.amber, size: 15),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Contact is locked until your supervisor admin unlocks your set of limit.',
                    style: TextStyle(color: _T.amber, fontSize: 10.5, height: 1.4),
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
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 9.5, fontWeight: FontWeight.w600,
                  letterSpacing: 0.2)),
          const SizedBox(height: 3),
          Text(value,
              style: const TextStyle(
                  color: _T.p1, fontSize: 12, fontWeight: FontWeight.w700)),
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
          const Text('Trading Discipline Stats',
              style: TextStyle(
                  color: _T.p1, fontWeight: FontWeight.w700, fontSize: 13)),
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
              const Text('Hours Spent From Controlling',
                  style: TextStyle(color: _T.p2, fontSize: 11)),
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
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: _T.p2, fontSize: 9, letterSpacing: 0.4)),
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
          const Text('ACCOUNT SETTINGS',
              style: TextStyle(
                  color: _T.p3,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8)),
          const SizedBox(height: 10),
          ..._items.map(
                (e) => _SettingRow(icon: e.$1, label: e.$2, active: e.$3),
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
  const _SettingRow(
      {required this.icon, required this.label, required this.active});

  @override
  State<_SettingRow> createState() => _SettingRowState();
}

class _SettingRowState extends State<_SettingRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: _hovered ? _T.bg : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          children: [
            Icon(widget.icon, color: _T.p2, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Text(widget.label,
                  style: const TextStyle(color: _T.p1, fontSize: 12)),
            ),
            if (widget.active) _Pill('ACTIVE', _T.green, _T.greenBg),
            if (!widget.active)
              const Icon(Icons.chevron_right, color: _T.p3, size: 16),
          ],
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
          const Text('System Information',
              style: TextStyle(
                  color: _T.p1, fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _SysItem('OS', 'Windows 11 (Premium Workstation)')),
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
                  child:
                  _SysItem('Account Type', 'Professional Trader (Active)')),
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
          Text(label,
              style: const TextStyle(
                  color: _T.p3,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: _T.p1, fontSize: 11.5, fontWeight: FontWeight.w600)),
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
        color: _T.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _T.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: _T.red, size: 16),
              const SizedBox(width: 7),
              const Text('Danger Zone',
                  style: TextStyle(
                      color: _T.red,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DangerAction(
                  icon: Icons.block,
                  title: 'Reset All Restrictions',
                  desc: 'Align all active locks and trade limits. Action cannot be undone.',
                  color: _T.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DangerAction(
                  icon: Icons.delete_outline,
                  title: 'Delete Account',
                  desc: 'Permanently removes profile and all trading history.',
                  color: _T.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DangerAction(
                  icon: Icons.logout,
                  title: 'Logout',
                  desc: 'Disconnects all sessions and returns to login screen.',
                  color: _T.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DangerAction extends StatefulWidget {
  final IconData icon;
  final String title, desc;
  final Color color;
  const _DangerAction(
      {required this.icon,
        required this.title,
        required this.desc,
        required this.color});

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
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _hovered
              ? widget.color.withOpacity(0.08)
              : widget.color.withOpacity(0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: widget.color.withOpacity(_hovered ? 0.4 : 0.2)),
        ),
        child: Row(
          children: [
            Icon(widget.icon, color: widget.color, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title,
                      style: TextStyle(
                          color: widget.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(widget.desc,
                      style:
                      const TextStyle(color: _T.p2, fontSize: 10.5, height: 1.4)),
                ],
              ),
            ),
          ],
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
              offset: const Offset(0, 1)),
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
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.28), width: 0.8),
      ),
      child: Text(label,
          style: TextStyle(
              color: fg,
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3)),
    );
  }
}

class _OutlineBtn extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _OutlineBtn(this.label, this.color, {required this.onTap});

  @override
  State<_OutlineBtn> createState() => _OutlineBtnState();
}

class _OutlineBtnState extends State<_OutlineBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 110),
          height: 32,
          decoration: BoxDecoration(
            color: _hovered
                ? widget.color.withOpacity(0.08)
                : widget.color.withOpacity(0.04),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
                color: widget.color.withOpacity(_hovered ? 0.6 : 0.35)),
          ),
          alignment: Alignment.center,
          child: Text(widget.label,
              style: TextStyle(
                  color: widget.color,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8)),
        ),
      ),
    );
  }
}
