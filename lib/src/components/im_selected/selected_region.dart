// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
//


part of im_kit;

class SelectionAreaWidgetController{
  final double screenHeight;
  final double safeTop;
  final double safeBot;
  Widget Function(Offset anchorAbove,Offset anchorBelow,SelectionAreaWidgetController intance)? showCtxmenusBuilder;
  ///控制图片的弹窗
  GlobalKey? globalKey;
  ContextMenuController? ctxMenuctr;
  final bool isWidget;
  bool canShowWidget=false;
  SelectionAreaWidgetController({
    this.globalKey,
    this.ctxMenuctr,
    this.showCtxmenusBuilder,
    required this.screenHeight,
    required this.safeTop,
    required this.safeBot,
    this.isWidget=false,
  });

  showCtxmenus(BuildContext context,{bool? canShow}){
    if(canShow!=null)canShowWidget=canShow;
    if(canShow==false)return;
    if(globalKey==null)return;
    if(ctxMenuctr==null)return;
    if(showCtxmenusBuilder==null)return;
    RenderBox? renderBox = globalKey!.currentContext?.findRenderObject() as RenderBox;
    var h=renderBox.size.height;var w=renderBox.size.width;
    var offset = renderBox.localToGlobal(Offset.zero); ///组件左上角坐标
    var topCenter=Offset(offset.dx+w/2, offset.dy);///获取元素上边中点的位置
    var botCenter=Offset(offset.dx+w/2, offset.dy+h);///获取元素下边中点的位置
    ///计算是否超出边界
    if(isCanShowForWidget(topCenter,botCenter)&&canShowWidget==true){
      ctxMenuctr?.show(context: context, contextMenuBuilder:(c)=>showCtxmenusBuilder!(topCenter,botCenter,this));
    }else{
      canShowWidget=false;
      ctxMenuctr?.remove();
    }
  }
  hideCtxMenus(){
    ctxMenuctr?.remove();
  }

  ///控制文本的弹窗
  SelectionAreaWidget? _state;
  void bindingState(SelectionAreaWidget state) {
    _state = state;
  }
  ///清楚选中区域
  clearSelection(){
    if(_state==null||_state?.selectableRegionState==null)return;
    hideToolbar();
    _state?.selectableRegionState?.clearSelection();
    _state?.selectableRegionState=null;
  }
  ///复制选中的部分
  copySelected()async{
    if(_state==null||_state?.selectableRegionState==null)return;
    _state?.selectableRegionState?.copySelected();
  }
  ///选中全部
  selectAll(){
    if(_state==null||_state?.selectableRegionState==null)return;
    _state?.selectableRegionState?.selectAll(SelectionChangedCause.toolbar);
  }
  ///为了滚动重新计算，隐藏手柄不取消选中
  hideToolbar(){
    if(_state==null||_state?.selectableRegionState==null)return;
    _state?.selectableRegionState?.hideToolbar();
  }
  ///为了滚动重新计算，显示手柄
  showToolbar(){
    if(_state==null||_state?.selectableRegionState==null)return;
    ///计算是否超出边界
    if(isCanShowForRich){
      _state?.selectableRegionState?.showToolbar();
    }else{
      _state?.selectableRegionState?.clearSelection();
    }
  }
  ///计算是否超出边界
  bool get isCanShowForRich {
    if(_state!.selectableRegionState?.contextMenuAnchorsCan==false)return false;
    Offset above=_state!.selectableRegionState!.contextMenuAnchors.primaryAnchor;
    Offset below=_state!.selectableRegionState!.contextMenuAnchors.secondaryAnchor == null? _state!.selectableRegionState!.contextMenuAnchors.primaryAnchor : _state!.selectableRegionState!.contextMenuAnchors.secondaryAnchor!;
    ///判断在顶部是否能够展示；below.dy < appbar的高度 = 文字已经在appbar下面了 , 不能展示
    if(below.dy<safeTop)return false;
    ///判断在底部部是否能够展示；above.dy >（ 屏幕高度 - 底部功能区域高度 ），文字已经在底部功能区域高度下面了, 不能展示
    if(above.dy>(screenHeight-safeBot))return false;
    return true;
  }
  ///计算是否超出边界
  bool isCanShowForWidget(Offset above,Offset below) {
    // Offset above=_state!.selectableRegionState!.contextMenuAnchors.primaryAnchor;
    // Offset below=_state!.selectableRegionState!.contextMenuAnchors.secondaryAnchor == null? _state!.selectableRegionState!.contextMenuAnchors.primaryAnchor : _state!.selectableRegionState!.contextMenuAnchors.secondaryAnchor!;
    ///判断在顶部是否能够展示；below.dy < appbar的高度 = 文字已经在appbar下面了 , 不能展示
    if(below.dy<safeTop)return false;
    ///判断在底部部是否能够展示；above.dy >（ 屏幕高度 - 底部功能区域高度 ），文字已经在底部功能区域高度下面了, 不能展示
    if(above.dy>(screenHeight-safeBot))return false;
    return true;
  }


