import 'package:flutter/material.dart';

class Decor {
  BoxDecoration container(
      {Color? color,
      Color? borderColor,
      double? borderCurve,
      List<BoxShadow>? boxShadow,
      BorderRadius? borderType,
      bool? useBordertype}) {
    return BoxDecoration(
        //  color: color ?? UserColors.purple,
        border: Border.all(
          color: borderColor ?? Colors.transparent,
        ),
        borderRadius: useBordertype == true
            ? borderType
            : BorderRadius.all(Radius.circular(borderCurve ?? 0)),
        boxShadow: boxShadow ?? [BoxShadow(color: color ?? UserColors.purple)],
        gradient: color == null
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(31, 241, 227, 0.5),
                  Color.fromRGBO(129, 53, 249, 0.8),
                ],
              )
            : null);
  }

  textStyle(
      {double? size,
      Color? color,
      FontWeight? fontweight,
      double? sHeight,
      double? letterspace,
      List<Shadow>? shadows}) {
    return TextStyle(
      fontSize: size,
      fontFamily: 'Nunito',
      letterSpacing: letterspace,
      height: sHeight,
      color: color ?? Colors.black,
      fontWeight: fontweight,
      shadows: shadows,
      // fontStyle: FontStyle.italic
    );
  }

  InputDecoration searchForm() {
    return InputDecoration(
        hintText: 'Search...',
        fillColor: ColorConv('#F3F4F8'),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        focusedErrorBorder:
            const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
        errorBorder:
            const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: ColorConv('#F3F4F8'))),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: ColorConv('#F3F4F8'))));
  }

  InputDecoration textform({
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? hintT,
    Widget? label,
    Color? borderColor,
    Color? fillColor,
    EdgeInsetsGeometry? contentPadding,
    TextStyle? hintStyle,
  }) {
    return InputDecoration(
        label: label,
        focusColor: UserColors.purple,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        labelText: hint,
        contentPadding: contentPadding,
        hintStyle: hintStyle,
        alignLabelWithHint: true,
        hintText: hintT,
        fillColor: fillColor ?? ColorConv('#F3F4F8'),
        filled: true,
        focusedErrorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.red)),
        errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.red)),
        enabledBorder: OutlineInputBorder(
            borderRadius:const BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: borderColor ?? ColorConv('#F3F4F8'))),
        focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            borderSide:
                BorderSide(color: borderColor ?? ColorConv('#F3F4F8'))));
  }
}

class UserColors {
  static const purple = Color.fromRGBO(129, 53, 249, 1);
  static const white = Colors.white;
}

class ColorConv extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  ColorConv(final String eventryColor) : super(_getColorFromHex(eventryColor));
}
