part of im_kit;

/////////////////////////////////////////////////////////////////////////
///
/// All rights reserved.
///
/// author: Spicely
///
/// Summary: 适用多平台的AppBar
///
/// Date: 2024年09月13日 22:15:15 Friday
///
//////////////////////////////////////////////////////////////////////////

class ImAppBar extends AppBar {
  final Widget? label;

  ImAppBar({
    Key? key,
    this.label,
    List<Widget>? actions,
  }) : super(
          key: key,
          automaticallyImplyLeading: Utils.isMobile,
          title: Padding(
            padding: EdgeInsets.only(top: ImKitIsolateManager.winBarHeight),
            child: label,
          ),
          toolbarHeight: AppBar().preferredSize.height + ImKitIsolateManager.winBarHeight,
          actions: actions?.map((action) {
            return Padding(
              padding: EdgeInsets.only(top: ImKitIsolateManager.winBarHeight),
              child: action, // 为每个 action 添加顶部间距
            );
          }).toList(),
        );
}
