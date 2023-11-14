// import 'dart:async';
// import 'dart:ui' as ui;
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';

part of im_kit;

Widget SelectMenuItem({
  required String t,
  required void Function() onTap,
  required Widget icon,
}) {
  return GestureDetector(
    onTap:onTap,
    child: Container(
      width: ImMessageTheme.ctxMenuW,
      height: ImMessageTheme.ctxMenuH,
      color: Colors.black87,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(width:ImMessageTheme.ctxMenuIconW, height:ImMessageTheme.ctxMenuIconH,child:Center(child:icon)),
          SizedBox(height:ImMessageTheme.ctxMenuGap),
          Container(
            // margin: const EdgeInsets.only(top: 2),
            child: Text(
              t,
              style: ImMessageTheme.ctxMenuStyle,
            ),
          ),
        ],
      ),
    ),
  );
}


class SelectableTextRich extends StatelessWidget {
  TextSelection? _selection;
  SelectionChangedCause? _cause;
  EditableTextState? _editableTextState;
  SelectableTextRich({
    super.key,
    required this.textSpan,
    required this.menus,
    required this.controller,
    required this.arrowColor,
    required this.mw,
    required this.mh,
  });

  SelectableTextRichController controller;
  final TextSpan textSpan;
  final Color arrowColor;
  final double mw;
  final double mh;
  final Widget menus;
  @override
  Widget build(BuildContext context) {
    controller.bindingState(this);
    return SelectableText.rich(///其它属性自己加**********************
      textSpan,
      onSelectionChanged: (selection,cause) {
        _cause=cause;_selection=selection;
        controller.bindingState(this);
      },
      contextMenuBuilder: (c, editableTextState) {
        _editableTextState=editableTextState;
        controller.bindingState(this);
        return TextSelectionToolbarWidget(
          anchorAbove: editableTextState.contextMenuAnchors.primaryAnchor,
          // anchors:editableTextState.contextMenuAnchors,
          anchorBelow: editableTextState.contextMenuAnchors.secondaryAnchor == null? editableTextState.contextMenuAnchors.primaryAnchor : editableTextState.contextMenuAnchors.secondaryAnchor!,
          menu:menus, mh: mh, mw: mw,
          arrowColor:arrowColor,
        );
      },
    );
  }

}



///控制器
class SelectableTextRichController{
  SelectableTextRichController();

  SelectableTextRich? _state;

  void bindingState(SelectableTextRich state) {
    _state = state;
  }

  ///选中所有
  void selectAll(){
    Future.delayed(Duration(milliseconds:30)).then((value){
      if(_state==null)return;
      if(_state?._editableTextState==null)return;
      if(_state?._cause==null)return;
      _state?._editableTextState!.selectAll(_state!._cause!);///选中全部
    });
  }

  ///清楚选中的文本和影藏菜单
  void clearSelAndTool(){
    Future.delayed(Duration(milliseconds:30)).then((value){
      if(_state==null)return;
      if(_state?._editableTextState==null)return;
      if(_state?._cause==null)return;
      _state?._editableTextState?.hideToolbar();
      _state?._editableTextState!.userUpdateTextEditingValue(
        _state!._editableTextState!.textEditingValue.copyWith(
          selection: TextSelection.collapsed(offset: -1),
        ),
        _state?._cause,
      );
    });
  }

  ///复制选中
  void copySelected(){
    Future.delayed(Duration(milliseconds:30)).then((value){
      if(_state==null)return;
      if(_state?._editableTextState==null)return;
      if(_state?._cause==null)return;
      _state!._editableTextState!.copySelection(_state!._cause!);///选中的复制到剪贴板
    });
  }


  ///为了滚动!!!!!!!的时候重新计算位置
  ///隐藏菜单
  void hideToolbar(){
    Future.delayed(Duration(milliseconds:30)).then((value){
      if(_state==null)return;
      if(_state?._editableTextState==null)return;
      if(_state?._cause==null)return;
      _state?._editableTextState?.hideToolbar();///选中的复制到剪贴板
    });
  }
  ///显示菜单
  void showToolbar(){
    Future.delayed(Duration(milliseconds:30)).then((value){
      if(_state==null)return;
      if(_state?._editableTextState==null)return;
      if(_state?._cause==null)return;
      _state?._editableTextState?.showToolbar();
      var _baseOffset;
      var _extentOffset;
      var baseOffset=_state!._selection!.baseOffset;
      var extentOffset=_state!._selection!.extentOffset;
      if(baseOffset<extentOffset){
        _baseOffset=baseOffset;
        _extentOffset=extentOffset;
      }else{
        _baseOffset=extentOffset;
        _extentOffset=baseOffset;
      }
      ///如果当前的位置为 TextSelection(baseOffset:6, extentOffset:9)
      /// 他不会出现拖拽圆球，   隐藏菜单 - 显示菜单 - 设置位置TextSelection(baseOffset:6, extentOffset:9)
      /// 解决 隐藏菜单 - 显示菜单 - 设置位置TextSelection(baseOffset:9, extentOffset:6)  - 显示菜单TextSelection(baseOffset:6, extentOffset:9)
      _state?._editableTextState!.userUpdateTextEditingValue(
        _state!._editableTextState!.textEditingValue.copyWith(selection: TextSelection(baseOffset:_extentOffset, extentOffset:_baseOffset),),
        _state?._cause,
      );
      Future.delayed(Duration(milliseconds: 1)).then((value){
        _state?._editableTextState!.userUpdateTextEditingValue(
          _state!._editableTextState!.textEditingValue.copyWith(selection: TextSelection(baseOffset:_baseOffset, extentOffset:_extentOffset),),
          _state?._cause,
        );
      });
    });
  }

