import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/core/widget/cutsom_alert_widget.dart';
import 'package:reseller_app_tav/core/widget/kyc_success_dialog.dart';
import 'package:reseller_app_tav/features/auth/providers/auth_provider.dart';
import 'package:reseller_app_tav/features/dashboard/providers/profile_provider.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/profile/info_contact_view.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/profile/kyc_form_tab_view.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/profile/kyc_image_source.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/profile/profile_header_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Di dalam class _ProfilePageState di file profile_page.dart

  bool _isKycEditing = false;
  int? _existingKycId;
  String? _existingFotoKtpUrl;
  String? _existingFotoSelfieUrl;
  String? _existingKKUrl;

  void _toggleKycEdit() {
    setState(() {
      if (_isKycEditing) {
        _initFields(); // Reset field jika batal edit
      }
      _isKycEditing = !_isKycEditing;
    });
  }

  bool _isEditing = false;
  final _kycFormKey = GlobalKey<FormState>();

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
        });
      }
    });
  }

  void _initFields() {
    final data = context.read<ProfileProvider>().profileData;
    final authProv = context.read<AuthProvider>();
    if (data != null) {
      _nameController.text = data['name'] ?? authProv.userName ?? '';
      _waController.text =
          data['no_whatsapp'] ??
          data['no_wa'] ??
          data['phone'] ??
          ''; // Menyesuaikan objek no_whatsapp dari JSON terbaru

      // Pemetaan Data KYC dari agen_data
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

        // URL Gambar S3 Server
        _existingFotoKtpUrl = agenData['foto_ktp'];
        _existingFotoSelfieUrl = agenData['foto_formal'];
        _existingKKUrl = agenData['foto_kk'];
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
      if (_isEditing) {
        _initFields();
      }
      _isEditing = !_isEditing;
    });
  }

  // Ubah fungsi _pickImage lama Anda menjadi seperti ini:
  Future<void> _pickImage(bool isSelfie, ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality:
            80, // Kompresi gambar agar tidak terlalu berat saat diunggah
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
      onSourceSelected: (ImageSource source) {
        _pickImage(isSelfie, source);
      },
    );
  }

  void _showKKSourcePicker(bool isKK) {
    KycImageSourcePicker.show(
      context,
      onSourceSelected: (ImageSource source) {
        _pickImage(isKK, source);
      },
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
        'Wajib melampirkan berkas Foto KTP dan Foto Formal, Serta Foto KK',
        false,
      );
      return;
    }

    final subDistrictId = int.tryParse(_subDistrictController.text.trim());

    if (subDistrictId == null || subDistrictId <= 0) {
      if (mounted) {
        CustomAnimatedAlert.show(
          context,
          'Sub District ID harus berupa angka yang valid',
          false,
        );
      }
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
      if (mounted) {
        CustomAnimatedAlert.show(
          context,
          'Gagal memproses unggahan dokumen KYC Anda',
          false,
        );
      }
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
            // PROFILE CARD ATAS
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

            // TAB BAR HEADER
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

            // VIEWS TAB VIEW
            Expanded(
              child: TabBarView(
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
