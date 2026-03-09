import 'package:flutter/material.dart';

const Set<ContextMenuButtonType> _allowedContextMenuButtons = {
  ContextMenuButtonType.selectAll,
  ContextMenuButtonType.cut,
  ContextMenuButtonType.copy,
  ContextMenuButtonType.paste,
};

Widget buildLimitedTextContextMenu(
  BuildContext context,
  EditableTextState editableTextState,
) {
  final filteredItems = editableTextState.contextMenuButtonItems
      .where((item) => _allowedContextMenuButtons.contains(item.type))
      .toList();

  if (filteredItems.isEmpty) {
    return const SizedBox.shrink();
  }

  return AdaptiveTextSelectionToolbar.buttonItems(
    anchors: editableTextState.contextMenuAnchors,
    buttonItems: filteredItems,
  );
}
