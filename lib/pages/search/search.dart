import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/states/search.dart';
import 'package:twitter/utilities/common.dart';
import 'package:twitter/utilities/constant.dart';
import 'package:twitter/utilities/page.dart' as page;
import 'package:twitter/widgets/navigation/appbar.dart';
import 'package:twitter/widgets/user/user_tile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key key, this.scaffoldKey}) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  State<StatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<SearchState>(context, listen: false);
      state.resetFilterList();
    });
    super.initState();
  }

  void onSettingIconPressed() {
    Navigator.pushNamed(context, '/' + page.Trends);
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<SearchState>(context);
    final list = state.users;
    return Scaffold(
      appBar: CustomAppBar(
        scaffoldKey: widget.scaffoldKey,
        icon: AppIcon.settings,
        onActionPressed: onSettingIconPressed,
        onSearchChanged: (text) {
          state.filterByUsername(text);
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          state.getDataFromDatabase();
          return Future.value(true);
        },
        child: ListView.separated(
          addAutomaticKeepAlives: false,
          physics: BouncingScrollPhysics(),
          itemBuilder: (context, index) => UserTile(
              user: list[index],
              onTap: () {
                firebaseAnalytics.logViewSearchResults(
                    searchTerm: list[index].userName);
                Navigator.of(context)
                    .pushNamed('/' + page.Profile + '/' + list[index]?.userId);
              }),
          separatorBuilder: (_, index) => Divider(
            height: 0,
          ),
          itemCount: list?.length ?? 0,
        ),
      ),
    );
  }
}
