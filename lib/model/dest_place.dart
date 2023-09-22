class DestPlace {
  const DestPlace(this.text, this.photo, this.coord);

  final String text;
  final String photo;
  final DestCoord coord;
}

class DestCoord {
  const DestCoord(this.latitude, this.longitude);

  final double latitude;
  final double longitude;
}
