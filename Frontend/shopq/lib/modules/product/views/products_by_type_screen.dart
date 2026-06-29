import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shopq/app/theme/app_colors.dart';
import 'package:shopq/core/network/api_client.dart';
import 'package:shopq/core/network/api_endpoints.dart';
import 'package:shopq/core/storage/storage_service.dart';
import 'package:shopq/core/widgets/product_card.dart';

/// Lists products of a single product type (e.g. "Best Selling", "50% Off").
/// Opened from a `shopq://product_type/<name>` notification deep link.
class ProductsByTypeScreen extends StatefulWidget {
  final String type;
  const ProductsByTypeScreen({super.key, required this.type});

  @override
  State<ProductsByTypeScreen> createState() => _ProductsByTypeScreenState();
}

class _ProductsByTypeScreenState extends State<ProductsByTypeScreen> {
  List _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.get(
        '${ApiEndpoints.VIEW_PRODUCT_BY_TYPE}?type=${Uri.encodeComponent(widget.type)}&page=1&limit=50',
        pincode: true,
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true) _products = data['products'] ?? [];
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
        title: Text(widget.type,
            style: GoogleFonts.jost(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryTextColor)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? Center(
                  child: Text('No products found',
                      style: GoogleFonts.jost(
                          color: AppColors.secondaryTextColor)))
              : RefreshIndicator(
                  color: AppColors.primaryColor,
                  onRefresh: _load,
                  child: GridView.builder(
                    padding: EdgeInsets.all(12.w),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
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
