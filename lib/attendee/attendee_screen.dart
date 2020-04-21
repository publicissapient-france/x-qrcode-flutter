import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:x_qrcode/api/api_service.dart';
import 'package:x_qrcode/attendee/attendee_bloc.dart';
import 'package:x_qrcode/bloc/bloc_provider.dart';
import 'package:x_qrcode/visitor/model/attendee_model.dart';
import 'package:x_qrcode/visitor/widget/header_widget.dart';
import 'package:x_qrcode/visitor/widget/info_widget.dart';

class AttendeeScreenArguments {
  final Attendee attendee;

  AttendeeScreenArguments(this.attendee);
}

const attendeeRoute = '/attendee';

class AttendeeScreen extends StatelessWidget {
  final AttendeeBloc bloc;

  AttendeeScreen({Key key, Attendee attendee})
      : this.bloc = AttendeeBloc(ApiService(), attendee),
        super(key: key);

  @override
  Widget build(BuildContext context) => BlocProvider<AttendeeBloc>(
      bloc: bloc,
      child: Scaffold(
          appBar: AppBar(
            title: Text('Informations'.toUpperCase()),
            elevation: 0,
          ),
          body: StreamBuilder<Attendee>(
              stream: bloc.attendeeStream,
              builder: (_, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: <Widget>[
                      HeaderWidget(
                        attendee: snapshot.data,
                        checkMode: true,
                        checkIn: snapshot.data.checkIn,
                        onCheck: bloc.checkIn,
                      ),
                      Expanded(
                        child: CustomScrollView(
                          slivers: <Widget>[
                            SliverList(
                              delegate: SliverChildListDelegate([
                                snapshot.data.company != null
                                    ? InfoWidget(
                                        snapshot.data.company,
                                        SvgPicture.asset(
                                            'images/ic_company.svg'),
                                        first: true,
                                      )
                                    : Container(),
                                snapshot.data.jobTitle != null
                                    ? InfoWidget(
                                        snapshot.data.jobTitle,
                                        SvgPicture.asset('images/ic_job.svg'),
                                      )
                                    : Container(),
                                InfoWidget(
                                  snapshot.data.email,
                                  SvgPicture.asset('images/ic_email.svg'),
                                  copyToClipboard: true,
                                ),
                              ]),
                            )
                          ],
                        ),
                      )
                    ],
                  );
                }
                return Container();
              })));
}
