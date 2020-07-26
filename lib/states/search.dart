import 'package:firebase_database/firebase_database.dart';
import 'package:twitter/model/user.dart';
import 'package:twitter/utilities/common.dart';
import 'package:twitter/utilities/enum.dart';

import 'app.dart';

class SearchState extends AppState {
  bool isBusy = false;
  SortUser sortBy = SortUser.ByMaxFollower;
  List<User> _userFilters;
  List<User> _users;

  List<User> get users {
    if (_userFilters == null) {
      return null;
    } else {
      return List.from(_userFilters);
    }
  }

  /// get [User list] from firebase realtime Database
  void getDataFromDatabase() {
    try {
      isBusy = true;
      firebaseDatabase.child('profile').once().then(
        (DataSnapshot snapshot) {
          _users = List<User>();
          _userFilters = List<User>();
          if (snapshot.value != null) {
            var map = snapshot.value;
            if (map != null) {
              map.forEach((key, value) {
                var model = User.fromJson(value);
                model.key = key;
                _users.add(model);
                _userFilters.add(model);
              });
              _userFilters.sort(
                  (x, y) => y.followers.length.compareTo(x.followers.length));
            }
          } else {
            _users = null;
          }
          isBusy = false;
        },
      );
    } catch (error) {
      isBusy = false;
      cprint(error, errorIn: 'getDataFromDatabase');
    }
  }

  /// It will reset filter list
  /// If user has use search filter and change screen and came back to search screen It will reset user list.
  /// This function call when search page open.
  void resetFilterList() {
    if (_users != null && _users.length != _userFilters.length) {
      _userFilters = List.from(_users);
      _userFilters.sort((x, y) =>
          y.followers.length.compareTo(x.followers.length));
      notifyListeners();
    }
  }

  /// This function call when search fiels text change.
  /// User list on  search field get filter by `name` string
  void filterByUsername(String name) {
    if (name.isEmpty && _users != null &&
        _users.length != _userFilters.length) {
      _userFilters = List.from(_users);
    }
    // return if userList is empty or null
    if (_users == null && _users.isEmpty) {
      print("Empty userList");
      return;
    }
    // sortBy userlist on the basis of username
    else if (name != null) {
      _userFilters = _users.where((x) =>
      x.userName != null &&
          x.userName.toLowerCase().contains(name.toLowerCase())).toList();
    }
    notifyListeners();
  }

  /// Sort user list on search user page.
  set updateUserSortPrefrence(SortUser val) {
    sortBy = val;
    notifyListeners();
  }

  String get selectedFilter {
    switch (sortBy) {
      case SortUser.ByAlphabetically:
        _userFilters.sort((x, y) => x.displayName.compareTo(y.displayName));
        notifyListeners();
        return "alphabetically";

      case SortUser.ByMaxFollower:
        _userFilters.sort((x, y) =>
            y.followers.length.compareTo(x.followers.length));
        notifyListeners();
        return "User with max follower";

      case SortUser.ByNewest:
        _userFilters.sort((x, y) =>
            DateTime.parse(y.createdAt).compareTo(DateTime.parse(x.createdAt)));
        notifyListeners();
        return "Newest user first";

      case SortUser.ByOldest:
        _userFilters.sort((x, y) =>
            DateTime.parse(x.createdAt).compareTo(DateTime.parse(y.createdAt)));
        notifyListeners();
        return "Oldest user first";

      case SortUser.ByVerified:
        _userFilters.sort((x, y) =>
            y.isVerified.toString().compareTo(x.isVerified.toString()));
        notifyListeners();
        return "Verified user first";

      default:
        return "Unknown";
    }
  }

  /// Return user list relative to provided `userIds`
  /// Method is used on
  List<User> userList = [];
  List<User> getuserDetail(List<String> userIds) {
    final list = _users.where((x) {
      if (userIds.contains(x.key)) {
        return true;
      } else {
        return false;
      }
    }).toList();
    return list;
  }
}
