import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const bool screenUtilUse = true;

const Color main_color = Color(0xff191962);
const Color renew_main_color2 = Color(0xff3A6EFE);
const Color renew_main_color2_sub = Color(0xff3EA0F2);
const Color sub_color = Color(0xffF6F6FF);
const Color sub_color2 = Color(0xffD5C6BB);
const Color main_btn = Color(0xff191962);
const Color sub_btn = Color(0xff65656D);
const Color copy_btn = Color(0xff31363A);

const Color rpa_btn_regist = Color(0xff0A8DFF);
const Color rpa_btn_modify = Color(0xff006633);
const Color rpa_btn_cancle = Color(0xffFF0033);

const Color renew_main_color = Color(0xff8AAAE6);

const Color terms_text = Color(0xff141420);
const Color swipe_edit_btn = Color(0xff3535B2);
const Color swipe_delete_btn = Color(0xffEF5350);

const Color line = Color(0xffe0e0e0);

const Color main_background = Color(0xffE2E2E2);

const Color cancel_btn = Color(0xff31363A);
const Color text_color_01 = Color(0xff00002A);
const Color text_color_02 = Color(0xff404057);
const Color text_color_03 = Color(0xff959595);
const Color text_color_04 = Color(0xffA4A6B2);
const Color text_color_05 = Color(0xff191962);
const Color text_color_06 = Color(0xff4187FF);
const Color text_color_07 = Color(0xffFA4256);
const Color text_box_color_01 = Color(0xff5050FF);
const Color text_box_color_02 = Color(0xffA7A7A7);

const Color box_body = Color(0xffFBFBFB);
const Color order_reg_background = Color(0xffF6F6FF);
const Color order_reg_line = Color(0xffF0F0F0);
const Color order_reg_round_01 = Color(0xffEDEDF3);
const Color order_reg_round_02 = Color(0xff31363A);

const Color order_item_background = Color(0xffeeeeee);
const Color order_state_01 = Color(0xff5050ff);
const Color order_state_04 = Color(0xff4187ff);
const Color order_state_05 = Color(0xffa7a7a7);
const Color order_state_09 = Color(0xffff5050);
const Color light_gray = Color(0xffe9e9e9);
const Color light_gray1 = Color(0xfff0f0f0);
const Color light_gray2 = Color(0xff6e6e6e);
const Color light_gray3 = Color(0xffafafaf);
const Color light_gray4 = Color(0xfff4f4f4);
const Color light_gray5 = Color(0xff7b7b7b);
const Color light_gray6 = Color(0xff727272);
const Color light_gray7 = Color(0xff9e9e9e);
const Color light_gray8 = Color(0xff909090);
const Color light_gray9 = Color(0xff838383);
const Color light_gray10 = Color(0xff3a3a3a);
const Color light_gray11 = Color(0xffe1e1e1);
const Color light_gray12 = Color(0xffbababa);
const Color light_gray13 = Color(0xff999999);
const Color light_gray14 = Color(0xffacacac);
const Color light_gray15 = Color(0xffdadada);
const Color light_gray16 = Color(0xff8e8e8e);
const Color light_gray17 = Color(0xff5c5c5c);
const Color light_gray18 = Color(0xffb7b7b7);
const Color light_gray19 = Color(0xffdddddd);
const Color light_gray20 = Color(0xff959595);
const Color light_gray21 = Color(0xff848484);
const Color light_gray22 = Color(0xffefefef);
const Color light_gray23 = Color(0xffc3c3c3);
const Color light_gray24 = Color(0xffececec);

const Color addr_zip_no = Color(0xfffa4256);
const Color addr_type_text = Color(0xff008bd3);

const Color point_red = Color(0xffFF5050);
const Color point_blue = Color(0xff5050FF);
const Color card_background = Color(0xffDFF1FF);

