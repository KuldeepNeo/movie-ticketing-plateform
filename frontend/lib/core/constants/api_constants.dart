class ApiConstants {
  // Configures the base url, fallback to localhost for development
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );

  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Cities
  static const String cities = '/cities';

  // Admin Movie Management
  static const String adminMovies = '/admin/movies';
  static String adminMovie(int id) => '/admin/movies/$id';

  // Admin Theater Management
  static const String adminTheaters = '/admin/theaters';
  static String adminTheater(int id) => '/admin/theaters/$id';

  // Admin Screen Management
  static String adminTheaterScreens(int theaterId) => '/admin/theaters/$theaterId/screens';
  static String adminScreen(int id) => '/admin/screens/$id';

  // Admin Show Management
  static const String adminShows = '/admin/shows';
  static String adminShow(int id) => '/admin/shows/$id';

  // Customer Movie Discovery
  static const String movies = '/movies';
  static String movieDetails(int id) => '/movies/$id';
}
