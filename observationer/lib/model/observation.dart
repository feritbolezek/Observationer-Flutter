/// Simple container class for the data an Observation can hold.
///
/// This class is immutable.
class Observation {
  Observation(
      {this.id,
      this.subject,
      this.body,
      this.created,
      this.longitude,
      this.latitude,
      this.imageUrl,
      this.local,
      this.localId});

  final int id;
  final String subject;
  final String body;
  final String created;
  final double longitude;
  final double latitude;
  List<String> imageUrl;
  final bool local;
  final String localId;
}
