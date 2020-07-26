import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/states/app.dart';
import 'package:twitter/utilities/constant.dart';
import 'package:twitter/widgets/image/twitter_icon.dart';
import 'package:twitter/widgets/navigation/tab_item.dart';

class BottomMenubar extends StatefulWidget {
  const BottomMenubar({this.pageController});

  final PageController pageController;

  _BottomMenubarState createState() => _BottomMenubarState();
}

class _BottomMenubarState extends State<BottomMenubar> {
  PageController _pageController;
  int _selectedIcon = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AppState>(context);
    return Container(
      height: 50,
      decoration:
          BoxDecoration(color: Theme.of(context).bottomAppBarColor, boxShadow: [
        BoxShadow(color: Colors.black12, offset: Offset(0, -.1), blurRadius: 0)
      ]),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _icon(0, 0 == state.pageIndex ? AppIcon.homeFill : AppIcon.home),
          _icon(1, 1 == state.pageIndex ? AppIcon.searchFill : AppIcon.search),
          _icon(
              2,
              2 == state.pageIndex
                  ? AppIcon.notificationFill
                  : AppIcon.notification),
          _icon(
              3,
              3 == state.pageIndex
                  ? AppIcon.messageFill
                  : AppIcon.messageEmpty),
        ],
      ),
    );
  }

  Widget _icon(int index, int icon) {
    var state = Provider.of<AppState>(context);
    return Expanded(
      child: Container(
        height: double.infinity,
        width: double.infinity,
        child: AnimatedAlign(
          duration: Duration(milliseconds: ANIM_DURATION),
          curve: Curves.easeIn,
          alignment: Alignment(0, ICON_ON),
          child: AnimatedOpacity(
            duration: Duration(milliseconds: ANIM_DURATION),
            opacity: ALPHA_ON,
            child: IconButton(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              padding: EdgeInsets.all(0),
              alignment: Alignment(0, 0),
              icon: /*isCustomIcon*/ true
                  ? TwitterIcon(
                  icon: icon,
                  size: 22,
                  isEnable: index == state.pageIndex)
                  : Icon(
                null,
                color: index == state.pageIndex
                    ? Theme
                    .of(context)
                    .primaryColor
                    : Theme
                    .of(context)
                    .textTheme
                    .caption
                    .color,
              ),
              onPressed: () {
                setState(() {
                  _selectedIcon = index;
                  state.setPageIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
