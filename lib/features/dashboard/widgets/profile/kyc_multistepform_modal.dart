import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/core/widget/alert_manager.dart';
import 'package:reseller_app_tav/core/widget/kyc_success_dialog.dart';
import 'package:reseller_app_tav/features/dashboard/providers/profile_provider.dart';
import 'package:reseller_app_tav/features/dashboard/services/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KycMultiStepFormModal extends StatefulWidget {
  final VoidCallback onSuccess;
  const KycMultiStepFormModal({super.key, required this.onSuccess});

  @override
  State<KycMultiStepFormModal> createState() => _KycMultiStepFormModalState();
}

class _KycMultiStepFormModalState extends State<KycMultiStepFormModal> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  int _currentPart = 0;
  final int _totalParts = 4;

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

  // Menggunakan List<dynamic> untuk menampung response dari backend secara fleksibel
  List<dynamic> _provinces = [];
  List<dynamic> _cities = [];
  List<dynamic> _districts = [];
  List<dynamic> _subDistricts = [];

  int? _selectedProvinceId;
  int? _selectedCityId;
  int? _selectedDistrictId;
  int? _selectedSubDistrictId;

  bool _isLoadingProvince = false;
  bool _isLoadingCity = false;
  bool _isLoadingDistrict = false;
  bool _isLoadingSubDistrict = false;

  @override
  void initState() {
    super.initState();
    _fetchProvinces();
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

  // Solusi Aman: Menggunakan perulangan manual/try-catch untuk menghindari error orElse Subtype di Dart
  String _getNameById(List<dynamic> list, int? id) {
    if (id == null || list.isEmpty) return '';
    for (var item in list) {
      if (item is Map && item['id'] == id) {
        return item['name']?.toString().toUpperCase() ?? '';
      }
    }
    return '';
  }

  // Fungsi Auto-Fill Terformat Real-time
  void _updateLiveAlamat() {
    List<String> parts = [];

    String rt = _rtCtrl.text.trim();
    String rw = _rwCtrl.text.trim();
    if (rt.isNotEmpty || rw.isNotEmpty) {
      String rtRwStr = "";
      if (rt.isNotEmpty) rtRwStr += "RT $rt";
      if (rw.isNotEmpty) {
        rtRwStr += (rtRwStr.isNotEmpty ? " / " : "") + "RW $rw";
      }
      parts.add(rtRwStr);
    }

    String subDistrictName = _getNameById(
      _subDistricts,
      _selectedSubDistrictId,
    );
    if (subDistrictName.isNotEmpty) {
      parts.add("KEL/DESA. $subDistrictName");
    }

    String districtName = _getNameById(_districts, _selectedDistrictId);
    if (districtName.isNotEmpty) {
      parts.add("KEC. $districtName");
    }

    String cityName = _getNameById(_cities, _selectedCityId);
    if (cityName.isNotEmpty) {
      parts.add(cityName);
    }

    String provinceName = _getNameById(_provinces, _selectedProvinceId);
    if (provinceName.isNotEmpty) {
      parts.add("PROV. $provinceName");
    }

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

  @override
  void dispose() {
    _pageController.dispose();
    _ktpCtrl.dispose();
    _namaCtrl.dispose();
    _tempatLahirCtrl.dispose();
    _tanggalLahirCtrl.dispose();
    _alamatCtrl.dispose();
    _bankCtrl.dispose();
    _noRekeningCtrl.dispose();
    _waDaruratCtrl.dispose();
    _rtCtrl.dispose();
    _rwCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String type) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() {
        if (type == 'KTP') _fotoKtp = File(pickedFile.path);
        if (type == 'Selfie') _fotoSelfie = File(pickedFile.path);
        if (type == 'KK') _fotoKK = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1945),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(
          context,
        ).copyWith(colorScheme: const ColorScheme.light(primary: Colors.black)),
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

    try {
      final success = await context.read<ProfileProvider>().uploadKycData(
        kycId: null,
        noWhatsappDarurat: _waDaruratCtrl.text.trim(),
        bank: _bankCtrl.text.trim(),
        namaDiRekening: _namaCtrl.text.trim(),
        noRekening: _noRekeningCtrl.text.trim(),
        nomorKtp: _ktpCtrl.text.trim(),
        jenisKelamin: _jenisKelamin,
        tempatLahir: _tempatLahirCtrl.text.trim(),
        tanggalLahir: _tanggalLahirCtrl.text.trim(),
        subDistrictId: _selectedSubDistrictId!,
        rt: _rtCtrl.text.trim(),
        rw: _rwCtrl.text.trim(),
        alamat: _alamatCtrl.text.trim(),
        fotoKtp: _fotoKtp,
        fotoKtpSelfie: _fotoSelfie,
        fotoKK: _fotoKK,
      );

      if (!mounted) return;

      if (success == true) {
        AlertManager.show(context, 'Data KYC berhasil dikirim!', true);
        Navigator.pop(context);
        KycSuccessDialog.show(context);
        widget.onSuccess();
      } else {
        AlertManager.show(
          context,
          'Gagal memverifikasi data KYC ke server.',
          false,
        );
      }
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildModernProgressStepper(),
                const SizedBox(height: 20),
                SizedBox(
                  height: 440,
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildPartOne(),
                      _buildPartTwo(),
                      _buildPartThree(),
                      _buildPartFour(),
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
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Verifikasi Akun (KYC)",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          Text(
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
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.black
                    : isDone
                    ? Colors.red
                    : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, size: 10, color: Colors.white)
                    : Text(
                        "${index + 1}",
                        style: TextStyle(
                          fontSize: 10,
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
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  color: index < _currentPart
                      ? Colors.red
                      : Colors.grey.shade200,
                ),
              ),
          ],
        ),
      );
    }),
  );

  Widget _buildPartOne() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _buildField('Nomor KTP', _ktpCtrl, TextInputType.number),
      _buildField('Nama Lengkap', _namaCtrl, TextInputType.text),
    ],
  );

  Widget _buildPartTwo() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _buildField('Tempat Lahir', _tempatLahirCtrl, TextInputType.text),
      _buildField(
        'Tanggal Lahir',
        _tanggalLahirCtrl,
        TextInputType.datetime,
        onTap: _selectDate,
      ),
    ],
  );

  Widget _buildPartThree() => ListView(
    shrinkWrap: true,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: _alamatCtrl,
          keyboardType: TextInputType.text,
          maxLines: 2,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Alamat Lengkap (Otomatis Terformat)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Alamat Lengkap tidak boleh kosong'
              : null,
        ),
      ),

      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _isLoadingProvince
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                ),
              )
            : DropdownButtonFormField<int>(
                isExpanded: true,
                value: _selectedProvinceId,
                hint: const Text('Pilih Provinsi'),
                decoration: InputDecoration(
                  labelText: 'Provinsi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: _provinces
                    .map(
                      (prov) => DropdownMenuItem<int>(
                        value: prov['id'] as int,
                        child: Text(
                          prov['name'].toString().toUpperCase(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedProvinceId = value;
                      _selectedCityId = null;
                      _selectedDistrictId = null;
                      _selectedSubDistrictId = null;
                      _cities = [];
                      _districts = [];
                      _subDistricts = [];
                    });
                    _updateLiveAlamat();
                    _fetchCities(value);
                  }
                },
                validator: (value) =>
                    value == null ? 'Provinsi wajib dipilih' : null,
              ),
      ),

      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _isLoadingCity
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                ),
              )
            : DropdownButtonFormField<int>(
                isExpanded: true,
                value: _selectedCityId,
                hint: const Text('Pilih Kota/Kabupaten'),
                decoration: InputDecoration(
                  labelText: 'Kota/Kabupaten',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: _cities
                    .map(
                      (city) => DropdownMenuItem<int>(
                        value: city['id'] as int,
                        child: Text(
                          city['name'].toString().toUpperCase(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCityId = value;
                      _selectedDistrictId = null;
                      _selectedSubDistrictId = null;
                      _districts = [];
                      _subDistricts = [];
                    });
                    _updateLiveAlamat();
                    _fetchDistricts(value);
                  }
                },
                validator: (value) =>
                    value == null ? 'Kota/Kabupaten wajib dipilih' : null,
              ),
      ),

      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _isLoadingDistrict
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                ),
              )
            : DropdownButtonFormField<int>(
                isExpanded: true,
                value: _selectedDistrictId,
                hint: const Text('Pilih Kecamatan'),
                decoration: InputDecoration(
                  labelText: 'Kecamatan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: _districts
                    .map(
                      (dist) => DropdownMenuItem<int>(
                        value: dist['id'] as int,
                        child: Text(
                          dist['name'].toString().toUpperCase(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedDistrictId = value;
                      _selectedSubDistrictId = null;
                      _subDistricts = [];
                    });
                    _updateLiveAlamat();
                    _fetchSubDistricts(value);
                  }
                },
                validator: (value) =>
                    value == null ? 'Kecamatan wajib dipilih' : null,
              ),
      ),

      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _isLoadingSubDistrict
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                ),
              )
            : DropdownButtonFormField<int>(
                isExpanded: true,
                value: _selectedSubDistrictId,
                hint: const Text('Pilih Kelurahan/Desa'),
                decoration: InputDecoration(
                  labelText: 'Kelurahan/Desa',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: _subDistricts
                    .map(
                      (subDist) => DropdownMenuItem<int>(
                        value: subDist['id'] as int,
                        child: Text(
                          subDist['name'].toString().toUpperCase(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedSubDistrictId = value;
                    });
                    _updateLiveAlamat();
                  }
                },
                validator: (value) =>
                    value == null ? 'Kelurahan/Desa wajib dipilih' : null,
              ),
      ),

      Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextFormField(
                controller: _rtCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'RT',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (_) => _updateLiveAlamat(),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'RT wajib diisi'
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextFormField(
                controller: _rwCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'RW',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (_) => _updateLiveAlamat(),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'RW wajib diisi'
                    : null,
              ),
            ),
          ),
        ],
      ),
      _buildField('WA Darurat', _waDaruratCtrl, TextInputType.phone),
    ],
  );

  Widget _buildPartFour() => Column(
    children: [
      Row(
        children: [
          Expanded(child: _buildField('Bank', _bankCtrl, TextInputType.text)),
          const SizedBox(width: 10),
          Expanded(
            child: _buildField('No Rek', _noRekeningCtrl, TextInputType.number),
          ),
        ],
      ),
      const SizedBox(height: 10),
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.8,
        children: [
          _buildUploadBox('KTP', _fotoKtp, () => _pickImage('KTP')),
          _buildUploadBox('Selfie', _fotoSelfie, () => _pickImage('Selfie')),
          _buildUploadBox('KK', _fotoKK, () => _pickImage('KK')),
        ],
      ),
    ],
  );

  Widget _buildField(
    String l,
    TextEditingController c,
    TextInputType t, {
    int maxLines = 1,
    VoidCallback? onTap,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: c,
      keyboardType: t,
      maxLines: maxLines,
      readOnly: onTap != null,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: l,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) => value == null || value.trim().isEmpty
          ? '$l tidak boleh kosong'
          : null,
    ),
  );

  Widget _buildUploadBox(String t, File? f, VoidCallback o) => GestureDetector(
    onTap: o,
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: f != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(f, fit: BoxFit.cover),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt),
                Text(t, style: const TextStyle(fontSize: 10)),
              ],
            ),
    ),
  );

  Widget _buildActionButtons(ProfileProvider p) => Row(
    children: [
      if (_currentPart > 0)
        Expanded(
          child: OutlinedButton(
            onPressed: () => setState(() {
              _currentPart--;
              _pageController.jumpToPage(_currentPart);
            }),
            child: const Text('Kembali'),
          ),
        ),
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          onPressed: () => _currentPart < 3
              ? setState(() {
                  if (_formKey.currentState!.validate()) {
                    _currentPart++;
                    _pageController.jumpToPage(_currentPart);
                  } else {
                    AlertManager.show(
                      context,
                      'Mohon lengkapi field yang kosong di halaman ini.',
                      false,
                    );
                  }
                })
              : _submitKyc(),
          child: p.isKycSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(_currentPart == 3 ? 'Kirim' : 'Lanjut'),
        ),
      ),
    ],
  );
}
