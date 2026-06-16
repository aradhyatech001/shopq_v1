import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../CustomWidgets/admin_widgets.dart';
import 'section_builder_screen.dart';
import '../utils/admin_api.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';

class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({super.key});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  List<Map<String, dynamic>> _tabs = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> _iconOptions = [
    {'key': 'all', 'icon': Icons.shopping_bag_outlined, 'label': 'All'},
    {'key': 'grid', 'icon': Icons.grid_view_rounded, 'label': 'Grid'},
    {'key': 'leaf', 'icon': Icons.eco_outlined, 'label': 'Leaf'},
    {'key': 'tractor', 'icon': Icons.agriculture_outlined, 'label': 'Farm'},
    {'key': 'apple', 'icon': Icons.local_florist_outlined, 'label': 'Fresh'},
    {
      'key': 'flame',
      'icon': Icons.local_fire_department_outlined,
      'label': 'Hot',
    },
    {'key': 'soap', 'icon': Icons.soap_outlined, 'label': 'Care'},
    {'key': 'rice', 'icon': Icons.grain_outlined, 'label': 'Grain'},
    {'key': 'snack', 'icon': Icons.cookie_outlined, 'label': 'Snack'},
    {'key': 'beverage', 'icon': Icons.local_drink_outlined, 'label': 'Drink'},
    {'key': 'dairy', 'icon': Icons.breakfast_dining_outlined, 'label': 'Dairy'},
    {'key': 'bakery', 'icon': Icons.bakery_dining_outlined, 'label': 'Bakery'},
    {
      'key': 'personal',
      'icon': Icons.face_retouching_natural_outlined,
      'label': 'Beauty',
    },
    {
      'key': 'cleaning',
      'icon': Icons.cleaning_services_outlined,
      'label': 'Clean',
    },
    {'key': 'baby', 'icon': Icons.child_care_outlined, 'label': 'Baby'},
    {'key': 'pet', 'icon': Icons.pets_outlined, 'label': 'Pet'},
    {'key': 'deals', 'icon': Icons.local_offer_outlined, 'label': 'Deals'},
    {'key': 'summer', 'icon': Icons.wb_sunny_outlined, 'label': 'Summer'},
  ];

  final List<Map<String, String>> _colorOptions = [
    {'label': 'Purple', 'hex': '#6C63FF'},
    {'label': 'Pink', 'hex': '#FF6584'},
    {'label': 'Orange', 'hex': '#FF8C42'},
    {'label': 'Green', 'hex': '#2DB87B'},
    {'label': 'Blue', 'hex': '#1E90FF'},
    {'label': 'Teal', 'hex': '#00B4D8'},
    {'label': 'Red', 'hex': '#E63946'},
    {'label': 'Amber', 'hex': '#F4A261'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([_fetchTabs(), _fetchCategories()]);
    setState(() => _isLoading = false);
  }

  Future<void> _fetchTabs() async {
    try {
      final res = await AdminApi.get(Uri.parse(ApiConstants.HOME_TABS_ALL));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true) {
          setState(() => _tabs = List<Map<String, dynamic>>.from(data['data']));
        }
      }
    } catch (e) {
      debugPrint('Error fetching tabs: $e');
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final res = await AdminApi.get(
        Uri.parse(ApiConstants.MAIN_VIEW_CATEGORY),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is List) {
          setState(() => _categories = List<Map<String, dynamic>>.from(data));
        }
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> _toggleTab(Map<String, dynamic> tab) async {
    try {
      final res = await AdminApi.post(
        Uri.parse(ApiConstants.HOME_TABS_TOGGLE),
        body: {'id': tab['id'].toString()},
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true) _fetchTabs();
    } catch (e) {
      debugPrint('Toggle error: $e');
    }
  }

  Future<void> _deleteTab(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Delete Tab',
          style: GoogleFonts.jost(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete this tab?',
          style: GoogleFonts.jost(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.jost()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: GoogleFonts.jost(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final res = await AdminApi.post(
        Uri.parse(ApiConstants.HOME_TABS_DELETE),
        body: {'id': id.toString()},
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        _fetchTabs();
        if (mounted) _showSnack('Tab deleted');
      }
    } catch (e) {
      debugPrint('Delete error: $e');
    }
  }

  void _showSnack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.jost(color: Colors.white)),
        backgroundColor: error ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  IconData _iconFor(String key) {
    return _iconOptions.firstWhere(
          (o) => o['key'] == key,
          orElse: () => _iconOptions[0],
        )['icon']
        as IconData;
  }

  Color _colorFor(String hex) {
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return AppColors.primaryColor;
    }
  }

  // ─── Add / Edit dialog ───────────────────────────────
  void _showTabDialog({Map<String, dynamic>? existing}) {
    final nameCtrl = TextEditingController(text: existing?['name'] ?? '');
    String selectedIcon = existing?['icon'] ?? 'all';
    // Tab types: all (full home), category (main category + subcategories),
    // none (themed/section-only tab e.g. Rice, Ramazan, Fresh). Coerce any
    // legacy values (categories/deals) to a valid option.
    String selectedType = existing?['type'] ?? 'all';
    if (!['all', 'category', 'none'].contains(selectedType)) {
      selectedType = selectedType == 'category' ? 'category' : 'none';
    }
    String selectedColor = existing?['bg_color'] ?? '#6C63FF';
    int? selectedCatId = existing?['category_id'] != null
        ? int.tryParse(existing!['category_id'].toString())
        : null;
    final posCtrl = TextEditingController(
      text: (existing?['position'] ?? _tabs.length).toString(),
    );

    // Banner image state
    Uint8List? bannerBytes;
    String? existingBannerUrl = existing?['banner_image']?.toString();
    bool removeBanner = false;
    bool isSaving = false;

    // Optional uploaded icon (image or .svg). Falls back to the named icon.
    Uint8List? iconBytes;
    String? iconFileName;
    String? existingIconUrl = existing?['icon_image']?.toString();
    bool removeIconImage = false;

    showAdminSideSheet(
      context,
      barrierDismissible: false,
      width: 480,
      child: StatefulBuilder(
        builder: (ctx, setS) => AdminSideSheet(
          title: existing == null ? 'Add Tab' : 'Edit Tab',
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Name ────────────────────────────────
                Text(
                  'Tab Name',
                  style: GoogleFonts.jost(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 6.h),
                TextField(
                  controller: nameCtrl,
                  style: GoogleFonts.jost(),
                  decoration: InputDecoration(
                    hintText: 'e.g. Rice, Fresh, Deals',
                    hintStyle: GoogleFonts.jost(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                  ),
                ),
                SizedBox(height: 14.h),

                // ── Type ────────────────────────────────
                Text(
                  'Type',
                  style: GoogleFonts.jost(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 6.h),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  style: GoogleFonts.jost(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text('All — full home feed'),
                    ),
                    DropdownMenuItem(
                      value: 'category',
                      child: Text('Category'),
                    ),
                    DropdownMenuItem(
                      value: 'none',
                      child: Text('None — themed tab'),
                    ),
                  ],
                  onChanged: (v) => setS(() => selectedType = v!),
                ),
                if (selectedType == 'category') ...[
                  SizedBox(height: 14.h),
                  Text(
                    'Category',
                    style: GoogleFonts.jost(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  DropdownButtonFormField<int>(
                    initialValue: selectedCatId,
                    style: GoogleFonts.jost(),
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                    ),
                    hint: Text('Select category', style: GoogleFonts.jost()),
                    items: _categories
                        .map(
                          (c) => DropdownMenuItem<int>(
                            value: int.tryParse(c['id'].toString()),
                            child: Text(
                              c['name'] ?? '',
                              style: GoogleFonts.jost(),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setS(() => selectedCatId = v),
                  ),
                ],
                SizedBox(height: 14.h),

                // ── Banner Image ─────────────────────────
                Text(
                  'Tab Banner Image',
                  style: GoogleFonts.jost(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Shown at top when this tab is selected (e.g. "SUMMER MADNESS", "BACHAT BAZAAR")',
                  style: GoogleFonts.jost(fontSize: 11.sp, color: Colors.grey),
                ),
                SizedBox(height: 8.h),
                // Show existing or newly picked banner
                if (bannerBytes != null) ...[
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: Image.memory(
                          bannerBytes!,
                          height: 110.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => setS(() {
                            bannerBytes = null;
                            removeBanner = true;
                          }),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                ] else if (!removeBanner &&
                    existingBannerUrl != null &&
                    existingBannerUrl.isNotEmpty) ...[
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: Image.network(
                          existingBannerUrl,
                          height: 110.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 110.h,
                            color: Colors.grey.shade200,
                            child: Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => setS(() {
                            removeBanner = true;
                          }),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                ],
                ImagePickerTile(
                  bytes: null,
                  height:
                      bannerBytes == null &&
                          (removeBanner ||
                              existingBannerUrl == null ||
                              existingBannerUrl.isEmpty)
                      ? 90
                      : 40,
                  onTap: () async {
                    final bytes = await ImagePickerWeb.getImageAsBytes();
                    if (bytes != null)
                      setS(() {
                        bannerBytes = bytes;
                        removeBanner = false;
                      });
                  },
                ),
                SizedBox(height: 14.h),

                // ── Icon ────────────────────────────────
                Text(
                  'Icon',
                  style: GoogleFonts.jost(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _iconOptions.map((o) {
                    final isSelected = selectedIcon == o['key'];
                    return GestureDetector(
                      onTap: () =>
                          setS(() => selectedIcon = o['key'] as String),
                      child: Tooltip(
                        message: o['label'] as String,
                        child: Container(
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryColor
                                : AppColors.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            o['icon'] as IconData,
                            size: 20.sp,
                            color: isSelected
                                ? Colors.white
                                : AppColors.primaryColor,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 12.h),

                // ── Custom icon (image / SVG) ─────────────
                Text(
                  'Custom Icon (image or .svg) — optional, overrides the icon above',
                  style: GoogleFonts.jost(fontSize: 11.sp, color: Colors.grey),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: iconBytes != null
                          ? ((iconFileName ?? '').toLowerCase().endsWith('.svg')
                              ? SvgPicture.memory(iconBytes!, fit: BoxFit.contain)
                              : Image.memory(iconBytes!, fit: BoxFit.contain))
                          : (!removeIconImage &&
                                  existingIconUrl != null &&
                                  existingIconUrl.isNotEmpty
                              ? (existingIconUrl.toLowerCase().endsWith('.svg')
                                  ? SvgPicture.network(existingIconUrl, fit: BoxFit.contain)
                                  : Image.network(existingIconUrl, fit: BoxFit.contain))
                              : Icon(Icons.add_photo_alternate_outlined,
                                  color: AppColors.primaryColor, size: 20.sp)),
                    ),
                    SizedBox(width: 10.w),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final info = await ImagePickerWeb.getImageInfo();
                        if (info?.data != null) {
                          setS(() {
                            iconBytes = info!.data;
                            iconFileName = info.fileName ?? 'icon.png';
                            removeIconImage = false;
                          });
                        }
                      },
                      icon: const Icon(Icons.upload_rounded, size: 16),
                      label: Text('Upload', style: GoogleFonts.jost()),
                    ),
                    if (iconBytes != null ||
                        (existingIconUrl != null && existingIconUrl.isNotEmpty && !removeIconImage)) ...[
                      SizedBox(width: 6.w),
                      TextButton(
                        onPressed: () => setS(() {
                          iconBytes = null;
                          iconFileName = null;
                          removeIconImage = true;
                        }),
                        child: Text('Remove', style: GoogleFonts.jost(color: Colors.red.shade400)),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 14.h),

                // ── Color ────────────────────────────────
                Text(
                  'Background Color',
                  style: GoogleFonts.jost(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _colorOptions.map((c) {
                    final isSelected = selectedColor == c['hex'];
                    final color = _colorFor(c['hex']!);
                    return GestureDetector(
                      onTap: () => setS(() => selectedColor = c['hex']!),
                      child: Tooltip(
                        message: c['label']!,
                        child: Container(
                          width: 32.w,
                          height: 32.h,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.black, width: 2.5)
                                : null,
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16.sp,
                                )
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 14.h),

                // ── Position ─────────────────────────────
                Text(
                  'Position',
                  style: GoogleFonts.jost(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 6.h),
                TextField(
                  controller: posCtrl,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.jost(),
                  decoration: InputDecoration(
                    hintText: '0, 1, 2 ...',
                    hintStyle: GoogleFonts.jost(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                  ),
                ),
              ],
            ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.jost()),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              onPressed: isSaving
                  ? null
                  : () async {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) {
                        _showSnack('Name is required', error: true);
                        return;
                      }
                      if (selectedType == 'category' && selectedCatId == null) {
                        _showSnack('Please select a category', error: true);
                        return;
                      }
                      setS(() => isSaving = true);
                      try {
                        final url = existing == null
                            ? ApiConstants.HOME_TABS_ADD
                            : ApiConstants.HOME_TABS_EDIT;
                        final body = <String, String>{
                          'name': name,
                          'icon': selectedIcon,
                          'type': selectedType,
                          'bg_color': selectedColor,
                          'position': posCtrl.text.trim(),
                        };
                        if (existing != null)
                          body['id'] = existing['id'].toString();
                        if (selectedCatId != null)
                          body['category_id'] = selectedCatId.toString();
                        if (removeBanner && bannerBytes == null)
                          body['remove_banner'] = '1';

                        // Banner image upload
                        if (bannerBytes != null) {
                          final ext = 'jpg';
                          final fname =
                              'tab_banner_${DateTime.now().millisecondsSinceEpoch}.$ext';
                          body['banner_data'] = base64Encode(bannerBytes!);
                          body['banner_name'] = fname;
                        }

                        // Custom icon (image / svg) upload
                        if (iconBytes != null) {
                          body['icon_data'] = base64Encode(iconBytes!);
                          body['icon_name'] = iconFileName ?? 'icon.png';
                        } else if (removeIconImage) {
                          body['remove_icon_image'] = '1';
                        }

                        final res = await AdminApi.post(
                          Uri.parse(url),
                          body: body,
                        );
                        final data = jsonDecode(res.body);
                        if (data['success'] == true) {
                          if (ctx.mounted) Navigator.pop(ctx);
                          _fetchTabs();
                          _showSnack(
                            existing == null ? 'Tab added!' : 'Tab updated!',
                          );
                        } else {
                          _showSnack(data['message'] ?? 'Error', error: true);
                        }
                      } catch (e) {
                        _showSnack('Error: $e', error: true);
                      } finally {
                        setS(() => isSaving = false);
                      }
                    },
              child: Text(
                isSaving ? 'Saving...' : 'Save',
                style: GoogleFonts.jost(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Home Tabs',
          style: GoogleFonts.jost(
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: AppColors.primaryColor),
            tooltip: 'Add Tab',
            onPressed: () => _showTabDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : _tabs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.tab_outlined, size: 60.sp, color: Colors.grey),
                  SizedBox(height: 12.h),
                  Text(
                    'No tabs yet',
                    style: GoogleFonts.jost(
                      color: Colors.grey,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ElevatedButton.icon(
                    onPressed: () => _showTabDialog(),
                    icon: const Icon(Icons.add),
                    label: Text('Add First Tab', style: GoogleFonts.jost()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Preview strip
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: 10.h,
                    horizontal: 8.w,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 8.w, bottom: 6.h),
                        child: Text(
                          'Preview (active tabs)',
                          style: GoogleFonts.jost(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 64.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _tabs
                              .where((t) => t['is_active'] == 1)
                              .length,
                          itemBuilder: (context, i) {
                            final tab = _tabs
                                .where((t) => t['is_active'] == 1)
                                .elementAt(i);
                            final color = _colorFor(
                              tab['bg_color'] ?? '#6C63FF',
                            );
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 6.w),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 36.w,
                                    height: 36.h,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _iconFor(tab['icon'] ?? 'all'),
                                      size: 16.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 3.h),
                                  Text(
                                    tab['name'] ?? '',
                                    style: GoogleFonts.jost(
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Tab list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    child: ReorderableListView.builder(
                      padding: EdgeInsets.all(12.w),
                      itemCount: _tabs.length,
                      onReorder: (oldIndex, newIndex) async {
                        if (newIndex > oldIndex) newIndex--;
                        final item = _tabs.removeAt(oldIndex);
                        _tabs.insert(newIndex, item);
                        setState(() {});
                        final payload = _tabs
                            .asMap()
                            .entries
                            .map(
                              (e) => {'id': e.value['id'], 'position': e.key},
                            )
                            .toList();
                        try {
                          await AdminApi.postJson(
                            Uri.parse(ApiConstants.HOME_TABS_REORDER),
                            body: {'tabs': payload},
                          );
                        } catch (_) {}
                      },
                      itemBuilder: (context, index) {
                        final tab = _tabs[index];
                        final isActive = tab['is_active'] == 1;
                        final color = _colorFor(tab['bg_color'] ?? '#6C63FF');
                        final bannerUrl = tab['banner_image']?.toString() ?? '';

                        return Card(
                          key: ValueKey(tab['id']),
                          elevation: 1,
                          margin: EdgeInsets.only(bottom: 8.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Banner thumbnail if present
                              if (bannerUrl.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12.r),
                                    topRight: Radius.circular(12.r),
                                  ),
                                  child: Image.network(
                                    bannerUrl,
                                    height: 70.h,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const SizedBox.shrink(),
                                  ),
                                ),
                              ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 6.h,
                                ),
                                leading: Container(
                                  width: 42.w,
                                  height: 42.h,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? color
                                        : Colors.grey.shade300,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _iconFor(tab['icon'] ?? 'all'),
                                    color: Colors.white,
                                    size: 18.sp,
                                  ),
                                ),
                                title: Text(
                                  tab['name'] ?? '',
                                  style: GoogleFonts.jost(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                subtitle: Text(
                                  _typeLabel(tab['type'], tab['category_name']),
                                  style: GoogleFonts.jost(
                                    fontSize: 11.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'Manage sections',
                                      icon: Icon(
                                        Icons.dashboard_customize_outlined,
                                        size: 18.sp,
                                        color: AppColors.primaryColor,
                                      ),
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              SectionBuilderScreen(tab: tab),
                                        ),
                                      ),
                                    ),
                                    Switch(
                                      value: isActive,
                                      activeColor: AppColors.primaryColor,
                                      onChanged: (_) => _toggleTab(tab),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit_outlined,
                                        size: 18.sp,
                                        color: Colors.blueGrey,
                                      ),
                                      onPressed: () =>
                                          _showTabDialog(existing: tab),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        size: 18.sp,
                                        color: Colors.red.shade300,
                                      ),
                                      onPressed: () =>
                                          _deleteTab(tab['id'] as int),
                                    ),
                                    Icon(
                                      Icons.drag_handle,
                                      color: Colors.grey,
                                      size: 18.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  String _typeLabel(String? type, String? catName) {
    switch (type) {
      case 'all':
        return 'Full home feed';
      case 'category':
        return catName != null ? 'Category: $catName' : 'Main category + subcategories';
      case 'none':
        return 'Themed tab — sections only';
      case 'categories':
        return 'All categories grid (legacy)';
      case 'deals':
        return 'Deals (legacy)';
      default:
        return type ?? '';
    }
  }
}
