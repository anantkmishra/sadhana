import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class Heading extends TextStyle {
  final Color color;
  final FontWeight fontWeight;
  final double size;
  final String fontFamily;

  const Heading({
    this.color = Colors.white,
    this.fontWeight = FontWeight.normal,
    this.size = 20,
    this.fontFamily = 'Montserrat',
  })  : assert(color != null && fontWeight != null),
        super(
          color: color,
          fontWeight: fontWeight,
          fontSize: size,
          fontFamily: fontFamily,
        );
}

class BigText extends TextStyle {
  final Color color;
  final FontWeight fontWeight;
  final double size;
  final String fontFamily;

  const BigText({
    this.color = Colors.white,
    this.fontWeight = FontWeight.bold,
    this.size = 28,
    this.fontFamily = 'Montserrat',
  })  : assert(color != null && fontWeight != null),
        super(
          color: color,
          fontWeight: fontWeight,
          fontSize: size,
          fontFamily: fontFamily,
        );
}

class Style1 extends TextStyle {
  final Color color;
  final FontWeight fontWeight;
  final double size;
  final String fontFamily;

  const Style1({
    this.color = Colors.white,
    this.fontWeight = FontWeight.bold,
    this.size = 20,
    this.fontFamily = 'Montserrat',
  })  : assert(color != null && fontWeight != null),
        super(
          color: color,
          fontWeight: fontWeight,
          fontSize: size,
          fontFamily: fontFamily,
        );
}

class ButtonText extends TextStyle {
  final Color color;
  final FontWeight fontWeight;
  final double size;
  final String fontFamily;

  const ButtonText({
    this.color = Colors.white,
    this.fontWeight = FontWeight.bold,
    this.size = 20,
    this.fontFamily = 'Montserrat',
  })  : assert(color != null && fontWeight != null),
        super(
          color: color,
          fontWeight: fontWeight,
          fontSize: size,
          fontFamily: fontFamily,
        );
}

class Style2 extends TextStyle {
  final Color color;
  final FontWeight fontWeight;
  final double size;
  final String fontFamily;

  const Style2({
    this.color = Colors.white,
    this.fontWeight = FontWeight.normal,
    this.size = 20,
    this.fontFamily = 'Montserrat',
  })  : assert(color != null && fontWeight != null),
        super(
          color: color,
          fontWeight: fontWeight,
          fontSize: size,
          fontFamily: fontFamily,
        );
}

class Style3 extends TextStyle {
  final Color color;
  final FontWeight fontWeight;
  final double size;
  final String fontFamily;
  final FontStyle style;

  const Style3({
    this.color = Colors.black,
    this.fontWeight = FontWeight.normal,
    this.size = 20,
    this.style = FontStyle.italic,
    this.fontFamily = 'Montserrat',
  })  : assert(color != null && fontWeight != null),
        super(
          color: color,
          fontStyle: style,
          fontWeight: fontWeight,
          fontSize: size,
          fontFamily: fontFamily,
        );
}
