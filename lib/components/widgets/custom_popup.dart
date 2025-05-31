import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:chatmcp/utils/color.dart';

/// 自定义弹窗基础组件
/// 提供统一的弹窗样式和行为
class BasePopup extends StatelessWidget {
  /// 弹窗内容
  final Widget content;

  /// 触发弹窗的子组件
  final Widget child;

  /// 是否显示箭头
  final bool showArrow;

  /// 箭头颜色
  final Color? arrowColor;

  /// 背景颜色
  final Color? backgroundColor;

  /// 弹窗最大宽度
  final double? maxWidth;

  /// 弹窗最大高度
  final double? maxHeight;

  /// 弹窗边距
  final EdgeInsetsGeometry? margin;

  /// 弹窗内边距
  final EdgeInsets? padding;

  /// 弹窗圆角
  final BorderRadius? borderRadius;

  /// 弹窗阴影
  final List<BoxShadow>? boxShadow;

  const BasePopup({
    super.key,
    required this.content,
    required this.child,
    this.showArrow = true,
    this.arrowColor,
    this.backgroundColor,
    this.maxWidth,
    this.maxHeight,
    this.margin,
    this.padding,
    this.borderRadius,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveArrowColor =
        arrowColor ?? AppColors.getSidebarBackgroundColor(context);
    final effectiveBackgroundColor =
        backgroundColor ?? AppColors.getSidebarBackgroundColor(context);
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(8);
    final effectiveBoxShadow = boxShadow ??
        [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];

    return CustomPopup(
      showArrow: showArrow,
      arrowColor: effectiveArrowColor,
      backgroundColor: effectiveBackgroundColor,
      contentPadding: EdgeInsets.all(0),
      content: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? 280,
          maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.6,
        ),
        margin: margin,
        padding: padding ?? const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: AppColors.getSidebarBackgroundColor(context),
          borderRadius: effectiveBorderRadius,
          boxShadow: effectiveBoxShadow,
        ),
        child: content,
      ),
      child: child,
    );
  }
}

/// 带搜索功能的弹窗基础组件
class SearchablePopup extends StatefulWidget {
  /// 弹窗内容构建器，接收搜索文本作为参数
  final Widget Function(String searchText) contentBuilder;

  /// 触发弹窗的子组件
  final Widget child;

  /// 搜索框提示文本
  final String searchHint;

  /// 是否显示箭头
  final bool showArrow;

  /// 箭头颜色
  final Color? arrowColor;

  /// 背景颜色
  final Color? backgroundColor;

  /// 弹窗最大宽度
  final double? maxWidth;

  /// 弹窗最大高度
  final double? maxHeight;

  /// 搜索框变化回调
  final void Function(String)? onSearchChanged;

  const SearchablePopup({
    super.key,
    required this.contentBuilder,
    required this.child,
    this.searchHint = 'Search',
    this.showArrow = true,
    this.arrowColor,
    this.backgroundColor,
    this.maxWidth,
    this.maxHeight,
    this.onSearchChanged,
  });

  @override
  State<SearchablePopup> createState() => _SearchablePopupState();
}

class _SearchablePopupState extends State<SearchablePopup> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasePopup(
      showArrow: widget.showArrow,
      arrowColor: widget.arrowColor,
      backgroundColor: widget.backgroundColor,
      maxWidth: widget.maxWidth ?? 280,
      maxHeight: widget.maxHeight ?? MediaQuery.of(context).size.height * 0.6,
      padding: EdgeInsets.zero,
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter popupSetState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 搜索框
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0),
                child: TextField(
                  controller: _searchController,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.getThemeTextColor(context),
                      ),
                  decoration: InputDecoration(
                    hintText: widget.searchHint,
                    hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.getInactiveTextColor(context),
                        ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 16,
                      color: AppColors.getInactiveTextColor(context),
                    ),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: widget.backgroundColor ??
                        AppColors.getSidebarBackgroundColor(context),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  ),
                  onChanged: (value) {
                    popupSetState(() {
                      _searchText = value.toLowerCase();
                    });
                    widget.onSearchChanged?.call(value);
                  },
                ),
              ),
              // 内容区域
              Flexible(
                child: widget.contentBuilder(_searchText),
              ),
            ],
          );
        },
      ),
      child: widget.child,
    );
  }
}

