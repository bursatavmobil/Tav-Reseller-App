import 'package:flutter/material.dart';
import 'package:reseller_app_tav/features/dashboard/providers/profile_provider.dart';

class InfoKontakTabView extends StatefulWidget {
  final String email;
  final Map<String, dynamic>? agenData;
  final ProfileProvider provider;
  final TextEditingController nameController;
  final TextEditingController waController;
  final bool isEditing;
  final VoidCallback onToggleEdit;
  final Future<void> Function() onSaveInfo;

  const InfoKontakTabView({
    super.key,
    required this.email,
    required this.agenData,
    required this.provider,
    required this.nameController,
    required this.waController,
    required this.isEditing,
    required this.onToggleEdit,
    required this.onSaveInfo,
  });

  @override
  State<InfoKontakTabView> createState() => _InfoKontakTabViewState();
}

class _InfoKontakTabViewState extends State<InfoKontakTabView> {
  final _infoFormKey = GlobalKey<FormState>();
  OverlayEntry? _overlayEntry;

  void _showBouncingTooltip(BuildContext context, Offset globalPosition) {
    _overlayEntry?.remove();
    _overlayEntry = null;

    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => _BouncingTooltipWidget(
        position: globalPosition,
        onDismiss: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
        },
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Form(
        key: _infoFormKey,
        child: Column(
          children: [
            // PETUNJUK DOUBLE TAP EDIT
            if (!widget.isEditing)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE52525).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE52525).withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.touch_app_outlined, size: 16, color: Color(0xFFE52525)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Petunjuk: Ketuk field 2x untuk mulai mengedit data.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE52525),
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEAEAEA), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Informasi Kontak',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
                      ),
                      IconButton(
                        onPressed: widget.provider.isSaving ? null : widget.onToggleEdit,
                        icon: Icon(
                          widget.isEditing ? Icons.close_rounded : Icons.edit_note_rounded,
                          color: widget.isEditing ? const Color(0xFFE52525) : const Color(0xFF666666),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFFF0F0F0)),
                  const SizedBox(height: 8),

                  _buildEditableField(
                    context: context,
                    icon: Icons.person_outline_rounded,
                    title: 'Nama Lengkap',
                    controller: widget.nameController,
                    enabled: widget.isEditing,
                    validator: (v) => v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildEditableField(
                    context: context,
                    icon: Icons.phone_android_rounded,
                    title: 'Nomor WhatsApp',
                    controller: widget.waController,
                    enabled: widget.isEditing,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v == null || v.isEmpty ? 'Nomor WhatsApp tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildStaticField(Icons.email_outlined, 'Email Sistem', widget.email),
                ],
              ),
            ),
            if (widget.agenData != null && !widget.isEditing) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEAEAEA), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rekening Pencairan Saldo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Montserrat')),
                    const Divider(color: Color(0xFFF0F0F0)),
                    _buildStaticField(Icons.account_balance_rounded, 'Nama Bank', widget.agenData!['bank'] ?? '-'),
                    const SizedBox(height: 14),
                    _buildStaticField(Icons.person_pin_rounded, 'Nama Pemilik', widget.agenData!['nama_di_rekening'] ?? '-'),
                    const SizedBox(height: 14),
                    _buildStaticField(Icons.credit_card_rounded, 'Nomor Rekening', widget.agenData!['no_rekening'] ?? '-'),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 100), // Spacing agar bottom bar tidak menutupi form
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required BuildContext context,
    required IconData icon,
    required String title,
    required TextEditingController controller,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return GestureDetector(
      onTapUp: (details) {
        if (!enabled) {
          _showBouncingTooltip(context, details.globalPosition);
        }
      },
      onDoubleTap: () {
        if (!enabled) widget.onToggleEdit();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[500], fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(fontSize: 13, color: Color(0xFF222222), fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              isDense: true,
              filled: !enabled,
              fillColor: enabled ? Colors.white : const Color(0xFFF9F9F9),
              prefixIcon: Icon(icon, size: 18, color: const Color(0xFF666666)),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEAEAEA))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCCCCCC))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE52525), width: 1.5)),
              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE52525))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticField(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: const Color(0xFF666666)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[500], fontFamily: 'Montserrat')),
              const SizedBox(height: 3),
              Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF222222), fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

// === KOMPONEN TOOLTIP BOUNCING ANIMATION ===
class _BouncingTooltipWidget extends StatefulWidget {
  final Offset position;
  final VoidCallback onDismiss;

  const _BouncingTooltipWidget({required this.position, required this.onDismiss});

  @override
  State<_BouncingTooltipWidget> createState() => _BouncingTooltipWidgetState();
}

class _BouncingTooltipWidgetState extends State<_BouncingTooltipWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx - 100,
      top: widget.position.dy - 55,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.touch_app, color: Colors.amber, size: 14),
                SizedBox(width: 6),
                Text(
                  'Ketuk 2x untuk edit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}