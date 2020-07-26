import 'package:twitter/utilities/widget.dart';

double getDimension(context, double unit) {
  if (fullWidth(context) <= 360.0) {
    return unit / 1.3;
  } else {
    return unit;
  }
}
