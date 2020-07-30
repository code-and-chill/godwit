import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:twitter/utilities/constant.dart';

class CustomNetworkImage extends StatelessWidget {
  final String path;
  final BoxFit fit;

  CustomNetworkImage(this.path, {this.fit = BoxFit.contain});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      fit: fit,
      imageUrl: path ?? mockProfilePicture,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageProvider,
            fit: fit,
          ),
        ),
      ),
      placeholderFadeInDuration: Duration(milliseconds: 500),
      placeholder: (context, url) => Container(
        color: Color(0xffeeeeee),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}

dynamic customAdvanceNetworkImage(String path) {
  if (path == null) {
    path = mockProfilePicture;
  }
  return CachedNetworkImageProvider(
    path ?? mockProfilePicture,
  );
}
