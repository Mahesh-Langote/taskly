import 'package:flutter/material.dart';

class MarkdownHelpDialog extends StatelessWidget {
  const MarkdownHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.format_shapes, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Markdown Formatting Guide',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    'Headings',
                    [
                      _MarkdownExample(
                        markdown: '# Heading 1',
                        description: 'Largest heading',
                      ),
                      _MarkdownExample(
                        markdown: '## Heading 2',
                        description: 'Medium heading',
                      ),
                      _MarkdownExample(
                        markdown: '### Heading 3',
                        description: 'Small heading',
                      ),
                    ],
                    isDarkMode,
                  ),
                  _buildDivider(),
                  _buildSection(
                    'Emphasis',
                    [
                      _MarkdownExample(
                        markdown: '**Bold text**',
                        description: 'Bold text',
                      ),
                      _MarkdownExample(
                        markdown: '_Italic text_',
                        description: 'Italic text',
                      ),
                      _MarkdownExample(
                        markdown: '~~Strikethrough~~',
                        description: 'Strikethrough text',
                      ),
                    ],
                    isDarkMode,
                  ),
                  _buildDivider(),
                  _buildSection(
                    'Lists',
                    [
                      _MarkdownExample(
                        markdown: '- Item 1\n- Item 2\n- Item 3',
                        description: 'Bullet list',
                      ),
                      _MarkdownExample(
                        markdown:
                            '1. First item\n2. Second item\n3. Third item',
                        description: 'Numbered list',
                      ),
                    ],
                    isDarkMode,
                  ),
                  _buildDivider(),
                  _buildSection(
                    'Other Elements',
                    [
                      _MarkdownExample(
                        markdown: '> This is a quote',
                        description: 'Block quote',
                      ),
                      _MarkdownExample(
                        markdown: '`inline code`',
                        description: 'Inline code',
                      ),
                      _MarkdownExample(
                        markdown: '```\nCode block\nLine 2\n```',
                        description: 'Code block',
                      ),
                      _MarkdownExample(
                        markdown: '[Link text](https://example.com)',
                        description: 'Link',
                      ),
                      _MarkdownExample(
                        markdown: '![Alt text](image_url)',
                        description: 'Image',
                      ),
                      _MarkdownExample(
                        markdown: '---',
                        description: 'Horizontal rule',
                      ),
                    ],
                    isDarkMode,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 44),
              ),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      String title, List<_MarkdownExample> examples, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        ...examples.map((example) => _buildExample(example, isDarkMode)),
      ],
    );
  }

  Widget _buildExample(_MarkdownExample example, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                example.markdown,
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                example.description,
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Divider(),
    );
  }
}

class _MarkdownExample {
  final String markdown;
  final String description;

  const _MarkdownExample({
    required this.markdown,
    required this.description,
  });
}
