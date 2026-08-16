import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:bike_taxi_app/services/auth_service.dart';
import 'package:bike_taxi_app/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? mapController;
  Location location = Location();
  LatLng _initialPosition = LatLng(33.3152, 44.3661); // بغداد

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  void _getUserLocation() async {
    try {
      var userLocation = await location.getLocation();
      setState(() {
        _initialPosition = LatLng(userLocation.latitude!, userLocation.longitude!);
      });
      mapController?.animateCamera(CameraUpdate.newLatLng(_initialPosition));
    } catch (e) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser();
    return Scaffold(
      appBar: AppBar(
        title: Text('طلب تكسي دراجة'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
            },
          )
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 14),
        myLocationEnabled: true,
        onMapCreated: (controller) => mapController = controller,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.directions_bike, color: Colors.white),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('طلب دراجة'),
              content: Text('تم استلام طلبك (مثال — هنا تحتاج Backend حقيقي لارسال طلبات).'),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('حسناً'))],
            ),
          );
        },
      ),
    );
  }
}
