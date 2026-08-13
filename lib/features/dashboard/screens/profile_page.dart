import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/core/widget/custom_dropdown_region.dart';
import 'package:reseller_app_tav/core/widget/cutsom_alert_widget.dart';
import 'package:reseller_app_tav/core/widget/kyc_success_dialog.dart';
import 'package:reseller_app_tav/features/auth/providers/auth_provider.dart';
import 'package:reseller_app_tav/features/dashboard/providers/profile_provider.dart';
import 'package:reseller_app_tav/features/dashboard/services/api_config.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/profile/info_contact_view.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/profile/kyc_form_tab_view.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/profile/kyc_image_source.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/profile/profile_header_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isKycEditing = false;
  int? _existingKycId;
  String? _existingFotoKtpUrl;
  String? _existingFotoSelfieUrl;
  String? _existingKKUrl;

  bool _isEditing = false;
  final _kycFormKey = GlobalKey<FormState>();

  // Master Bank State
  List<dynamic> _banks = [];
  dynamic _selectedBank;

  // Controllers Info & Kontak
  late TextEditingController _nameController;
  late TextEditingController _waController;

  // Controllers KYC Form
  final _waDaruratController = TextEditingController();
  final _bankController = TextEditingController();
  final _namaRekeningController = TextEditingController();
  final _noRekeningController = TextEditingController();
  final _noKtpController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final _subDistrictController = TextEditingController();
  final _rtController = TextEditingController();
  final _rwController = TextEditingController();
  final _alamatController = TextEditingController();

  String _jenisKelamin = 'laki-laki';
  File? _fotoKtpFile;
  File? _fotoKtpSelfieFile;
  File? _fotoKK;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _waController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProfileProvider>().loadProfileData().then((_) {
          _initFields();
          _fetchBanksSilent();
        });
      }
    });
  }

  Future<Dio> _getDio() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      ),
    );
  }

  Future<void> _fetchBanksSilent() async {
    try {
      final dio = await _getDio();
      final response = await dio.get('master-bank');
      if (response.data['status'] == true && mounted) {
        setState(() {
          _banks = response.data['data'] ?? [];
          _matchSelectedBank();
        });
      }
    } catch (e) {
      debugPrint('Error fetch master bank background: $e');
    }
  }

  void _matchSelectedBank() {
    if (_bankController.text.isNotEmpty && _banks.isNotEmpty) {
      setState(() {
        _selectedBank = _banks.firstWhere(
          (e) =>
              e['nama_bank'].toString().toUpperCase() ==
              _bankController.text.toUpperCase(),
          orElse: () => null,
        );
      });
    }
  }

  void _initFields() {
    final data = context.read<ProfileProvider>().profileData;
    final authProv = context.read<AuthProvider>();
    if (data != null) {
      _nameController.text = data['name'] ?? authProv.userName ?? '';
      _waController.text =
          data['no_whatsapp'] ?? data['no_wa'] ?? data['phone'] ?? '';

      final agenData = data['agen_data'];
      if (agenData != null) {
        _existingKycId = agenData['id'];
        _noKtpController.text = agenData['nomor_ktp']?.toString() ?? '';
        _jenisKelamin = agenData['jenis_kelamin'] ?? 'laki-laki';
        _tempatLahirController.text = agenData['tempat_lahir'] ?? '';
        _tanggalLahirController.text = agenData['tanggal_lahir'] ?? '';
        _subDistrictController.text =
            agenData['sub_district_id']?.toString() ?? '';
        _rtController.text = agenData['rt']?.toString() ?? '';
        _rwController.text = agenData['rw']?.toString() ?? '';
        _alamatController.text = agenData['alamat'] ?? '';
        _waDaruratController.text = agenData['no_whatsapp_darurat'] ?? '';
        _bankController.text = agenData['bank'] ?? '';
        _namaRekeningController.text = agenData['nama_di_rekening'] ?? '';
        _noRekeningController.text = agenData['no_rekening']?.toString() ?? '';

        _existingFotoKtpUrl = agenData['foto_ktp'];
        _existingFotoSelfieUrl = agenData['foto_formal'];
        _existingKKUrl = agenData['foto_kk'];

        _matchSelectedBank();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _waController.dispose();
    _waDaruratController.dispose();
    _bankController.dispose();
    _namaRekeningController.dispose();
    _noRekeningController.dispose();
    _noKtpController.dispose();
    _tempatLahirController.dispose();
    _tanggalLahirController.dispose();
    _subDistrictController.dispose();
    _rtController.dispose();
    _rwController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      if (_isEditing) _initFields();
      _isEditing = !_isEditing;
    });
  }

  void _toggleKycEdit() {
    setState(() {
      if (_isKycEditing) _initFields();
      _isKycEditing = !_isKycEditing;
    });
  }

  Future<void> _pickImage(bool isSelfie, ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          if (isSelfie) {
            _fotoKtpSelfieFile = File(pickedFile.path);
          } else {
            _fotoKtpFile = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showImageSourcePicker(bool isSelfie) {
    KycImageSourcePicker.show(
      context,
      onSourceSelected: (source) => _pickImage(isSelfie, source),
    );
  }

  void _showKKSourcePicker(bool isKK) {
    KycImageSourcePicker.show(
      context,
      onSourceSelected: (source) => _pickImage(isKK, source),
    );
  }

  Future<void> _handleSaveInfo() async {
    final profileProv = context.read<ProfileProvider>();
    final success = await profileProv.saveProfileUpdate(
      name: _nameController.text.trim(),
      noWhatsapp: _waController.text.trim(),
    );

    if (success) {
      setState(() => _isEditing = false);
      if (mounted)
        CustomAnimatedAlert.show(context, 'Profil berhasil diperbarui', true);
    } else {
      if (mounted)
        CustomAnimatedAlert.show(context, 'Gagal memperbarui profil', false);
    }
  }

  Future<void> _handleSaveKyc() async {
    if (!_kycFormKey.currentState!.validate()) return;

    if (_existingKycId == null &&
        (_fotoKtpFile == null ||
            _fotoKtpSelfieFile == null ||
            _fotoKK == null)) {
      CustomAnimatedAlert.show(
        context,
        'Wajib melampirkan berkas Foto KTP, Foto Formal, dan Foto KK',
        false,
      );
      return;
    }

    final subDistrictId = int.tryParse(_subDistrictController.text.trim());
    if (subDistrictId == null || subDistrictId <= 0) {
      if (mounted)
        CustomAnimatedAlert.show(
          context,
          'Sub District ID harus berupa angka yang valid',
          false,
        );
      return;
    }

    final profileProv = context.read<ProfileProvider>();
    final success = await profileProv.uploadKycData(
      kycId: _existingKycId,
      noWhatsappDarurat: _waDaruratController.text.trim(),
      bank: _bankController.text.trim(),
      namaDiRekening: _namaRekeningController.text.trim(),
      noRekening: _noRekeningController.text.trim(),
      nomorKtp: _noKtpController.text.trim(),
      jenisKelamin: _jenisKelamin,
      tempatLahir: _tempatLahirController.text.trim(),
      tanggalLahir: _tanggalLahirController.text.trim(),
      subDistrictId: subDistrictId,
      rt: _rtController.text.trim(),
      rw: _rwController.text.trim(),
      alamat: _alamatController.text.trim(),
      fotoKtp: _fotoKtpFile,
      fotoKtpSelfie: _fotoKtpSelfieFile,
      fotoKK: _fotoKK,
    );

    if (success) {
      if (mounted) KycSuccessDialog.show(context);
      setState(() {
        _isKycEditing = false;
        _fotoKtpFile = null;
        _fotoKtpSelfieFile = null;
        _fotoKK = null;
      });
      profileProv.loadProfileData();
    } else {
      if (mounted)
        CustomAnimatedAlert.show(
          context,
          'Gagal memproses unggahan dokumen KYC Anda',
          false,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProv = context.watch<ProfileProvider>();
    final authProv = context.watch<AuthProvider>();

    if (profileProv.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE52320)),
        ),
      );
    }

    final data = profileProv.profileData;
    final String name = data?['name'] ?? authProv.userName ?? 'Reseller';
    final String email = data?['email'] ?? 'Tidak ada email';
    final Map<String, dynamic>? agenData = data?['agen_data'];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 16.0,
                left: 16.0,
                right: 16.0,
              ),
              child: ProfileHeaderCard(
                userPhotoUrl: authProv.userPhotoUrl,
                name: name,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12,
              ),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAEAEA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: const Color(0xFFE52525),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF666666),
                  labelStyle: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  tabs: const [
                    Tab(text: 'Info & Kontak'),
                    Tab(text: 'Menu KYC'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // TAB 1: INFO & KONTAK
                  Stack(
                    children: [
                      InfoKontakTabView(
                        email: email,
                        agenData: agenData,
                        provider: profileProv,
                        nameController: _nameController,
                        waController: _waController,
                        isEditing: _isEditing,
                        onToggleEdit: _toggleEdit,
                        onSaveInfo: _handleSaveInfo,
                      ),
                      if (_isEditing)
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: _buildInlineActionButtons(
                            onSave: _handleSaveInfo,
                            onCancel: _toggleEdit,
                            isLoading: profileProv.isSaving,
                          ),
                        ),
                    ],
                  ),

                  // TAB 2: MENU KYC
                  Stack(
                    children: [
                      KycFormTabView(
                        formKey: _kycFormKey,
                        provider: profileProv,
                        noKtpController: _noKtpController,
                        tempatLahirController: _tempatLahirController,
                        tanggalLahirController: _tanggalLahirController,
                        subDistrictController: _subDistrictController,
                        rtController: _rtController,
                        rwController: _rwController,
                        alamatController: _alamatController,
                        waDaruratController: _waDaruratController,
                        bankController: _bankController,
                        namaRekeningController: _namaRekeningController,
                        noRekeningController: _noRekeningController,
                        jenisKelamin: _jenisKelamin,
                        onJenisKelaminChanged: (val) =>
                            setState(() => _jenisKelamin = val!),
                        fotoKtpFile: _fotoKtpFile,
                        fotoKtpSelfieFile: _fotoKtpSelfieFile,
                        fotoKK: _fotoKK,
                        existingKKUrl: _existingKKUrl,
                        existingFotoKtpUrl: _existingFotoKtpUrl,
                        existingFotoSelfieUrl: _existingFotoSelfieUrl,
                        onPickFotoKtp: () => _showImageSourcePicker(false),
                        onPickFotoKtpSelfie: () => _showImageSourcePicker(true),
                        onPickFotoKK: () => _showKKSourcePicker(true),
                        onSubmit: _handleSaveKyc,
                        isEditing: _isKycEditing,
                        hasExistingData: _existingKycId != null,
                        onToggleEdit: _toggleKycEdit,
                        customBankDropdown: CustomSearchDropdown<dynamic>(
                          label: 'Nama Bank',
                          hint: 'Pilih Nama Bank',
                          items: _banks,
                          selectedValue: _selectedBank,
                          itemLabelBuilder: (item) =>
                              item['nama_bank'].toString().toUpperCase(),
                          itemBuilder: (context, item) => Row(
                            children: [
                              if (item['icon_bank'] != null &&
                                  item['icon_bank'].toString().isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    item['icon_bank'],
                                    width: 24,
                                    height: 24,
                                    fit: BoxFit.contain,
                                  ),
                                )
                              else
                                const Icon(Icons.account_balance, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                item['nama_bank'].toString().toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          searchMatcher: (item, query) =>
                              item['nama_bank']
                                  .toString()
                                  .toLowerCase()
                                  .contains(query) ||
                              item['kode_bank']
                                  .toString()
                                  .toLowerCase()
                                  .contains(query),
                          onChanged: _isKycEditing
                              ? (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedBank = value;
                                      _bankController.text = value['nama_bank']
                                          .toString();
                                    });
                                  }
                                }
                              : null,
                          validator: (_) => _selectedBank == null
                              ? 'Nama bank wajib dipilih'
                              : null,
                        ),
                      ),
                      if (_isKycEditing)
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: _buildInlineActionButtons(
                            onSave: _handleSaveKyc,
                            onCancel: _toggleKycEdit,
                            isLoading: profileProv.isKycSaving,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FLOATING BOTTOM ACTION BAR UNTUK EDIT/BATAL/SIMPAN
  Widget _buildInlineActionButtons({
    required VoidCallback onSave,
    required VoidCallback onCancel,
    required bool isLoading,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : onCancel,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE52525),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Simpan Data',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
