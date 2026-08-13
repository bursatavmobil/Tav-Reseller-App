import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/core/widget/alert_manager.dart';
import 'package:reseller_app_tav/core/widget/custom_dropdown_region.dart';
import 'package:reseller_app_tav/core/widget/kyc_success_dialog.dart';
import 'package:reseller_app_tav/features/dashboard/models/profile_response_model.dart';
import 'package:reseller_app_tav/features/dashboard/providers/dashboard_provider.dart';
import 'package:reseller_app_tav/features/dashboard/providers/profile_provider.dart';
import 'package:reseller_app_tav/features/dashboard/services/api_config.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/profile/ocr_modal_validation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class KycMultiStepFormModal extends StatefulWidget {
  final VoidCallback onSuccess;
  final int? kycId;
  final ProfileData? profileData;

  const KycMultiStepFormModal({
    super.key,
    required this.onSuccess,
    this.kycId,
    this.profileData,
  });

  @override
  State<KycMultiStepFormModal> createState() => _KycMultiStepFormModalState();
}

class _KycMultiStepFormModalState extends State<KycMultiStepFormModal> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  int _currentPart = 0;

  final int _totalParts = 3;

  final _ktpCtrl = TextEditingController();
  final _namaCtrl = TextEditingController();
  final _tempatLahirCtrl = TextEditingController();
  final _tanggalLahirCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _noRekeningCtrl = TextEditingController();
  final _waDaruratCtrl = TextEditingController();
  final _rtCtrl = TextEditingController(text: "01");
  final _rwCtrl = TextEditingController(text: "02");

  String _jenisKelamin = 'laki-laki';
  File? _fotoKtp;
  File? _fotoSelfie;
  File? _fotoKK;

  List<dynamic> _provinces = [];
  List<dynamic> _cities = [];
  List<dynamic> _districts = [];
  List<dynamic> _subDistricts = [];
  List<dynamic> _banks = [];

  dynamic _selectedBank;

  int? _selectedProvinceId;
  int? _selectedCityId;
  int? _selectedDistrictId;
  int? _selectedSubDistrictId;

  bool _isLoadingProvince = false;
  bool _isLoadingCity = false;
  bool _isLoadingDistrict = false;
  bool _isLoadingSubDistrict = false;
  bool _isLoadingBank = false;

  @override
  void initState() {
    super.initState();
    _fetchProvinces();
    _fetchBanks();
    _checkAndAutofillExistingData();
  }

  void _checkAndAutofillExistingData() {
    debugPrint('==================================================');
    debugPrint('[FORM KYC INIT DEBUG] Menguji Data Masuk...');
    debugPrint('Parameter widget.kycId      : ${widget.kycId}');
    debugPrint(
      'Parameter widget.profileData : ${widget.profileData != null ? "TERSEDIA" : "NULL"}',
    );
    debugPrint('==================================================');

    if (widget.profileData != null) {
      final p = widget.profileData!;

      setState(() {
        // 1. Ambil data dasar dari ProfileData strongly-typed (Aman & Sukses)
        _namaCtrl.text = p.name.toUpperCase();
        debugPrint('[FORM KYC AUTOFILL] Autofill Nama: ${_namaCtrl.text}');

        if (p.agenData != null) {
          _bankCtrl.text = p.agenData!.bank.toUpperCase();
          _noRekeningCtrl.text = p.agenData!.noRekening;
          if (p.agenData!.namaDiRekening.isNotEmpty) {
            _namaCtrl.text = p.agenData!.namaDiRekening.toUpperCase();
          }
          debugPrint(
            '[FORM KYC AUTOFILL] Autofill Bank        : ${_bankCtrl.text}',
          );
          debugPrint(
            '[FORM KYC AUTOFILL] Autofill No Rekening : ${_noRekeningCtrl.text}',
          );
        }

        // 2. AMBIL FIELD DINAMIS VIA MAP JSON DI DASHBOARD PROVIDER (Mencegah Class ProfileData diakses langsung)
        try {
          final dashboardProvider = Provider.of<DashboardProvider>(
            context,
            listen: false,
          );
          final Map<String, dynamic>? rawJson =
              dashboardProvider.rawProfileJson;

          if (rawJson != null) {
            debugPrint(
              '[FORM KYC DYNAMIC] Memulai ekstraksi data dari rawProfileJson...',
            );

            // 🟢 GUNAKAN rawJson KANAN/KIRI, JANGAN MENYENTUH VARIABEL LAIN
            if (rawJson['nomor_ktp'] != null || rawJson['nomorKtp'] != null) {
              _ktpCtrl.text = (rawJson['nomor_ktp'] ?? rawJson['nomorKtp'])
                  .toString();
              debugPrint(
                '[FORM KYC AUTOFILL] KTP Sukses Terbaca : ${_ktpCtrl.text}',
              );
            }

            if (rawJson['tempat_lahir'] != null ||
                rawJson['tempatLahir'] != null) {
              _tempatLahirCtrl.text =
                  (rawJson['tempat_lahir'] ?? rawJson['tempatLahir'])
                      .toString()
                      .toUpperCase();
              debugPrint(
                '[FORM KYC AUTOFILL] Tempat Lahir Terbaca: ${_tempatLahirCtrl.text}',
              );
            }

            if (rawJson['tanggal_lahir'] != null ||
                rawJson['tanggalLahir'] != null) {
              _tanggalLahirCtrl.text =
                  (rawJson['tanggal_lahir'] ?? rawJson['tanggalLahir'])
                      .toString();
            }

            if (rawJson['no_whatsapp_darurat'] != null ||
                rawJson['noWhatsappDarurat'] != null) {
              _waDaruratCtrl.text =
                  (rawJson['no_whatsapp_darurat'] ??
                          rawJson['noWhatsappDarurat'])
                      .toString();
            }

            if (rawJson['rt'] != null)
              _rtCtrl.text = rawJson['rt'].toString().toUpperCase();
            if (rawJson['rw'] != null)
              _rwCtrl.text = rawJson['rw'].toString().toUpperCase();

            if (rawJson['alamat'] != null) {
              _alamatCtrl.text = rawJson['alamat'].toString().toUpperCase();
              debugPrint(
                '[FORM KYC AUTOFILL] Alamat Sukses Terbaca: ${_alamatCtrl.text}',
              );
            }

            if (rawJson['jenis_kelamin'] != null ||
                rawJson['jenisKelamin'] != null) {
              _jenisKelamin =
                  (rawJson['jenis_kelamin'] ?? rawJson['jenisKelamin'])
                      .toString()
                      .toLowerCase();
            }
          } else {
            debugPrint(
              '[FORM KYC WARNING] rawProfileJson di DashboardProvider bernilai NULL.',
            );
          }
        } catch (e) {
          debugPrint(
            '[FORM KYC DYNAMIC ERROR] Gagal memetakan data sekunder: $e',
          );
        }
      });

      debugPrint('[FORM KYC INIT DEBUG] Selesai memetakan data awal.');
      debugPrint('==================================================');
    }
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

  String _getNameById(List<dynamic> list, int? id) {
    if (id == null || list.isEmpty) return '';
    for (var item in list) {
      if (item is Map && item['id'] == id) {
        return item['name']?.toString().toUpperCase() ?? '';
      }
    }
    return '';
  }

  String _formatLocationItemName(dynamic item) {
    if (item is! Map) return item.toString().toUpperCase();
    String origName = (item['name'] ?? '').toString().toUpperCase();

    if (item.containsKey('type') && item['type'] != null) {
      String typeStr = item['type'].toString().toLowerCase();
      if (typeStr.contains('kota')) return "$origName, KOTA";
      if (typeStr.contains('kab')) return "$origName, KAB";
      if (typeStr.contains('kec')) return "$origName, KEC";
      if (typeStr.contains('des') || typeStr.contains('kel'))
        return "$origName, KEL/DESA";
    }

    if (origName.startsWith('KOTA '))
      return "${origName.replaceAll('KOTA ', '')}, KOTA";
    if (origName.startsWith('KABUPATEN '))
      return "${origName.replaceAll('KABUPATEN ', '')}, KAB";
    if (origName.startsWith('KAB. '))
      return "${origName.replaceAll('KAB. ', '')}, KAB";
    if (origName.startsWith('KECAMATAN '))
      return "${origName.replaceAll('KECAMATAN ', '')}, KEC";
    if (origName.startsWith('KEC. '))
      return "${origName.replaceAll('KEC. ', '')}, KEC";
    if (origName.startsWith('KELURAHAN '))
      return "${origName.replaceAll('KELURAHAN ', '')}, KEL";
    if (origName.startsWith('DESA '))
      return "${origName.replaceAll('DESA ', '')}, DESA";

    return origName;
  }

  void _updateLiveAlamat() {
    List<String> parts = [];
    String rt = _rtCtrl.text.trim().toUpperCase();
    String rw = _rwCtrl.text.trim().toUpperCase();
    if (rt.isNotEmpty || rw.isNotEmpty) {
      String rtRwStr = "";
      if (rt.isNotEmpty) rtRwStr += "RT $rt";
      if (rw.isNotEmpty)
        rtRwStr += (rtRwStr.isNotEmpty ? " / " : "") + "RW $rw";
      parts.add(rtRwStr);
    }

    dynamic subDistObj;
    for (var e in _subDistricts) {
      if (e['id'] == _selectedSubDistrictId) subDistObj = e;
    }
    if (subDistObj != null) parts.add(_formatLocationItemName(subDistObj));

    dynamic distObj;
    for (var e in _districts) {
      if (e['id'] == _selectedDistrictId) distObj = e;
    }
    if (distObj != null) parts.add(_formatLocationItemName(distObj));

    dynamic cityObj;
    for (var e in _cities) {
      if (e['id'] == _selectedCityId) cityObj = e;
    }
    if (cityObj != null) parts.add(_formatLocationItemName(cityObj));

    String provinceName = _getNameById(_provinces, _selectedProvinceId);
    if (provinceName.isNotEmpty) parts.add("PROV. $provinceName");

    setState(() {
      _alamatCtrl.text = parts.join(", ");
    });
  }

  Future<void> _fetchProvinces() async {
    setState(() => _isLoadingProvince = true);
    try {
      final dio = await _getDio();
      final response = await dio.get('region/province');
      if (response.data['status'] == true && mounted) {
        setState(() {
          _provinces = response.data['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error fetch provinces: $e');
    } finally {
      if (mounted) setState(() => _isLoadingProvince = false);
    }
  }

  Future<void> _fetchBanks() async {
    setState(() => _isLoadingBank = true);
    try {
      final dio = await _getDio();
      final response = await dio.get('master-bank');
      if (response.data['status'] == true && mounted) {
        setState(() {
          _banks = response.data['data'] ?? [];
          if (_bankCtrl.text.isNotEmpty && _banks.isNotEmpty) {
            _selectedBank = _banks.firstWhere(
              (e) =>
                  e['nama_bank'].toString().toUpperCase() ==
                  _bankCtrl.text.toUpperCase(),
              orElse: () => null,
            );
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetch banks: $e');
    } finally {
      if (mounted) setState(() => _isLoadingBank = false);
    }
  }

  Future<void> _fetchCities(int provId) async {
    setState(() {
      _isLoadingCity = true;
      _cities = [];
    });
    try {
      final dio = await _getDio();
      final response = await dio.get('region/city/$provId');
      if (response.data['status'] == true && mounted) {
        setState(() {
          _cities = response.data['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error fetch cities: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingCity = false);
        _updateLiveAlamat();
      }
    }
  }

  Future<void> _fetchDistricts(int cityId) async {
    setState(() {
      _isLoadingDistrict = true;
      _districts = [];
    });
    try {
      final dio = await _getDio();
      final response = await dio.get('region/district/$cityId');
      if (response.data['status'] == true && mounted) {
        setState(() {
          _districts = response.data['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error fetch districts: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingDistrict = false);
        _updateLiveAlamat();
      }
    }
  }

  Future<void> _fetchSubDistricts(int districtId) async {
    setState(() {
      _isLoadingSubDistrict = true;
      _subDistricts = [];
    });
    try {
      final dio = await _getDio();
      final response = await dio.get('region/sub-district/$districtId');
      if (response.data['status'] == true && mounted) {
        setState(() {
          _subDistricts = response.data['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error fetch sub-districts: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingSubDistrict = false);
        _updateLiveAlamat();
      }
    }
  }

  Future<void> _showImageSourceBottomSheet(String type) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF121212),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Text(
                  'UNGGAH FOTO ${type.toUpperCase()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pilih metode unggah berkas dokumen fisik Anda.',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(type, ImageSource.camera);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFE52525),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            color: const Color(0xFF1A1A1A),
                          ),
                          child: Column(
                            children: const [
                              Icon(
                                Icons.camera_alt_rounded,
                                color: Color(0xFFFFD700),
                                size: 32,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Kamera',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(type, ImageSource.gallery);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade800),
                            borderRadius: BorderRadius.circular(16),
                            color: const Color(0xFF1A1A1A),
                          ),
                          child: Column(
                            children: const [
                              Icon(
                                Icons.photo_library_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Galeri',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(String type, ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      imageQuality:
          85, // Kualitas ditingkatkan agar OCR membaca teks lebih presisi
    );

    if (pickedFile != null && mounted) {
      File tempFile = File(pickedFile.path);

      // Tampilkan Modal Terpisah Validasi OCR
      bool? isConfirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            OcrValidationModal(imageFile: tempFile, documentType: type),
      );

      // Jika pengguna mengonfirmasi "Gunakan", simpan gambar ke state form utama
      if (isConfirmed == true) {
        setState(() {
          if (type == 'KTP') _fotoKtp = tempFile;
          if (type == 'Selfie') _fotoSelfie = tempFile;
          if (type == 'KK') _fotoKK = tempFile;
        });
      }
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1945),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFE52525),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(
        () => _tanggalLahirCtrl.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}",
      );
    }
  }

  Future<void> _submitKyc() async {
    debugPrint('=== [KYC SUBMIT START] ===');

    if (!_formKey.currentState!.validate()) {
      AlertManager.show(
        context,
        'Mohon lengkapi seluruh kolom formulir yang wajib diisi.',
        false,
      );
      return;
    }

    if (_selectedSubDistrictId == null) {
      AlertManager.show(
        context,
        'Silakan pilih kelurahan/desa terlebih dahulu!',
        false,
      );
      return;
    }

    final payload = {
      'noWhatsappDarurat': _waDaruratCtrl.text.trim().toLowerCase(),
      'bank': _bankCtrl.text.trim().toLowerCase(),
      'namaDiRekening': _namaCtrl.text.trim().toLowerCase(),
      'noRekening': _noRekeningCtrl.text.trim().toLowerCase(),
      'nomorKtp': _ktpCtrl.text.trim().toLowerCase(),
      'jenisKelamin': _jenisKelamin.toLowerCase(),
      'tempatLahir': _tempatLahirCtrl.text.trim().toLowerCase(),
      'tanggalLahir': _tanggalLahirCtrl.text.trim().toLowerCase(),
      'subDistrictId': _selectedSubDistrictId,
      'rt': _rtCtrl.text.trim().toLowerCase(),
      'rw': _rwCtrl.text.trim().toLowerCase(),
      'alamat': _alamatCtrl.text.trim().toLowerCase(),
    };

    try {
      final profileProv = context.read<ProfileProvider>();
      final success = await profileProv.uploadKycData(
        kycId: widget.kycId,
        noWhatsappDarurat: payload['noWhatsappDarurat'] as String,
        bank: payload['bank'] as String,
        namaDiRekening: payload['namaDiRekening'] as String,
        noRekening: payload['noRekening'] as String,
        nomorKtp: payload['nomorKtp'] as String,
        jenisKelamin: payload['jenisKelamin'] as String,
        tempatLahir: payload['tempatLahir'] as String,
        tanggalLahir: payload['tanggalLahir'] as String,
        subDistrictId: payload['subDistrictId'] as int,
        rt: payload['rt'] as String,
        rw: payload['rw'] as String,
        alamat: payload['alamat'] as String,
        fotoKtp: _fotoKtp,
        fotoKtpSelfie: _fotoSelfie,
        fotoKK: _fotoKK,
      );

      if (!mounted) return;

      if (success == true) {
        AlertManager.show(context, 'Data KYC berhasil diperbarui!', true);
        Navigator.pop(context);
        KycSuccessDialog.show(context);
        widget.onSuccess();
      } else {
        // Tampilkan error spesifik dari errorMessage milik Provider
        AlertManager.show(
          context,
          profileProv.errorMessage ?? 'Gagal memverifikasi data KYC ke server.',
          false,
        );
      }
    } on DioException catch (e) {
      if (!mounted) return;

      if (e.response?.data != null) {
        final data = e.response?.data;
        
        // Ambil pesan spesifik dari key 'text'
        if (data is Map && data['text'] != null) {
          AlertManager.show(context, data['text'].toString(), false);
          return;
        }
      }

      AlertManager.showError(context, e);
    } catch (e) {
      if (!mounted) return;
      AlertManager.showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final watchProv = context.watch<ProfileProvider>();
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildModernProgressStepper(),
                const SizedBox(height: 20),
                SizedBox(
                  height: 480,
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildPartOne(),
                      _buildPartTwo(),
                      _buildPartThree(),
                    ],
                  ),
                ),
                _buildActionButtons(watchProv),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.kycId != null
                ? "Pembaruan Data KYC"
                : "Verifikasi Akun (KYC)",
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const Text(
            "Lengkapi data identitas resmi Anda",
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
      IconButton(
        icon: const Icon(Icons.close, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
    ],
  );

  Widget _buildModernProgressStepper() => Row(
    children: List.generate(_totalParts, (index) {
      bool isDone = index < _currentPart;
      bool isActive = index == _currentPart;
      return Expanded(
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.black
                    : isDone
                    ? const Color(0xFFE52525)
                    : Colors.grey.shade200,
                shape: BoxShape.circle,
                border: isActive
                    ? Border.all(color: const Color(0xFFFFD700), width: 1.5)
                    : null,
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : Text(
                        "${index + 1}",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isActive || isDone
                              ? Colors.white
                              : Colors.grey.shade500,
                        ),
                      ),
              ),
            ),
            if (index < _totalParts - 1)
              Expanded(
                child: Container(
                  height: 2.5,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  color: index < _currentPart
                      ? const Color(0xFFE52525)
                      : Colors.grey.shade200,
                ),
              ),
          ],
        ),
      );
    }),
  );

  Widget _buildPartOne() => ListView(
    shrinkWrap: true,
    physics: const ClampingScrollPhysics(),
    children: [
      _buildField('Nomor KTP', _ktpCtrl, TextInputType.number),
      _buildField('Nama Lengkap', _namaCtrl, TextInputType.text),
      _buildField('Tempat Lahir', _tempatLahirCtrl, TextInputType.text),
      _buildField(
        'Tanggal Lahir',
        _tanggalLahirCtrl,
        TextInputType.datetime,
        onTap: _selectDate,
      ),
    ],
  );

  Widget _buildPartTwo() => ListView(
    shrinkWrap: true,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: _alamatCtrl,
          maxLines: 2,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Alamat Lengkap (Otomatis)',
            fillColor: Colors.grey.shade100,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
      CustomSearchDropdown<dynamic>(
        label: 'Provinsi',
        hint: 'Pilih Provinsi',
        items: _provinces,
        selectedValue: _provinces.firstWhere(
          (e) => e['id'] == _selectedProvinceId,
          orElse: () => null,
        ),
        itemLabelBuilder: (item) => item['name'].toString().toUpperCase(),
        searchMatcher: (item, query) =>
            item['name'].toString().toLowerCase().contains(query),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedProvinceId = value['id'];
              _selectedCityId = null;
              _selectedDistrictId = null;
              _selectedSubDistrictId = null;
              _cities = [];
              _districts = [];
              _subDistricts = [];
            });
            _updateLiveAlamat();
            _fetchCities(value['id']);
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _formKey.currentState?.validate(),
            );
          }
        },
        validator: (_) =>
            _selectedProvinceId == null ? 'Provinsi wajib dipilih' : null,
      ),
      CustomSearchDropdown<dynamic>(
        label: 'Kota/Kabupaten',
        hint: 'Pilih Kota/Kabupaten',
        items: _cities,
        selectedValue: _cities.firstWhere(
          (e) => e['id'] == _selectedCityId,
          orElse: () => null,
        ),
        itemLabelBuilder: (item) => _formatLocationItemName(item),
        searchMatcher: (item, query) =>
            item['name'].toString().toLowerCase().contains(query),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedCityId = value['id'];
              _selectedDistrictId = null;
              _selectedSubDistrictId = null;
              _districts = [];
              _subDistricts = [];
            });
            _updateLiveAlamat();
            _fetchDistricts(value['id']);
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _formKey.currentState?.validate(),
            );
          }
        },
        validator: (_) =>
            _selectedCityId == null ? 'Kota/Kabupaten wajib dipilih' : null,
      ),
      CustomSearchDropdown<dynamic>(
        label: 'Kecamatan',
        hint: 'Pilih Kecamatan',
        items: _districts,
        selectedValue: _districts.firstWhere(
          (e) => e['id'] == _selectedDistrictId,
          orElse: () => null,
        ),
        itemLabelBuilder: (item) => _formatLocationItemName(item),
        searchMatcher: (item, query) =>
            item['name'].toString().toLowerCase().contains(query),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedDistrictId = value['id'];
              _selectedSubDistrictId = null;
              _subDistricts = [];
            });
            _updateLiveAlamat();
            _fetchSubDistricts(value['id']);
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _formKey.currentState?.validate(),
            );
          }
        },
        validator: (_) =>
            _selectedDistrictId == null ? 'Kecamatan wajib dipilih' : null,
      ),
      CustomSearchDropdown<dynamic>(
        label: 'Kelurahan/Desa',
        hint: 'Pilih Kelurahan/Desa',
        items: _subDistricts,
        selectedValue: _subDistricts.firstWhere(
          (e) => e['id'] == _selectedSubDistrictId,
          orElse: () => null,
        ),
        itemLabelBuilder: (item) => _formatLocationItemName(item),
        searchMatcher: (item, query) =>
            item['name'].toString().toLowerCase().contains(query),
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedSubDistrictId = value['id']);
            _updateLiveAlamat();
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _formKey.currentState?.validate(),
            );
          }
        },
        validator: (_) => _selectedSubDistrictId == null
            ? 'Kelurahan/Desa wajib dipilih'
            : null,
      ),
      Row(
        children: [
          Expanded(child: _buildField('RT', _rtCtrl, TextInputType.number)),
          const SizedBox(width: 10),
          Expanded(child: _buildField('RW', _rwCtrl, TextInputType.number)),
        ],
      ),
      _buildField('WA Darurat', _waDaruratCtrl, TextInputType.phone),
    ],
  );

  Widget _buildPartThree() => ListView(
  shrinkWrap: true,
  children: [
    CustomSearchDropdown<dynamic>(
      label: 'Nama Bank',
      hint: _isLoadingBank ? 'Memuat data bank...' : 'Pilih Nama Bank',
      items: _banks,
      selectedValue: _selectedBank,
      itemLabelBuilder: (item) => item['nama_bank'].toString().toUpperCase(),
      itemBuilder: (context, item) => Row(
        children: [
          if (item['icon_bank'] != null && item['icon_bank'].toString().isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                item['icon_bank'],
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.account_balance, size: 20),
              ),
            )
          else
            const Icon(Icons.account_balance, size: 20),
          const SizedBox(width: 12),
        
          Text(
            item['nama_bank'].toString().toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
      searchMatcher: (item, query) =>
          item['nama_bank'].toString().toLowerCase().contains(query) ||
          item['kode_bank'].toString().toLowerCase().contains(query),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedBank = value;
            _bankCtrl.text = value['nama_bank'].toString();
          });
          WidgetsBinding.instance.addPostFrameCallback((_) => _formKey.currentState?.validate());
        }
      },
      validator: (_) => _selectedBank == null ? 'Nama bank wajib dipilih' : null,
    ),
    _buildField('Nomor Rekening', _noRekeningCtrl, TextInputType.number),
    const SizedBox(height: 10),
    GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.8,
      children: [
        _buildUploadBox('KTP', _fotoKtp, () => _showImageSourceBottomSheet('KTP')),
        _buildUploadBox('Selfie', _fotoSelfie, () => _showImageSourceBottomSheet('Selfie')),
        _buildUploadBox('KK', _fotoKK, () => _showImageSourceBottomSheet('KK')),
      ],
    ),
  ],
);

  Widget _buildField(
    String l,
    TextEditingController c,
    TextInputType t, {
    VoidCallback? onTap,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: c,
      keyboardType: t,
      readOnly: onTap != null,
      onTap: onTap,
      textCapitalization: TextCapitalization.characters,
      inputFormatters: [UpperCaseTextFormatter()],
      onChanged: (_) {
        // Re-trigger validasi agar pesan error langsung hilang begitu field diisi
        if (_formKey.currentState != null) {
          _formKey.currentState!.validate();
        }
      },
      decoration: InputDecoration(
        labelText: l,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE52525)),
        ),
      ),
      validator: (value) =>
          value == null || value.trim().isEmpty ? '$l wajib diisi' : null,
    ),
  );

  Widget _buildUploadBox(String t, File? f, VoidCallback o) => GestureDetector(
    onTap: o,
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade50,
      ),
      child: f != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(f, fit: BoxFit.cover),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt_outlined, color: Colors.grey),
                const SizedBox(height: 4),
                Text(
                  t,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
    ),
  );

  Widget _buildActionButtons(ProfileProvider p) => Row(
    children: [
      if (_currentPart > 0)
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.black),
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              setState(() {
                _currentPart--;
                _pageController.jumpToPage(_currentPart);
              });
            },
            child: const Text('Kembali'),
          ),
        ),
      if (_currentPart > 0) const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            // Jalankan validasi pada FormState
            final bool isValid = _formKey.currentState?.validate() ?? false;

            if (_currentPart < (_totalParts - 1)) {
              if (isValid) {
                setState(() {
                  _currentPart++;
                  _pageController.jumpToPage(_currentPart);
                });
              } else {
                AlertManager.show(
                  context,
                  'Mohon lengkapi field yang kosong.',
                  false,
                );
              }
            } else {
              if (isValid) {
                _submitKyc();
              } else {
                AlertManager.show(
                  context,
                  'Mohon lengkapi seluruh kolom formulir yang wajib diisi.',
                  false,
                );
              }
            }
          },
          child: p.isKycSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(_currentPart == (_totalParts - 1) ? 'Kirim' : 'Lanjut'),
        ),
      ),
    ],
  );
}
