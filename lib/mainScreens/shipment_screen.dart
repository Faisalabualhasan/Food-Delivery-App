import 'package:flutter/material.dart';

class ShipmentScreen extends StatefulWidget {
  final String? purchaserId;
  final String? sellerId;
  final String? getOrderID;
  final String? purchaserAddress;
  final double? purchaserLat;
  final double? purchaserLng;

  ShipmentScreen({
    this.purchaserId,
    this.sellerId,
    this.getOrderID,
    this.purchaserAddress,
    this.purchaserLat,
    this.purchaserLng,
  });

  @override
  _ShipmentScreenState createState() => _ShipmentScreenState();
}

class _ShipmentScreenState extends State<ShipmentScreen> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
