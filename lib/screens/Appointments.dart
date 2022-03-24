import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hospital_management_system/constants/colors.dart';
import 'package:hospital_management_system/screens/choiceSign.dart';
import 'package:http/http.dart' as http;
import 'package:hospital_management_system/services/NetworkHelper.dart';
import 'package:hospital_management_system/widgets/MyTextField.dart';

class Appointments extends StatefulWidget {
  final String userId;
  final dynamic userInfo;
  Appointments({this.userId, this.userInfo});

  @override
  _AppointmentsState createState() => _AppointmentsState();
}

class _AppointmentsState extends State<Appointments> {
  bool _loading = false;
  List _appointments = [
    {
      'full_name': 'sammer',
      'appointment_status': 'pending',
      'description': 'done',
      'date': '2020-01-01',
      'time': '10:00',
      'appointment_id': 'id1'
    },
    {
      'full_name': 'DEMOsammer',
      'appointment_status': 'pending',
      'description': 'done',
      'date': '2020-01-01',
      'time': '10:00',
      'appointment_id': 'id1'
    }
  ];
  List _doctors = [
    {"full_name": 'kosaka'},
    {"full_name": 'samoka'}
  ];

  TimeOfDay selectedTime = TimeOfDay.now();

  double width;
  double height;
  var _selectedDocotor;
  String dropdownValue = 'Update';

  TextEditingController _descriptionController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void initState() {
    // _getAppointments();
    // _getDoctors();
    super.initState();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

// get the appointments list

  // adding a new appointment
  // updating an appointment
  Future<http.Response> _updateAppointment(appointmentId) async {
    setState(() {
      _loading = true;
    });

    final http.Response response = await Network().postData({
      'appointment_id': appointmentId.toString(),
      'description': _descriptionController.text
    }, '/updateAppointment.php');

    print('response ---- ${jsonDecode(response.body)}');

    setState(() {
      _loading = false;
    });

    return response;
  }

  // cancelling an appointment
  Future<http.Response> _cancelAppointment(appointmentId) async {
    setState(() {
      _loading = true;
    });

    final http.Response response = await Network().postData({
      'appointment_id': appointmentId.toString(),
    }, '/cancelAppointment.php');

    print('response ---- ${jsonDecode(response.body)}');

    setState(() {
      _loading = false;
    });

    return response;
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Appointments'),
      ),
      floatingActionButton: Visibility(
        visible: widget.userInfo['given_name'] == ChooseSign.patient,
        child: FloatingActionButton.extended(
          label: widget.userInfo['given_name'] == ChooseSign.patient
              ? Text('Request Appointment')
              : Text('Pending Appointments'),
          onPressed: () {
            _addNewAppointmentDialog(context);
          },
          icon: Icon(FlutterIcons.calendar_plus_mco),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Container(
              height: height,
              child: _appointments.length > 0
                  ? SingleChildScrollView(
                      child: RefreshIndicator(
                        onRefresh: () async {},
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          height: height * 0.85,
                          width: double.infinity,
                          child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: _appointments.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 10, 20, 6),
                                  margin:
                                      const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  width: width,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: colorWhite,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: Offset(0, 3)),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _appointments[index]['full_name'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2, horizontal: 5),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: _appointments[index][
                                                            'appointment_status'] ==
                                                        'PENDING'
                                                    ? Colors.orange
                                                    : _appointments[index][
                                                                'appointment_status'] ==
                                                            'ACCEPTED'
                                                        ? Colors.green
                                                        : Colors.blue[700]),
                                            child: Text(
                                              _appointments[index]
                                                  ['appointment_status'],
                                              style: TextStyle(
                                                  color: colorWhite,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Container(
                                            width: width - 80,
                                            height: 50,
                                            child: Text(
                                              _appointments[index]
                                                  ['description'],
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          )
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'Appointment: ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          (_appointments[index]['date'] ==
                                                      null ||
                                                  _appointments[index]
                                                          ['time'] ==
                                                      null)
                                              ? Text(
                                                  'N/A',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500),
                                                )
                                              : Text(
                                                  '${_appointments[index]['date']}  ${_appointments[index]['time']}',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          if (widget.userInfo['given_name'] ==
                                                  ChooseSign.doctor &&
                                              _appointments[index]
                                                      ['appointment_status'] ==
                                                  'pending')
                                            Expanded(
                                              child: DropdownButton<String>(
                                                isDense: true,
                                                isExpanded: true,
                                                icon: Icon(
                                                  Icons.more_horiz,
                                                ),
                                                underline: Container(
                                                  height: 0,
                                                  color:
                                                      Colors.deepPurpleAccent,
                                                ),
                                                onChanged: (String newValue) {
                                                  setState(() {
                                                    dropdownValue = newValue;
                                                  });
                                                },
                                                items: <String>[
                                                  'View',
                                                  'Approve',
                                                ].map<DropdownMenuItem<String>>(
                                                    (String value) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: value,
                                                    child: Text(value),
                                                    onTap: () {
                                                      print(value);
                                                      print(
                                                          _appointments[index]);

                                                      if (value == 'View') {
                                                        _viewAppointmentDialog(
                                                            context,
                                                            _appointments[
                                                                index]);
                                                      } else if (value ==
                                                          'Approve') {
                                                        _approveTime_2(context);
                                                      }
                                                    },
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        ),
                      ),
                    )
                  : Center(
                      child: Text('No appointment data found!'),
                    ),
            ),
    );
  }

  void _selectTime(BuildContext context) async {
    final TimeOfDay timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (timeOfDay != null && timeOfDay != selectedTime) {
      setState(() {
        selectedTime = timeOfDay;
        Navigator.pop(context);
      });
    }
  }

  // view appointment details dialog
  Future<Widget> _approveTime_2(context) async {
    await Future.delayed(Duration(milliseconds: 100));
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(16),
              ),
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                      ),
                    ),
                    height: 50,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text('Select Time Slot',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: colorWhite),
                        textAlign: TextAlign.center),
                  ),
                  GestureDetector(
                    onTap: () {
                      _selectTime(context);
                    },
                    child: Text(
                      "${selectedTime.hour}:${selectedTime.minute}",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),
          );
        });
  }

