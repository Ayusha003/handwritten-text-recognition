import 'package:flutter/material.dart';
import 'package:flutter_placeholder_textlines/placeholder_lines.dart';
import 'package:translator_project/core/styles/app_text_styles.dart';

class EditableTextWidget extends StatefulWidget {
  final String initialText;

  const EditableTextWidget({Key? key, required this.initialText}) : super(key: key);

  @override
  State<EditableTextWidget> createState() => _EditableTextWidgetState();
}

class _EditableTextWidgetState extends State<EditableTextWidget> {
  bool isEditing = false;
  bool isGeneratingText = false; // assuming this is part of your logic
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      maxLines: null,
      style: AppTextStyles.textStyleSFProText,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Edit text here',
      ),
    );
  }
}
