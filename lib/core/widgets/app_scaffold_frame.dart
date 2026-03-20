import 'package:flutter/material.dart';

class AppScaffoldFrame extends StatelessWidget {
  const AppScaffoldFrame({
    required this.body,
    this.bottomNavigationBar,
    super.key,
  });

  final Widget body;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: body),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
