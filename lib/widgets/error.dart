import 'package:flutter/material.dart';

class ErrorApi extends StatelessWidget {
  final dynamic message;

  final dynamic onRetry;

  const ErrorApi({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body:  Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$message'),
              ElevatedButton(onPressed: (){
                onRetry();
              }, child: Text('Retry'))
            ],
          ),)
    );
  }
}
