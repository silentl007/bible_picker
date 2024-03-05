import 'package:bible_picker/classes.dart';
import 'package:flutter/material.dart';

Widget customDivider({double? height, Color? color}) {
  return Divider(
    height: height ?? 1,
    color: color ?? Colors.transparent,
  );
}

customhorizontal({double? width}) {
  return SizedBox(
    width: width ?? 1,
  );
}

Widget sufficIcon() {
  return const Icon(
    Icons.keyboard_arrow_down_outlined,
    color: Colors.black,
  );
}

Future<T?> bottomSheetWidget<T>(
        {required BuildContext context,
        bool useFullBody = false,
        double? height,
        required Widget body,
        bool enableDrag = true,
        bool showDragHandle = false,
        bool keyboardPushToTop = true,
        bool tapoutsidedismiss = true,
        bool useInternalPadding = true,
        Color? backgroundcolor,
        Color? barriercolor,
        Offset? anchorPoint,
        String? title}) =>
    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundcolor ?? Colors.white,
      anchorPoint: anchorPoint,
      barrierColor: barriercolor ?? Colors.transparent,
      isScrollControlled: true,
      showDragHandle: showDragHandle,
      enableDrag: enableDrag,
      isDismissible: tapoutsidedismiss,
      shape: bottomSheetShape(),
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          height: height ?? 250,
          decoration: containerSheetDecoration(),
          child: useInternalPadding
              ? Padding(
                  padding: internalPadding(),
                  child: Column(
                    children: [const BottomSheetTop(), Expanded(child: body)],
                  ),
                )
              : Column(
                  children: [const BottomSheetTop(), Expanded(child: body)],
                ),
        ),
      ),
    );
RoundedRectangleBorder bottomSheetShape() {
  return RoundedRectangleBorder(
    borderRadius: sheetRadius(),
  );
}

EdgeInsets internalPadding() {
  return const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15);
}

BorderRadius sheetRadius() => const BorderRadius.only(
    topRight: Radius.circular(20), topLeft: Radius.circular(20));

BoxDecoration containerSheetDecoration() => BoxDecoration(
      color: Colors.white,
      border: const Border(
        left: BorderSide(
          color: Colors.black,
        ),
        right: BorderSide(
          color: Colors.black,
        ),
        top: BorderSide(
          color: Colors.black,
        ),
      ),
      borderRadius: sheetRadius(),
    );

class BottomSheetTop extends StatelessWidget {
  const BottomSheetTop({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 10,
          ),
          Container(
            width: 40,
            height: 2,
            decoration: BoxDecoration(
              color: ColorConv('#AFB1B9'),
              borderRadius: BorderRadius.circular(
                2,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
