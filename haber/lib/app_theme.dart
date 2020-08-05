import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  AppTheme._();

  static const Color notWhite = Color(0xFFEDF0F2);
  static const Color nearlyWhite = Color(0xFFFEFEFE);
  static const Color white = Color(0xFFFFFFFF);
  static const Color nearlyBlack = Color(0xFF213333);
  static const Color grey = Color(0xFF3A5160);
  static const Color dark_grey = Color(0xFF313A44);

  static const Color darkText = Color(0xFF253840);
  static const Color darkerText = Color(0xFF17262A);
  static const Color lightText = Color(0xFF4A6572);
  static const Color deactivatedText = Color(0xFF767676);
  static const Color dismissibleBackground = Color(0xFF364A54);
  static const Color chipBackground = Color(0xFFEEF1F3);
  static const Color spacer = Color(0xFFF2F2F2);
  static const String fontName = 'WorkSans';

  static final TextTheme textTheme = TextTheme(
    headline4: display1,
    headline5: headline,
    headline6: title,
    subtitle2: subtitle,
    bodyText2: body2,
    bodyText1: body1,
    caption: caption,
  );

  static final TextStyle display1 = GoogleFonts.montserrat(
    // h4 -> display1
    fontWeight: FontWeight.bold,
    fontSize: 36,
    letterSpacing: 0.4,
    height: 0.9,
    color: darkerText,
  );

  static final TextStyle headline = GoogleFonts.montserrat(
    // h5 -> headline
    fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: 0.27,
    color: darkerText,
  );

  static final TextStyle title = GoogleFonts.montserrat(
    // h6 -> title
    fontWeight: FontWeight.bold,
    fontSize: 16,
    letterSpacing: 0.18,
    color: darkerText,
  );

  static final TextStyle title2 = GoogleFonts.montserrat(
    // h6 -> title
    fontSize: 16,
    letterSpacing: 0.18,
    color: darkerText,
  );

  static final TextStyle subtitle = GoogleFonts.montserrat(
    // subtitle2 -> subtitle
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: -0.04,
    color: darkText,
  );

  static final TextStyle body2 = GoogleFonts.montserrat(
    // body1 -> body2
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.2,
    color: darkText,
  );

  static final TextStyle body1 = GoogleFonts.montserrat(
    // body2 -> body1
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: -0.05,
    color: darkText,
  );

  static final TextStyle caption = GoogleFonts.montserrat(
    // Caption -> caption
    fontWeight: FontWeight.w400,
    fontSize: 12,
    letterSpacing: 0.2,
    color: lightText, // was lightText
  );

  static final TextStyle caption2 = GoogleFonts.montserrat(
    // Caption -> caption
    fontWeight: FontWeight.bold,
    fontSize: 9,
    color: lightText, // was lightText
  );

  static final TextStyle caption2Adaptive = GoogleFonts.montserrat(
    // Caption -> caption
    fontWeight: FontWeight.bold,
    fontSize: ScreenUtil().setSp(32),
    color: lightText, // was lightText
  );

  static final TextStyle captionMont = GoogleFonts.montserrat(
    // Caption -> caption
    fontWeight: FontWeight.w300,
    fontSize: ScreenUtil().setSp(36),
    letterSpacing: 0.2,
    color: lightText, // was lightText
  );

  static final TextStyle captionWhite = GoogleFonts.montserrat(
    // Caption -> caption
    fontWeight: FontWeight.w300,
    fontSize: 11,
    letterSpacing: 0.2,
    color: Colors.white, // was lightText
  );

  static final TextStyle captionWhiteBig = GoogleFonts.montserrat(
    // Caption -> caption
    fontWeight: FontWeight.w300,
    fontSize: 13,
    letterSpacing: 0.2,
    color: Colors.white, // was lightText
  );
}
