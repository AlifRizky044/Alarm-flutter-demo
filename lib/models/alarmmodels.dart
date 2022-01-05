import 'dart:convert';

class Alarm{
  String? waktu;
  String? status;
  String? kegiatan;
  int? alarmID;

  Alarm({this.waktu, this.status, this.kegiatan, this.alarmID});

  factory Alarm.fromJson(Map<String, dynamic> jsonData) {
    return Alarm(
      waktu: jsonData['waktu'],
      status: jsonData['status'],
      kegiatan: jsonData['kegiatan'],
      alarmID: jsonData['alarmID'],
    );
  }

  static Map<String, dynamic> toMap(Alarm alarm) => {
    'waktu': alarm.waktu,
    'status': alarm.status,
    'kegiatan': alarm.kegiatan,
    'alarmID': alarm.alarmID
  };

  static String encode(List<Alarm> musics) => json.encode(
    musics
        .map<Map<String, dynamic>>((music) => Alarm.toMap(music))
        .toList(),
  );

  static List<Alarm> decode(String alarms) =>
      (json.decode(alarms) as List<dynamic>)
          .map<Alarm>((item) => Alarm.fromJson(item))
          .toList();
}

// class AlarmArray{
//   List<Alarm> alarmArr = [
//     Alarm("09:00",true,"Masak ayam"),
//     Alarm("10:00",true,"Apa ya"),
//   ];
// }