// adding new appointment dialog
  Future<Widget> _addNewAppointmentDialog(context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(16),
              ),
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                      ),
                    ),
                    height: 70,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text('New Appointment',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: colorWhite),
                        textAlign: TextAlign.center),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 10.0),
                            child: DropdownButtonFormField(
                              value: _selectedDocotor,
                              items: _doctors
                                  .map((value) => DropdownMenuItem(
                                        child: Text(value["full_name"]),
                                        value: value,
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                print('inside on change');
                                setState(() {
                                  _selectedDocotor = value;
                                  print('set change: $value');
                                });
                              },
                              isExpanded: true,
                              iconEnabledColor: primaryColor,
                              dropdownColor: fillColor,
                              isDense: true,
                              iconSize: 30.0,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  MaterialCommunityIcons.doctor,
                                  color: primaryColor,
                                ),
                                filled: true,
                                fillColor: fillColor,
                                labelText: _selectedDocotor == null
                                    ? 'Select the Doctor'
                                    : 'Doctor',
                                contentPadding:
                                    EdgeInsets.fromLTRB(16, 10, 0, 10),
                                hintStyle: TextStyle(color: hintColor),
                                hintText: "Select the Doctor",
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: primaryColor, width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: primaryColor, width: 1.0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: errorColor, width: 1),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: errorColor, width: 1),
                                ),
                                errorStyle: TextStyle(),
                              ),
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          MyTextField(
                            hint: 'Description',
                            icon: MaterialCommunityIcons.note_text,
                            isMultiline: true,
                            maxLines: 5,
                            controller: _descriptionController,
                            validation: (val) {
                              if (val.isEmpty) {
                                return 'A description is required';
                              }
                              return null;
                            },
                          ),
                          GestureDetector(
                            onTap: () {
                              if (_formKey.currentState.validate()) {
                                _appointments.add(_appointments[0]);
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: 30.0,
                              width: double.infinity,
                              child: Text(
                                'SAVE',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),
          );
        });
  }

  // view appointment details dialog
  Future<Widget> _viewAppointmentDialog(context, appointment) async {
    await Future.delayed(Duration(milliseconds: 100));
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(16),
              ),
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                      ),
                    ),
                    height: 70,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text('Appointment Details',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: colorWhite),
                        textAlign: TextAlign.center),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Form(
                      key: _formKey,
                      child: Container(
                        height: 200,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Description:',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 16),
                              ),
                              Text(appointment['description']),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    'Date: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                  Text(appointment['date'] != null
                                      ? appointment['date']
                                      : 'N/A')
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Time: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                  Text(appointment['time'] != null
                                      ? appointment['time']
                                      : 'N/A')
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Comments: ',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 16),
                              ),
                              Text(appointment['comments'] != null
                                  ? appointment['comments']
                                  : 'N/A'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 30.0,
                      width: double.infinity,
                      child: Text(
                        'CLOSE',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),
          );
        });
  }
}
