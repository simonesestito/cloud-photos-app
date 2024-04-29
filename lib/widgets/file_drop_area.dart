import 'package:cloud_photos_app/app_file.dart';
import 'package:cloud_photos_app/widgets/labeled_icon.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

typedef FileCallback = void Function(AppFile file);

class FileDropArea extends StatefulWidget {
  final FileCallback onFileDrop;

  const FileDropArea({super.key, required this.onFileDrop});

  @override
  State<FileDropArea> createState() => _FileDropAreaState();
}

class _FileDropAreaState extends State<FileDropArea> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final borderColor = _isDragging
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface;
    final areaColor =
        _isDragging ? borderColor.withAlpha(64) : borderColor.withAlpha(16);
    final icon = _isDragging ? Icons.file_copy : Icons.file_copy_outlined;
    final label =
        _isDragging ? 'Release file here' : 'Drop file or click to select';

    return DropTarget(
      onDragEntered: (_) => setState(() {
        _isDragging = true;
      }),
      onDragExited: (_) => setState(() {
        _isDragging = false;
      }),
      onDragDone: (details) {
        setState(() {
          _isDragging = false;
        });
        if (details.files.isNotEmpty) {
          widget.onFileDrop(AppFile.fromXFile(details.files.first));
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          child: DottedBorder(
            radius: const Radius.circular(16),
            color: borderColor,
            strokeWidth: 2,
            dashPattern: const [8, 4],
            child: Container(
              color: areaColor,
              child: LabeledIcon(
                icon: Icon(icon, color: borderColor),
                text: Text(label),
              ),
            ),
          ),
          onTap: () => _openFileSelector(),
        ),
      ),
    );
  }

  void _openFileSelector() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      dialogTitle: 'Select a photo to upload',
    );

    if (result != null) {
      widget.onFileDrop(AppFile.fromPlatformFile(result.files.single));
    }
  }
}
