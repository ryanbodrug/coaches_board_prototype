import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class TextEditorMarkdown extends StatefulWidget {
  const TextEditorMarkdown({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TextExitorState();
}

class _TextExitorState extends State<TextEditorMarkdown> with TickerProviderStateMixin {
  String text = """
---
# Header 1
## Header 2
### Header 3
#### Header 4
##### Header 5
###### Header 6
---

### Styles: 

**bold text**

*italicized text*

***bold and italic***

**bold and _nested_ italic**

~~Strikethrough~~

---

### Quotes: 

> blockquote

`code`

---

### Table: 

| Syntax | Description |
| ----------- | ----------- |
| Header | Title |
| Paragraph | Text |

---

### Ordered List: 

1. First item
2. Second item
3. Third item

### Unordered List: 

- First item
- Second item
- Third item

--- 
[example link](https://www.bing.com)

www.bing.com

Example image: ![alt text](resource:images/paths/backwards.png)
""";

  TextEditingController textController = TextEditingController();
  late TabController tabController;
  late FocusNode textFieldFocusNode;
  final kEditIndex = 1;
  Key textFieldKey = Key("TextEditorTextFieldKey");

  @override
  void initState() {
    textController.text = text; //default text
    tabController = TabController(length: 2, vsync: this, animationDuration: Duration.zero);

    textFieldFocusNode = FocusNode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LimitedBox(
      maxHeight: 400,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: TabBar(
            controller: tabController,
            tabs: const <Widget>[
              Tab(
                icon: Icon(Icons.preview),
              ),
              Tab(
                icon: Icon(Icons.edit),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: <Widget>[
            Container(
              color: Colors.amber,
              child: Markdown(
                shrinkWrap: true,
                data: text,
                selectable: true,
                onTapText: onMarkdownTap,
                onTapLink: launchUrl,
              ),
            ),
            Container(
              color: Colors.greenAccent,
              child: TextField(
                  autofocus: true,
                  focusNode: textFieldFocusNode,
                  controller: textController,
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: null,
                  onChanged: (value) => setState(() {
                        text = value;
                      })),
            ),
          ],
        ),
      ),
    );
  }

  void launchUrl(String text, String? href, String title) {
    if (href != null) {
      Uri? url = Uri.tryParse(href.trimLeft());
      if (url != null) {
        if (!url.hasScheme) {
          href = 'https://' + href;
        }
      }
      launch(href);
    }
  }

  void onMarkdownTap() {
    tabController.index = kEditIndex;
    textFieldFocusNode.requestFocus();
  }
}
