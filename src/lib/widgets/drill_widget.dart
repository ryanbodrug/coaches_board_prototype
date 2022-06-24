import 'package:coaches_board/board.dart';
import 'package:coaches_board/models/drill.dart';
// import 'package:coaches_board/widgets/text_editor_markdown.dart';
import 'package:coaches_board/widgets/text_editor_quill.dart';
import 'package:flutter/material.dart';

class DrillWidget extends StatelessWidget {
  final Drill drill;

  const DrillWidget({Key? key, required this.drill}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [const Icon(Icons.punch_clock), SizedBox(width: 30, child: TextField(controller: TextEditingController(text: drill.durationInMinutes.toString())))],
          ),
          title: Center(child: Text(drill.title)),
          children: [
            DrillMetadataWidget(drill: drill),
          ]),
    );
  }
}

class DrillMetadataWidget extends StatelessWidget {
  final Drill drill;

  const DrillMetadataWidget({Key? key, required this.drill}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Board(),
        ExpansionTile(
          title: const Text("Tags"),
          children: drill.tags.map<Text>((String tag) {
            return Text(tag);
          }).toList(),
        ),
        const ExpansionTile(
          title: Text("Timeline"),
          children: [Text("Timelinebody")],
        ),
        const ExpansionTile(
          title: Text("Description"),
          // children: [TextEditorMarkdown()],
          children: [TextEditorQuill()],
        ),
      ],
    );
  }
}
