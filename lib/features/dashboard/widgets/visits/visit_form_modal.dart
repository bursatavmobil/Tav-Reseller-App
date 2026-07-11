import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/features/dashboard/providers/visit_schedule_provider.dart';
import 'package:reseller_app_tav/features/dashboard/widgets/visits/field_car_selector.dart';

import '../../models/visit_schedule_model.dart';

class VisitFormModal extends StatefulWidget {
  final VisitScheduleItem? editItem;
  final VoidCallback onSuccess;

  const VisitFormModal({super.key, this.editItem, required this.onSuccess});

  static void show(
    BuildContext context, {
    VisitScheduleItem? editItem,
    required VoidCallback onSuccess,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => VisitFormModal(editItem: editItem, onSuccess: onSuccess),
    );
  }

  @override
  State<VisitFormModal> createState() => _VisitFormModalState();
}

class _VisitFormModalState extends State<VisitFormModal> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _tipeController = TextEditingController(text: 'Negosiasi');
  final _catatanController = TextEditingController();

  int? _selectedCarId;
  String? _selectedCarName;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.editItem != null) {
      _nameController.text = widget.editItem!.namaKonsumen;
      _catatanController.text = widget.editItem!.catatan;
      _tipeController.text = widget.editItem!.tipe;
      _selectedCarId = widget.editItem!.carId;
      _selectedCarName = widget.editItem!.car?.name;
      _selectedDate = DateTime.tryParse(widget.editItem!.tanggal);
      if (widget.editItem!.jam.isNotEmpty) {
        final rawTime = widget.editItem!.jam.split(':');
        if (rawTime.length >= 2) {
          _selectedTime = TimeOfDay(
            hour: int.parse(rawTime[0]),
            minute: int.parse(rawTime[1]),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tipeController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.red,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.red,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _selectedCarId == null ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi seluruh data form termasuk memilih mobil'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final tglStr =
          "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
      final jamStr =
          "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00";

      await context.read<VisitScheduleProvider>().saveSchedule(
        id: widget.editItem?.id,
        carId: _selectedCarId!,
        tipe: _tipeController.text.trim(),
        namaKonsumen: _nameController.text.trim(),
        tanggal: tglStr,
        jam: jamStr,
        catatan: _catatanController.text.trim(),
      );

      widget.onSuccess();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.editItem == null
                    ? "Buat Kunjungan Baru"
                    : "Edit Jadwal Kunjungan",
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Divider(height: 24, color: Colors.grey),

              // Nama Konsumen
              TextFormField(
                controller: _nameController,
                style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'Nama Konsumen',
                  labelStyle: TextStyle(color: Colors.grey),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nama konsumen wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Pemanggil Komponen Car Selector Widget hasil pemisahan file
              CarSelectorWidget(
                initialCarId: _selectedCarId,
                initialCarName: _selectedCarName,
                onCarSelected: (id, name) {
                  _selectedCarId = id;
                  _selectedCarName = name;
                },
              ),
              const SizedBox(height: 16),

              // Tipe Kunjungan (Sekarang Menggunakan Input Biasa / TextFormField)
              TextFormField(
                controller: _tipeController,
                style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'Tipe Kunjungan',
                  labelStyle: TextStyle(color: Colors.grey),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? 'Tipe kunjungan wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),

              // Custom Modern Picker Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      icon: const Icon(Icons.calendar_month, color: Colors.red),
                      label: Text(
                        _selectedDate == null
                            ? 'Pilih Tanggal'
                            : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.black87,
                          fontSize: 13,
                        ),
                      ),
                      onPressed: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      icon: const Icon(Icons.access_time, color: Colors.red),
                      label: Text(
                        _selectedTime == null
                            ? 'Pilih Jam'
                            : _selectedTime!.format(context),
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.black87,
                          fontSize: 13,
                        ),
                      ),
                      onPressed: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Catatan
              TextFormField(
                controller: _catatanController,
                maxLines: 2,
                style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'Catatan',
                  labelStyle: TextStyle(color: Colors.grey),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button (Nuansa Hitam & Putih)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Simpan Jadwal',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
