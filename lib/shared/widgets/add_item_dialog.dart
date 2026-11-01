import 'package:flutter/material.dart';

void showAddDialog(
  BuildContext context, {
  required String title,
  required String hint,
  required ValueChanged<String> onSave,
}) {
  final controller = TextEditingController();

  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: hint,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: () {
            onSave(controller.text);
            Navigator.pop(dialogContext);
          },
          child: const Text('حفظ'),
        ),
      ],
    ),
  ).then((_) => controller.dispose());
}
