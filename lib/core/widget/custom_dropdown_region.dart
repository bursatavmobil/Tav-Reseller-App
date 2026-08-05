import 'package:flutter/material.dart';

class CustomSearchDropdown<T> extends StatefulWidget {
  final String label;
  final String hint;
  final List<T> items;
  final T? selectedValue;
  final String Function(T) itemLabelBuilder;
  final bool Function(T, String) searchMatcher;
  final ValueChanged<T?> onChanged;
  final FormFieldValidator<T>? validator;

  const CustomSearchDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.selectedValue,
    required this.itemLabelBuilder,
    required this.searchMatcher,
    required this.onChanged,
    this.validator,
  });

  @override
  State<CustomSearchDropdown<T>> createState() =>
      _CustomSearchDropdownState<T>();
}

class _CustomSearchDropdownState<T> extends State<CustomSearchDropdown<T>> {
  void _showSearchBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _DropdownSearchSheet<T>(
          label: widget.label,
          items: widget.items,
          selectedValue: widget.selectedValue,
          itemLabelBuilder: widget.itemLabelBuilder,
          searchMatcher: widget.searchMatcher,
          onSelected: (value) {
            Navigator.pop(context);
            widget.onChanged(value);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.selectedValue != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: widget.items.isEmpty ? null : _showSearchBottomSheet,
        borderRadius: BorderRadius.circular(10),
        child: FormField<T>(
          initialValue: widget.selectedValue,
          validator: widget.validator,
          builder: (FormFieldState<T> state) {
            return InputDecorator(
              decoration: InputDecoration(
                labelText: widget.label,
                labelStyle: const TextStyle(
                  color: Colors.grey,
                  fontFamily: 'Montserrat',
                ),
                errorText: state.errorText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFFE52525),
                  ), // Red Focus
                ),
                suffixIcon: widget.items.isEmpty
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color.fromARGB(0, 0, 0, 0),
                          ),
                        ),
                      )
                    : const Icon(Icons.arrow_drop_down, color: Colors.black),
                filled: true,
                fillColor: Colors.white,
              ),
              child: Text(
                hasValue
                    ? widget.itemLabelBuilder(widget.selectedValue as T)
                    : widget.hint,
                style: TextStyle(
                  color: hasValue ? Colors.black : Colors.grey.shade500,
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DropdownSearchSheet<T> extends StatefulWidget {
  final String label;
  final List<T> items;
  final T? selectedValue;
  final String Function(T) itemLabelBuilder;
  final bool Function(T, String) searchMatcher;
  final ValueChanged<T> onSelected;

  const _DropdownSearchSheet({
    required this.label,
    required this.items,
    required this.selectedValue,
    required this.itemLabelBuilder,
    required this.searchMatcher,
    required this.onSelected,
  });

  @override
  State<_DropdownSearchSheet<T>> createState() =>
      _DropdownSearchSheetState<T>();
}

class _DropdownSearchSheetState<T> extends State<_DropdownSearchSheet<T>> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  void _filterList(String query) {
    setState(() {
      _filteredItems = widget.items
          .where((item) => widget.searchMatcher(item, query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Text(
                "Pilih ${widget.label}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchCtrl,
                onChanged: _filterList,
                decoration: InputDecoration(
                  hintText: "Cari nama wilayah...",
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFFFFD700),
                    ), // Gold Accent
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = _filteredItems[index];
                    final isSelected = item == widget.selectedValue;
                    return ListTile(
                      title: Text(
                        widget.itemLabelBuilder(item),
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFFE52525)
                              : Colors.black, // Red if selected
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: Color(0xFFE52525),
                            )
                          : null,
                      onTap: () => widget.onSelected(item),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
