import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

class SearchInput extends StatelessWidget {
  const SearchInput({
    Key key,
    @required this.searchTextEditingController,
  }) : super(key: key);

  final TextEditingController searchTextEditingController;

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        child: TextField(
          controller: searchTextEditingController,
          textInputAction: TextInputAction.search,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 16),
              prefixIcon: SvgPicture.asset(
                'images/ic_search.svg',
                fit: BoxFit.scaleDown,
              ),
              hintText: 'Rechercher...'),
        ),
      );
}
