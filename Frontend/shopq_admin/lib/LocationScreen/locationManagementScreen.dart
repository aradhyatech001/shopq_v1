import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../CustomWidgets/admin_widgets.dart';
import '../utils/admin_api.dart';
import '../utils/api_constants.dart';
import '../utils/colors.dart';

// ── Models ────────────────────────────────────────────────────────────────────
class _District {
  final String id;
  final String name;
  _District({required this.id, required this.name});

  factory _District.fromJson(Map<String, dynamic> j) =>
      _District(id: j['id'].toString(), name: j['district_name'] ?? '');

  @override
  bool operator ==(Object o) =>
      identical(this, o) || (o is _District && o.id == id);

  @override
  int get hashCode => id.hashCode;
}

class _City {
  final String id;
  final String name;
  final String districtId;
  _City({required this.id, required this.name, required this.districtId});

  factory _City.fromJson(Map<String, dynamic> j) => _City(
    id: j['id']?.toString() ?? '',
    name: j['city_name'] ?? '',
    districtId: j['district_id']?.toString() ?? '',
  );
}

// ── Screen ────────────────────────────────────────────────────────────────────
class LocationManagementScreen extends StatefulWidget {
  const LocationManagementScreen({super.key});

  @override
  State<LocationManagementScreen> createState() =>
      _LocationManagementScreenState();
}

