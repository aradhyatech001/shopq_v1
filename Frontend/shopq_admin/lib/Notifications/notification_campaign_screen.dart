import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/admin_api.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';

/// Admin → Notifications: compose, schedule, send and track notification
/// campaigns. Talks to /admin/campaigns (Phase 3-5 backend).
class NotificationCampaignScreen extends StatefulWidget {
  const NotificationCampaignScreen({super.key});

  @override
  State<NotificationCampaignScreen> createState() =>
      _NotificationCampaignScreenState();
}

class _NotificationCampaignScreenState
    extends State<NotificationCampaignScreen> {
  List _campaigns = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await AdminApi.get(Uri.parse(ApiConstants.CAMPAIGNS));
      final data = jsonDecode(res.body);
      if (data['success'] == true) _campaigns = data['data'] ?? [];
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send(int id) async {
    await AdminApi.postJson(Uri.parse(ApiConstants.campaignSend(id)));
    _snack('Campaign queued for sending');
    _load();
  }

  Future<void> _cancel(int id) async {
    await AdminApi.postJson(Uri.parse(ApiConstants.campaignCancel(id)));
    _snack('Campaign cancelled');
    _load();
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(m), behavior: SnackBarBehavior.floating),
      );

  Future<void> _openForm([Map? existing]) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _CampaignFormDialog(existing: existing),
    );
    if (saved == true) _load();
  }

  Future<void> _duplicate(int id) async {
    await AdminApi.postJson(Uri.parse(ApiConstants.campaignDuplicate(id)));
    _snack('Campaign duplicated');
    _load();
  }

  Future<void> _delete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete campaign?', style: GoogleFonts.jost()),
        content: Text('This cannot be undone.', style: GoogleFonts.jost()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: GoogleFonts.jost())),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.errorColor),
              child: Text('Delete', style: GoogleFonts.jost(color: Colors.white))),
        ],
      ),
    );
    if (ok != true) return;
    await AdminApi.delete(Uri.parse(ApiConstants.campaignDelete(id)));
    _snack('Campaign deleted');
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Notifications',
                    style: GoogleFonts.jost(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryTextColor)),
                const Spacer(),
                IconButton(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh_rounded),
                    color: AppColors.secondaryTextColor),
                SizedBox(width: 8.w),
                FilledButton.icon(
                  onPressed: _openForm,
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryColor),
                  icon: const Icon(Icons.add),
                  label: Text('New Campaign', style: GoogleFonts.jost()),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text('Compose, schedule and track push campaigns',
                style: GoogleFonts.jost(
                    fontSize: 13.sp, color: AppColors.secondaryTextColor)),
            SizedBox(height: 16.h),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _campaigns.isEmpty
                      ? _empty()
                      : ListView.separated(
                          itemCount: _campaigns.length,
                          separatorBuilder: (_, __) => SizedBox(height: 10.h),
                          itemBuilder: (_, i) => _card(_campaigns[i] as Map),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.campaign_outlined,
                size: 60.sp, color: AppColors.hintTextColor),
            SizedBox(height: 12.h),
            Text('No campaigns yet',
                style: GoogleFonts.jost(
                    fontSize: 15.sp, color: AppColors.secondaryTextColor)),
          ],
        ),
      );

  Widget _card(Map c) {
    final status = c['status']?.toString() ?? '';
    final sent = (c['sent_count'] ?? 0) as int;
    final read = (c['read_count'] ?? 0) as int;
    final click = (c['click_count'] ?? 0) as int;
    final audience = (c['audience_count'] ?? 0) as int;
    final openRate = sent > 0 ? (read / sent * 100) : 0.0;
    final ctr = sent > 0 ? (click / sent * 100) : 0.0;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(c['title']?.toString() ?? '',
                    style: GoogleFonts.jost(
                        fontSize: 15.sp, fontWeight: FontWeight.w700)),
              ),
              _statusChip(status),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert,
                    size: 18.sp, color: AppColors.secondaryTextColor),
                onSelected: (v) {
                  final id = c['id'] as int;
                  if (v == 'edit') _openForm(c);
                  if (v == 'duplicate') _duplicate(id);
                  if (v == 'delete') _delete(id);
                },
                itemBuilder: (_) => [
                  if (status == 'draft' || status == 'scheduled')
                    PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit', style: GoogleFonts.jost())),
                  PopupMenuItem(
                      value: 'duplicate',
                      child: Text('Duplicate', style: GoogleFonts.jost())),
                  PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete',
                          style: GoogleFonts.jost(color: AppColors.errorColor))),
                ],
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            '${c['type']} · ${c['audience']}'
            '${c['recurrence'] != null ? ' · ${c['recurrence']}' : ''}',
            style: GoogleFonts.jost(
                fontSize: 11.sp, color: AppColors.secondaryTextColor),
          ),
          if ((c['body']?.toString() ?? '').isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(c['body'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.jost(
                    fontSize: 12.sp, color: AppColors.primaryTextColor)),
          ],
          SizedBox(height: 12.h),
          Wrap(
            spacing: 18.w,
            runSpacing: 8.h,
            children: [
              _metric('Audience', '$audience'),
              _metric('Sent', '$sent'),
              _metric('Read', '$read'),
              _metric('Clicks', '$click'),
              _metric('Open rate', '${openRate.toStringAsFixed(0)}%'),
              _metric('CTR', '${ctr.toStringAsFixed(0)}%'),
            ],
          ),
          if (status == 'draft' || status == 'scheduled') ...[
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (status == 'scheduled')
                  TextButton(
                      onPressed: () => _cancel(c['id'] as int),
                      child: Text('Cancel',
                          style: GoogleFonts.jost(color: AppColors.errorColor))),
                SizedBox(width: 8.w),
                FilledButton(
                  onPressed: () => _send(c['id'] as int),
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryColor),
                  child: Text('Send now', style: GoogleFonts.jost()),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _metric(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: GoogleFonts.jost(
                  fontSize: 15.sp, fontWeight: FontWeight.w700)),
          Text(label,
              style: GoogleFonts.jost(
                  fontSize: 10.sp, color: AppColors.secondaryTextColor)),
        ],
      );

  Widget _statusChip(String s) {
    final color = switch (s) {
      'sent' => AppColors.successColor,
      'sending' => AppColors.primaryColor,
      'scheduled' => AppColors.warningColor,
      'cancelled' => AppColors.errorColor,
      _ => AppColors.secondaryTextColor,
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(s.toUpperCase(),
          style: GoogleFonts.jost(
              fontSize: 10.sp, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Create / schedule form
// ─────────────────────────────────────────────────────────────────────────────
class _CampaignFormDialog extends StatefulWidget {
  final Map? existing;
  const _CampaignFormDialog({this.existing});

  @override
  State<_CampaignFormDialog> createState() => _CampaignFormDialogState();
}

class _CampaignFormDialogState extends State<_CampaignFormDialog> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _image = TextEditingController();
  final _deeplink = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _pincode = TextEditingController();
  final _userIds = TextEditingController();
  final _inactiveDays = TextEditingController();
  final _newDays = TextEditingController();

  String _type = 'general_announcement';
  String _audience = 'customers';
  String _deliveryMode = 'token'; // token | topic
  String _schedule = 'now'; // now | schedule
  String _recurrence = 'none';
  DateTime? _scheduledAt;
  bool _hasPending = false;
  bool _noOrders = false;

  int? _reach;
  bool _previewing = false;
  bool _saving = false;

  // "Link to" picker — choose a specific category / product type, etc.
  List _categories = [];
  List _productTypes = [];
  String _linkType = 'none'; // none|category|product_type|offers|deals
  int? _selCategoryId;
  String? _selProductType;

  /// Campaign types relevant to the chosen audience.
  List<String> get _typeOptions {
    switch (_audience) {
      case 'vendors':
        return const [
          'new_order', 'order_cancelled', 'settlement_update', 'new_review',
          'stock_warning', 'subscription_reminder', 'vendor_update',
          'general_announcement', 'custom',
        ];
      case 'delivery':
        return const [
          'new_assignment', 'pickup_reminder', 'delivery_reminder',
          'cod_reminder', 'route_update', 'delivery_update',
          'general_announcement', 'custom',
        ];
      default: // customers
        return const [
          'general_announcement', 'promotional_offer', 'coupon', 'flash_sale',
          'festival', 'app_update', 'maintenance', 'referral', 'custom',
        ];
    }
  }

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _loadPickers();
    _prefillFromExisting();
  }

  void _prefillFromExisting() {
    final e = widget.existing;
    if (e == null) return;
    _title.text = e['title']?.toString() ?? '';
    _body.text = e['body']?.toString() ?? '';
    _image.text = e['image']?.toString() ?? '';
    _type = e['type']?.toString() ?? _type;
    _audience = e['audience']?.toString() ?? _audience;
    _deliveryMode = e['delivery_mode']?.toString() ?? 'token';
    // Keep the type valid for the audience's option list.
    if (!_typeOptions.contains(_type)) _type = _typeOptions.first;

    final data = e['data'];
    if (data is Map && data['deeplink'] != null) {
      _deeplink.text = data['deeplink'].toString();
    }
    final crit = e['criteria'];
    if (crit is Map) {
      if (crit['user_ids'] is List) {
        _userIds.text = (crit['user_ids'] as List).join(',');
      }
      final geo = crit['geo'];
      if (geo is Map) {
        if (geo['city'] is List) _city.text = (geo['city'] as List).join(', ');
        if (geo['state'] is List) _state.text = (geo['state'] as List).join(', ');
        if (geo['pincode'] is List) {
          _pincode.text = (geo['pincode'] as List).join(', ');
        }
      }
      final beh = crit['behavior'];
      if (beh is Map) {
        _hasPending = beh['has_pending'] == true;
        _noOrders = beh['no_orders'] == true;
        if (beh['inactive_days'] != null) {
          _inactiveDays.text = '${beh['inactive_days']}';
        }
        if (beh['new_within_days'] != null) {
          _newDays.text = '${beh['new_within_days']}';
        }
      }
    }
  }

  Future<void> _loadPickers() async {
    try {
      final c = await AdminApi.get(Uri.parse(ApiConstants.MAIN_VIEW_CATEGORY));
      final cd = jsonDecode(c.body);
      _categories = cd is List ? cd : (cd['data'] ?? []);
    } catch (_) {}
    try {
      final t = await AdminApi.get(Uri.parse(ApiConstants.VIEW_PRODUCT_TYPES));
      final td = jsonDecode(t.body);
      if (td['success'] == true) _productTypes = td['data'] ?? [];
    } catch (_) {}
    if (mounted) setState(() {});
  }

  /// "Link to" targets available for the chosen audience — each app handles a
  /// different set of in-app destinations.
  List<String> get _linkTargets {
    switch (_audience) {
      case 'vendors':
        return const ['none', 'orders', 'payouts', 'products'];
      case 'delivery':
        return const ['none', 'orders'];
      default: // customers
        return const ['none', 'category', 'product_type', 'offers', 'deals'];
    }
  }

  /// Build the deep link from the chosen "Link to" target.
  void _applyLink() {
    switch (_linkType) {
      case 'category':
        _deeplink.text =
            _selCategoryId != null ? 'shopq://category/$_selCategoryId' : '';
        break;
      case 'product_type':
        _deeplink.text = _selProductType != null
            ? 'shopq://product_type/${Uri.encodeComponent(_selProductType!)}'
            : '';
        break;
      case 'offers':
        _deeplink.text = 'shopq://offers';
        break;
      case 'deals':
        _deeplink.text = 'shopq://deals';
        break;
      // Vendor / delivery destinations.
      case 'orders':
        _deeplink.text = 'shopq://orders';
        break;
      case 'payouts':
        _deeplink.text = 'shopq://payouts';
        break;
      case 'products':
        _deeplink.text = 'shopq://products';
        break;
      default:
        break; // 'none' → leave the manual deep link as-is
    }
  }

  /// One-tap presets for the most common campaigns ("fast send").
  void _applyTemplate(String key) {
    setState(() {
      switch (key) {
        case 'special_offer':
          _type = 'promotional_offer';
          _title.text = 'Special offer just for you! 🎉';
          _body.text = "Exclusive deals are live — grab them before they're gone.";
          _deeplink.text = 'shopq://offers';
          break;
        case 'new_products':
          _type = 'general_announcement';
          _title.text = 'New arrivals are here! 🆕';
          _body.text = 'Fresh products just added. Be the first to check them out.';
          _deeplink.text = 'shopq://products';
          break;
        case 'discount':
          _type = 'flash_sale';
          _title.text = 'Big discounts live! 💥';
          _body.text = 'Up to 50% OFF on selected products. Limited time only.';
          _deeplink.text = 'shopq://deals';
          break;
      }
    });
  }

  List<String> _csv(String s) =>
      s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  Map<String, dynamic> _criteria() {
    final geo = <String, dynamic>{};
    if (_city.text.trim().isNotEmpty) geo['city'] = _csv(_city.text);
    if (_state.text.trim().isNotEmpty) geo['state'] = _csv(_state.text);
    if (_pincode.text.trim().isNotEmpty) geo['pincode'] = _csv(_pincode.text);

    final behavior = <String, dynamic>{};
    if (_hasPending) behavior['has_pending'] = true;
    if (_noOrders) behavior['no_orders'] = true;
    if (_inactiveDays.text.trim().isNotEmpty) {
      behavior['inactive_days'] = int.tryParse(_inactiveDays.text.trim());
    }
    if (_newDays.text.trim().isNotEmpty) {
      behavior['new_within_days'] = int.tryParse(_newDays.text.trim());
    }
    return {
      if (_userIds.text.trim().isNotEmpty)
        'user_ids': _csv(_userIds.text)
            .map(int.tryParse)
            .whereType<int>()
            .toList(),
      if (geo.isNotEmpty) 'geo': geo,
      if (behavior.isNotEmpty) 'behavior': behavior,
    };
  }

  Future<void> _preview() async {
    setState(() => _previewing = true);
    try {
      final res = await AdminApi.postJson(
        Uri.parse(ApiConstants.CAMPAIGN_PREVIEW),
        body: {'audience': _audience, 'criteria': _criteria()},
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true) _reach = data['reach'] as int;
    } catch (_) {
    } finally {
      if (mounted) setState(() => _previewing = false);
    }
  }

  Future<void> _submit({required bool sendNow}) async {
    if (_title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Title is required')));
      return;
    }
    setState(() => _saving = true);
    try {
      final data = <String, dynamic>{};
      if (_deeplink.text.trim().isNotEmpty) data['deeplink'] = _deeplink.text.trim();

      final action = sendNow
          ? 'send'
          : (_schedule == 'schedule' ? 'schedule' : 'draft');

      final body = {
        'type': _type,
        'audience': _audience,
        'delivery_mode': _deliveryMode,
        'title': _title.text.trim(),
        'body': _body.text.trim(),
        if (_image.text.trim().isNotEmpty) 'image': _image.text.trim(),
        if (data.isNotEmpty) 'data': data,
        'criteria': _criteria(),
        'action': action,
        if (_schedule == 'schedule' && _scheduledAt != null)
          'scheduled_at': _scheduledAt!.toUtc().toIso8601String(),
        if (_schedule == 'schedule' && _recurrence != 'none')
          'recurrence': _recurrence,
      };

      final url = _isEdit
          ? ApiConstants.campaignUpdate(widget.existing!['id'] as int)
          : ApiConstants.CAMPAIGNS;
      final res = await AdminApi.postJson(Uri.parse(url), body: body);
      final r = jsonDecode(res.body);
      if (!mounted) return;
      if (r['success'] == true) {
        // Editing then "Send now" → update first, then dispatch.
        if (_isEdit && sendNow) {
          await AdminApi.postJson(
              Uri.parse(ApiConstants.campaignSend(widget.existing!['id'] as int)));
        }
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(r['message']?.toString() ?? 'Failed')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickSchedule() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(
        context: context, initialTime: TimeOfDay.now());
    if (t == null) return;
    setState(() => _scheduledAt =
        DateTime(d.year, d.month, d.day, t.hour, t.minute));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 560.w, maxHeight: 640.h),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_isEdit ? 'Edit Campaign' : 'New Campaign',
                  style: GoogleFonts.jost(
                      fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 12.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_audience == 'customers') ...[
                        Text('Quick templates',
                            style: GoogleFonts.jost(
                                fontSize: 12.sp, fontWeight: FontWeight.w700)),
                        SizedBox(height: 6.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 6.h,
                          children: [
                            ActionChip(
                                avatar: const Icon(Icons.local_offer_rounded, size: 16),
                                label: const Text('Special Offer'),
                                onPressed: () => _applyTemplate('special_offer')),
                            ActionChip(
                                avatar: const Icon(Icons.fiber_new_rounded, size: 16),
                                label: const Text('New Products'),
                                onPressed: () => _applyTemplate('new_products')),
                            ActionChip(
                                avatar: const Icon(Icons.percent_rounded, size: 16),
                                label: const Text('Discount Products'),
                                onPressed: () => _applyTemplate('discount')),
                          ],
                        ),
                        SizedBox(height: 8.h),
                      ],
                      Row(children: [
                        Expanded(child: _dropdown('Type', _type, _typeOptions,
                            (v) => setState(() => _type = v!))),
                        SizedBox(width: 12.w),
                        Expanded(child: _dropdown('Audience', _audience,
                            const ['customers', 'vendors', 'delivery'],
                            (v) => setState(() {
                                  _audience = v!;
                                  _reach = null;
                                  // Type list differs per audience — reset it.
                                  _type = _typeOptions.first;
                                  // Reset link state — targets differ per app.
                                  _linkType = 'none';
                                  _selCategoryId = null;
                                  _selProductType = null;
                                  _deeplink.clear();
                                }))),
                      ]),
                      SizedBox(height: 8.h),
                      Row(children: [
                        Text('Delivery: ',
                            style: GoogleFonts.jost(
                                fontSize: 12.sp, fontWeight: FontWeight.w600)),
                        ChoiceChip(
                            label: const Text('Token (inbox+analytics)'),
                            selected: _deliveryMode == 'token',
                            onSelected: (_) =>
                                setState(() => _deliveryMode = 'token')),
                        SizedBox(width: 8.w),
                        ChoiceChip(
                            label: const Text('Topic (broadcast)'),
                            selected: _deliveryMode == 'topic',
                            onSelected: (_) =>
                                setState(() => _deliveryMode = 'topic')),
                      ]),
                      if (_deliveryMode == 'topic')
                        Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            'Topic mode broadcasts to all_${_audience} (or pincode_<code> if pincodes set). Fast, but no per-user inbox/analytics.',
                            style: GoogleFonts.jost(
                                fontSize: 10.sp,
                                color: AppColors.secondaryTextColor),
                          ),
                        ),
                      _field('Title', _title),
                      _field('Body', _body, maxLines: 2),
                      _field('Image URL (optional)', _image),
                      SizedBox(height: 8.h),
                      Text('Link to (sets the deep link)',
                          style: GoogleFonts.jost(
                              fontSize: 12.sp, fontWeight: FontWeight.w700)),
                      Row(children: [
                        Expanded(
                          child: _dropdown(
                              'Target',
                              _linkType,
                              _linkTargets, (v) {
                            setState(() => _linkType = v ?? 'none');
                            _applyLink();
                          }),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(child: _linkSecondary()),
                      ]),
                      _field('Deep link (auto-filled, editable)', _deeplink),
                      _field('User IDs — single or comma-separated (optional)',
                          _userIds, number: false),
                      if (_audience == 'customers') ...[
                        SizedBox(height: 8.h),
                        Text('Audience filter (optional)',
                            style: GoogleFonts.jost(
                                fontWeight: FontWeight.w700, fontSize: 12.sp)),
                        _field('Pincode (comma sep)', _pincode),
                        Row(children: [
                          Expanded(child: _field('City (comma sep)', _city)),
                          SizedBox(width: 12.w),
                          Expanded(child: _field('State (comma sep)', _state)),
                        ]),
                        Row(children: [
                          Expanded(
                              child: _field('Inactive ≥ days', _inactiveDays,
                                  number: true)),
                          SizedBox(width: 12.w),
                          Expanded(
                              child: _field('New ≤ days', _newDays,
                                  number: true)),
                        ]),
                        CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          value: _hasPending,
                          onChanged: (v) => setState(() => _hasPending = v ?? false),
                          title: Text('Has pending orders',
                              style: GoogleFonts.jost(fontSize: 12.sp)),
                        ),
                        CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          value: _noOrders,
                          onChanged: (v) => setState(() => _noOrders = v ?? false),
                          title: Text('Never ordered',
                              style: GoogleFonts.jost(fontSize: 12.sp)),
                        ),
                      ],
                      SizedBox(height: 8.h),
                      Row(children: [
                        ChoiceChip(
                            label: const Text('Send now'),
                            selected: _schedule == 'now',
                            onSelected: (_) => setState(() => _schedule = 'now')),
                        SizedBox(width: 8.w),
                        ChoiceChip(
                            label: const Text('Schedule'),
                            selected: _schedule == 'schedule',
                            onSelected: (_) =>
                                setState(() => _schedule = 'schedule')),
                      ]),
                      if (_schedule == 'schedule') ...[
                        SizedBox(height: 8.h),
                        Row(children: [
                          OutlinedButton.icon(
                            onPressed: _pickSchedule,
                            icon: const Icon(Icons.event),
                            label: Text(
                                _scheduledAt == null
                                    ? 'Pick date & time'
                                    : _scheduledAt.toString().substring(0, 16),
                                style: GoogleFonts.jost()),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                              child: _dropdown('Repeat', _recurrence,
                                  const ['none', 'daily', 'weekly', 'monthly'],
                                  (v) => setState(() => _recurrence = v!))),
                        ]),
                      ],
                      SizedBox(height: 10.h),
                      Row(children: [
                        OutlinedButton.icon(
                          onPressed: _previewing ? null : _preview,
                          icon: _previewing
                              ? SizedBox(
                                  width: 14.w,
                                  height: 14.w,
                                  child: const CircularProgressIndicator(
                                      strokeWidth: 2))
                              : const Icon(Icons.groups_outlined),
                          label: Text('Preview reach', style: GoogleFonts.jost()),
                        ),
                        SizedBox(width: 12.w),
                        if (_reach != null)
                          Text('≈ $_reach recipients',
                              style: GoogleFonts.jost(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryColor)),
                      ]),
                    ],
                  ),
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel', style: GoogleFonts.jost())),
                  TextButton(
                      onPressed: _saving ? null : () => _submit(sendNow: false),
                      child: Text('Save draft', style: GoogleFonts.jost())),
                  SizedBox(width: 8.w),
                  FilledButton(
                    onPressed: _saving ? null : () => _submit(sendNow: _schedule == 'now'),
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryColor),
                    child: Text(
                        _schedule == 'now' ? 'Send now' : 'Schedule',
                        style: GoogleFonts.jost(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c,
          {int maxLines = 1, bool number = false}) =>
      Padding(
        padding: EdgeInsets.only(top: 8.h),
        child: TextField(
          controller: c,
          maxLines: maxLines,
          keyboardType: number ? TextInputType.number : null,
          style: GoogleFonts.jost(fontSize: 13.sp),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.jost(fontSize: 12.sp),
            isDense: true,
            border: const OutlineInputBorder(),
          ),
        ),
      );

  /// The second control for the "Link to" picker — depends on the target.
  Widget _linkSecondary() {
    switch (_linkType) {
      case 'category':
        return _pickerDropdown<int>(
          'Category',
          _selCategoryId,
          _categories
              .map<DropdownMenuItem<int>>((c) => DropdownMenuItem(
                    value: c['id'] is int ? c['id'] : int.tryParse('${c['id']}'),
                    child: Text('${c['name']}',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.jost(fontSize: 13.sp)),
                  ))
              .toList(),
          (v) {
            setState(() => _selCategoryId = v);
            _applyLink();
          },
        );
      case 'product_type':
        return _pickerDropdown<String>(
          'Product type',
          _selProductType,
          _productTypes
              .map<DropdownMenuItem<String>>((t) => DropdownMenuItem(
                    value: t['name']?.toString(),
                    child: Text('${t['name']}',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.jost(fontSize: 13.sp)),
                  ))
              .toList(),
          (v) {
            setState(() => _selProductType = v);
            _applyLink();
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _pickerDropdown<T>(String label, T? value,
          List<DropdownMenuItem<T>> items, ValueChanged<T?> onChanged) =>
      Padding(
        padding: EdgeInsets.only(top: 8.h),
        child: DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.jost(fontSize: 12.sp),
            isDense: true,
            border: const OutlineInputBorder(),
          ),
          items: items,
          onChanged: onChanged,
        ),
      );

  Widget _dropdown(String label, String value, List<String> items,
          ValueChanged<String?> onChanged) =>
      Padding(
        padding: EdgeInsets.only(top: 8.h),
        child: DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.jost(fontSize: 12.sp),
            isDense: true,
            border: const OutlineInputBorder(),
          ),
          items: items
              .map((t) => DropdownMenuItem(
                  value: t,
                  child: Text(t, style: GoogleFonts.jost(fontSize: 13.sp))))
              .toList(),
          onChanged: onChanged,
        ),
      );
}
