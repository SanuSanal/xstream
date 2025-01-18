import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:xstream/model/league_details_model.dart';
import 'package:http/http.dart' as http;
import 'package:xstream/model/match_data.dart';

Future<List<LeagueDetails>> fetchLeagueSchedule(String day) async {
  List<LeagueDetails> responseDetails = [];

  const url = 'https://soccerlive.app';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    var document = parse(response.body);

    List<Element> tournaments =
        document.getElementsByClassName("top-tournament");
    for (var tournament in tournaments) {
      var leagueName = tournament.querySelector('.league-name')?.text.trim();
      var leagueLogo =
          tournament.querySelector('img')?.attributes['src']?.trim();

      var matches = tournament.querySelectorAll('ul.competitions li');
      List<MatchData> matcheData = [];
      for (var match in matches) {
        var teams = match.querySelectorAll('.name');
        var homeTeam = teams.isNotEmpty ? teams[0].text.trim() : '';
        var awayTeam = teams.length > 1 ? teams[1].text.trim() : '';

        var info = match.querySelector('time')?.attributes['datetime'];

        if (info == null || info.isEmpty) {
          var scoreElement = match.querySelector('.competition-cell-score');
          var scoreText = scoreElement?.nodes[0].text?.trim();
          var statusText = scoreElement
              ?.querySelector('.competition-cell-status')
              ?.text
              .trim();
          info = "$scoreText#$statusText";
        }

        var teamLogos = match.querySelectorAll('.team-logo img');
        var homeLogo =
            teamLogos.isNotEmpty ? teamLogos[0].attributes['src']?.trim() : '';
        var awayLogo =
            teamLogos.length > 1 ? teamLogos[1].attributes['src']?.trim() : '';

        matcheData.add(MatchData(
            homeTeam: homeTeam,
            awayTeam: awayTeam,
            info: info,
            homeLogoUrl: homeLogo ?? '',
            awayLogoUrl: awayLogo ?? ''));
      }
      responseDetails.add(LeagueDetails(
          leagueName: leagueName ?? '',
          leagueLogoUrl: leagueLogo ?? '',
          matches: matcheData));
    }
  }

  return responseDetails;
}
