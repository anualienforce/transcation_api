import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  final dynamic message;

  const EmptyWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Transactions'),
          centerTitle: true,
        ),
        body: Center(child: Text('$message'),)
    );
  }
}
