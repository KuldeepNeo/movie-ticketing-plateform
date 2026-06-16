class TheaterModel {
  final int id;
  final String name;
  final String address;
  final int cityId;
  final String area;
  final String status;
  final String? createdAt;

  const TheaterModel({
    required this.id,
    required this.name,
    required this.address,
    required this.cityId,
    required this.area,
    required this.status,
    this.createdAt,
  });

  factory TheaterModel.fromJson(Map<String, dynamic> json) {
    return TheaterModel(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      cityId: json['city_id'] as int,
      area: json['area'] as String,
      status: json['status'] as String,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city_id': cityId,
      'area': area,
      'status': status,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  @override
  String toString() {
    return 'TheaterModel(id: $id, name: $name, area: $area)';
  }
}

class ScreenModel {
  final int id;
  final int theaterId;
  final String name;
  final int rowsCount;
  final int columnsCount;
  final int? totalSeats;
  final String status;
  final String? createdAt;

  const ScreenModel({
    required this.id,
    required this.theaterId,
    required this.name,
    required this.rowsCount,
    required this.columnsCount,
    this.totalSeats,
    required this.status,
    this.createdAt,
  });

  factory ScreenModel.fromJson(Map<String, dynamic> json) {
    return ScreenModel(
      id: json['id'] as int,
      theaterId: json['theater_id'] as int,
      name: json['name'] as String,
      rowsCount: json['rows_count'] as int,
      columnsCount: json['columns_count'] as int,
      totalSeats: json['total_seats'] as int?,
      status: json['status'] as String,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'theater_id': theaterId,
      'name': name,
      'rows_count': rowsCount,
      'columns_count': columnsCount,
      if (totalSeats != null) 'total_seats': totalSeats,
      'status': status,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  @override
  String toString() {
    return 'ScreenModel(id: $id, name: $name, totalSeats: $totalSeats)';
  }
}