class _LocationManagementScreenState extends State<LocationManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  // ── District state ────────────────────────────────────────
  final _distNameCtrl = TextEditingController();
  List<_District> _districts = [];
  bool _loadingDist = true;
  bool _addingDist = false;

  // ── City state ────────────────────────────────────────────
  final _cityNameCtrl = TextEditingController();
  List<_City> _cities = [];
  bool _loadingCities = true;
  bool _addingCity = false;
  _District? _selectedDist;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _fetchDistricts();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _distNameCtrl.dispose();
    _cityNameCtrl.dispose();
    super.dispose();
  }

  // ── API: Districts ────────────────────────────────────────
  Future<void> _fetchDistricts() async {
    setState(() => _loadingDist = true);
    try {
      final res = await AdminApi.get(Uri.parse(ApiConstants.VIEW_DISTRICT));
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['districts'] != null && mounted) {
        final list = (data['districts'] as List)
            .map((j) => _District.fromJson(j))
            .toList();
        setState(() {
          _districts = list;
          _loadingDist = false;
          if (_selectedDist == null && list.isNotEmpty) {
            _selectedDist = list.first;
            _fetchCities(list.first.id);
          } else if (list.isEmpty) {
            _cities = [];
          }
        });
      } else {
        if (mounted) setState(() => _loadingDist = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingDist = false);
    }
  }

  Future<void> _addDistrict() async {
    final name = _distNameCtrl.text.trim();
    if (name.isEmpty) {
      _snack('Name required', AppColors.warningColor);
      return;
    }
    setState(() => _addingDist = true);
    try {
      final res = await AdminApi.post(
        Uri.parse(ApiConstants.ADD_DISTRICT),
        body: {'district_name': name},
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        _snack('City added!', AppColors.successColor);
        _distNameCtrl.clear();
        _fetchDistricts();
      } else {
        _snack(data['message'] ?? 'Failed', AppColors.errorColor);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _addingDist = false);
    }
  }

  Future<void> _editDistrict(_District d) async {
    final ctrl = TextEditingController(text: d.name);
    final ok = await _editDialog('Edit City', ctrl);
    if (!ok) return;
    try {
      final res = await AdminApi.post(
        Uri.parse(ApiConstants.UPDATE_DISTRICT),
        body: {'district_id': d.id, 'district_name': ctrl.text.trim()},
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        _snack('Updated!', AppColors.successColor);
        _fetchDistricts();
      }
    } catch (_) {}
  }

  Future<void> _deleteDistrict(_District d) async {
    final ok = await confirmDelete(
      context,
      title: 'Delete City',
      message: 'This will also delete all areas under ${d.name}.',
    );
    if (!ok) return;
    try {
      final res = await AdminApi.post(
        Uri.parse(ApiConstants.DELETE_DISTRICT),
        body: {'district_id': d.id},
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        _snack('Deleted', AppColors.successColor);
        setState(() {
          _districts.removeWhere((x) => x.id == d.id);
          if (_selectedDist?.id == d.id) {
            _selectedDist = _districts.isNotEmpty ? _districts.first : null;
            _cities = [];
          }
        });
        _fetchDistricts();
      }
    } catch (_) {}
  }

  // ── API: Cities ───────────────────────────────────────────
  Future<void> _fetchCities(String districtId) async {
    if (districtId.isEmpty) {
      setState(() {
        _cities = [];
        _loadingCities = false;
      });
      return;
    }
    setState(() => _loadingCities = true);
    try {
      final res = await AdminApi.post(
        Uri.parse(ApiConstants.VIEW_CITY),
        body: {'district_id': districtId},
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['cities'] != null && mounted) {
        setState(() {
          _cities = (data['cities'] as List)
              .map((j) => _City.fromJson(j))
              .toList();
          _loadingCities = false;
        });
      } else {
        if (mounted)
          setState(() {
            _cities = [];
            _loadingCities = false;
          });
      }
    } catch (_) {
      if (mounted)
        setState(() {
          _cities = [];
          _loadingCities = false;
        });
    }
  }

  Future<void> _addCity() async {
    if (_selectedDist == null) {
      _snack('Select a city first', AppColors.warningColor);
      return;
    }
    final name = _cityNameCtrl.text.trim();
    if (name.isEmpty) {
      _snack('Name required', AppColors.warningColor);
      return;
    }
    setState(() => _addingCity = true);
    try {
      final res = await AdminApi.post(
        Uri.parse(ApiConstants.ADD_CITY),
        body: {'district_id': _selectedDist!.id, 'city_name': name},
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        _snack('Area added!', AppColors.successColor);
        _cityNameCtrl.clear();
        _fetchCities(_selectedDist!.id);
      } else {
        _snack(data['message'] ?? 'Failed', AppColors.errorColor);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _addingCity = false);
    }
  }

  Future<void> _editCity(_City c) async {
    final ctrl = TextEditingController(text: c.name);
    final ok = await _editDialog('Edit Area', ctrl);
    if (!ok) return;
    try {
      final res = await AdminApi.post(
        Uri.parse(ApiConstants.UPDATE_CITY),
        body: {'city_id': c.id, 'city_name': ctrl.text.trim()},
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        _snack('Updated!', AppColors.successColor);
        if (_selectedDist != null) _fetchCities(_selectedDist!.id);
      }
    } catch (_) {}
  }

  Future<void> _deleteCity(_City c) async {
    final ok = await confirmDelete(
      context,
      title: 'Delete Area',
      message: 'Remove ${c.name}?',
    );
    if (!ok) return;
    try {
      final res = await AdminApi.post(
        Uri.parse(ApiConstants.DELETE_CITY),
        body: {'city_id': c.id},
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        _snack('Deleted', AppColors.successColor);
        if (_selectedDist != null) _fetchCities(_selectedDist!.id);
      }
    } catch (_) {}
  }

  // ── Edit dialog ───────────────────────────────────────────
  Future<bool> _editDialog(String title, TextEditingController ctrl) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            title: Text(
              title,
              style: GoogleFonts.jost(fontWeight: FontWeight.w700),
            ),
            content: TextField(
              controller: ctrl,
              autofocus: true,
              style: GoogleFonts.jost(fontSize: 14.sp),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel', style: GoogleFonts.jost()),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Save',
                  style: GoogleFonts.jost(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
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
      title: 'Locations',
      subtitle: '${_districts.length} cities',
      child: Column(
        children: [
          // Tab bar
          Container(
            color: AppColors.surfaceColor,
            child: TabBar(
              controller: _tabCtrl,
              indicatorColor: AppColors.primaryColor,
              labelColor: AppColors.primaryColor,
              unselectedLabelColor: AppColors.secondaryTextColor,
              labelStyle: GoogleFonts.jost(fontWeight: FontWeight.w700),
              unselectedLabelStyle: GoogleFonts.jost(),
              tabs: const [
                Tab(text: 'Cities'),
                Tab(text: 'Areas'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [_buildDistrictTab(), _buildCityTab()],
            ),
          ),
        ],
      ),
    );
  }

  // ── District tab ──────────────────────────────────────────
  Widget _buildDistrictTab() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // List
        Expanded(
          flex: 3,
          child: _loadingDist
              ? const Center(child: CircularProgressIndicator())
              : _districts.isEmpty
              ? const EmptyState(
                  icon: Icons.location_city_outlined,
                  message: 'No cities yet',
                )
              : ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: _districts.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (_, i) => _LocationTile(
                    name: _districts[i].name,
                    onEdit: () => _editDistrict(_districts[i]),
                    onDelete: () => _deleteDistrict(_districts[i]),
                  ),
                ),
        ),

        const VerticalDivider(width: 1),

        // Add form
        SizedBox(
          width: 300.w,
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: SectionCard(
              title: 'Add City',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FormLabel('City Name', required: true),
                  TextField(
                    controller: _distNameCtrl,
                    style: GoogleFonts.jost(fontSize: 13.sp),
                    onSubmitted: (_) => _addDistrict(),
                    decoration: const InputDecoration(hintText: 'e.g. Patiala'),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    child: _addingDist
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _addDistrict,
                            child: Text(
                              'Add City',
                              style: GoogleFonts.jost(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── City tab ──────────────────────────────────────────────
  Widget _buildCityTab() {
    final ids = _districts.map((d) => d).toList();
    final valid = ids.contains(_selectedDist) ? _selectedDist : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // List
        Expanded(
          flex: 3,
          child: Column(
            children: [
              // District selector
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Container(
                  height: 44.h,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: DropdownButton<_District>(
                    value: valid,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    hint: Text(
                      'Select city',
                      style: GoogleFonts.jost(
                        fontSize: 13.sp,
                        color: AppColors.hintTextColor,
                      ),
                    ),
                    style: GoogleFonts.jost(
                      fontSize: 13.sp,
                      color: AppColors.primaryTextColor,
                    ),
                    icon: Icon(
                      Icons.expand_more_rounded,
                      size: 18.sp,
                      color: AppColors.hintTextColor,
                    ),
                    items: _districts
                        .map(
                          (d) => DropdownMenuItem(
                            value: d,
                            child: Text(
                              d.name,
                              style: GoogleFonts.jost(fontSize: 13.sp),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (d) {
                      setState(() => _selectedDist = d);
                      if (d != null) _fetchCities(d.id);
                    },
                  ),
                ),
              ),

              Expanded(
                child: _loadingCities
                    ? const Center(child: CircularProgressIndicator())
                    : _cities.isEmpty
                    ? EmptyState(
                        icon: Icons.location_on_outlined,
                        message: _selectedDist == null
                            ? 'Select a city first'
                            : 'No areas in ${_selectedDist!.name}',
                      )
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: _cities.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10.h),
                        itemBuilder: (_, i) => _LocationTile(
                          name: _cities[i].name,
                          onEdit: () => _editCity(_cities[i]),
                          onDelete: () => _deleteCity(_cities[i]),
                        ),
                      ),
              ),
            ],
          ),
        ),

        const VerticalDivider(width: 1),

        // Add form
        SizedBox(
          width: 300.w,
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: SectionCard(
              title: 'Add Area',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FormLabel('Select City', required: true),
                  Container(
                    height: 44.h,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: DropdownButton<_District>(
                      value: valid,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      hint: Text(
                        'City',
                        style: GoogleFonts.jost(
                          fontSize: 13.sp,
                          color: AppColors.hintTextColor,
                        ),
                      ),
                      style: GoogleFonts.jost(
                        fontSize: 13.sp,
                        color: AppColors.primaryTextColor,
                      ),
                      icon: Icon(
                        Icons.expand_more_rounded,
                        size: 18.sp,
                        color: AppColors.hintTextColor,
                      ),
                      items: _districts
                          .map(
                            (d) => DropdownMenuItem(
                              value: d,
                              child: Text(
                                d.name,
                                style: GoogleFonts.jost(fontSize: 13.sp),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (d) {
                        setState(() => _selectedDist = d);
                        if (d != null) _fetchCities(d.id);
                      },
                    ),
                  ),
                  SizedBox(height: 12.h),
                  const FormLabel('Area Name', required: true),
                  TextField(
                    controller: _cityNameCtrl,
                    style: GoogleFonts.jost(fontSize: 13.sp),
                    onSubmitted: (_) => _addCity(),
                    decoration: const InputDecoration(
                      hintText: 'e.g. Model Town',
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    child: _addingCity
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _addCity,
                            child: Text(
                              'Add Area',
                              style: GoogleFonts.jost(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Location tile ─────────────────────────────────────────────────────────────
class _LocationTile extends StatelessWidget {
  final String name;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LocationTile({
    required this.name,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on_rounded,
            color: AppColors.primaryColor,
            size: 18.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.jost(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: AppColors.primaryColor,
              size: 18.sp,
            ),
            onPressed: onEdit,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 28.w, minHeight: 28.w),
          ),
          SizedBox(width: 4.w),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: AppColors.errorColor,
              size: 18.sp,
            ),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 28.w, minHeight: 28.w),
          ),
        ],
      ),
    );
  }
}
