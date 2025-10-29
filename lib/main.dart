import 'package:flutter/material.dart';
import './screen/student_screen.dart';
 
void main(){
    runApp(MyApp());
}
 
// ส่วนของ Stateless widget
class MyApp extends StatelessWidget{
  const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'First Flutter App',
            home: StudentScreen()
        );
    }
}