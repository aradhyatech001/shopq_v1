import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../CustomWidgets/admin_widgets.dart';
import '../utils/admin_api.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';

// ── Setting item model ────────────────────────────────────────────────────────
class _SettingItem {
  final String label;
  final IconData icon;
  final Color color;
  final String getUrl;
  final String postUrl;
  final String responseKey; // key inside data{}
  final String postKey; // key to POST with
  final String prefix; // e.g. '₹' or ''

  const _SettingItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.getUrl,
    required this.postUrl,
    required this.responseKey,
    required this.postKey,
    this.prefix = '',
  });
}

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  // ── All setting items ─────────────────────────────────────
  static final List<_SettingItem> _items = [
    _SettingItem(
      label: 'Delivery Time',
      icon: Icons.access_time_rounded,
      color: AppColors.cardBlue,
      getUrl: ApiConstants.FETCH_DELIVERY_TIME,
      postUrl: ApiConstants.UPDATE_DELIVERY_TIME,
      responseKey: 'time',
      postKey: 'time',
    ),
    _SettingItem(
      label: 'Delivery Charge',
      icon: Icons.local_shipping_rounded,
      color: AppColors.cardPurple,
      getUrl: ApiConstants.FETCH_DELIVERY_AMOUNT,
      postUrl: ApiConstants.UPDATE_DELIVERY_AMOUNT,
      responseKey: 'amount',
      postKey: 'amount',
      prefix: '₹',
    ),
    _SettingItem(
      label: 'Free Delivery Above',
      icon: Icons.delivery_dining_rounded,
      color: AppColors.cardGreen,
      getUrl: ApiConstants.GET_FREE_DELIVERY_AMOUNT,
      postUrl: ApiConstants.UPDATE_FREE_DELIVERY_AMOUNT,
      responseKey: 'amount',
      postKey: 'amount',
      prefix: '₹',
    ),
    _SettingItem(
      label: 'Min Order Amount',
      icon: Icons.shopping_cart_rounded,
      color: AppColors.cardOrange,
      getUrl: ApiConstants.GET_MINIMUM_ORDER_AMOUT,
      postUrl: ApiConstants.UPDATE_MINIMUM_ORDER_AMOUT,
      responseKey: 'amount',
      postKey: 'amount',
      prefix: '₹',
    ),
    _SettingItem(
      label: 'Handling Charge',
      icon: Icons.inventory_2_rounded,
      color: AppColors.cardRed,
      getUrl: ApiConstants.GET_HANDLING_CHARGE,
      postUrl: ApiConstants.UPDATE_HANDLING_CHARGE,
      responseKey: 'amount',
      postKey: 'amount',
      prefix: '₹',
    ),
    _SettingItem(
      label: 'Calling Number',
      icon: Icons.phone_rounded,
      color: AppColors.cardTeal,
      getUrl: ApiConstants.GET_CALLING_NUMBER,
      postUrl: ApiConstants.UPDATE_CALLING_NUMBER,
      responseKey: 'call_help',
      postKey: 'call_help',
    ),
    _SettingItem(
      label: 'WhatsApp Number',
      icon: Icons.chat_rounded,
      color: AppColors.cardGreen,
      getUrl: ApiConstants.GET_WHATSAPP_NUMBER,
      postUrl: ApiConstants.UPDATE_WHATSAPP_NUMBER,
      responseKey: 'whatsapp_no',
      postKey: 'whatsapp_no',
    ),
    _SettingItem(
      label: 'Support Email',
      icon: Icons.email_rounded,
      color: AppColors.cardBlue,
      getUrl: ApiConstants.GET_EMAIL,
      postUrl: ApiConstants.UPDATE_EMAIL,
      responseKey: 'email',
      postKey: 'email',
    ),
  ];

  // ── State: value per item ─────────────────────────────────
  final Map<int, String> _values = {};
  final Map<int, bool> _updating = {};
  bool _loadingAll = true;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() => _loadingAll = true);
    await Future.wait(List.generate(_items.length, (i) => _fetchOne(i)));
    if (mounted) setState(() => _loadingAll = false);
  }

  Future<void> _fetchOne(int idx) async {
    try {
      final res = await AdminApi.get(Uri.parse(_items[idx].getUrl));
      final data = jsonDecode(res.body);
      if (data['success'] == true && mounted) {
        setState(
          () => _values[idx] =
              data['data'][_items[idx].responseKey]?.toString() ?? '—',
        );
      }
    } catch (_) {
      if (mounted) setState(() => _values[idx] = 'Error');
    }
  }

  Future<void> _update(int idx, String newVal) async {
    if (newVal.isEmpty) return;
    setState(() => _updating[idx] = true);
    try {
      final res = await AdminApi.post(
        Uri.parse(_items[idx].postUrl),
        body: {_items[idx].postKey: newVal},
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        setState(() => _values[idx] = newVal);
        _snack('${_items[idx].label} updated', AppColors.successColor);
      } else {
        _snack(data['message'] ?? 'Failed', AppColors.errorColor);
      }
    } catch (_) {
      _snack('Update failed', AppColors.errorColor);
    } finally {
      if (mounted) setState(() => _updating[idx] = false);
    }
  }

  void _showEditDialog(int idx) {
    final ctrl = TextEditingController(text: _values[idx] ?? '');
    final item = _items[idx];

    // Choose keyboard + limits based on what the setting holds.
    final isPhone  = item.label.toLowerCase().contains('number');
    final isAmount = item.prefix == '₹';
    final isEmail  = item.label.toLowerCase().contains('email');

    TextInputType keyboardType = TextInputType.text;
    List<TextInputFormatter>? formatters;
    int? maxLength;
    if (isPhone) {
      keyboardType = TextInputType.phone;
      formatters = [FilteringTextInputFormatter.digitsOnly];
      maxLength = 10;
    } else if (isAmount) {
      keyboardType = const TextInputType.numberWithOptions(decimal: true);
      formatters = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))];
    } else if (isEmail) {
      keyboardType = TextInputType.emailAddress;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Edit ${item.label}',
          style: GoogleFonts.jost(fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: keyboardType,
          inputFormatters: formatters,
          maxLength: maxLength,
          style: GoogleFonts.jost(fontSize: 14.sp),
          decoration: InputDecoration(
            counterText: '',
            hintText: 'Enter new value',
            prefixText: item.prefix.isNotEmpty ? item.prefix : null,
          ),
          onSubmitted: (v) {
            Navigator.pop(context);
            _update(idx, v.trim());
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.jost()),
          ),
          ElevatedButton(
            onPressed: () {
              final v = ctrl.text.trim();
              Navigator.pop(context);
              _update(idx, v);
            },
            child: Text('Save', style: GoogleFonts.jost(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.jost(color: Colors.white)),
        backgroundColor: color,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AdminPageShell(
      title: 'Settings',
      subtitle: 'App configuration',
      actions: [
        IconButton(
          onPressed: _fetchAll,
          icon: Icon(
            Icons.refresh_rounded,
            color: AppColors.secondaryTextColor,
            size: 20.sp,
          ),
        ),
      ],
      child: _loadingAll
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: LayoutBuilder(
                builder: (_, c) {
                  final cols = c.maxWidth > 800 ? 2 : 1;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _items.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                      childAspectRatio: cols == 2 ? 3.5 : 4.5,
                    ),
                    itemBuilder: (_, i) => _SettingTile(
                      item: _items[i],
                      value: _values[i] ?? '…',
                      isUpdating: _updating[i] == true,
                      onEdit: () => _showEditDialog(i),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// ── Setting tile ──────────────────────────────────────────────────────────────
class _SettingTile extends StatelessWidget {
  final _SettingItem item;
  final String value;
  final bool isUpdating;
  final VoidCallback onEdit;

  const _SettingTile({
    required this.item,
    required this.value,
    required this.isUpdating,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(item.icon, color: item.color, size: 20.sp),
          ),
          SizedBox(width: 14.w),

          // Label + value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.label,
                  style: GoogleFonts.jost(
                    fontSize: 11.sp,
                    color: AppColors.secondaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  '${item.prefix}$value',
                  style: GoogleFonts.jost(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Edit button
          if (isUpdating)
            SizedBox(
              width: 20.w,
              height: 20.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: item.color,
              ),
            )
          else
            IconButton(
              icon: Icon(
                Icons.edit_rounded,
                color: AppColors.primaryColor,
                size: 18.sp,
              ),
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
        ],
      ),
    );
  }
}