const Color styleBaseCol1 = Color(0xff0C5767);
const Color styleBaseCol2 = Color(0xff083742);
const Color styleBaseCol3 = Color(0xff72A3AD);
const Color styleSubCol = Color(0xffEDD5B2);
const Color styleSubCol2 = Color(0xffD4B78C);
const Color styleGreyCol1 = Color(0xffCDCDCD);
const Color styleGreyCol2 = Color(0xffE0E0E0);
const Color styleGreyCol3 = Color(0xffFAFAFA);
const Color styleWhiteCol = Color(0xffFFFFFF);
const Color styleBlackCol1 = Color(0xff000000);
const Color styleBlackCol2 = Color(0xff666666);
const Color styleBlackCol3 = Color(0xff333333);
const Color styleBalckCol4 = Color(0xff00002A);
const Color styleRedCol = Color(0xffFF0000);
const Color styleDividerGrey = Color(0xffE5E5E5);
const Color styleDefaultGrey = Color(0xff999999);
final double styleFontSize5 = CustomStyle.getSp(5.0);
final double styleFontSize6 = CustomStyle.getSp(6.0);
final double styleFontSize7 = CustomStyle.getSp(7.0);
final double styleFontSize8 = CustomStyle.getSp(8.0);
final double styleFontSize9 = CustomStyle.getSp(9.0);
final double styleFontSize10 = CustomStyle.getSp(10.0);
final double styleFontSize11 = CustomStyle.getSp(11.0);
final double styleFontSize12 = CustomStyle.getSp(12.0);
final double styleFontSize13 = CustomStyle.getSp(13.0);
final double styleFontSize14 = CustomStyle.getSp(14.0);
final double styleFontSize15 = CustomStyle.getSp(15.0);
final double styleFontSize16 = CustomStyle.getSp(16.0);
final double styleFontSize17 = CustomStyle.getSp(17.0);
final double styleFontSize18 = CustomStyle.getSp(18.0);
final double styleFontSize20 = CustomStyle.getSp(20.0);
final double styleFontSize22 = CustomStyle.getSp(22.0);
final double styleFontSize36 = CustomStyle.getSp(36.0);

final double styleFontSize28 = CustomStyle.getSp(28.0);
final double styleFontSize30 = CustomStyle.getSp(30.0);

final double styleRadius2 = CustomStyle.getRadius(2.0);
final double styleRadius3 = CustomStyle.getRadius(3.0);
final double styleRadius5 = CustomStyle.getRadius(5.0);
final double styleRadius10 = CustomStyle.getRadius(10.0);
final double styleRadius15 = CustomStyle.getRadius(15.0);
final double styleRadius20 = CustomStyle.getRadius(20.0);
final double styleRadius30 = CustomStyle.getRadius(30.0);
final double styleRadius35 = CustomStyle.getRadius(35.0);



class CustomStyle {
  static TextStyle baseFont() {
    return TextStyle(
      fontSize: styleFontSize14,
      color: styleBlackCol1
    );
  }

