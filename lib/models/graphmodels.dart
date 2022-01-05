import 'dart:convert';

class graphModel{
  graphModel({this.namaAlarm, this.delay});
  String? namaAlarm;
  int? delay;

  factory graphModel.fromJson(Map<String, dynamic> jsonData) {
    return graphModel(
      namaAlarm: jsonData['namaAlarm'],
      delay: jsonData['delay']
    );
  }

  static Map<String, dynamic> toMap(graphModel graph) => {
    'namaAlarm': graph.namaAlarm,
    'delay': graph.delay
  };

  static String encode(List<graphModel> musics) => json.encode(
    musics
        .map<Map<String, dynamic>>((music) => graphModel.toMap(music))
        .toList(),
  );

  static List<graphModel> decode(String alarms) =>
      (json.decode(alarms) as List<dynamic>)
          .map<graphModel>((item) => graphModel.fromJson(item))
          .toList();
}