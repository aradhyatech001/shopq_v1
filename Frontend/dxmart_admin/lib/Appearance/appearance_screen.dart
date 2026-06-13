import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/admin_api.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';

/// Admin screen to manage the user-app appearance (theme colors + texts).
/// Reads/writes /app-config — the user app picks these up on next launch.
class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _Field {
  final String key;
  final String label;
  final bool isColor;
  final TextEditingController ctrl = TextEditingController();
  _Field(this.key, this.label, {this.isColor = false});
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  bool _loading = true;
  bool _saving = false;

  final List<_Field> _fields = [
    _Field('primary_color', 'Primary Color', isColor: true),
    _Field('secondary_color', 'Secondary Color', isColor: true),
    _Field('app_name', 'App Name'),
    _Field('delivery_time_text', 'Delivery Time Text'),
    _Field('free_delivery_text', 'Free Delivery Text'),
    _Field('search_hint', 'Search Bar Hint'),
    _Field('assurance_1', 'Assurance 1'),
    _Field('assurance_2', 'Assurance 2'),
    _Field('assurance_3', 'Assurance 3'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final f in _fields) f.ctrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await AdminApi.get(Uri.parse(ApiConstants.APP_CONFIG_GET));
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['config'] is Map) {
        final cfg = Map<String, dynamic>.from(data['config']);
        for (final f in _fields) {
          f.ctrl.text = '${cfg[f.key] ?? ''}';
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final body = {for (final f in _fields) f.key: f.ctrl.text.trim()};
      final res = await AdminApi.postJson(Uri.parse(ApiConstants.APP_CONFIG_UPDATE), body: body);
      final data = jsonDecode(res.body);
      if (!mounted) return;
      final ok = data['success'] == true;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Appearance saved' : (data['message'] ?? 'Failed'),
            style: GoogleFonts.jost()),
        backgroundColor: ok ? AppColors.successColor : AppColors.errorColor,
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e', style: GoogleFonts.jost()),
          backgroundColor: AppColors.errorColor,
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Color? _parseHex(String hex) {
    var h = hex.trim().replaceFirst('#', '');
    if (h.length == 6) h = 'FF$h';
    if (h.length != 8) return null;
    final v = int.tryParse(h, radix: 16);
    return v == null ? null : Color(v);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User App Appearance',
                          style: GoogleFonts.jost(
                              fontSize: 24.sp, fontWeight: FontWeight.w800)),
                      SizedBox(height: 4.h),
                      Text('Controls the colors and texts of the customer app. '
                          'Changes apply when the app is next opened.',
                          style: GoogleFonts.jost(
                              fontSize: 13.sp, color: AppColors.secondaryTextColor)),
                      SizedBox(height: 24.h),
                      ..._fields.map(_buildField),
                      SizedBox(height: 24.h),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _saving ? null : _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r)),
                          ),
                          child: _saving
                              ? SizedBox(
                                  width: 20.w, height: 20.w,
                                  child: const CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : Text('Save Appearance',
                                  style: GoogleFonts.jost(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15.sp,
                                      color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildField(_Field f) {
    final preview = f.isColor ? _parseHex(f.ctrl.text) : null;
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(f.label,
              style: GoogleFonts.jost(
                  fontSize: 13.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 6.h),
          Row(
            children: [
              if (f.isColor) ...[
                Container(
                  width: 40.w, height: 40.w,
                  decoration: BoxDecoration(
                    color: preview ?? AppColors.borderColor,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                ),
                SizedBox(width: 10.w),
              ],
              Expanded(
                child: TextField(
                  controller: f.ctrl,
                  onChanged: f.isColor ? (_) => setState(() {}) : null,
                  style: GoogleFonts.jost(fontSize: 14.sp),
                  decoration: InputDecoration(
                    hintText: f.isColor ? '#RRGGBB' : null,
                    hintStyle: GoogleFonts.jost(color: AppColors.hintTextColor),
                    filled: true,
                    fillColor: AppColors.surfaceColor,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: const BorderSide(color: AppColors.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: const BorderSide(color: AppColors.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide:
                          BorderSide(color: AppColors.primaryColor, width: 1.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
