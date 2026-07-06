import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/broker_connection.dart';
import '../providers/connection_providers.dart';

// ─────────────────────────────────────────────
//  THEME TOKENS  (light / white)
// ─────────────────────────────────────────────

class _T {
  // backgrounds
  static const pageBg = Color(0xFFF5F6FA); // very soft off-white
  static const cardBg = Color(0xFFFFFFFF);
  static const footerBg = Color(0xFFFFFFFF);

  // borders
  static const border = Color(0xFFE4E7ED);
  static const borderHover = Color(0xFFBDC3CF);

  // text
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFF9CA3AF);

  // status
  static const green = Color(0xFF16A34A);
  static const greenBg = Color(0xFFDCFCE7);
  static const gray = Color(0xFF6B7280);
  static const grayBg = Color(0xFFF3F4F6);

  // accents
  static const blue = Color(0xFF2563EB);
  static const teal = Color(0xFF0D9488);

  // button
  static const btnBorder = Color(0xFFD1D5DB);
  static const btnBg = Color(0xFFF9FAFB);
  static const btnBgHover = Color(0xFFEFF1F5);
  static const manageBorder = Color(0xFF2563EB);
  static const manageBg = Color(0xFFEFF6FF);
  static const manageText = Color(0xFF1D4ED8);
}

// ─────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────

class ConnectionScreen extends ConsumerStatefulWidget {
  const ConnectionScreen({super.key});

