import 'package:flutter/material.dart';

/// Canonical order-status model — IDENTICAL across the user, admin, vendor and
/// delivery apps and matching the backend (OrderStatusService).
///
/// Sub-order flow : pending → confirmed → packed → assigned → picked_up → out_for_delivery → delivered (+ cancelled)
/// Parent derived : pending, processing, partially_shipped, out_for_delivery,
///                  partially_delivered, delivered, partially_cancelled, cancelled
class OrderStatus {
  static int step(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'pending':
        return 0;
      case 'confirmed':
      case 'accepted':
      case 'packed':
      case 'processing':
        return 1;
      case 'assigned':
      case 'picked_up':
      case 'out_for_delivery':
      case 'way':
      case 'partially_shipped':
      case 'partially_delivered':
        return 2;
      case 'delivered':
        return 3;
      case 'cancelled':
      case 'canceled':
      case 'partially_cancelled':
        return -1;
      default:
        return 0;
    }
  }

  static bool isCancelled(String? raw) {
    final s = (raw ?? '').toLowerCase();
    return s == 'cancelled' || s == 'canceled' || s == 'partially_cancelled';
  }

  static bool isComplete(String? raw) {
    final s = (raw ?? '').toLowerCase();
    return s == 'delivered' || s == 'completed' || isCancelled(s);
  }

  static String label(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'packed':
        return 'Packed';
      case 'assigned':
        return 'Assigned';
      case 'picked_up':
        return 'Picked up';
      case 'out_for_delivery':
        return 'Out for delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
      case 'canceled':
        return 'Cancelled';
      case 'processing':
        return 'Processing';
      case 'partially_shipped':
        return 'Partially shipped';
      case 'partially_delivered':
        return 'Partially delivered';
      case 'partially_cancelled':
        return 'Partially cancelled';
      default:
        final s = (raw ?? '').trim();
        return s.isEmpty ? '—' : (s[0].toUpperCase() + s.substring(1));
    }
  }

  static Color color(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'delivered':
        return const Color(0xFF38A169);
      case 'pending':
        return const Color(0xFFDD6B20);
      case 'confirmed':
      case 'processing':
        return const Color(0xFF1A73E8);
      case 'packed':
      case 'assigned':
        return const Color(0xFF7C4DFF);
      case 'picked_up':
      case 'out_for_delivery':
      case 'partially_shipped':
        return const Color(0xFF0EA5E9);
      case 'partially_delivered':
        return const Color(0xFF14B8A6);
      case 'cancelled':
      case 'canceled':
      case 'partially_cancelled':
        return const Color(0xFFE53E3E);
      default:
        return const Color(0xFF718096);
    }
  }
}
