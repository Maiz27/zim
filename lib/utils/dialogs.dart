import 'package:fluttertoast/fluttertoast.dart';

class Dialogs {
  static void showToast(String value) {
    Fluttertoast.showToast(
      msg: value,
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 1,
    );
  }
}
