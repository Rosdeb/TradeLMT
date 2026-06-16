import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:raminups/components/AppText/appText.dart';
import 'package:raminups/components/Ios_effect/iosTapEffect.dart';
import 'package:raminups/core/utils/app_colour.dart';
import '../providers/home_providers.dart';
import '../widgets/logout_widgets.dart';

// ─── static nav data ─────────────────────────────────────────────────────────
const _kDests = [
  _NavDest(icon: Iconsax.element_4_copy,   selected: Iconsax.element_4,   label: 'Dashboard'),
  _NavDest(icon: Iconsax.link, selected: Iconsax.link_copy, label: 'Connect'),
  _NavDest(icon: Iconsax.setting_2,       selected: Iconsax.setting_2_copy,       label: 'Setting'),
  _NavDest(icon: Iconsax.crown,       selected: Iconsax.star,       label: 'Subscription'),
];

class AppSidebar extends ConsumerWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(activeTabProvider);

    return SizedBox(
      width: 150,
      child: ColoredBox(
        color: AppColors.white_bg,
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Logo
            // Nav items
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: _kDests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 2),
                itemBuilder: (_, i) => _NavTile(
                  dest: _kDests[i],
                  isActive: selected == i,
                  onTap: () => ref.read(activeTabProvider.notifier).state = i,
                ),
              ),
            ),
            
            const Spacer(),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: IosTapEffect(
                onTap: (){
                  showLogoutDialog(context);
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.logout,color: Colors.black,size: 16,),
                    const SizedBox(width: 8),
                    AppText("Logout",fontSize: 14,fontWeight: FontWeight.w500,color: Colors.black,),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
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
}

// ─── single tile ─────────────────────────────────────────────────────────────
class _NavTile extends StatefulWidget {
  const _NavTile({
    required this.dest,
    required this.isActive,
    required this.onTap,
  });

  final _NavDest dest;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final active  = widget.isActive;
    final hovered = _hovered && !active;

    return RepaintBoundary(
      child: Tooltip(
        message: widget.dest.label,
        preferBelow: false,
        waitDuration: const Duration(milliseconds: 600),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit:  (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onTap: widget.onTap,
            onTapDown:   (_) => setState(() => _pressed = true),
            onTapUp:     (_) => setState(() => _pressed = false),
            onTapCancel: ()  => setState(() => _pressed = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
              transform: _pressed
                  ? (Matrix4.identity()..scale(0.70, 0.65, 1.0))
                  : Matrix4.identity(),
              transformAlignment: Alignment.center,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.activeGlow
                    : hovered
                    ? const Color(0x0FFFFFFF)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 160),
                    child: Icon(
                      active ? widget.dest.selected : widget.dest.icon,
                      key: ValueKey(active),
                      color: active
                          ? AppColors.activeGreen
                          : hovered
                          ? const Color(0xf000000)
                          : AppColors.mutedIcon,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.dest.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      color: active
                          ? AppColors.activeGreen
                          : hovered
                          ? const Color(0xFF040404)
                          : AppColors.mutedIcon,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── data class ──────────────────────────────────────────────────────────────
class _NavDest {
  final IconData icon;
  final IconData selected;
  final String label;
  const _NavDest({required this.icon, required this.selected, required this.label});
}