  @override
  ConsumerState<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends ConsumerState<ConnectionScreen> {
  StreamSubscription<String>? _subscription;

  @override
  void initState() {
    super.initState();
    developer.log('SSE connection initialized: event on', name: 'ConnectionScreen');
    _subscription = ref.read(brokerSseServiceProvider).connect().listen((event) {
      developer.log('SSE event received: $event', name: 'ConnectionScreen');
      if (event.contains('broker_connections_updated')) {
        ref.invalidate(brokerConnectionsProvider);
      }
    });
  }

  @override
  void dispose() {
    developer.log('SSE connection disposed: event off', name: 'ConnectionScreen');
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectionsAsync = ref.watch(brokerConnectionsProvider);

    return Scaffold(
      backgroundColor: _T.pageBg,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────
            const Text(
              'Broker Gateway',
              style: TextStyle(
                color: _T.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Establish secure, encrypted connections to your primary trading venues.',
              style: TextStyle(color: _T.textSecondary, fontSize: 12.5),
            ),
            const Text(
              'Professional grade API bridges ensure millisecond execution sync.',
              style: TextStyle(color: _T.textSecondary, fontSize: 12.5),
            ),

            const SizedBox(height: 22),

            // ── Broker Grid ─────────────────────────
            Expanded(
              child: connectionsAsync.when(
                data: (connections) {
                  if (connections.isEmpty) {
                    return const Center(
                      child: Text(
                        'No broker connections available.',
                        style: TextStyle(color: _T.textSecondary),
                      ),
                    );
                  }
                  return GridView.builder(
                    itemCount: connections.length,
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 280,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.58,
                    ),
                    itemBuilder: (context, i) => _BrokerCard(broker: connections[i]),
                  );
                },
                loading: () => GridView.builder(
                  itemCount: 8,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 280,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.58,
                  ),
                  itemBuilder: (context, i) => const _BrokerCardShimmer(),
                ),
                error: (error, stack) => Center(
                  child: Text(
                    'Error: $error',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Footer ───────────────────────────────
            const _EncryptionFooter(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  BROKER CARD
// ─────────────────────────────────────────────

class _BrokerCard extends StatefulWidget {
  final BrokerConnection broker;
  const _BrokerCard({required this.broker});

  @override
  State<_BrokerCard> createState() => _BrokerCardState();
}

class _BrokerCardState extends State<_BrokerCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final b = widget.broker;
    final isComingSoon = b.status == 'coming_soon';

    return MouseRegion(
      cursor: isComingSoon
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        decoration: BoxDecoration(
          color: isComingSoon ? const Color(0xFFFAFAFA) : _T.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _hovered && !isComingSoon ? _T.borderHover : _T.border,
            width: 1,
          ),
          boxShadow: _hovered && !isComingSoon
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // top row: icon + status pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // icon box
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isComingSoon
                        ? const Color(0xFFF3F4F6)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isComingSoon ? _T.border : const Color(0xFFF8FAFC),
                    ),
                  ),
                  child: Opacity(
                    opacity: isComingSoon ? 0.45 : 1,
                    child: Image.asset(
                      b.logoAsset,
                      height: 19,
                      width: 19,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                _StatusPill(status: b.status, statusLabel: b.statusLabel),
              ],
            ),

            const SizedBox(height: 8),

            // name
            Text(
              b.displayName,
              style: TextStyle(
                color: isComingSoon ? _T.textMuted : _T.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              b.subtitle,
              style: const TextStyle(color: _T.textSecondary, fontSize: 10.5),
            ),

            const Spacer(),

            if (!isComingSoon) _ActionButton(broker: b),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  STATUS PILL
// ─────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final String status;
  final String statusLabel;
  const _StatusPill({
    required this.status,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isConnected = status == 'connected';
    final isComingSoon = status == 'coming_soon';

    final Color fg = isConnected
        ? _T.green
        : isComingSoon
        ? _T.textMuted
        : _T.gray;

    final Color bg = isConnected
        ? _T.greenBg
        : isComingSoon
        ? const Color(0xFFF3F4F6)
        : _T.grayBg;

    final String label = statusLabel.isNotEmpty
        ? '● $statusLabel'
        : (isConnected
            ? '● CONNECTED'
            : isComingSoon
                ? '● COMING SOON'
                : '● NOT CONNECTED');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.30), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 8,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ACTION BUTTON
// ─────────────────────────────────────────────

class _ActionButton extends ConsumerStatefulWidget {
  final BrokerConnection broker;
  const _ActionButton({required this.broker});

  @override
  ConsumerState<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends ConsumerState<_ActionButton> {
  bool _hovered = false;
  bool _pressed = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isManage = widget.broker.status == 'connected';
    final label = _isLoading
        ? 'CONNECTING...'
        : (widget.broker.actionLabel.isNotEmpty
            ? widget.broker.actionLabel.toUpperCase()
            : (isManage ? 'MANAGE' : 'CONNECT'));

    final Color bg = isManage
        ? (_pressed ? const Color(0xFFDBEAFE) : (_hovered ? _T.manageBg : _T.manageBg))
        : (_pressed ? const Color(0xFFE5E7EB) : (_hovered ? _T.btnBgHover : _T.btnBg));

    final Color border = isManage ? _T.manageBorder : _T.btnBorder;
    final Color text = isManage ? _T.manageText : _T.textSecondary;

    return MouseRegion(
      cursor: _isLoading
          ? SystemMouseCursors.wait
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: _isLoading ? null : (_) => setState(() => _pressed = true),
        onTapUp: _isLoading ? null : (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: _isLoading
            ? null
            : () async {
                setState(() => _isLoading = true);
                try {
                  final repository = ref.read(connectionRepositoryProvider);
                  final url = await repository.connectBroker(widget.broker.id);

                  if (url != null && url.isNotEmpty) {
                    await launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,

                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to retrieve connection URL.')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error connecting: $e')),
                  );
                } finally {
                  if (mounted) {
                    setState(() => _isLoading = false);
                  }
                }
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: double.infinity,
          height: 27,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: border, width: 0.9),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: text,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────
//  ENCRYPTION FOOTER
// ─────────────────────────────────────────────

class _EncryptionFooter extends StatelessWidget {
  const _EncryptionFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      decoration: BoxDecoration(
        color: _T.footerBg,
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
      child: Row(
        children: [
          // shield icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _T.blue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _T.blue.withOpacity(0.2)),
            ),
            child: const Icon(Icons.shield_outlined, color: _T.blue, size: 18),
          ),
          const SizedBox(width: 14),

          // text
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Military-Grade Encryption',
                  style: TextStyle(
                    color: _T.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Your broker credentials never touch our servers. We use localized API proxies and OAuth 2.0 tunneling to ensure only your local terminal can execute trades.',
                  style: TextStyle(
                    color: _T.textSecondary,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          _EncBadge(label: 'AES-256', sublabel: 'Encryption', color: _T.blue),
          const SizedBox(width: 10),
          _EncBadge(label: 'TLS 1.3', sublabel: 'Transport', color: _T.teal),
        ],
      ),
    );
  }
}

class _EncBadge extends StatelessWidget {
  final String label;
  final String sublabel;
  final Color color;

  const _EncBadge({
    required this.label,
    required this.sublabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.22), width: 0.9),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sublabel,
            style: TextStyle(
              color: color.withOpacity(0.65),
              fontSize: 9.5,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SHIMMER LOADING CARD
// ─────────────────────────────────────────────

class _BrokerCardShimmer extends StatefulWidget {
  const _BrokerCardShimmer();

  @override
  State<_BrokerCardShimmer> createState() => _BrokerCardShimmerState();
}

class _BrokerCardShimmerState extends State<_BrokerCardShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double opacity = 0.3 + (_controller.value * 0.4);
        return Container(
          decoration: BoxDecoration(
            color: _T.cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _T.border,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Opacity(
            opacity: opacity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon + Status Pill row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Name placeholder
                Container(
                  width: 100,
                  height: 13,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                // Subtitle placeholder
                Container(
                  width: 140,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                // Button placeholder
                Container(
                  width: double.infinity,
                  height: 27,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