  static TextStyle CustomFont(double fontSize, Color color,{FontWeight? font_weight}) {
    return TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: font_weight != null?font_weight:FontWeight.normal
    );
  }

  static TextStyle loginTitleFont() {
    return baseFont().copyWith(
      color: styleWhiteCol,
      fontSize: styleFontSize13,
      fontWeight: FontWeight.w700,
    );
  }

  static TextStyle appBarTitleFont(fontSize,color) {
    return CustomFont(fontSize, color)
        .copyWith(fontWeight: FontWeight.w500, fontSize: styleFontSize16);
  }

  static TextStyle appBarTitleFont_sub() {
    return baseFont()
        .copyWith(fontWeight: FontWeight.w700, fontSize: styleFontSize14);
  }

  static TextStyle baseFontB() {
    return baseFont().copyWith(fontWeight: FontWeight.w700);
  }

  static TextStyle baseFont16B() {
    return baseFont().copyWith(fontWeight: FontWeight.w700,fontSize: styleFontSize16);
  }

  static TextStyle baseFont20B() {
    return baseFont().copyWith(fontWeight: FontWeight.w700,fontSize: styleFontSize20);
  }

  static TextStyle subTitleFont() {
    return baseFont()
        .copyWith(fontWeight: FontWeight.w700, fontSize: styleFontSize15);
  }

  static TextStyle redFont() {
    return baseFont().copyWith(color: styleRedCol);
  }

  static TextStyle redFont13() {
    return baseFont().copyWith(color: styleRedCol, fontSize: styleFontSize13);
  }

  static TextStyle greyFont12() {
    return baseFont().copyWith(color: styleGreyCol2, fontSize: styleFontSize12);
  }

  static TextStyle greyFont13() {
    return baseFont().copyWith(color: styleGreyCol2, fontSize: styleFontSize13);
  }

  static TextStyle greyFont15() {
    return baseFont().copyWith(color: styleGreyCol2, fontSize: styleFontSize15);
  }

  static TextStyle greyFont16() {
    return baseFont().copyWith(color: styleGreyCol2, fontSize: styleFontSize16);
  }

  static TextStyle blackFont15B() {
    return baseFont().copyWith(color: styleBlackCol1, fontSize: styleFontSize15,fontWeight: FontWeight.w700);
  }


  static TextStyle greyFont13B() {
    return baseFont().copyWith(
        color: styleGreyCol2,
        fontSize: styleFontSize13,
        fontWeight: FontWeight.w700);
  }

  static TextStyle whiteFont() {
    return baseFont().copyWith(color: styleWhiteCol);
  }

  static TextStyle whiteFontB() {
    return baseFont()
        .copyWith(color: styleWhiteCol, fontWeight: FontWeight.w700);
  }

  static TextStyle whiteFontB_700() {
    return baseFont().copyWith(
        color: styleWhiteCol,
        fontWeight: FontWeight.w700);
  }

  static TextStyle whiteFont15B() {
    return baseFont().copyWith(
        color: styleWhiteCol,
        fontSize: styleFontSize15,
        fontWeight: FontWeight.w700);
  }

  static TextStyle whiteFont16B() {
    return baseFont().copyWith(
        color: styleWhiteCol,
        fontSize: styleFontSize16,
        fontWeight: FontWeight.w700);
  }

  static TextStyle whiteFont17B() {
    return baseFont().copyWith(
        color: styleWhiteCol,
        fontSize: styleFontSize17,
        fontWeight: FontWeight.w700);
  }

  static TextStyle type1StateTrueFont16B() {
    return baseFont().copyWith(
        color: styleSubCol,
        fontSize: styleFontSize16,
        fontWeight: FontWeight.w700);
  }

  static TextStyle type1StateFalseFont16B() {
    return baseFont().copyWith(
        color: styleBaseCol3,
        fontSize: styleFontSize16,
        fontWeight: FontWeight.w700);
  }

  static TextStyle type2StateTrueFont13B() {
    return baseFont().copyWith(
        color: styleGreyCol2,
        fontSize: styleFontSize13);
  }

  static TextStyle type2StateFalseFont13B() {
    return baseFont().copyWith(
        color: styleBaseCol3,
        fontSize: styleFontSize13);
  }

  static TextStyle type3StateTrueFont11B() {
    return baseFont().copyWith(
        color: styleGreyCol2,
        fontSize: styleFontSize11);
  }

  static TextStyle type3StateFalseFont11B() {
    return baseFont().copyWith(
        color: styleBaseCol3,
        fontSize: styleFontSize11);
  }

  static TextStyle greyFont() {
    return baseFont().copyWith(color: styleGreyCol2);
  }

  static TextStyle greyDefFont() {
    return baseFont().copyWith(color: styleDefaultGrey);
  }

  static TextStyle greyDefFont900B() {
    return baseFont().copyWith(color: styleDefaultGrey,fontWeight: FontWeight.w900);
  }


  static TextStyle greyDefFont13() {
    return baseFont()
        .copyWith(color: styleDefaultGrey, fontSize: styleFontSize13);
  }

  static TextStyle greyDefFont15B() {
    return baseFont().copyWith(
        color: styleDefaultGrey,
        fontSize: styleFontSize15,
        fontWeight: FontWeight.w700);
  }

  static TextStyle subFont() {
    return baseFont().copyWith(color: styleSubCol);
  }

  static TextStyle subFont900B() {
    return baseFont().copyWith(
        color: styleSubCol,
        fontWeight: FontWeight.w900
    );
  }

  static TextStyle subCol2Font() {
    return baseFont().copyWith(color: styleSubCol2);
  }

  static TextStyle baseColFont() {
    return baseFont().copyWith(color: styleBaseCol1);
  }

  static TextStyle baseColFont900B() {
    return baseFont().copyWith(
        color: styleBaseCol1,
        fontWeight: FontWeight.w900
    );
  }

  static TextStyle baseColFont13() {
    return baseFont().copyWith(color: styleBaseCol1, fontSize: styleFontSize13);
  }

  static TextStyle baseColFontB() {
    return baseFont()
        .copyWith(color: styleBaseCol1, fontWeight: FontWeight.w700);
  }

  static TextStyle baseColFontB_1() {
    return baseFont()
        .copyWith(color: styleBaseCol1, fontWeight: FontWeight.w900);
  }

  static TextStyle baseColFontB_2() {
    return baseFont()
        .copyWith(color: styleBaseCol1, fontWeight: FontWeight.w300);
  }

  static TextStyle baseColFontC() {
    return baseFont()
        .copyWith(color: styleBlackCol2, fontWeight: FontWeight.w300);
  }

  static TextStyle baseColFontD() {
    return baseFont()
        .copyWith(color: styleBlackCol3, fontWeight: FontWeight.w300);
  }

  static TextStyle baseColFontD_400() {
    return baseFont()
        .copyWith(color: styleBlackCol3, fontWeight: FontWeight.w400);
  }

  static TextStyle baseColFontD_500() {
    return baseFont()
        .copyWith(color: styleBlackCol3, fontWeight: FontWeight.w500);
  }

  static TextStyle baseColFontD_700() {
    return baseFont()
        .copyWith(color: styleBlackCol3, fontWeight: FontWeight.w700);
  }

  static TextStyle baseColFontD_800() {
    return baseFont()
        .copyWith(color: styleBlackCol3, fontWeight: FontWeight.w800);
  }

  static TextStyle baseColFontD_900() {
    return baseFont()
        .copyWith(color: styleBlackCol3, fontWeight: FontWeight.w900);
  }

  static TextStyle baseCol3Font() {
    return baseFont().copyWith(color: styleBaseCol3);
  }

  static TextStyle blackFont() {
    return baseFont().copyWith(color: styleBlackCol1);
  }

  static TextStyle black2Font() {
    return baseFont().copyWith(color: styleBlackCol2);
  }

  static TextStyle alertMsgFont() {
    return baseFont()
        .copyWith(color: styleBlackCol1, fontSize: styleFontSize15);
  }

  static BoxDecoration baseBoxDeco() {
    return BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(styleRadius15)),
    );
  }

  static BoxDecoration baseBoxDecoBase() {
    return baseBoxDeco().copyWith(
      color: styleBaseCol1,
    );
  }

  static BoxDecoration baseBoxDecoWhite() {
    return baseBoxDeco().copyWith(
      color: styleWhiteCol,
    );
  }

  static BoxDecoration customBoxDeco(Color color,{double? radius,Color? border_color}) {

    return border_color != null ? BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(radius ?? styleRadius15)),
      border: Border.all(color: border_color,width: CustomStyle.getWidth(0.5))
    ).copyWith(
    color: color
    ):
    BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(radius ?? styleRadius15)),
    ).copyWith(
      color: color
    );

  }

  static BoxDecoration baseBoxDecoSub() {
    return baseBoxDeco().copyWith(
      color: styleSubCol,
    );
  }

  static BoxDecoration baseBoxDecoGrey() {
    return baseBoxDeco().copyWith(
      color: styleGreyCol1,
    );
  }

  static BoxDecoration baseBoxDecoWhite15() {
    return baseBoxDeco().copyWith(
      borderRadius: BorderRadius.all(Radius.circular(styleRadius15)),
      color: styleWhiteCol,
    );
  }

  static BoxDecoration baseBoxDecoWhite30() {
    return baseBoxDeco().copyWith(
      borderRadius: BorderRadius.all(Radius.circular(styleRadius30)),
      color: styleWhiteCol,
    );
  }

  static BoxDecoration baseBoxDecoSub15() {
    return baseBoxDeco().copyWith(
      borderRadius: BorderRadius.all(Radius.circular(styleRadius15)),
      color: styleSubCol,
    );
  }

  static BoxDecoration baseBoxDecoSub35() {
    return baseBoxDeco().copyWith(
      borderRadius: BorderRadius.all(Radius.circular(styleRadius35)),
      color: styleSubCol,
    );
  }

  static BoxDecoration baseBoxDecoBase15() {
    return baseBoxDeco().copyWith(
      borderRadius: BorderRadius.all(Radius.circular(styleRadius15)),
      color: styleBaseCol1,
    );
  }

  static BoxDecoration baseBoxDecoBase35() {
    return baseBoxDeco().copyWith(
      borderRadius: BorderRadius.all(Radius.circular(styleRadius35)),
      color: styleBaseCol1,
    );
  }

  static Border borderAllSub() {
    return Border.all(color: styleSubCol, width: CustomStyle.getWidth(0.5));
  }

  static Border borderAllDeGrey5() {
    return Border.all(
        color: styleDefaultGrey, width: CustomStyle.getWidth(0.5));
  }

  static Border borderAllBlack() {
    return Border.all(color: styleBlackCol1, width: CustomStyle.getWidth(0.5));
  }

  static Border borderAllWhite() {
    return Border.all(color: styleWhiteCol, width: CustomStyle.getWidth(0.5));
  }

  static Border borderAllBase({Color? color, double? width}) {
    return Border.all(color: color??line, width: width??CustomStyle.getWidth(0.5));
  }

  static Border borderAllGrey() {
    return Border.all(color: styleGreyCol1, width: CustomStyle.getWidth(0.5));
  }

  static Border borderAllTransparent() {
    return Border.all(
        color: Colors.transparent, width: CustomStyle.getWidth(0));
  }

  static Border borderTopBottomDeGrey5() {
    return Border(
        top: BorderSide(
            color: styleDefaultGrey, width: CustomStyle.getWidth(0.5)),
        bottom: BorderSide(
            color: styleDefaultGrey, width: CustomStyle.getWidth(0.5)));
  }

  static BorderSide bdBlack03() {
    return BorderSide(color: styleBlackCol1, width: CustomStyle.getWidth(0.3));
  }

  static BorderSide bdGrey03() {
    return bdBlack03().copyWith(color: styleGreyCol1);
  }

  static BorderSide bdGrey05() {
    return bdBlack03()
        .copyWith(color: styleGreyCol1, width: CustomStyle.getWidth(0.5));
  }

  static BorderSide bdGrey1() {
    return bdBlack03()
        .copyWith(color: styleGreyCol1, width: CustomStyle.getWidth(1.0));
  }

  static BorderSide bdBase03() {
    return bdBlack03().copyWith(color: styleBaseCol1);
  }

  static BorderSide bdRed03() {
    return bdBlack03().copyWith(color: styleRedCol);
  }

  static BorderSide bdRed05() {
    return bdBlack03()
        .copyWith(color: styleRedCol, width: CustomStyle.getWidth(0.5));
  }

  static InputDecoration textFieldDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(
        borderSide: bdGrey05(),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: bdGrey05(),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: bdGrey05(),
      ),
      fillColor: styleWhiteCol,
      filled: true,
      isDense: true,
      counterText: '',
     contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(5.w),vertical: CustomStyle.getHeight(10.h)),
    );
  }

  static InputDecoration textFieldErrDeco() {
    return InputDecoration(
      border: OutlineInputBorder(
        borderSide: bdRed05(),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: bdRed05(),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: bdRed05(),
      ),
      fillColor: styleWhiteCol,
      filled: true,
      isDense: true,
      counterText: '',
      contentPadding: EdgeInsets.symmetric(horizontal: CustomStyle.getWidth(10.h),vertical: CustomStyle.getHeight(5.w)),
    );
  }

  static InputDecoration textBottomLineDeco() {
    return InputDecoration(
        border: UnderlineInputBorder(
          borderSide: bdGrey05(),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: bdGrey05(),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: bdGrey05(),
        ),
        fillColor: styleWhiteCol,
        filled: true,
        isDense: true,
        counterText: '');
  }

  static Widget getDivider() {
    return SizedBox(
        height: CustomStyle.getHeight(0.5),
        child: Divider(color: styleDividerGrey));
  }

  static Widget getDivider1() {
    return SizedBox(
        height: CustomStyle.getHeight(1.0),
        child: Divider(color: styleDividerGrey));
  }

  static Widget getDivider2() {
    return SizedBox(
        height: CustomStyle.getHeight(4.0),
        child: Divider(color: styleDefaultGrey));
  }

  static Widget getDivider10() {
    return SizedBox(
        height: CustomStyle.getHeight(10.h),
        child: const Divider(color: styleDefaultGrey));
  }

  static Widget getDivider_verti() {
    return SizedBox(
      width: CustomStyle.getWidth(5),
      child: Divider(color: line),
    );
  }

  static Widget getDividerGrey() {
    return SizedBox(
        height: CustomStyle.getHeight(0.5),
        child: Divider(color: styleGreyCol1));
  }

  static Widget sizedBoxWidth(_width) {
    return SizedBox(width: CustomStyle.getWidth(_width));
  }

  static Widget sizedBoxHeight(_height) {
    return SizedBox(height: CustomStyle.getHeight(_height));
  }

  static double getWidth(double _width) {
    return screenUtilUse ? ScreenUtil().setWidth(_width) : _width;
  }

  static double getHeight(double _height) {
    return screenUtilUse ? ScreenUtil().setHeight(_height) : _height;
  }

  static double getSp(double _fSize) {
    return screenUtilUse ? ScreenUtil().setSp(_fSize) : _fSize;
  }

  static double getRadius(double _size) {
    return screenUtilUse ? ScreenUtil().radius(_size) : _size;
  }
}
