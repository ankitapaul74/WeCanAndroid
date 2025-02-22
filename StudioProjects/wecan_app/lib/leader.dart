class Leader {
  String id;
  String name;
  String year;
  String position;
  String imageUrl;

  Leader({required this.id, required this.name, required this.year, required this.position, required this.imageUrl});

  factory Leader.fromMap(Map<String, dynamic> map, String documentId) {
    return Leader(
      id: documentId,
      name: map['name'],
      year: map['year'],
      position: map['position'],
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'year': year,
      'position': position,
      'imageUrl': imageUrl,
    };
  }
}
