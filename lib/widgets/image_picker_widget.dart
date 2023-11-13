import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  final double imageSize;
  final void Function(File image) imagePickFunction;



  const ImagePickerWidget({super.key,
    required this.imageSize,
    required this.imagePickFunction,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _pickedImage;


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async{
        var pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
        if(pickedImage == null) return;
        setState(() {
          _pickedImage = File(pickedImage.path);
        });
        widget.imagePickFunction(_pickedImage!);
      },
      child: CircleAvatar(
        radius: widget.imageSize,
        backgroundColor: Colors.grey,
        backgroundImage: _pickedImage == null ? null : FileImage(_pickedImage!),
        child: _pickedImage == null ? Icon(
          Icons.camera_alt,
          size: widget.imageSize / 1.25,
          color: Theme.of(context).colorScheme.primary,)
            : null,
      ),
    );
  }
}
