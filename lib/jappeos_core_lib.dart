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

import 'dart:math';

import 'package:jappeos_messaging/jappeos_messaging.dart';

const JOS_LOCATION = "/JappeOS/";

/// Names of the JappeOS system processes like the desktop, login screen, etc.
class JappeOSProcessNames {
  static var core = "jappeos_core", login = "jappeos_login", desktop = "jappeos_desktop", crashHandler = "jappeos_crh";
}

// TODO, IMPORTANT: UPDATE JAPPEOS_CORE TO USE THE NEW MESSAGING SYSTEM FOLLOWING THE CORRECT ARGUMENT NAMES FOUND FROM THIS FILE!!!
/// Access the functionality of JappeOS's core.
class JappeOS {
  static final Settings _settings = Settings();
  static Settings get settings => _settings;

  static final WindowManager _windowManager = WindowManager();
  static WindowManager get windowManager => _windowManager;

  static final Desktop _desktop = Desktop();
  static Desktop get desktop => _desktop;

  static final SystemPrograms _systemPrograms = SystemPrograms();
  static SystemPrograms get systemPrograms => _systemPrograms;

  // ++----------------------------------------------------------------------------------++

  static const touchMode = false;

  static bool _initDone = false;
  static bool? _loggedIn;

  /// Initializes this library!
  // ignore: non_constant_identifier_names
  static void INIT() {
    if (_initDone) return;
    JappeOSMessaging.init(49152);
    JappeOSMessaging.receive.subscribe((msg) {
      if (msg?.value1.name == "logged-in") {
        _loggedIn = (msg?.value1.args['v']?.toLowerCase() == 'true');
      }
    });
    _initDone = true;
  }

  /// Safely shuts down the system.
  static void safeShutdown() {
    INIT();
    JappeOSMessaging.clean();
    JappeOSMessaging.send(Message("shutdown", {}), 8888);
  }

  /// Logs in to the Linux system.
  static Future<bool> login(String username, String password) async {
    INIT();
    int id = Random().nextInt(100);
    JappeOSMessaging.send(Message("login", {'u': username, 'p': password, 'callbackID': id.toString()}), 8888);
    // Listen for a callback to know if login was successful; TODO

    return Future.value(true);
  }

  /// Check if a user is logged in to the system.
  static Future<bool> isLoggedIn() async {
    // TODO Callback system
    INIT();
    JappeOSMessaging.send(Message("logged-in", {}), 8888);
    Future.doWhile(() async {
      return _loggedIn == null;
    });
    bool b = _loggedIn!;
    _loggedIn = null;
    return b;
  }

  /// Logs out from the current user.
  static void logout() {
    INIT();
    JappeOSMessaging.send(Message("logout", {}), 8888);
  }
}

// REGION -->>---------------------------------------->> [ SETTINGS ] <<----------------------------------------<<--

/// Manage the current system settings.
class Settings {
  static const path = "${JOS_LOCATION}settings.json";

  // ------------------------ APPEARANCE ------------------------
  Setting appearance$theme = Setting(() {}, () {});
  Setting appearance$themeColor = Setting(() {}, () {});
}

/// A single setting used by [Settings].
class Setting {
  final dynamic Function() get;
  final void Function() set;

  Setting(this.get, this.set);
}

// REGION -->>---------------------------------------->> [ WINDOW MANAGER ] <<----------------------------------------<<--

/// Access to the window manager to manage the windowing system.
class WindowManager {
  /// Creates a new window and displays it on the screen.
  //void newWindow(WindowType window) {}
}

// REGION -->>---------------------------------------->> [ DESKTOP ] <<----------------------------------------<<--

/// Access the basic desktop systems.
class Desktop {
  /// Send a notification that will be displayed on the screen.
  void sendNotification(String message) {}
}

// REGION -->>---------------------------------------->> [ SYSTEM PROGRAMS ] <<----------------------------------------<<--

/// A class for a system program/program type; settings, web browser, etc.
abstract class SystemProgram {
  /// Launch the target system program with arguments.
  void launch([List<String>? args]);

  /// Send a command/message to the target system program.
  void command(String cmd);
}

/// Access the default system programs.
class SystemPrograms {
  final SP$Settings _settings = SP$Settings();
  SP$Settings get settings => _settings;
}

class SP$Settings extends SystemProgram {
  @override
  void launch([List<String>? args]) {
    // TODO: implement launch
  }

  @override
  void command(String cmd) {}
}
