/// The movie lists the app can show.
///
/// The `name` (e.g. `topRated`) is also used in the `/see-all/:category`
/// route. Each value is mapped to its TMDB endpoint in the data layer
/// (`MovieCategoryEndpoint`), so the domain stays free of API details.
enum MovieCategory { trending, topRated, upcoming, nowPlaying }
