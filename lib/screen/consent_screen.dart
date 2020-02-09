import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class ConsentScreen extends StatefulWidget {
  final String visitorId;

  ConsentScreen({Key key, @required this.visitorId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConsentScreenState(visitorId);
}

class _ConsentScreenState extends State<ConsentScreen> {
  final String visitorId;

  final signature = SignatureController();

  var consent = false;
  var signed = false;

  _ConsentScreenState(this.visitorId);

  @override
  void initState() {
    signature.addListener(() => setState(() => signed = true));
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text('🔏 Consentement'),
      ),
      body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Container(
                  height: 100,
                  alignment: Alignment(0, 1),
                  child: Image.network(
                      'https://www.sfeir.com/img/logo-SFEIR-normal.png')),
              RichText(
                text: TextSpan(
                    text: 'Je souhaite partager avec ',
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                          text: 'Sfeir',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: ' les données personnelles suivantes :'),
                    ]),
              ),
              Container(
                alignment: Alignment(-1, -1),
                color: Colors.white,
                margin: EdgeInsets.only(top: 16, bottom: 16),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('John Doe'),
                    Text('PS Engineering'),
                    Text('jd@ps-engineering.fr'),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Container(
                      width: MediaQuery.of(context).size.width * 0.79,
                      child: RichText(
                        text: TextSpan(
                            text: 'Je déclare avir pris connaissance de la ',
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                  text: 'politique de confidentialité',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: ' de la société '),
                              TextSpan(
                                  text: 'Sfeir',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text:
                                      ', et j‘accepte que mes informations détaillées ci-avant lui soient communiquées directement par l‘Organisateur.'),
                            ]),
                      )),
                  Checkbox(
                    value: consent,
                    onChanged: (bool value) {
                      setState(() {
                        consent = value;
                      });
                    },
                  )
                ],
              ),
              Container(
                  padding: EdgeInsets.only(top: 16),
                  child: Signature(
                    controller: signature,
                    width: MediaQuery.of(context).size.width,
                    height: 200,
                    backgroundColor: Colors.white,
                  )),
              Container(
                  padding: EdgeInsets.only(top: 16, bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      RaisedButton(
                        onPressed: () {},
                        child: Text('Annuler'),
                      ),
                      RaisedButton(
                        onPressed: consent && signed ? () {} : null,
                        child: Text('Valider'),
                      )
                    ],
                  ))
            ],
          )));
}