  void dispose() {
    _state=null;
  }
}


//https://blog.csdn.net/gloryFlow/article/details/132970840

class _RenderCupertinoTextSelectionToolbarShape extends RenderShiftedBox {
  Size kToolbarArrowSize;
  double mh;
  // double mw;
  _RenderCupertinoTextSelectionToolbarShape(
      this._anchor,
      this._isAbove,
      super.child,
      {
        this.kToolbarArrowSize=const Size(14.0, 7.0),
        this.mh=100.0,
      }
      );

  @override
  bool get isRepaintBoundary => true;

  Offset get anchor => _anchor;
  Offset _anchor;
  set anchor(Offset value) {
    if (value == _anchor) {
      return;
    }
    _anchor = value;
    markNeedsLayout();
  }

  bool get isAbove => _isAbove;
  bool _isAbove;
  set isAbove(bool value) {
    if (_isAbove == value) {
      return;
    }
    _isAbove = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    if (child == null) {
      return;
    }
    final BoxConstraints enforcedConstraint = constraints.loosen();
    ///整个元素的高度 === TextSelectionToolbarWidget中的child高度 + 箭头高度 （kToolbarArrowSize.height）
    ///出现在上方的时候 不用+7 ，出现在下方的时候要加 +7
    var heightConstraint = BoxConstraints.tightFor(height:kToolbarArrowSize.height+mh);///
    child!.layout(heightConstraint.enforce(enforcedConstraint), parentUsesSize: true);
    final BoxParentData childParentData = child!.parentData! as BoxParentData;
    childParentData.offset = Offset(
      0.0,
      _isAbove ? -kToolbarArrowSize.height : 0.0,///菜单出现在上方的时候，与箭头之间的距离
    );
    size = Size(
      child!.size.width,
      child!.size.height - kToolbarArrowSize.height,
    );
  }
  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) {
      return;
    }
    final BoxParentData childParentData = child!.parentData! as BoxParentData;
    _clipPathLayer.layer = context.pushClipPath(
      needsCompositing,
      offset + childParentData.offset,
      Offset.zero & child!.size,
      _clipPath(),
          (PaintingContext innerContext, Offset innerOffset){
        // return innerContext.paintChild(child!, Offset(innerOffset.dx,innerOffset.dy));
        // return innerContext.paintChild(child!, Offset(innerOffset.dx,0));
        return innerContext.paintChild(child!, Offset(innerOffset.dx,innerOffset.dy));
      },
      oldLayer: _clipPathLayer.layer,
    );
  }

  // The path is described in the toolbar's coordinate system.
  Path _clipPath() {
    final BoxParentData childParentData = child!.parentData! as BoxParentData;
    final Path rrect = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset(0.0, kToolbarArrowSize.height)
          & Size(
            child!.size.width,
            child!.size.height - kToolbarArrowSize.height * 2,
          ),
          Radius.circular(8),
        ),
      );

    final Offset localAnchor = globalToLocal(_anchor);
    final double centerX = childParentData.offset.dx + child!.size.width / 2;
    final double arrowXOffsetFromCenter = localAnchor.dx - centerX;
    final double arrowTipX = child!.size.width / 2 + arrowXOffsetFromCenter;

    final double arrowBaseY = _isAbove
        ? child!.size.height - kToolbarArrowSize.height
        : kToolbarArrowSize.height;

    final double arrowTipY = _isAbove ? child!.size.height : 0;

    final Path arrow = Path()
      ..moveTo(arrowTipX, arrowTipY)
      ..lineTo(arrowTipX - kToolbarArrowSize.width / 2, arrowBaseY)
      ..lineTo(arrowTipX + kToolbarArrowSize.width / 2, arrowBaseY)
      ..close();

    return Path.combine(PathOperation.union, rrect, arrow);
  }

  final LayerHandle<ClipPathLayer> _clipPathLayer = LayerHandle<ClipPathLayer>();
  Paint? _debugPaint;

  @override
  void dispose() {
    _clipPathLayer.layer = null;
    super.dispose();
  }

  @override
  void debugPaintSize(PaintingContext context, Offset offset) {
    assert(() {
      if (child == null) {
        return true;
      }

      _debugPaint ??= Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          const Offset(10.0, 10.0),
          const <Color>[Color(0x00000000), Color(0xFFFF00FF), Color(0xFFFF00FF), Color(0x00000000)],
          const <double>[0.25, 0.25, 0.75, 0.75],
          TileMode.repeated,
        )
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      final BoxParentData childParentData = child!.parentData! as BoxParentData;
      context.canvas.drawPath(_clipPath().shift(offset + childParentData.offset), _debugPaint!);
      return true;
    }());
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, { required Offset position }) {
    // Positions outside of the clipped area of the child are not counted as
    // hits.
    final BoxParentData childParentData = child!.parentData! as BoxParentData;
    final Rect hitBox = Rect.fromLTWH(
      childParentData.offset.dx,
      childParentData.offset.dy + kToolbarArrowSize.height,
      child!.size.width,
      child!.size.height - kToolbarArrowSize.height * 2,
    );
    if (!hitBox.contains(position)) {
      return false;
    }

    return super.hitTestChildren(result, position: position);
  }
}

