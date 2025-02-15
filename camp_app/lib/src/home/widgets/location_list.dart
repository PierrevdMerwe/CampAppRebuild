import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../campsite/screens/campsite_search_screen.dart';
import 'package:provider/provider.dart';
import '../../core/config/theme/theme_model.dart';

class LocationList extends StatelessWidget {
  final List<LocationItem> locations;

  const LocationList({super.key, required this.locations});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: locations.length,
        itemBuilder: (BuildContext context, int index) {
          return LocationCard(location: locations[index]);
        },
      ),
    );
  }
}

class LocationItem {
  final String name;
  final String imagePath;

  const LocationItem({required this.name, required this.imagePath});
}

class LocationCard extends StatelessWidget {
  final LocationItem location;

  const LocationCard({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return Padding(
      padding: const EdgeInsets.only(
        top: 10.0,
        left: 10.0,
        right: 10.0,
        bottom: 5.0,
      ),
      child: SizedBox(
        width: 250,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchScreen(location.name),
              ),
            );
          },
          child: Card(
            color: const Color(0xffF5F8F5), // Light green-white color
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 5),
                  Container(
                    width: 225,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      image: DecorationImage(
                        image: AssetImage(location.imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    location.name,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: themeModel.isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Helper class to manage location data
class LocationData {
  static List<LocationItem> getAllLocations() {
    return [
      const LocationItem(
        name: 'Western Cape',
        imagePath: 'images/western_cape.png',
      ),
      const LocationItem(
        name: 'Northern Cape',
        imagePath: 'images/northern_cape.png',
      ),
      const LocationItem(
        name: 'North West',
        imagePath: 'images/north_west.png',
      ),
      const LocationItem(
        name: 'Mpumalanga',
        imagePath: 'images/mpumalanga.png',
      ),
      const LocationItem(
        name: 'Limpopo',
        imagePath: 'images/limpopo.png',
      ),
      const LocationItem(
        name: 'KwaZulu-Natal',
        imagePath: 'images/kzn.png',
      ),
      const LocationItem(
        name: 'Gauteng',
        imagePath: 'images/gauteng.png',
      ),
      const LocationItem(
        name: 'Free State',
        imagePath: 'images/free_state.jpg',
      ),
      const LocationItem(
        name: 'Eastern Cape',
        imagePath: 'images/eastern_cape.png',
      ),
    ];
  }
}