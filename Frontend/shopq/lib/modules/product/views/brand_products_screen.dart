import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shopq/app/theme/app_colors.dart';
import 'package:shopq/core/network/api_client.dart';
import 'package:shopq/core/network/api_endpoints.dart';
import 'package:shopq/core/storage/storage_service.dart';
import 'package:shopq/core/widgets/product_card.dart';

/// Shows all products of a single brand. Opened from the brand grid or a
/// `shopq://brand/<id>` deep link.
class BrandProductsScreen extends StatefulWidget {
  final int brandId;
  final String brandName;
  const BrandProductsScreen(
      {super.key, required this.brandId, this.brandName = 'Brand'});

  @override
  State<BrandProductsScreen> createState() => _BrandProductsScreenState();
}

class _BrandProductsScreenState extends State<BrandProductsScreen> {
  List _products = [];
  bool _loading = true;
  String _title = '';

  @override
  void initState() {
    super.initState();
    _title = widget.brandName;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res =
          await ApiClient.get(ApiEndpoints.brandProducts(widget.brandId), pincode: true);
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        _products = data['products'] ?? [];
        if (data['brand']?['name'] != null) _title = data['brand']['name'];
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = StorageService.userId;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.primaryTextColor),
        title: Text(_title,
            style: GoogleFonts.jost(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryTextColor)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? Center(
                  child: Text('No products from this brand yet',
                      style: GoogleFonts.jost(
                          color: AppColors.secondaryTextColor)))
              : RefreshIndicator(
                  color: AppColors.primaryColor,
                  onRefresh: _load,
                  child: GridView.builder(
                    padding: EdgeInsets.all(12.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.42,
                      crossAxisSpacing: 8.w,
                      mainAxisSpacing: 8.h,
                    ),
                    itemCount: _products.length,
                    itemBuilder: (_, i) => ProductCard(
                      product: Map<String, dynamic>.from(_products[i]),
                      userId: userId,
                    ),
                  ),
                ),
    );
  }
}