class _CupertinoTextSelectionToolbarShape extends SingleChildRenderObjectWidget {
  final Offset _anchor;
  final bool _isAbove;
  final double mh;
  final double mw;
  final kToolbarArrowSize;

  const _CupertinoTextSelectionToolbarShape({
    required Offset anchor,
    required bool isAbove,
    required this.mh,
    required this.mw,
    this.kToolbarArrowSize = const Size(14.0, 7.0),
    super.child,
  }) : _anchor = anchor, _isAbove = isAbove;



  @override
  _RenderCupertinoTextSelectionToolbarShape createRenderObject(BuildContext context) => _RenderCupertinoTextSelectionToolbarShape(
    _anchor,
    _isAbove,
    null,
    mh: mh,
    kToolbarArrowSize:kToolbarArrowSize,
  );

  @override
  void updateRenderObject(BuildContext context, _RenderCupertinoTextSelectionToolbarShape renderObject) {
    renderObject..anchor = _anchor..isAbove = _isAbove;
  }
}


class TextSelectionToolbarWidget extends StatelessWidget {
  Size kToolbarArrowSize=const Size(14.0, 7.0);
  Color arrowColor;
  double mh;///菜单的高度
  double mw;///菜单的宽度
  double kHeight;///菜单的高度
  double kContentDistance = 8.0;///菜单在上方的时候与元素之间的距离
  static const double kContentDistanceBelow = 16.0 - 2.0;///菜单在下方的时候与元素之间的距离
  final Offset anchorAbove;
  final Offset anchorBelow;
  final Widget menu;
  /// Creates an instance of TextSelectionToolbar.
  TextSelectionToolbarWidget({
    super.key,
    required this.menu,
    required this.anchorAbove,
    required this.anchorBelow,
    required this.arrowColor,
    this.kHeight = 146.0,
    required this.mh,
    required this.mw,
    // this.toolbarBuilder = _defaultToolbarBuilder,
  });

  Widget toolbarBuilder(BuildContext context, Offset anchor, bool isAbove, Widget child) {
    final Widget outputChild = _CupertinoTextSelectionToolbarShape(
        anchor: anchor,
        isAbove: isAbove,
        child:Container(
          color:arrowColor,
          padding: EdgeInsets.only(top: kToolbarArrowSize.height),
          child: child,
        ),
        mh:mh+kToolbarArrowSize.height,
        mw:mw,
        kToolbarArrowSize :kToolbarArrowSize
    );
    // return outputChild;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.zero),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.1),
            blurRadius: 15.0,
            offset: Offset( 0.0,isAbove ? 0.0 : Size(14.0, 7.0).height),
          ),
        ],
      ),
      child: outputChild,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Offset anchorAbovePadded = anchorAbove - Offset(0.0, kContentDistance);///x轴是中箭头的中心位置
    final Offset anchorBelowPadded = anchorBelow + const Offset(0.0, kContentDistanceBelow);///x轴是中箭头的中心位置
    const double screenPadding = 8.0;///距离屏幕的安全范围
    final double paddingAbove = MediaQuery.paddingOf(context).top+ screenPadding;
    final double availableHeight = anchorAbovePadded.dy - kContentDistance - paddingAbove;
    final bool fitsAbove = kHeight <= availableHeight;///是否显示在文本上面
    final Offset localAdjustment = Offset(screenPadding, paddingAbove);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        screenPadding,
        paddingAbove,
        screenPadding,
        screenPadding,
      ),
      child: CustomSingleChildLayout(
        delegate: TextSelectionToolbarLayoutDelegate(
          anchorAbove: anchorAbovePadded - localAdjustment,
          anchorBelow: anchorBelowPadded - localAdjustment,
          fitsAbove: fitsAbove,
        ),
        child: toolbarBuilder(context,anchorAbovePadded,fitsAbove,menu),
      ),
    );
  }
}
