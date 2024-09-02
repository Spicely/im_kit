// part of im_kit;

// const double _kToolbarScreenPadding = 8.0;
// const double _kToolbarWidth = 90.0;

// class EditActions extends StatelessWidget {
//   final ExtendedEditableTextState editableTextState;

//   const EditActions({
//     super.key,
//     required this.editableTextState,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final double paddingAbove = MediaQuery.paddingOf(context).top + _kToolbarScreenPadding;
//     final Offset localAdjustment = Offset(_kToolbarScreenPadding, paddingAbove);
//     return Padding(
//         padding: MenuFlyout.itemsPadding,
//         child: CustomSingleChildLayout(
//           delegate: DesktopTextSelectionToolbarLayoutDelegate(
//             anchor: editableTextState.contextMenuAnchors.primaryAnchor - localAdjustment,
//           ),
//           child: SizedBox(
//             width: _kToolbarWidth,
//             child: Acrylic(
//               elevation: 8,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//               child: ListView(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 children: [
//                   if (editableTextState.selectAllEnabled)
//                     ListTileMenu.selectable(
//                       onSelectionChange: (_) {},
//                       title: SizedBox(width: _kToolbarWidth, child: Text('全选', style: const TextStyle(fontSize: 12).useSystemChineseFont())),
//                       onPressed: () {
//                         editableTextState.selectAll(SelectionChangedCause.toolbar);
//                       },
//                     ),
//                   FutureBuilder(
//                     future: Pasteboard.image,
//                     builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
//                       if (snapshot.hasData) {
//                         return ListTileMenu.selectable(
//                           onSelectionChange: (_) {},
//                           title: SizedBox(width: _kToolbarWidth, child: Text('粘贴', style: const TextStyle(fontSize: 12).useSystemChineseFont())),
//                           onPressed: () async {
//                             if (snapshot.data != null) {
//                               String path = await ImKitIsolateManager.saveBytesToTemp(snapshot.data!);
//                               final TextEditingValue textEditingValue = editableTextState.textEditingValue;
//                               final TextSelection selection = textEditingValue.selection;
//                               final int lastSelectionIndex = max(selection.baseOffset, selection.extentOffset);
//                               final TextEditingValue collapsedTextEditingValue = textEditingValue.copyWith(
//                                 selection: TextSelection.collapsed(offset: lastSelectionIndex),
//                               );
//                               String text = '[file:$path]';
//                               editableTextState.userUpdateTextEditingValue(
//                                 collapsedTextEditingValue.replaced(selection, text),
//                                 SelectionChangedCause.toolbar,
//                               );
//                               SchedulerBinding.instance.addPostFrameCallback((_) {
//                                 if (context.mounted) {
//                                   editableTextState.bringIntoView(textEditingValue.selection.extent);
//                                 }
//                               }, debugLabel: 'EditableText.bringSelectionIntoView');
//                               editableTextState.hideToolbar();
//                             }
//                           },
//                         );
//                       } else {
//                         return const SizedBox();
//                       }
//                     },
//                   ),
//                   if (editableTextState.pasteEnabled)
//                     ListTileMenu.selectable(
//                       onSelectionChange: (_) {},
//                       title: SizedBox(width: _kToolbarWidth, child: Text('粘贴', style: const TextStyle(fontSize: 12).useSystemChineseFont())),
//                       onPressed: () {
//                         editableTextState.pasteText(SelectionChangedCause.toolbar);
//                       },
//                     ),
//                   if (editableTextState.cutEnabled)
//                     ListTileMenu.selectable(
//                       onSelectionChange: (_) {},
//                       title: SizedBox(width: _kToolbarWidth, child: Text('剪切', style: const TextStyle(fontSize: 12).useSystemChineseFont())),
//                       onPressed: () {
//                         editableTextState.cutSelection(SelectionChangedCause.toolbar);
//                       },
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ));
//   }
// }
