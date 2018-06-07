import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'l10n/messages_all.dart';

class BallotLocalizations {
  static Future<BallotLocalizations> load(Locale locale) {
    final String name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      return new BallotLocalizations();
    });
  }

  static BallotLocalizations of(BuildContext context) {
    return Localizations.of<BallotLocalizations>(context, BallotLocalizations);
  }

  String get mainTitle {
    return Intl.message(
      'Ballot',
      name: 'mainTitle',
    );
  }

  String get addressInputTitle {
    return Intl.message(
      'Voting Address',
      name: 'addressInputTitle',
    );
  }

  String get signInWithGoogle {
    return Intl.message(
      'Sign in with Google',
      name: 'signInWithGoogle',
    );
  }

  String get votingAddressLabel {
    return Intl.message(
      'Registered Voting Address',
      name: 'votingAddressLabel',
    );
  }

  String get lookup {
    return Intl.message(
      'Lookup',
      name: 'lookup',
    );
  }

  String get votingProfileTitle {
    return Intl.message(
      'Voting Profile',
      name: 'votingProfileTitle',
    );
  }

  String get changeAddress {
    return Intl.message(
      'Change Address',
      name: 'changeAddress',
    );
  }

  String get required {
    return Intl.message(
      'Required',
      name: 'required',
    );
  }

  String get error {
    return Intl.message(
      'Error',
      name: 'error',
    );
  }
}

class BallotLocalizationsDelegate
    extends LocalizationsDelegate<BallotLocalizations> {
  const BallotLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en'].contains(locale.languageCode);

  @override
  Future<BallotLocalizations> load(Locale locale) =>
      BallotLocalizations.load(locale);

  @override
  bool shouldReload(BallotLocalizationsDelegate old) => false;
}
