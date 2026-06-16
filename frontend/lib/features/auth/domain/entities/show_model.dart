class ShowModel {
  final int id;
  final int movieId;
  final int screenId;
  final String showDate;
  final String startTime;
  final String endTime;
  final int ticketPrice;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final int? totalSeatsCreated;

  const ShowModel({
    required this.id,
    required this.movieId,
    required this.screenId,
    required this.showDate,
    required this.startTime,
    required this.endTime,
    required this.ticketPrice,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.totalSeatsCreated,
  });

  factory ShowModel.fromJson(Map<String, dynamic> json) {
    return ShowModel(
      id: json['id'] as int,
      movieId: json['movie_id'] as int,
      screenId: json['screen_id'] as int,
      showDate: json['show_date'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      ticketPrice: json['ticket_price'] as int,
      status: json['status'] as String? ?? 'scheduled',
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      totalSeatsCreated: json['total_seats_created'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movie_id': movieId,
      'screen_id': screenId,
      'show_date': showDate,
      'start_time': startTime,
      'end_time': endTime,
      'ticket_price': ticketPrice,
      'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (totalSeatsCreated != null) 'total_seats_created': totalSeatsCreated,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShowModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          movieId == other.movieId &&
          screenId == other.screenId &&
          showDate == other.showDate &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          ticketPrice == other.ticketPrice &&
          status == other.status;

  @override
  int get hashCode =>
      id.hashCode ^
      movieId.hashCode ^
      screenId.hashCode ^
      showDate.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      ticketPrice.hashCode ^
      status.hashCode;

  @override
  String toString() {
    return 'ShowModel(id: $id, movieId: $movieId, screenId: $screenId, showDate: $showDate, startTime: $startTime, endTime: $endTime, ticketPrice: $ticketPrice, status: $status)';
  }
}
