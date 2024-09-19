// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:novel_flutter_bit/db/preferences_db.dart';
import 'package:novel_flutter_bit/icons/novel_icon_icons.dart';
import 'package:novel_flutter_bit/pages/novel/enum/novel_read_font_weight_enum.dart';
import 'package:novel_flutter_bit/pages/novel/state/novel_read_state.dart';
import 'package:novel_flutter_bit/style/theme_enum.dart';
import 'package:novel_flutter_bit/style/theme_style.dart';
import 'package:novel_flutter_bit/tools/logger_tools.dart';
import 'package:novel_flutter_bit/tools/padding_extension.dart';
import 'package:novel_flutter_bit/tools/size_extension.dart';
import 'package:novel_flutter_bit/widget/slider_novel.dart';

class ShowSliderSheet extends StatefulWidget {
  ShowSliderSheet({
    super.key,
    required this.color,
    required this.value,
    required this.onChanged,
    required this.themeStyleProvider,
  });
  final Color color;
  late double value;
  final dynamic Function(dynamic)? onChanged;
  final ThemeStyleProvider themeStyleProvider;
  @override
  State<ShowSliderSheet> createState() => _ShowSliderSheetState();
}

class _ShowSliderSheetState extends State<ShowSliderSheet> {
  late Map<ThemeEnum, ThemeData> themes;
  @override
  void initState() {
    super.initState();
    themes = widget.themeStyleProvider.getThemeList();
    LoggerTools.looger.i(themes);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return DefaultTextStyle(
      style: TextStyle(
          fontWeight: FontWeight.w300,
          color: theme.textTheme.bodyLarge?.color,
          fontSize: 18),
      child: SizedBox(
        height: 400,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              10.verticalSpace,
              const Align(
                  child: Text(
                "设置",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              )),
              20.verticalSpace,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text("字体大小：${NovelReadState.size.toInt()}"),
              ),
              SliderNovel(
                color: widget.color,
                value: widget.value,
                onChanged: (p0) {
                  widget.value = p0;
                  setState(() {});
                  if (widget.onChanged != null) {
                    widget.onChanged!(widget.value);
                  }
                },
              ),
              10.verticalSpace,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("主题选择"),
                    5.verticalSpace,
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: _getThemeListWidget(),
                    ),
                    20.verticalSpace,
                    const Text("字体粗细"),
                    5.verticalSpace,
                    Wrap(
                        spacing: 8,
                        runSpacing: 10,
                        children: _getFontWeightList()),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// 获取主题列表
  List<Widget> _getThemeListWidget() {
    List<Widget> list = [];
    for (int i = 0; i < themes.length; i++) {
      final key = themes.keys.elementAt(i);
      final value = themes[key];
      final isSelected =
          widget.themeStyleProvider.theme.primaryColor == value!.primaryColor;
      Widget child = GestureDetector(
          onTap: () => widget.themeStyleProvider.setTheme(key),
          child: Container(
              width: 37,
              height: 37,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                color: value.primaryColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: isSelected
                  ? const Icon(
                      NovelIcon.meteor,
                      color: Colors.white,
                      size: 20,
                    )
                  : 0.verticalSpace));
      list.add(child);
    }
    return list;
  }

  /// 获取字体大小 列表
  List<Widget> _getFontWeightList() {
    return NovelReadFontWeightEnum.values.map((value) {
      final isSelect = value == NovelReadState.weight;
      final colorTheme = widget.themeStyleProvider.theme;
      return GestureDetector(
        onTap: () {
          setState(() {
            NovelReadState.weight = value;
          });
          PreferencesDB.instance.setNovleFontWeight(value);
          if (widget.onChanged != null) {
            widget.onChanged!(widget.value);
          }
        },
        child: AnimatedContainer(
            width: 50,
            padding: 5.padding,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black12, width: .2),
                borderRadius: BorderRadius.circular(5),
                color: isSelect
                    ? colorTheme.primaryColor
                    : colorTheme.primaryColor.withOpacity(.4)),
            duration: Durations.medium4,
            child: Text(value.name,
                style: TextStyle(shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.4),
                    offset: const Offset(1, 1),
                    blurRadius: 5,
                  ),
                ], fontSize: 16, color: Colors.white))),
      );
    }).toList();
  }
}