  showPop({BuildContext? context,bool? canShow}){
    if(isWidget){
      showCtxmenus(context!,canShow:canShow);
    }else{
      showToolbar();
    }
  }
  hidePop(){
    if(isWidget){
      hideCtxMenus();
    }else{
      hideToolbar();
    }
  }
  clear(){
    hideCtxMenus();
    clearSelection();
  }
}

class SelectionAreaWidget extends StatelessWidget {
  SelectedContent? selection;
  csr.CustomSelectableRegionState? selectableRegionState;
  SelectionAreaWidget({
    super.key,
    required this.child,
    required this.controller,
    required this.builder,
  });
  final SelectionAreaWidgetController controller;
  final Widget child;
  Widget Function(BuildContext, csr.CustomSelectableRegionState,SelectedContent? selection) builder;

  @override
  Widget build(BuildContext context) {
    controller.bindingState(this);
    return csa.CustomSelectionArea(
      contextMenuBuilder: (c, state) {
        selectableRegionState=state;
        controller.bindingState(this);
        return builder(c,state,selection);
      },
      onSelectionChanged: (s){selection=s;controller.bindingState(this);},
      child: SelectionContainer(
        // registrar: customSelectionRegistrar,
          delegate: SelectAllContainerDelegate(),
          child:child
      ),
    );
  }
}

class CtxMenusWidget {
  GlobalKey? globalKey;
  SelectionAreaWidgetController? controller;
  Widget widget;
  CtxMenusWidget(this.widget,{this.controller,this.globalKey});
}

/*
长按第一次全选元素
Padding(
  padding: EdgeInsets.symmetric(vertical:10,horizontal:10),
  child:SelectionArea(
    child: SelectionContainer(
      delegate: SelectAllContainerDelegate(),
      child:Text('Rowadwadaad阿瓦达多爱我的啊wdadadadad',style: TextStyle(color: Colors.red,height:1.0)),
    ),
  ),
)
*/
class SelectAllContainerDelegate extends MultiSelectableSelectionContainerDelegate {
  bool _isSelected = true;
  Timer? timer;
  @override
  void ensureChildUpdated(Selectable selectable) {
    if (_isSelected) {
      dispatchSelectionEventToChild(selectable, const SelectAllSelectionEvent());
    }
  }
  @override
  SelectionResult handleSelectWord(SelectWordSelectionEvent event) {
    return handleSelectAll(const SelectAllSelectionEvent());
  }

  @override
  SelectionResult handleSelectionEdgeUpdate(SelectionEdgeUpdateEvent event) {
    if(_isSelected){
      final Rect containerRect =Rect.fromLTWH(0, 0, containerSize.width, containerSize.height);
      final Matrix4 globalToLocal = getTransformTo(null)..invert();
      final Offset localOffset =MatrixUtils.transformPoint(globalToLocal, event.globalPosition);
      timer?.cancel();
      timer=null;
      timer=Timer(Duration(milliseconds:60),(){
        if(_isSelected==true)_isSelected=false;
        timer?.cancel();
      });
      return SelectionUtils.getResultBasedOnRect(containerRect, localOffset);
    }
    return  super.handleSelectionEdgeUpdate(event);
  }

  @override
  SelectionResult handleClearSelection(ClearSelectionEvent event) {
    _isSelected = false;
    return super.handleClearSelection(event);
  }

  @override
  SelectionResult handleSelectAll(SelectAllSelectionEvent event) {
    _isSelected = true;
    return super.handleSelectAll(event);
  }
}

