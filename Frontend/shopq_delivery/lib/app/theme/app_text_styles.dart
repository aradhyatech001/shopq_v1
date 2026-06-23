import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle heading(double size, {Color? color, FontWeight weight = FontWeight.w700}) =>
      GoogleFonts.jost(fontSize: size, fontWeight: weight, color: color);

  static TextStyle body(double size, {Color? color}) =>
      GoogleFonts.jost(fontSize: size, color: color);
}
