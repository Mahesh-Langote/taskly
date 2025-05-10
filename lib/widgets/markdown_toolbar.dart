import 'package:flutter/material.dart';

class MarkdownToolbar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onInsert;

  const MarkdownToolbar({
    super.key,
    required this.controller,
    required this.onInsert,
  });

  void _insertMarkdown(String markdownSyntax, {String? placeholder}) {
    final currentText = controller.text;
    final selection = TextSelection.fromPosition(controller.selection.base);
    final beforeCursor = currentText.substring(0, selection.baseOffset);
    final afterCursor = currentText.substring(selection.baseOffset);

    final textToInsert = placeholder != null
        ? markdownSyntax.replaceAll('__placeholder__', placeholder)
        : markdownSyntax;

    final newText = beforeCursor + textToInsert + afterCursor;

    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: beforeCursor.length + textToInsert.length,
      ),
    );

    onInsert(newText);
  }

  void _insertWithSelection(String before, String after) {
    final currentText = controller.text;
    final selection = controller.selection;

    if (selection.isValid && !selection.isCollapsed) {
      // Text is selected, wrap it with markdown syntax
      final selectedText =
          currentText.substring(selection.start, selection.end);
      final newText = currentText.replaceRange(
          selection.start, selection.end, '$before$selectedText$after');

      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection(
          baseOffset: selection.start +
              before.length +
              selectedText.length +
              after.length,
          extentOffset: selection.start +
              before.length +
              selectedText.length +
              after.length,
        ),
      );

      onInsert(newText);
    } else {
      // No text selected, just insert placeholder
      _insertMarkdown('${before}__placeholder__${after}', placeholder: 'text');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildToolbarButton(
              icon: Icons.format_bold,
              tooltip: 'Bold',
              onPressed: () => _insertWithSelection('**', '**'),
            ),
            _buildToolbarButton(
              icon: Icons.format_italic,
              tooltip: 'Italic',
              onPressed: () => _insertWithSelection('_', '_'),
            ),
            _buildToolbarButton(
              icon: Icons.format_strikethrough,
              tooltip: 'Strikethrough',
              onPressed: () => _insertWithSelection('~~', '~~'),
            ),
            _buildToolbarDivider(),
            _buildToolbarButton(
              icon: Icons.title,
              tooltip: 'Heading',
              onPressed: () =>
                  _insertMarkdown('## __placeholder__', placeholder: 'Heading'),
            ),
            _buildToolbarButton(
              icon: Icons.format_quote,
              tooltip: 'Quote',
              onPressed: () =>
                  _insertMarkdown('> __placeholder__', placeholder: 'Quote'),
            ),
            _buildToolbarDivider(),
            _buildToolbarButton(
              icon: Icons.format_list_bulleted,
              tooltip: 'Bullet List',
              onPressed: () => _insertMarkdown('\n- __placeholder__',
                  placeholder: 'List item'),
            ),
            _buildToolbarButton(
              icon: Icons.format_list_numbered,
              tooltip: 'Numbered List',
              onPressed: () => _insertMarkdown('\n1. __placeholder__',
                  placeholder: 'List item'),
            ),
            _buildToolbarDivider(),
            _buildToolbarButton(
              icon: Icons.code,
              tooltip: 'Code',
              onPressed: () => _insertWithSelection('`', '`'),
            ),
            _buildToolbarButton(
              icon: Icons.code_outlined,
              tooltip: 'Code Block',
              onPressed: () => _insertMarkdown('\n```\n__placeholder__\n```\n',
                  placeholder: 'Code'),
            ),
            _buildToolbarDivider(),
            _buildToolbarButton(
              icon: Icons.link,
              tooltip: 'Link',
              onPressed: () => _insertMarkdown('[__placeholder__](url)',
                  placeholder: 'Link text'),
            ),

            _buildToolbarButton(
              icon: Icons.table_chart_outlined,
              tooltip: 'Table',
              onPressed: () => _insertMarkdown(
                  '\n| Column 1 | Column 2 | Column 3 |\n| -------- | -------- | -------- |\n| Cell 1   | Cell 2   | Cell 3   |\n'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarDivider() {
    return Container(
      height: 24,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.grey.withOpacity(0.5),
    );
  }
}
