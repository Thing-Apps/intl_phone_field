import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/helpers.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class PickerBottomSheetStyle {
  final double borderRadius;

  final Color? borderColor;

  final Color? backgroundColor;

  final String? title;

  final TextStyle? titleTextStyle;

  final EdgeInsets? titlePadding;

  final TextStyle? countryCodeStyle;

  final TextStyle? countryNameStyle;

  final Widget? listTileDivider;

  final EdgeInsets? listTilePadding;

  final EdgeInsets? padding;

  final bool showSearchField;

  final Color? searchFieldCursorColor;

  final InputDecoration? searchFieldInputDecoration;

  final EdgeInsets? searchFieldPadding;

  final double? width;

  PickerBottomSheetStyle({
    this.borderRadius = 40,
    this.borderColor = Colors.transparent,
    this.title,
    this.titleTextStyle,
    this.titlePadding,
    this.backgroundColor,
    this.countryCodeStyle,
    this.countryNameStyle,
    this.listTileDivider,
    this.listTilePadding,
    this.padding,
    this.showSearchField = true,
    this.searchFieldCursorColor,
    this.searchFieldInputDecoration,
    this.searchFieldPadding,
    this.width,
  });
}

class CountryPickerBottomSheet extends StatefulWidget {
  final List<Country> countryList;
  final Country selectedCountry;
  final ValueChanged<Country> onCountryChanged;
  final String searchText;
  final List<Country> filteredCountries;
  final PickerBottomSheetStyle? style;
  final String languageCode;

  const CountryPickerBottomSheet({
    Key? key,
    required this.searchText,
    required this.languageCode,
    required this.countryList,
    required this.onCountryChanged,
    required this.selectedCountry,
    required this.filteredCountries,
    this.style,
  }) : super(key: key);

  @override
  State<CountryPickerBottomSheet> createState() =>
      _CountryPickerBottomSheetState();
}

class _CountryPickerBottomSheetState extends State<CountryPickerBottomSheet> {
  late List<Country> _filteredCountries;
  late Country _selectedCountry;

  @override
  void initState() {
    _selectedCountry = widget.selectedCountry;
    _filteredCountries = widget.filteredCountries.toList()
      ..sort(
        (a, b) => a
            .localizedName(widget.languageCode)
            .compareTo(b.localizedName(widget.languageCode)),
      );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const defaultBorderRadius = 40.0;

    return Container(
      padding: widget.style?.padding ?? const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: widget.style?.backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
              widget.style?.borderRadius ?? defaultBorderRadius),
          topRight: Radius.circular(
              widget.style?.borderRadius ?? defaultBorderRadius),
        ),
        border: Border(
            top: BorderSide(
                color: widget.style?.borderColor ?? Colors.white24,
                width: 1.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
              widget.style?.borderRadius ?? defaultBorderRadius),
          topRight: Radius.circular(
              widget.style?.borderRadius ?? defaultBorderRadius),
        ),
        child: CupertinoScaffold(
          topRadius: Radius.circular(
              widget.style?.borderRadius ?? defaultBorderRadius),
          body: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (widget.style?.title != null)
          Padding(
            padding: widget.style?.titlePadding ?? const EdgeInsets.all(0),
            child: Text(widget.style?.title! ?? '',
                style: widget.style?.titleTextStyle),
          ),
        if (widget.style?.showSearchField ?? true)
          Padding(
            padding:
                widget.style?.searchFieldPadding ?? const EdgeInsets.all(0),
            child: TextField(
              cursorColor: widget.style?.searchFieldCursorColor,
              decoration: widget.style?.searchFieldInputDecoration ??
                  InputDecoration(
                    suffixIcon: const Icon(Icons.search),
                    labelText: widget.searchText,
                  ),
              onChanged: (value) {
                _filteredCountries = widget.countryList.stringSearch(value)
                  ..sort(
                    (a, b) => a
                        .localizedName(widget.languageCode)
                        .compareTo(b.localizedName(widget.languageCode)),
                  );
                if (mounted) setState(() {});
              },
            ),
          ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _filteredCountries.length,
            itemBuilder: (ctx, index) => Column(
              children: <Widget>[
                ListTile(
                  leading: kIsWeb
                      ? Image.asset(
                          'assets/flags/${_filteredCountries[index].code.toLowerCase()}.png',
                          package: 'intl_phone_field',
                          width: 32,
                        )
                      : Text(
                          _filteredCountries[index].flag,
                          style: const TextStyle(fontSize: 18),
                        ),
                  contentPadding: widget.style?.listTilePadding,
                  title: Text(
                    _filteredCountries[index]
                        .localizedName(widget.languageCode),
                    style: widget.style?.countryNameStyle ??
                        const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  trailing: Text(
                    '+${_filteredCountries[index].dialCode}',
                    style: widget.style?.countryCodeStyle ??
                        const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  onTap: () {
                    _selectedCountry = _filteredCountries[index];
                    widget.onCountryChanged(_selectedCountry);
                    Navigator.of(context).pop();
                  },
                ),
                widget.style?.listTileDivider ?? const Divider(thickness: 1),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
