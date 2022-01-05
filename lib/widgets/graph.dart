import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../models/graphmodels.dart';

class Graph extends StatefulWidget{
  Graph({Key? key, required this.fromNotifikasi}) : super(key: key);
  State<Graph> createState() => _graphState();
  bool fromNotifikasi;
}



class _graphState extends State<Graph> {
  List<graphModel>? data;
  void setIni() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen', false);
  }

  Future<Null> getData() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? graphDataString = await prefs.getString('graphdata');
    List<graphModel> graphDataList = [];
    if(graphDataString != null){
      graphDataList = graphModel.decode(graphDataString);
    }
    // String? userPref = prefs.getString('user');
    // List<Map<String,dynamic>> userMap = jsonDecode(userPref!) as List<Map<String, dynamic>>;
    setState(() {
      data = graphDataList;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    setIni();
  }
  @override
  Widget build(BuildContext context) {
    if(data != null){
      print(widget.fromNotifikasi);
      if(widget.fromNotifikasi == true){
        return Scaffold(
          appBar: AppBar(
                title: Text("Flutter Alarm" ,style: TextStyle(color: Colors.white),),
                backgroundColor: Colors.black26,
          ),
          body: SafeArea(
              child: buildGrafik(context, data!)
          ),
        );
      }else{
        return buildGrafik(context, data!);

      }
    }else{
      return Text("");
    }
  }
}
Widget buildGrafik(BuildContext context, List<graphModel> data){
  if(data.isNotEmpty){
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Initialize the chart widget
          SfCartesianChart(

              primaryXAxis: CategoryAxis(),
              // Chart title
              title: ChartTitle(text: 'Grafik Waktu Respon Membuka Notifikasi Alarm'),
              // Enable legend
              legend: Legend(isVisible: true),

              // Enable tooltip
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <ChartSeries<graphModel, String>>[
                ColumnSeries<graphModel, String>(
                    dataSource: data,
                    xValueMapper: (graphModel d, _) => d.namaAlarm,
                    yValueMapper: (graphModel d, _) => d.delay,
                    name: 'Nama Alarm',
                    // Enable data label
                    dataLabelSettings: DataLabelSettings(isVisible: true))
              ]),
        ]);
  }else{
    return Center(child: Text("Data tidak ada"));
  }

}
class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final double sales;
}