import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../assistantMethods/get_current_location.dart';
import '../global/global.dart';
import '../maps/map_utils.dart';
import '../splashScreen/splash_screen.dart';

class ParcelDeliveringScreen extends StatefulWidget {
  final String? purchaserId;
  final String? purchaserAddress;
  final double? purchaserLat;
  final double? purchaserLng;
  final String? sellerId;
  final String? getOrderId;

  const ParcelDeliveringScreen({
    this.purchaserId,
    this.purchaserAddress,
    this.purchaserLat,
    this.purchaserLng,
    this.sellerId,
    this.getOrderId,
  });

  @override
  _ParcelDeliveringScreenState createState() => _ParcelDeliveringScreenState();
}

class _ParcelDeliveringScreenState extends State<ParcelDeliveringScreen> {
  String orderTotalAmount = "";
  late String sellerId;

  confirmParcelHasBeenDelivered(
    String getOrderId,
    String sellerId,
    String purchaserId,
    String purchaserAddress,
    double purchaserLat,
    double purchaserLng,
  ) {
    String riderNewTotalEarningAmount;
    try {
      double previousRiderEarnings = double.tryParse(previousEarnings) ?? 0.0;
      double perParcelDeliveryAmount = double.tryParse(orderTotalAmount) ?? 0.0;
      riderNewTotalEarningAmount =
          (previousRiderEarnings + perParcelDeliveryAmount).toString();
    } catch (e) {
      print("Error parsing double value: $e");
      return;
    }

    FirebaseFirestore.instance.collection("orders").doc(getOrderId).update({
      "status": "ended",
      "address": completeAddress,
      "lat": position!.latitude,
      "lng": position!.longitude,
      "earnings": perParcelDeliveryAmount.toString(),
    }).then((value) {
      FirebaseFirestore.instance
          .collection("riders")
          .doc(sharedPreferences!.getString("uid"))
          .update({
        "earnings": riderNewTotalEarningAmount,
      });
    }).then((value) {
      FirebaseFirestore.instance.collection("sellers").doc(sellerId).update({
        "earnings":
            (double.parse(orderTotalAmount) + double.parse(previousEarnings))
                .toString(),
      });
    }).then((value) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(purchaserId)
          .collection("orders")
          .doc(getOrderId)
          .update({
        "status": "ended",
        "riderUID": sharedPreferences!.getString("uid"),
      });
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (c) => const MySplashScreen()),
    );
  }

  getOrderTotalAmount() {
    FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.getOrderId)
        .get()
        .then((snap) {
      setState(() {
        orderTotalAmount = snap.data()!["totalAmount"].toString();
        sellerId = snap.data()!["sellerUID"].toString();
      });
    }).then((value) {
      getSellerData();
    });
  }

  getSellerData() {
    FirebaseFirestore.instance
        .collection("sellers")
        .doc(sellerId)
        .get()
        .then((snap) {
      setState(() {
        previousEarnings = snap.data()!["earnings"].toString();
      });
    });
  }

  @override
  void initState() {
    super.initState();

    UserLocation uLocation = UserLocation();
    uLocation.getCurrentLocation();

    getOrderTotalAmount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "images/confirm2.png",
          ),
          const SizedBox(
            height: 5,
          ),
          GestureDetector(
            onTap: () {
              MapUtils.lauchMapFromSourceToDestination(
                position!.latitude,
                position!.longitude,
                widget.purchaserLat!,
                widget.purchaserLng!,
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/restaurant.png',
                  width: 50,
                ),
                const SizedBox(
                  width: 7,
                ),
                Column(
                  children: const [
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      "Show Delivery Drop-off Location",
                      style: TextStyle(
                        fontFamily: "Signatra",
                        fontSize: 18,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: InkWell(
                onTap: () {
                  UserLocation uLocation = UserLocation();
                  uLocation.getCurrentLocation();

                  confirmParcelHasBeenDelivered(
                    widget.getOrderId!,
                    sellerId,
                    widget.purchaserId!,
                    widget.purchaserAddress!,
                    widget.purchaserLat!,
                    widget.purchaserLng!,
                  );
                },
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.cyan, Colors.amber],
                      begin: FractionalOffset(0.0, 0.0),
                      end: FractionalOffset(1.0, 0.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp,
                    ),
                  ),
                  width: MediaQuery.of(context).size.width - 90,
                  height: 50,
                  child: const Center(
                    child: Text(
                      "Order has been Delivered - Confirm",
                      style: TextStyle(color: Colors.white, fontSize: 15.0),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
