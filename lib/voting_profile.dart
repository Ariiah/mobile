import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'address_input.dart';
import 'contest.dart';
import 'divisions.dart';
import 'localizations.dart';
import 'login.dart';
import 'polling_station.dart';
import 'user.dart';
import 'widgets.dart';

class VotingProfile extends StatelessWidget {
  VotingProfile({Key key, this.firebaseUser}) : super(key: key);

  final FirebaseUser firebaseUser;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(BallotLocalizations.of(context).votingProfileTitle),
        actions: <Widget>[
          LoginPage.createLogoutButton(context, _auth, _googleSignIn),
        ],
      ),
      body: _createBody(),
    );
  }

  Widget _createAddressValue() => StreamBuilder(
      stream: User.getAddressRef(firebaseUser).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _createVotingAddressListTile(
              context, snapshot.data['address']);
        }
        // By default, show a loading spinner
        return Center(child: CircularProgressIndicator());
      });

  Widget _createBody() => StreamBuilder(
      stream: User.getUpcomingRef(firebaseUser).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _createVoteInfoBody(context, snapshot.data);
        }
        return Center(child: CircularProgressIndicator());
      });

  List _createListItems(context, DocumentSnapshot doc) {
    final items = [];

    items.add({'_listItemType': 'addressHeader'});
    items.add({'_listItemType': 'addressValue'});

    if (!(doc.exists)) {
      items.add({'_listItemType': 'loading'});
      return items;
    }

    final election =
        doc.exists && doc.data != null ? doc.data['election'] : null;

    List votingLocations =
        doc.exists && doc.data != null ? doc.data['votingLocations'] : null;

    if (votingLocations != null && votingLocations.length > 0) {
      items.add({'_listItemType': 'votingLocationHeader'});
      final location = votingLocations[0];
      location['_listItemType'] = 'votingLocation';
      items.add(location);
    }

    final List contests =
        doc.exists && doc.data != null ? doc.data['contests'] : null;

    if (contests != null) {
      items.add({
        '_listItemType': 'header',
        'text': BallotLocalizations.of(context).contestsHeader
      });
      for (int i = 0; i < contests.length; ++i) {
        final contest = contests[i];
        contest['_listItemType'] = 'contest';
        contest['electionId'] = election['id'];
        contest['contestIndex'] = i;
        items.add(contest);
      }
    }

    return items;
  }

  Widget _createVoteInfoBody(context, DocumentSnapshot doc) {
    final theme = Theme.of(context);
    final items = _createListItems(context, doc);
    return ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final Map item = items[index];
          final String type = item['_listItemType'];

          if (type == 'loading') {
            return ListTile(
                leading: CircularProgressIndicator(),
                title: Text(BallotLocalizations.of(context).loading));
          }

          if (type == 'addressHeader') {
            return getHeader(theme,
                text: BallotLocalizations.of(context).votingAddressLabel,
                trailing: BallotLocalizations.of(context).divisionsTitle,
                onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => DivisionsPage(firebaseUser),
                  ));
            });
          }

          if (type == 'addressValue') {
            return _createAddressValue();
          }

          if (type == 'votingLocationHeader') {
            List votingLocations = doc.exists && doc.data != null
                ? doc.data['votingLocations']
                : null;
            return getHeader(theme,
                text: BallotLocalizations.of(context).votingLocationTitle,
                trailing: BallotLocalizations.of(context).all, onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PollingStationsPage(votingLocations),
                  ));
            });
          }

          if (type == 'votingLocation') {
            return PollingStationPage.getAddressHeader(context, item);
          }

          if (type == 'header') {
            return getHeader(theme, text: item['text']);
          }

          if (type == 'text') {
            return ListTile(title: item['text']);
          }

          if (type == 'contest') {
            return ListTile(
                title: Text(item['name']),
                onTap: () {
                  final ref = User
                      .getRef(firebaseUser)
                      .collection('elections')
                      .document('upcoming');
                  Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ContestPage(
                            firebaseUser: firebaseUser,
                            ref: ref,
                            electionId: item['electionId'],
                            contestIndex: item['contestIndex']),
                      ));
                });
          }

          return Container();
        });
  }

  void _goToAddressInput(context) {
    Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddressInputPage(
              firebaseUser: firebaseUser,
              firstTime: false,
              hint: BallotLocalizations.of(context).votingAddressLabel),
        ));
  }

  ListTile _createVotingAddressListTile(context, String address) {
    return ListTile(
        title: Text(address),
        trailing: IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => _goToAddressInput(context),
        ));
  }
}
