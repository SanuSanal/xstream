import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xstream/model/league_details_model.dart';
import 'package:xstream/model/match_data.dart';
import 'package:xstream/service/match_schedule_service.dart';

class MatchSchedulePage extends StatefulWidget {
  const MatchSchedulePage({super.key});

  @override
  MatchSchedulePageState createState() => MatchSchedulePageState();
}

class MatchSchedulePageState extends State<MatchSchedulePage> {
  List<LeagueDetails> _tournaments = [];
  String _key = 'TODAY';
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _loadTournaments(_key);
  }

  Future<void> _loadTournaments(day) async {
    var tournaments = await fetchLeagueSchedule(day);
    setState(() {
      _tournaments = tournaments;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title:
            const Text('Match Schedule', style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          _buildDateButtons(),
          _loading
              ? _loadingWidget()
              : Expanded(
                  child: _tournaments.isEmpty
                      ? const Text('No Matches Scheduled')
                      : ListView.builder(
                          itemCount: _tournaments.length,
                          itemBuilder: (context, index) {
                            var tournament = _tournaments[index];

                            return LeagueSection(
                                leagueName: tournament.leagueName,
                                leagueLogo: tournament.leagueLogoUrl,
                                matches: tournament.matches);
                          }),
                ),
        ],
      ),
    );
  }

  Widget _buildDateButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildDateButton('Yesterday', key: 'YESTERDAY'),
          _buildDateButton('Today', key: 'TODAY'),
          _buildDateButton('Tomorrow', key: 'TOMORROW'),
        ],
      ),
    );
  }

  Widget _buildDateButton(String title, {required String key}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _key == key ? Colors.teal : Colors.grey[300],
      ),
      onPressed: () {
        setState(() {
          _key = key;
          _loading = true;
          _tournaments = [];
        });

        _loadTournaments(key);
      },
      child: Text(title),
    );
  }

  Widget _loadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/loading.gif',
            width: 100,
            height: 100,
          ),
          const SizedBox(height: 20),
          const Text(
            "Loading...",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class LeagueSection extends StatelessWidget {
  final String leagueName;
  final String leagueLogo;
  final List<MatchData> matches;

  const LeagueSection(
      {super.key,
      required this.leagueName,
      required this.leagueLogo,
      required this.matches});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Image.network(
                  leagueLogo,
                  width: 30,
                  height: 30,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.sports_soccer_sharp,
                        color: Colors.red, size: 30);
                  },
                ),
                Text(
                  leagueName,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ...matches.map((match) => MatchCard(match: match)),
        ],
      ),
    );
  }
}

class MatchCard extends StatelessWidget {
  final MatchData match;

  const MatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    String firstPart = '';
    String secondPart = '';

    if (match.info.contains('LIVE') ||
        match.info.contains('FT') ||
        match.info.contains('HT') ||
        match.info.contains('AET')) {
      firstPart = match.info.split('#')[0];
      secondPart = match.info.split('#')[1];
    } else if (match.info.isNotEmpty) {
      var gmtDateTime = DateTime.parse(match.info);
      var localDateTime = gmtDateTime.toLocal();

      firstPart = DateFormat('HH:mm').format(localDateTime);
      secondPart = DateFormat('dd-MMM').format(localDateTime);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _buildTeam(match.homeTeam, match.homeLogoUrl, true),
                  )),
              Flexible(
                flex: 1,
                child: Column(
                  children: [
                    Text(
                      firstPart,
                      style: const TextStyle(color: Colors.black, fontSize: 12),
                    ),
                    Text(
                      secondPart,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Flexible(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: _buildTeam(match.awayTeam, match.awayLogoUrl, false),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeam(String teamName, String logoUrl, bool isHome) {
    var image = Image.network(
      logoUrl,
      width: 30,
      height: 30,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.error, color: Colors.red, size: 30);
      },
    );
    var teamNameLabel = Flexible(
      child: Text(
        teamName,
        style: const TextStyle(color: Colors.black, fontSize: 14),
        overflow: TextOverflow.visible,
        maxLines: 2,
      ),
    );
    return Row(
      mainAxisAlignment:
          isHome ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        isHome ? teamNameLabel : image,
        const SizedBox(width: 8),
        isHome ? image : teamNameLabel,
      ],
    );
  }
}
