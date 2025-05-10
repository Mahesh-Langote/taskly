import 'package:flutter/material.dart';

class TagInputChip extends StatefulWidget {
  final Function(String) onTagAdded;
  final Function(String) onTagRemoved;
  final List<String> initialTags;
  final String hint;

  const TagInputChip({
    super.key,
    required this.onTagAdded,
    required this.onTagRemoved,
    this.initialTags = const [],
    this.hint = 'Add a tag',
  });

  @override
  State<TagInputChip> createState() => _TagInputChipState();
}

class _TagInputChipState extends State<TagInputChip> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.initialTags);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    tag = tag.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        widget.onTagAdded(tag);
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDarkMode
                      ? Colors.grey.shade800.withOpacity(0.5)
                      : Colors.grey.shade100,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onSubmitted: (value) {
                  _addTag(value);
                  _focusNode.requestFocus();
                },
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                _addTag(_controller.text);
                _focusNode.requestFocus();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(14),
              ),
              child: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _tags.map((tag) {
            return Chip(
              label: Text(tag),
              onDeleted: () {
                setState(() {
                  _tags.remove(tag);
                  widget.onTagRemoved(tag);
                });
              },
              backgroundColor: theme.primaryColor.withOpacity(0.2),
            );
          }).toList(),
        ),
      ],
    );
  }
}
