import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:async';
import 'dart:io';

import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:tuple/tuple.dart';

class TextEditorQuill extends StatefulWidget {
  const TextEditorQuill({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TextExitorState();
}

class _TextExitorState extends State<TextEditorQuill> with TickerProviderStateMixin {
  QuillController? _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    final doc = Document();
    _controller = QuillController(document: doc, selection: const TextSelection.collapsed(offset: 0));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const LimitedBox(maxHeight: 400, child: Scaffold(body: Center(child: Text('Loading...'))));
    }

    var quillEditor = QuillEditor(
        controller: _controller!,
        scrollController: ScrollController(),
        scrollable: true,
        focusNode: _focusNode,
        autoFocus: false,
        readOnly: false,
        placeholder: 'Add content',
        expands: true,
        padding: EdgeInsets.zero,
        customStyles: DefaultStyles(
          h1: DefaultTextBlockStyle(
              const TextStyle(
                fontSize: 32,
                color: Colors.black,
                height: 1.15,
                fontWeight: FontWeight.w300,
              ),
              const Tuple2(16, 0),
              const Tuple2(0, 0),
              null),
          sizeSmall: const TextStyle(fontSize: 9),
        ));

    var toolbar = QuillToolbar.basic(
      controller: _controller!,
      // provide a callback to enable picking images from device.
      // if omit, "image" button only allows adding images from url.
      // same goes for videos.
      // onImagePickCallback: _onImagePickCallback,
      // onVideoPickCallback: _onVideoPickCallback,
      // uncomment to provide a custom "pick from" dialog.
      // mediaPickSettingSelector: _selectMediaPickSetting,
      multiRowsDisplay: true,
      showAlignmentButtons: true,
    );

    return LimitedBox(
      maxHeight: 400,
      child: Scaffold(
        //   body: RawKeyboardListener(
        //     focusNode: FocusNode(),
        //     onKey: (event) {
        //       if (event.data.isControlPressed && event.character == 'b') {
        //         if (_controller!.getSelectionStyle().attributes.keys.contains('bold')) {
        //           _controller!.formatSelection(Attribute.clone(Attribute.bold, null));
        //         } else {
        //           _controller!.formatSelection(Attribute.bold);
        //         }
        //       } else if (event.data.isControlPressed && event.character == 'i') {
        //         if (_controller!.getSelectionStyle().attributes.keys.contains('italic')) {
        //           _controller!.formatSelection(Attribute.clone(Attribute.italic, null));
        //         } else {
        //           _controller!.formatSelection(Attribute.italic);
        //         }
        //       } else if (event.data.isControlPressed && event.character == 'u') {
        //         if (_controller!.getSelectionStyle().attributes.keys.contains('underline')) {
        //           _controller!.formatSelection(Attribute.clone(Attribute.underline, null));
        //         } else {
        //           _controller!.formatSelection(Attribute.underline);
        //         }
        //       } else if (event.data.isControlPressed && event.character == '1') {
        //         if (_controller!.getSelectionStyle().attributes.keys.contains('h1')) {
        //           _controller!.formatSelection(Attribute.clone(Attribute.h1, null));
        //         } else {
        //           _controller!.formatSelection(Attribute.h1);
        //         }
        //       } else if (event.data.isControlPressed && event.character == '2') {
        //         if (_controller!.getSelectionStyle().attributes.keys.contains('h2')) {
        //           _controller!.formatSelection(Attribute.clone(Attribute.h2, null));
        //         } else {
        //           _controller!.formatSelection(Attribute.h2);
        //         }
        //       } else if (event.data.isControlPressed && event.character == '3') {
        //         if (_controller!.getSelectionStyle().attributes.keys.contains('h3')) {
        //           _controller!.formatSelection(Attribute.clone(Attribute.h3, null));
        //         } else {
        //           _controller!.formatSelection(Attribute.h3);
        //         }
        //       }
        //     },
        //     child: Column(children: [
        //       Expanded(
        //         flex: 1,
        //         child: toolbar,
        //       ),
        //       Expanded(
        //         flex: 9,
        //         child: quillEditor,
        //       ),
        //     ]),
        //   ),
        // ),

        body: Shortcuts(
          manager: LoggingShortcutManager(),
          shortcuts: <LogicalKeySet, Intent>{
            LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyB): _StyleIntent(attributeName: 'bold', attribute: Attribute.bold),
            LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyI): _StyleIntent(attributeName: 'italic', attribute: Attribute.italic),
            LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyU): _StyleIntent(attributeName: 'underline', attribute: Attribute.underline),
            LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit1): _StyleIntent(attributeName: 'h1', attribute: Attribute.h1),
            LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit2): _StyleIntent(attributeName: 'h2', attribute: Attribute.h2),
            LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit3): _StyleIntent(attributeName: 'h3', attribute: Attribute.h3),
          },
          child: Actions(
            dispatcher: LoggingActionDispatcher(),
            actions: <Type, Action<Intent>>{
              _StyleIntent: _StyleAction(_controller),
            },
            child: Focus(
              autofocus: true,
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: toolbar,
                  ),
                  Expanded(
                    flex: 9,
                    child: quillEditor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A ShortcutManager that logs all keys that it handles.
class LoggingShortcutManager extends ShortcutManager {
  @override
  KeyEventResult handleKeypress(BuildContext context, RawKeyEvent event) {
    final KeyEventResult result = super.handleKeypress(context, event);
    if (result == KeyEventResult.handled) {
      print('Handled shortcut $event in $context');
    }
    return result;
  }
}

/// An ActionDispatcher that logs all the actions that it invokes.
class LoggingActionDispatcher extends ActionDispatcher {
  @override
  Object? invokeAction(
    covariant Action<Intent> action,
    covariant Intent intent, [
    BuildContext? context,
  ]) {
    print('Action invoked: $action($intent) from $context');
    super.invokeAction(action, intent, context);

    return null;
  }
}

class _StyleIntent extends Intent {
  final String attributeName;
  final Attribute attribute;
  const _StyleIntent({required this.attributeName, required this.attribute});
}

class _StyleAction extends Action<_StyleIntent> {
  QuillController? controller;

  _StyleAction(this.controller);

  @override
  Object? invoke(covariant _StyleIntent intent) {
    if (controller != null) {
      if (controller!.getSelectionStyle().attributes.keys.contains(intent.attributeName)) {
        controller!.formatSelection(Attribute.clone(intent.attribute, null));
      } else {
        controller!.formatSelection(intent.attribute);
      }
    }
    return null;
  }
}
