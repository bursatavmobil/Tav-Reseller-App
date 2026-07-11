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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Form(
        key: _infoFormKey,
        child: Column(
          children: [
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
                  _buildInputField(
                    icon: Icons.person_outline_rounded,
                    title: 'Nama Lengkap',
                    controller: widget.nameController,
                    enabled: widget.isEditing,
                    validator: (v) => v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    icon: Icons.phone_android_rounded,
                    title: 'Nomor WhatsApp',
                    controller: widget.waController,
                    enabled: widget.isEditing,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v == null || v.isEmpty ? 'Nomor WhatsApp tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildStaticField(Icons.email_outlined, 'Email Sistem', widget.email),
                  if (widget.isEditing) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                            onPressed: widget.onToggleEdit,
                            child: const Text('Batal', style: TextStyle(color: Color(0xFF666666))),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE52525),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              if (_infoFormKey.currentState!.validate()) {
                                widget.onSaveInfo();
                              }
                            },
                            child: widget.provider.isSaving
                                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Simpan', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required IconData icon,
    required String title,
    required TextEditingController controller,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
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
            fillColor: const Color(0xFFF9F9F9),
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF666666)),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEAEAEA))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCCCCCC))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE52525), width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE52525))),
          ),
        ),
      ],
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