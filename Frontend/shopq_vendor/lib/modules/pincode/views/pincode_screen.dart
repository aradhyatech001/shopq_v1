import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/vendor_widgets.dart';

class PincodeScreen extends StatefulWidget {
  const PincodeScreen({super.key});

  @override
  State<PincodeScreen> createState() => _PincodeScreenState();
}

class _PincodeScreenState extends State<PincodeScreen> {
  List _allPincodes     = [];
  Set<int> _selectedIds = {};
  bool _loading         = true;
  bool _saving          = false;
  String _search        = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final aRes  = await VendorApiHelper.get(ApiConstants.PINCODES_ALL);
      final aData = jsonDecode(aRes.body);
      if (aData['success'] == true) setState(() => _allPincodes = aData['data'] ?? []);

      final vRes  = await VendorApiHelper.get(ApiConstants.VENDOR_PINCODES);
      final vData = jsonDecode(vRes.body);
      if (vData['success'] == true) {
        final selected = vData['selected_pincodes'] as List? ?? [];
        setState(() => _selectedIds = selected
            .map((p) => int.tryParse('${p['id']}'))
            .whereType<int>()
            .toSet());
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final res  = await VendorApiHelper.postJson(ApiConstants.VENDOR_PINCODES_UPDATE, body: {'pincode_ids': _selectedIds.toList()});
      final data = jsonDecode(res.body);
      if (!mounted) return;
      final ok = data['success'] == true;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            ok ? (data['message'] ?? 'Saved') : (data['message'] ?? 'Failed to save'),
            style: GoogleFonts.jost()),
        backgroundColor: ok ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
      // Re-sync from the server so the UI reflects what actually persisted.
      if (ok) await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e', style: GoogleFonts.jost()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  List get _filtered {
    if (_search.isEmpty) return _allPincodes;
    final q = _search.toLowerCase();
    return _allPincodes.where((p) =>
        (p['code'] ?? '').toString().contains(q) ||
        (p['area_name'] ?? '').toString().toLowerCase().contains(q) ||
        (p['city'] ?? '').toString().toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return VendorPage(
      title: 'Service Areas',
      subtitle: '${_selectedIds.length} of ${_allPincodes.length} selected',
      actions: [
        FilledButton(
          onPressed: _saving ? null : _save,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.success,
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
          child: _saving
              ? SizedBox(width: 18.w, height: 18.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text('Save', style: GoogleFonts.jost(fontWeight: FontWeight.w600, color: Colors.white)),
        ),
      ],
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── Search ─────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search bar
                      TextField(
                        onChanged: (v) => setState(() => _search = v),
                        style: GoogleFonts.jost(fontSize: 14.sp),
                        decoration: InputDecoration(
                          hintText: 'Search by pincode or area...',
                          hintStyle: GoogleFonts.jost(
                              fontSize: 13.sp, color: AppColors.hint),
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: AppColors.hint),
                          filled: true,
                          fillColor: AppColors.surface,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: const BorderSide(
                                color: AppColors.borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: const BorderSide(
                                color: AppColors.borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 1.5),
                          ),
                        ),
                      ),     // TextField
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),

                // ── Pincode list ───────────────────────────────
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_off_rounded,
                                  size: 52.sp, color: AppColors.hint),
                              SizedBox(height: 12.h),
                              Text('No pincodes found',
                                  style: GoogleFonts.jost(
                                      color: AppColors.textSecondary,
                                      fontSize: 14.sp)),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 40.h),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => SizedBox(height: 6.h),
                          itemBuilder: (_, i) => _pincodeItem(filtered[i]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _pincodeItem(Map pincode) {
    final id       = pincode['id'] as int;
    final code     = pincode['code']?.toString() ?? '';
    final area     = pincode['area_name']?.toString() ?? '';
    final city     = pincode['city']?.toString() ?? '';
    final isActive = pincode['is_active'] == true;
    final selected = _selectedIds.contains(id);

    return GestureDetector(
      onTap: () {
        if (!isActive) return;
        setState(() {
          if (selected) {
            _selectedIds.remove(id);
          } else {
            _selectedIds.add(id);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.borderColor,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? Icon(Icons.check_rounded,
                      color: Colors.white, size: 14.sp)
                  : null,
            ),
            SizedBox(width: 14.w),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    code,
                    style: GoogleFonts.jost(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (area.isNotEmpty || city.isNotEmpty)
                    Text(
                      [if (area.isNotEmpty) area, if (city.isNotEmpty) city]
                          .join(', '),
                      style: GoogleFonts.jost(
                          fontSize: 12.sp, color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
            // Active badge
            if (!isActive)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  'INACTIVE',
                  style: GoogleFonts.jost(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
