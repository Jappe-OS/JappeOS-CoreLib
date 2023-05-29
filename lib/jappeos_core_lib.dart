//  JappeOS-CoreLib, Core library for JappeOS.
//  Copyright (C) 2023  Jappe02
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Affero General Public License as
//  published by the Free Software Foundation, either version 3 of the
//  License, or (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Affero General Public License for more details.
//
//  You should have received a copy of the GNU Affero General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

// ignore_for_file: constant_identifier_names

import 'package:jappeos_messaging/jappeos_messaging.dart';

const JOS_LOCATION = "/JappeOS/";

class JappeOS {
  static final Settings _settings = Settings();
  static Settings get settings => _settings;

  static const touchMode = false;

  static bool _initDone = false;
  static bool? _loggedIn;

  static void INIT() {
    if (_initDone) return;
    CoreMessageMan.init("${JOS_LOCATION}pipes/corelib/");
    CoreMessageMan.receive.subscribe((msg) {
      if (msg?.message == JMSG_COREPRCSS_MSG_RECV_LOGGEDIN) {
        _loggedIn = (msg?.args['v:']?.toLowerCase() == 'true');
      }
    });
    _initDone = true;
  }

  static void safeShutdown() {
    INIT();
    CoreMessageMan.send("${JOS_LOCATION}pipes/core/", Message(JMSG_COREPRCSS_MSG_SHUTDOWN, {}));
  }

  // TODO: Return a Future<bool> to know if login was successful or make a LoginCallback so that it can contain a error message.
  static void login(String username, String password) {
    INIT();
    CoreMessageMan.send("${JOS_LOCATION}pipes/core/", Message(JMSG_COREPRCSS_MSG_LOGIN, {'u:': username, 'p:': password}));
  }

  static Future<bool> isLoggedIn() async {
    INIT();
    CoreMessageMan.send("${JOS_LOCATION}pipes/core/", Message(JMSG_COREPRCSS_MSG_RECV_LOGGEDIN, {r'$from': '${JOS_LOCATION}pipes/corelib/'}));
    Future.doWhile(() async {
      return _loggedIn == null;
    });
    bool b = _loggedIn!;
    _loggedIn = null;
    return b;
  }

  static void logout() {
    INIT();
    CoreMessageMan.send("${JOS_LOCATION}pipes/core/", Message(JMSG_COREPRCSS_MSG_LOGOUT, {}));
  }
}

class Settings {
  static const path = "${JOS_LOCATION}settings.json";

  // ------------------------ APPEARANCE ------------------------
  Setting appearance$theme = Setting(() {}, () {});
  Setting appearance$themeColor = Setting(() {}, () {});
}

class Setting {
  final dynamic Function() get;
  final void Function() set;

  Setting(this.get, this.set);
}
