import 'package:xstream/model/match_data.dart';

class LeagueDetails {
  final String leagueName;
  final String leagueLogoUrl;
  final List<MatchData> matches;

  LeagueDetails(
      {required this.leagueName,
      required this.leagueLogoUrl,
      required this.matches});
}
