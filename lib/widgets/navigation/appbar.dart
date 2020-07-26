import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/states/auth.dart';
import 'package:twitter/utilities/theme.dart';
import 'package:twitter/widgets/image/twitter_icon.dart';
import 'package:twitter/widgets/input/search.dart';

import '../../utilities/widget.dart';
import 'ink_well.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget> actions;
  final Size appBarHeight = Size.fromHeight(56.0);
  final int icon;
  final bool isBackButton;
  final bool isBottomLine;
  final bool isCrossButton;
  final bool isSubmitDisable;
  final Widget leading;
  final Function onActionPressed;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String submitButtonText;
  final TextEditingController textController;
  final Widget title;
  final ValueChanged<String> onSearchChanged;

  CustomAppBar(
      {Key key,
      this.leading,
      this.title,
      this.actions,
      this.scaffoldKey,
      this.icon,
      this.onActionPressed,
      this.textController,
      this.isBackButton = false,
      this.isCrossButton = false,
      this.submitButtonText,
      this.isSubmitDisable = true,
      this.isBottomLine = true,
      this.onSearchChanged})
      : super(key: key);

  @override
  Size get preferredSize => appBarHeight;

  List<Widget> _getActionButtons(BuildContext context) {
    return <Widget>[
      submitButtonText != null
          ? Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: CustomInkWell(
          splashColor: Theme
              .of(context)
              .primaryColorLight,
          radius: BorderRadius.circular(40),
          onPressed: () {
            if (onActionPressed != null) onActionPressed();
          },
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            decoration: BoxDecoration(
              color: !isSubmitDisable
                  ? Theme
                  .of(context)
                  .primaryColor
                  : Theme
                  .of(context)
                  .primaryColor
                  .withAlpha(150),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              submitButtonText,
              style: TextStyle(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .onPrimary),
            ),
          ),
        ),
      )
          : icon == null
          ? Container()
          : IconButton(
        onPressed: () {
          if (onActionPressed != null) onActionPressed();
        },
        icon: TwitterIcon(
            icon: icon, iconColor: AppColor.primary, size: 25),
      )
    ];
  }

  Widget _getUserAvatar(BuildContext context) {
    var authState = Provider.of<AuthState>(context);
    return Padding(
      padding: EdgeInsets.all(10),
      child: CustomInkWell(
        splashColor: Theme
            .of(context)
            .primaryColorLight,
        onPressed: () {
          scaffoldKey.currentState.openDrawer();
        },
        child:
        customImage(context, authState.userModel?.profilePict, height: 30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(color: Colors.blue),
      backgroundColor: Colors.white,
      leading: isBackButton
          ? BackButton()
          : isCrossButton
          ? IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          Navigator.pop(context);
        },
      )
          : _getUserAvatar(context),
      title: title ?? SearchField("Search...", onSearchChanged, textController),
      actions: _getActionButtons(context),
      bottom: PreferredSize(
        child: Container(
          color: isBottomLine
              ? Colors.grey.shade200
              : Theme
              .of(context)
              .backgroundColor,
          height: 1.0,
        ),
        preferredSize: Size.fromHeight(0.0),
      ),
    );
  }
}
