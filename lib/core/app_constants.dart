class AppConstants {
  static const genres = [
    'All',
    'Action',
    'Adventure',
    'Animation',
    'Biography',
    'Comedy',
    'Crime',
    'Documentary',
    'Drama',
    'Family',
    'Fantasy',
    'History',
    'Horror',
    'Music',
    'Mystery',
    'Romance',
    'Sci-Fi',
    'Sport',
    'Thriller',
    'War',
    'Western',
  ];

  static const homeGenres = ['Action', 'Comedy', 'Drama', 'Animation', 'Horror', 'Sci-Fi'];

  static const avatarsCount = 9;

  static String avatarUrl(int index) =>
      'https://api.dicebear.com/7.x/avataaars/png?seed=route$index&size=200&backgroundColor=b6e3f4';
}
