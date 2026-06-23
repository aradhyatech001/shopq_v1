import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/admin_api.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';

class PincodeScreen extends StatefulWidget {
  const PincodeScreen({super.key});

  @override
  State<PincodeScreen> createState() => _PincodeScreenState();
}

class _PincodeScreenState extends State<PincodeScreen> {
  List _pincodes = [];
  bool _loading = false;
  String _search = '';
  final _searchCtrl = TextEditingController();

  // Right-panel Add/Edit form (split layout).
  final _codeCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Map? _editing; // null = Add mode
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _fetchPincodes();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _codeCtrl.dispose();
    _areaCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    super.dispose();
  }

  // ── API ───────────────────────────────────────────────────
  Future<void> _fetchPincodes() async {
    setState(() => _loading = true);
    try {
      final res = await AdminApi.get(Uri.parse(ApiConstants.ADMIN_PINCODES));
      final data = jsonDecode(res.body);
      if (data['success'] == true && mounted) {
        setState(() => _pincodes = data['data'] ?? []);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggle(int id) async {
    try {
      await AdminApi.postJson(
        Uri.parse(ApiConstants.ADMIN_PINCODES_TOGGLE),
        body: {'id': id},
      );
      _fetchPincodes();
    } catch (_) {}
  }

  Future<void> _delete(int id) async {
    try {
      final res = await AdminApi.postJson(
        Uri.parse(ApiConstants.ADMIN_PINCODES_DELETE),
        body: {'id': id},
      );
      final data = jsonDecode(res.body);
      if (mounted) {
        _showSnack(data['message'] ?? 'Deleted');
        _fetchPincodes();
      }
    } catch (e) {
      if (mounted) _showSnack('Error: $e');
    }
  }

  // Loads a pincode into the right panel for editing (no dialog).
  void _startEdit(Map p) {
    setState(() {
      _editing = p;
      _codeCtrl.text = p['code']?.toString() ?? '';
      _areaCtrl.text = p['area_name']?.toString() ?? '';
      _cityCtrl.text = p['city']?.toString() ?? '';
      _stateCtrl.text = p['state']?.toString() ?? '';
    });
  }

  void _resetForm() {
    setState(() {
      _editing = null;
      _codeCtrl.clear();
      _areaCtrl.clear();
      _cityCtrl.clear();
      _stateCtrl.clear();
    });
  }

  // Add (no editing) or update (editing) — one right panel does both.
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final editing = _editing != null;
    setState(() => _saving = true);
    try {
      final body = {
        if (editing) 'id': _editing!['id'],
        'code':      _codeCtrl.text.trim(),
        'area_name': _areaCtrl.text.trim(),
        'city':      _cityCtrl.text.trim(),
        'state':     _stateCtrl.text.trim(),
      };
      final res = await AdminApi.postJson(
        Uri.parse(editing ? ApiConstants.ADMIN_PINCODES_EDIT : ApiConstants.ADMIN_PINCODES_ADD),
        body: body,
      );
      final data = jsonDecode(res.body);
      if (!mounted) return;
      _showSnack(data['message'] ?? 'Done');
      if (data['success'] == true || data['success'] == 'true') {
        _resetForm();
        _fetchPincodes();
      }
    } catch (e) {
      if (mounted) _showSnack('Error: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _buildForm() {
    final editing = _editing != null;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: AppColors.cardShadow,
      ),
      padding: EdgeInsets.all(18.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(editing ? 'Edit Pincode' : 'Add Pincode',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16.sp)),
            SizedBox(height: 16.h),
            _field(_codeCtrl, 'Pincode', required: true, readOnly: editing,
                keyboardType: TextInputType.number, maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
            SizedBox(height: 12.h),
            _field(_areaCtrl, 'Area Name', required: true),
            SizedBox(height: 12.h),
            _field(_cityCtrl, 'City'),
            SizedBox(height: 12.h),
            _field(_stateCtrl, 'State'),
            SizedBox(height: 18.h),
            Row(children: [
              Expanded(
                child: _saving
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                        onPressed: _save,
                        child: Text(editing ? 'Save' : 'Add',
                            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
              ),
              SizedBox(width: 10.w),
              OutlinedButton(
                onPressed: _resetForm,
                child: Text(editing ? 'Cancel' : 'Reset', style: GoogleFonts.poppins()),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  void _bulkAddDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Bulk Add Pincodes', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: SizedBox(
          width: 420.w,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'Paste one per line in format:\n  code,area_name,city,state',
              style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.secondaryTextColor),
            ),
            SizedBox(height: 10.h),
            TextField(
              controller: ctrl,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: '110001,Connaught Place,New Delhi,Delhi\n400001,Fort,Mumbai,Maharashtra',
                hintStyle: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.hintTextColor),
                border: const OutlineInputBorder(),
                contentPadding: EdgeInsets.all(10.w),
              ),
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
            onPressed: () async {
              Navigator.pop(context);
              final lines = ctrl.text.trim().split('\n');
              final pincodes = <Map>[];
              for (final line in lines) {
                final parts = line.split(',');
                if (parts.length < 2) continue;
                pincodes.add({
                  'code':      parts[0].trim(),
                  'area_name': parts[1].trim(),
                  'city':      parts.length > 2 ? parts[2].trim() : '',
                  'state':     parts.length > 3 ? parts[3].trim() : '',
                });
              }
              if (pincodes.isEmpty) return;
              try {
                final res = await AdminApi.postJson(
                  Uri.parse(ApiConstants.ADMIN_PINCODES_BULK),
                  body: {'pincodes': pincodes},
                );
                final data = jsonDecode(res.body);
                if (mounted) {
                  _showSnack('Added: ${data['added']}, Skipped: ${data['skipped']}');
                  _fetchPincodes();
                }
              } catch (e) {
                if (mounted) _showSnack('Error: $e');
              }
            },
            child: const Text('Import', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label,
      {bool required = false, bool readOnly = false,
       TextInputType keyboardType = TextInputType.text,
       int? maxLength, List<TextInputFormatter>? inputFormatters}) {
    return TextFormField(
      controller: ctrl,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        counterText: '',
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        filled: readOnly,
        fillColor: readOnly ? AppColors.backgroundColor : null,
      ),
      validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null,
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  List get _filtered {
    if (_search.isEmpty) return _pincodes;
    final q = _search.toLowerCase();
    return _pincodes.where((p) {
      return (p['code'] ?? '').toString().contains(q) ||
             (p['area_name'] ?? '').toString().toLowerCase().contains(q) ||
             (p['city'] ?? '').toString().toLowerCase().contains(q) ||
             (p['state'] ?? '').toString().toLowerCase().contains(q);
    }).toList();
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(children: [
        _buildHeader(),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(children: [
                  _buildSearchBar(),
                  Expanded(child: _buildList()),
                ]),
              ),
              const VerticalDivider(width: 1),
              SizedBox(
                width: 340.w,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(18.w),
                  child: _buildForm(),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildHeader() => Container(
        color: AppColors.surfaceColor,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Row(children: [
          const Icon(Icons.location_on_rounded, color: AppColors.primaryColor),
          SizedBox(width: 10.w),
          Text('Pincode Management',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18.sp)),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text('${_pincodes.length}',
                style: GoogleFonts.poppins(color: AppColors.primaryColor, fontSize: 12.sp, fontWeight: FontWeight.w600)),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: _bulkAddDialog,
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text('Bulk Add'),
          ),
          SizedBox(width: 8.w),
          IconButton(onPressed: _fetchPincodes, icon: const Icon(Icons.refresh_rounded)),
        ]),
      );

  Widget _buildSearchBar() => Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _search = v),
          decoration: InputDecoration(
            hintText: 'Search by code, area, city, state...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _search.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () { _searchCtrl.clear(); setState(() => _search = ''); },
                  )
                : null,
            filled: true,
            fillColor: AppColors.surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 12.h),
          ),
        ),
      );

  Widget _buildList() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final list = _filtered;
    if (list.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.location_off_outlined, size: 56.sp, color: AppColors.hintTextColor),
          SizedBox(height: 12.h),
          Text(_search.isNotEmpty ? 'No results for "$_search"' : 'No pincodes yet.',
              style: GoogleFonts.poppins(color: AppColors.secondaryTextColor)),
        ]),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
      itemCount: list.length,
      separatorBuilder: (_, __) => SizedBox(height: 6.h),
      itemBuilder: (_, i) => _pincodeRow(list[i]),
    );
  }

  Widget _pincodeRow(Map p) {
    final isActive = p['is_active'] == true;
    final vendorCount = p['vendor_count'] ?? 0;
    final selected = _editing != null && _editing!['id'] == p['id'];

    return Material(
      color: selected ? AppColors.primaryLight : AppColors.surfaceColor,
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryLight : AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.location_on_rounded,
              color: isActive ? AppColors.primaryColor : AppColors.hintTextColor,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(p['code'] ?? '',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14.sp)),
                SizedBox(width: 8.w),
                if (vendorCount > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text('$vendorCount vendor${vendorCount > 1 ? 's' : ''}',
                        style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.green[700], fontWeight: FontWeight.w600)),
                  ),
              ]),
              Text(
                [p['area_name'], p['city'], p['state']]
                    .where((s) => s != null && s.toString().isNotEmpty)
                    .join(', '),
                style: GoogleFonts.poppins(color: AppColors.secondaryTextColor, fontSize: 12.sp),
              ),
            ]),
          ),
          Switch(
            value: isActive,
            onChanged: (_) => _toggle(p['id']),
            activeColor: AppColors.primaryColor,
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: AppColors.primaryColor, size: 18.sp),
            tooltip: 'Edit',
            onPressed: () => _startEdit(p),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red, size: 18.sp),
            tooltip: 'Delete',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Delete ${p['code']}?',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  content: const Text('This will also remove it from vendors\' service areas.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () { Navigator.pop(context); _delete(p['id']); },
                      child: const Text('Delete', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          ),
        ]),
      ),
    );
  }
}
