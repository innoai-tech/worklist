import 'package:flutter/material.dart';

abstract class NavigationPage implements Widget {
  NavigationDestination get destination;
}

abstract class QuickView {
  Widget get view;
}
