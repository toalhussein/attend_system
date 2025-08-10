import 'package:flutter/material.dart';

class CustomNotifier {

  CustomNotifier._();
  
 static ValueNotifier<DateTime>selectedDate=ValueNotifier<DateTime>(DateTime.now());

 static ValueNotifier<bool>isLoading=ValueNotifier<bool>(false);


  static void selectDate(DateTime dateTime){
    selectedDate.value=dateTime;
  }


  static void triggerLoading(){
    isLoading.value=!isLoading.value;
  }
}