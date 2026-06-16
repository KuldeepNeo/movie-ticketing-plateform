import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:movie_ticketing_app/core/network/dio_client.dart';
import 'package:movie_ticketing_app/core/constants/api_constants.dart';
import 'package:movie_ticketing_app/features/auth/presentation/screens/home_screen.dart';
import 'package:movie_ticketing_app/features/auth/presentation/controllers/city_provider.dart';
import 'package:movie_ticketing_app/features/auth/domain/entities/city_model.dart';

class MockSelectedCityNotifier extends SelectedCityNotifier {
  @override
  CityModel? build() {
    return const CityModel(id: 3, name: 'Mumbai');
  }
}

void main() {
  late Dio mockDio;

  setUp(() {
    mockDio = Dio();
    mockDio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (options.path == ApiConstants.movies) {
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'status': 'success',
              'data': [
                {
                  'id': 1,
                  'title': 'Galactic Action Storm',
                  'synopsis': 'A team of astronauts must save Earth.',
                  'runtime_minutes': 148,
                  'language': 'English',
                  'genre': 'Action',
                  'age_rating': 'U/A',
                  'poster_url': '', // Empty to avoid NetworkImage call in test
                  'banner_url': '',
                  'status': 'published'
                }
              ],
              'meta': {'page': 1, 'limit': 20, 'total': 1}
            },
          ));
        } else {
          handler.next(options);
        }
      },
    ));
  });

  testWidgets('HomeScreen renders search, filters, and published movie horizontal cards list', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dioProvider.overrideWithValue(mockDio),
          selectedCityProvider.overrideWith(() => MockSelectedCityNotifier()),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Initial settle
    await tester.pumpAndSettle();

    // Verify header showing the active city
    expect(find.text('Now Showing in Mumbai'), findsOneWidget);

    // Verify search bar hints
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Search movies by title...'), findsOneWidget);

    // Verify movie list content card is loaded
    expect(find.text('Galactic Action Storm'), findsOneWidget);
    expect(find.text('English • U/A'), findsOneWidget);
    expect(find.text('Action'), findsNWidgets(2)); // Matches both filter chip and movie card genre

    // Verify genre and language chips are rendered
    expect(find.text('Comedy'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
  });
}
