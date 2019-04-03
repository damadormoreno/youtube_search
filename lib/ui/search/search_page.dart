import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:youtube_search/ui/search/search.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchPage extends StatefulWidget {
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchBloc = kiwi.Container().resolve<SearchBloc>();
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: _searchBloc,
      child: _buildScaffold(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _searchBloc.dispose();
  }

  Scaffold _buildScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: new SearchBar(),
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
