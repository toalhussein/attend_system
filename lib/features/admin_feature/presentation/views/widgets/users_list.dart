// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:attend_system/core/calendar_notifier.dart';
import 'package:attend_system/core/record.dart';
import 'package:attend_system/features/admin_feature/presentation/views/widgets/user_details_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';

class UsersList extends StatelessWidget {
  const UsersList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    return StreamBuilder(
      stream: firestore.collection('users').snapshots(),
      builder: (context, users) {
        if (!users.hasData) {
          return const Center(child: Text('Loading'));
        } else if (users.hasError) {
          return const Center(child: Text('Error'));
        } else {
          return ValueListenableBuilder(
            valueListenable: CustomNotifier.selectedDate,
            builder: (context, value, child) => ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: users.data!.docs.length,
              itemBuilder: (context, index) {
                  return StreamBuilder(
                    stream: getRecordsStream(firestore, users, index, value),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error data'));
                      } else if (!snapshot.hasData) {
                        return Center(child: Text('No Users Found'));
                      } else {
                        Timestamp? attend =
                            snapshot.data?.data()?['attendance'];

                        Timestamp? depart = snapshot.data?.data()?['departure'];

                        return UserDetailsCard(
                          userName: users.data!.docs[index].data()['name'],
                          workId: users.data!.docs[index].data()['work_id'],
                          arrivalTime: attend != null
                              ? formatDate(
                                  attend.toDate().toLocal(), [hh, ':', nn, ' ', am])
                              : '-',
                          departTime: depart != null
                              ? formatDate(
                                  depart.toDate().toLocal(), [hh, ':', nn, ' ', am])
                              : '-',
                          workingTime: (attend != null && depart != null)
                              ? '${(depart.toDate().hour - attend.toDate().hour).abs()} H'
                              : '-',
                          lang: snapshot.data?.data()?['location']
                                  ?['longitude'] ??
                              0,
                          lat: snapshot.data?.data()?['location']
                                  ?['latitude'] ??
                              0,
                          outLang: snapshot.data?.data()?['out_location']
                                  ?['longitude'] ??
                              0,
                          outLat: snapshot.data?.data()?['out_location']
                                  ?['latitude'] ??
                              0,
                        );
                      }
                    },
                  );
                },
              ),
            );
        }
      },
    );
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getRecordsStream(
      FirebaseFirestore firestore,
      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> users,
      int index,
      DateTime value) {
    return firestore
        .collection('users')
        .doc(users.data!.docs[index].id)
        .collection('records')
        .doc(SignRecord.getFormattedDate(value))
        .snapshots();
  }
}
