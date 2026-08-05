import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/features/dashboard/providers/negosiasi_provider.dart';

class UpsertCustomerDialog extends StatefulWidget {
  final dynamic customer;
  final VoidCallback onSuccess;

  const UpsertCustomerDialog({
    super.key,
    this.customer,
    required this.onSuccess,
  });

  static void show(
    BuildContext context, {
    dynamic customer,
    required VoidCallback onSuccess,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          UpsertCustomerDialog(customer: customer, onSuccess: onSuccess),
    );
  }

  @override
  State<UpsertCustomerDialog> createState() => _UpsertCustomerDialogState();
}

class _UpsertCustomerDialogState extends State<UpsertCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  File? _selectedFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.customer;
    _nameController = TextEditingController(
      text: c != null ? c['first_name'] : '',
    );
    _phoneController = TextEditingController(text: c != null ? c['phone'] : '');
    _emailController = TextEditingController(text: c != null ? c['email'] : '');
    _addressController = TextEditingController(
      text: (c != null && c['user_address_default'] != null)
          ? c['user_address_default']['address']
          : '',
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _selectedFile = File(result.files.single.path!));
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final service = context.read<NegotiationProvider>().negotiationService;
      final res = await service.saveCustomer(
        id: widget.customer != null ? widget.customer['id'].toString() : null,
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        fotoKtp: _selectedFile,
      );

      if (res.data['status'] == true) {
        widget.onSuccess();
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(
        fontFamily: 'Montserrat',
        color: Color(0xFF8E8E93),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: const TextStyle(
        fontFamily: 'Montserrat',
        color: Color(0xFFD4AF37),
        fontWeight: FontWeight.w700,
      ),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF8E8E93), size: 18),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFEFEFEF), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFD4AF37),
          width: 1.2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE52525), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE52525), width: 1.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      widget.customer != null
                          ? Icons.edit_note_rounded
                          : Icons.person_add_alt_1_rounded,
                      color: const Color(0xFFD4AF37),
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.customer != null
                          ? "Ubah Data Customer"
                          : "Tambah Customer Baru",
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: Color(0xFFEFEFEF), height: 1),
                ),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                  ),
                  decoration: _buildInputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icons.person_outline_rounded,
                  ),
                  validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                  ),
                  decoration: _buildInputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icons.phone_iphone_rounded,
                  ),
                  validator: (v) =>
                      v!.isEmpty ? 'Nomor telepon wajib diisi' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                  ),
                  decoration: _buildInputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icons.mail_outline_rounded,
                  ),
                  validator: (v) => v!.isEmpty ? 'Email wajib diisi' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _addressController,
                  maxLines: 3,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                  ),
                  decoration: _buildInputDecoration(
                    labelText: 'Full Address',
                    prefixIcon: Icons.location_on_outlined,
                  ),
                  validator: (v) =>
                      v!.isEmpty ? 'Alamat lengkap wajib diisi' : null,
                ),
                const SizedBox(height: 20),
                const Text(
                  "DOKUMEN IDENTITAS",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF8E8E93),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickFile,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _selectedFile != null
                            ? const Color(0xFFD4AF37)
                            : const Color(0xFFEFEFEF),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _selectedFile != null
                              ? Icons.image_rounded
                              : Icons.cloud_upload_rounded,
                          color: _selectedFile != null
                              ? const Color(0xFFD4AF37)
                              : const Color(0xFF8E8E93),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedFile != null
                                    ? "Foto KTP Dipilih"
                                    : "Upload Foto KTP",
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _selectedFile != null
                                      ? const Color(0xFFD4AF37)
                                      : const Color(0xFF1A1A1A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _selectedFile != null
                                    ? _selectedFile!.path.split('/').last
                                    : (widget.customer != null
                                          ? "KTP Tersimpan (Ketuk untuk ganti)"
                                          : "Format file gambar (JPG/PNG)"),
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 10,
                                  color: Color(0xFF8E8E93),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_selectedFile == null)
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Color(0xFFEFEFEF),
                            size: 12,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFEFEFEF)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "BATAL",
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Color(0xFF8E8E93),
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE52525),
                        disabledBackgroundColor: const Color(0xFFF1F3F5),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "SIMPAN DATA",
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}