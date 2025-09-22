import 'package:flutter/material.dart';

class CurrencyConverterPage extends StatefulWidget{
  const CurrencyConverterPage({super.key});
  @override
  State<CurrencyConverterPage> createState()=>_CurrencyConverterPageState();
}
class _CurrencyConverterPageState extends State<CurrencyConverterPage>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title:Text("Currency Converter",
        style:TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold
        ) ,),

        
      ),

    );
  }
}

