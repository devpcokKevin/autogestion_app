import 'dart:io';

import 'package:autogestion/shared/appbar.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importa para manejar fechas
import 'package:syncfusion_flutter_calendar/calendar.dart';

class miHorarioScreen extends StatefulWidget {
  final String appBarTitle;
  final IconData appBarIcon;

  const miHorarioScreen({
    Key? key,
    required this.appBarTitle,
    required this.appBarIcon,
  }) : super(key: key);

  @override
  State<miHorarioScreen> createState() => _miHorarioScreenState();
}

class _miHorarioScreenState extends State<miHorarioScreen> {
  String _horarioNombre = '';
  String _horarioInicio = '';
  String _horarioFin = '';
  List<dynamic> _turnos = [];

  @override
  void initState() {
    super.initState();
    _fetchHorario();
  }

  Future<void> _fetchHorario() async {
    final url = 'https://10.0.2.2:7259/api/Horario/ListarTurnoXHorario';
    final data = {
      "trabajador_id": 10008,
      "empresa_codigo": "20354561124",
    };
    BaseOptions options = BaseOptions(
      connectTimeout: 1000,
      receiveTimeout: 1000,
    );
    Dio dio = Dio(options);
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
    try {
      final response = await dio.post(url, data: data);
      if (response.statusCode == 200) {
        print('Response data: ${response.data}');
        setState(() {
          _horarioNombre = response.data['item3']['horario_nombre'];
          _horarioInicio = response.data['item3']['horario_inicio'];
          _horarioFin = response.data['item3']['horario_fin'];
          _turnos = response.data['item4'];
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: widget.appBarTitle,
        icon: widget.appBarIcon,
        implyLeading: false,
        marginLeft: 50.0,
      ),
      body: _horarioInicio.isEmpty || _horarioFin.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SfCalendar(
        view: CalendarView.week,
        dataSource: _buildDataSource(),
        headerStyle: CalendarHeaderStyle(
          textAlign: TextAlign.center,
          textStyle: TextStyle(color: Colors.black),
          backgroundColor: Colors.transparent,
        ),
        viewHeaderStyle: ViewHeaderStyle(
          dayTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        monthViewSettings: MonthViewSettings(
          appointmentDisplayMode:
          MonthAppointmentDisplayMode.appointment,
          showAgenda: true,
          agendaViewHeight: 100,
        ),
        timeSlotViewSettings: TimeSlotViewSettings(
          timeIntervalHeight: 80.0, // Altura del intervalo de tiempo
          startHour: double.parse(_horarioInicio.split(':')[0]), // Hora de inicio convertida a double
          endHour: double.parse(_horarioFin.split(':')[0]), // Hora de fin convertida a double
          timeInterval: Duration(hours: 1), // Intervalo de tiempo de 1 hora
          timeFormat: 'hh:mm a', // Formato de las horas
          timeTextStyle: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          dayFormat: 'EE', // Formato del día
        ),
        onTap: (calendarTapDetails) {},
        onViewChanged: (viewChangedDetails) {},
      ),
    );
  }

  CalendarDataSource _buildDataSource() {
    List<Appointment> appointments = [];

    for (var turno in _turnos) {
      final DateTime turnoDate = _calculateTurnoDate(turno['turno_dia']);
      final DateTime turnoInicio = DateTime(
        turnoDate.year,
        turnoDate.month,
        turnoDate.day,
        int.parse(turno['turno_inicio'].split(':')[0]),
        int.parse(turno['turno_inicio'].split(':')[1]),
      );
      final DateTime turnoFin = DateTime(
        turnoDate.year,
        turnoDate.month,
        turnoDate.day,
        int.parse(turno['turno_fin'].split(':')[0]),
        int.parse(turno['turno_fin'].split(':')[1]),
      );

      // Crear evento principal para el turno
      Appointment mainAppointment = Appointment(
        startTime: turnoInicio,
        endTime: turnoFin,
        subject: turno['turno_nombre'],
        color: Colors.blue,
      );

      // Agregar el evento principal
      appointments.add(mainAppointment);

      // Verificar y agregar el período de refrigerio si está definido
      if (turno['turno_refrigerio_inicio'] != null &&
          turno['turno_refrigerio_fin'] != null) {
        final DateTime refrigerioInicio = DateTime(
          turnoDate.year,
          turnoDate.month,
          turnoDate.day,
          int.parse(turno['turno_refrigerio_inicio'].split(':')[0]),
          int.parse(turno['turno_refrigerio_inicio'].split(':')[1]),
        );
        final DateTime refrigerioFin = DateTime(
          turnoDate.year,
          turnoDate.month,
          turnoDate.day,
          int.parse(turno['turno_refrigerio_fin'].split(':')[0]),
          int.parse(turno['turno_refrigerio_fin'].split(':')[1]),
        );

        // Crear evento para el refrigerio
        Appointment refrigerioAppointment = Appointment(
          startTime: refrigerioInicio,
          endTime: refrigerioFin,
          subject: turno['turno_nombre'] + ' (Refrigerio)',
          color: Colors.yellow,
        );

        // Agregar el evento de refrigerio
        appointments.add(refrigerioAppointment);
      }
    }

    return MeetingDataSource(appointments);
  }

  DateTime _calculateTurnoDate(String turnoDia) {
    // Obtener la fecha de inicio del horario
    final DateTime now = DateTime.now();
    final DateTime horarioInicio = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(_horarioInicio.split(':')[0]),
      int.parse(_horarioInicio.split(':')[1]),
    );

    // Calcular la fecha del turno según el día
    final int diasDesdeInicio = int.parse(turnoDia) - 1; // Restar 1 porque el día comienza en 1
    final DateTime turnoDate = horarioInicio.add(Duration(days: diasDesdeInicio));

    return turnoDate;
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}
