import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:movie_ticketing_app/core/network/dio_client.dart';
import 'package:movie_ticketing_app/core/constants/api_constants.dart';
import 'package:movie_ticketing_app/features/auth/presentation/screens/admin_shows_screen.dart';

void main() {
  late Dio mockDio;

  beforeEach(() {
    mockDio = Dio();
    mockDio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (options.path == ApiConstants.adminShows) {
          if (options.method == 'GET') {
            handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'status': 'success',
                'data': [
                  {
                    'id': 1,
                    'movie_id': 10,
                    'screen_id': 5,
                    'show_date': '2026-06-25',
                    'start_time': '2026-06-25T14:00:00Z',
                    'end_time': '2026-06-25T16:00:00Z',
                    'ticket_price': 250,
                    'status': 'scheduled',
                    'created_at': '2026-06-16T12:00:00Z'
                  }
                ],
                'meta': {'page': 1, 'limit': 20, 'total': 1}
              },
            ));
          } else if (options.method == 'POST') {
            handler.resolve(Response(
              requestOptions: options,
              statusCode: 201,
              data: {
                'status': 'success',
                'data': {
                  'id': 2,
                  'movie_id': 10,
                  'screen_id': 5,
                  'show_date': '2026-06-25',
                  'start_time': '2026-06-25T14:00:00Z',
                  'end_time': '2026-06-25T16:00:00Z',
                  'ticket_price': 250,
                  'status': 'scheduled'
                }
              },
            ));
          }
        } else if (options.path == ApiConstants.adminMovies) {
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'status': 'success',
              'data': [
                {
                  'id': 10,
                  'title': 'Test Published Movie',
                  'synopsis': 'Test Synopsis details here.',
                  'runtime_minutes': 120,
                  'language': 'English',
                  'genre': 'Action',
                  'age_rating': 'U/A',
                  'poster_url': 'http://example.com/poster.jpg',
                  'banner_url': 'http://example.com/banner.jpg',
                  'status': 'published'
                }
              ],
              'meta': {'page': 1, 'limit': 20, 'total': 1}
            },
          ));
        } else if (options.path == ApiConstants.adminTheaters) {
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'status': 'success',
              'data': [
                {
                  'id': 1,
                  'name': 'PVR Test',
                  'address': 'Test Address',
                  'city_id': 3,
                  'area': 'Test Area',
                  'status': 'active'
                }
              ]
            },
          ));
        } else if (options.path == ApiConstants.adminTheaterScreens(1)) {
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'status': 'success',
              'data': [
                {
                  'id': 5,
                  'theater_id': 1,
                  'name': 'Screen 1',
                  'rows_count': 10,
                  'columns_count': 10,
                  'status': 'active'
                }
              ]
            },
          ));
        } else {
          handler.next(options);
        }
      },
    ));
  });

  testWidgets('AdminShowsScreen renders, lists shows, and opens schedule dialog', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dioProvider.overrideWithValue(mockDio),
        ],
        child: const MaterialApp(
          home: AdminShowsScreen(),
        ),
      ),
    );

    // Let listings load
    await tester.pumpAndSettle();

    // Verify Title and schedule button
    expect(find.text('Shows Schedule'), findsOneWidget);
    expect(find.text('Schedule Show'), findsOneWidget);

    // Verify datatable listings
    expect(find.text('#1'), findsOneWidget);
    expect(find.text('Test Published Movie'), findsOneWidget);
    expect(find.text('Screen #5'), findsOneWidget);
    expect(find.text('Rs. 250'), findsOneWidget);
    expect(find.text('SCHEDULED'), findsOneWidget);

    // Click on Schedule Show button
    await tester.tap(find.text('Schedule Show'));
    await tester.pumpAndSettle();

    // Verify Dialog opened
    expect(find.text('Schedule New Show'), findsOneWidget);
    expect(find.text('Select Movie'), findsOneWidget);
    expect(find.text('Select Theater'), findsOneWidget);
    expect(find.text('Select Screen'), findsOneWidget);
    expect(find.text('Ticket Price (Rs.)'), findsOneWidget);
  });
}

// Dummy helper functions for hook setup in tests
void beforeEach(void Function() body) {
  setUp(body);
}