/// 弹窗列表项组件
class PopupListItem extends StatelessWidget {
  /// 列表项内容
  final Widget child;

  /// 点击回调
  final VoidCallback? onTap;

  /// 是否选中
  final bool isSelected;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  /// 选中时的颜色
  final Color? selectedColor;

  const PopupListItem({
    super.key,
    required this.child,
    this.onTap,
    this.isSelected = false,
    this.padding,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(child: child),
            if (isSelected)
              Icon(
                Icons.check,
                size: 14,
                color: selectedColor ?? AppColors.getTextButtonColor(context),
              ),
          ],
        ),
      ),
    );
  }
}

/// 弹窗分组标题组件
class PopupGroupHeader extends StatelessWidget {
  /// 标题文本
  final String title;

  /// 图标
  final Widget? icon;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  const PopupGroupHeader({
    super.key,
    required this.title,
    this.icon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(16, 6, 16, 2),
      child: Row(
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: TextStyle(
              color: AppColors.getThemeTextColor(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// 弹窗分隔线组件
class PopupDivider extends StatelessWidget {
  /// 分隔线高度
  final double height;

  /// 左边距
  final double indent;

  /// 右边距
  final double endIndent;

  /// 分隔线颜色
  final Color? color;

  const PopupDivider({
    super.key,
    this.height = 1,
    this.indent = 8,
    this.endIndent = 8,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height,
      indent: indent,
      endIndent: endIndent,
      color: color ?? AppColors.getCodePreviewBorderColor(context),
    );
  }
}

/// 空状态组件
class PopupEmptyState extends StatelessWidget {
  /// 空状态文本
  final String message;

  /// 文本样式
  final TextStyle? textStyle;

  const PopupEmptyState({
    super.key,
    required this.message,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          message,
          style: textStyle ??
              Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.getInactiveTextColor(context),
                  ),
        ),
      ),
    );
  }
}

/// 底层弹窗实现组件
class CustomPopupWidget extends StatelessWidget {
  final Widget content;
  final Widget child;
  final bool showArrow;
  final Color arrowColor;
  final Color backgroundColor;

  const CustomPopupWidget({
    super.key,
    required this.content,
    required this.child,
    required this.showArrow,
    required this.arrowColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return BasePopup(
      showArrow: showArrow,
      arrowColor: arrowColor,
      backgroundColor: backgroundColor,
      content: content,
      child: child,
    );
  }
}

/// 自定义弹窗路由实现
class CustomPopupRoute extends StatelessWidget {
  final Widget content;
  final Widget child;
  final bool showArrow;
  final Color arrowColor;
  final Color backgroundColor;

  const CustomPopupRoute({
    super.key,
    required this.content,
    required this.child,
    required this.showArrow,
    required this.arrowColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // 现在使用 BasePopup 而不是直接使用 flutter_popup 包
    return BasePopup(
      showArrow: showArrow,
      arrowColor: arrowColor,
      backgroundColor: backgroundColor,
      content: content,
      child: child,
    );
  }
}

/*
使用示例：

1. 基础弹窗：
BasePopup(
  content: Text('弹窗内容'),
  child: ElevatedButton(
    onPressed: null,
    child: Text('点击显示弹窗'),
  ),
)

2. 带搜索的弹窗：
SearchablePopup(
  searchHint: '搜索...',
  contentBuilder: (searchText) {
    return Column(
      children: [
        PopupGroupHeader(title: '分组标题'),
        PopupListItem(
          child: Text('列表项'),
          onTap: () {},
          isSelected: true,
        ),
        PopupDivider(),
        PopupEmptyState(message: '没有找到结果'),
      ],
    );
  },
  child: Text('点击搜索'),
)
*/
