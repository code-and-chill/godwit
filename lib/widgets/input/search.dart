import 'package:flutter/material.dart';
import 'package:twitter/utilities/theme.dart';

class SearchField extends StatelessWidget {
  final String hint;
  final Function onSearchChanged;
  final TextEditingController textController;

  SearchField(this.hint, this.onSearchChanged, this.textController);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 50,
        padding: EdgeInsets.symmetric(vertical: 5),
        child: TextField(
          onChanged: onSearchChanged,
          controller: textController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(width: 0, style: BorderStyle.none),
              borderRadius: const BorderRadius.all(
                const Radius.circular(25.0),
              ),
            ),
            hintText: hint,
            fillColor: AppColor.extraLightGrey,
            filled: true,
            focusColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          ),
        ));
    ;
  }
}
