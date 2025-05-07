import 'package:flutter/material.dart';

class MyTab {
  final String text;
  final IconData? icon;
  final Widget? child;

  MyTab({required this.text, this.icon, this.child});
}

class Tabs extends StatefulWidget {
  final List<MyTab> tabs;
  final int selectedIndex;
  final void Function(int) onTap;

  const Tabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left option card list
        SizedBox(
          width: 200,
          child: ListView.builder(
            itemCount: widget.tabs.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: widget.tabs[index].icon != null
                    ? Icon(
                        widget.tabs[index].icon as IconData,
                        color:
                            _selectedIndex == index ? Colors.blue : Colors.grey,
                      )
                    : null,
                title: Text(
                  widget.tabs[index].text ?? '',
                  style: TextStyle(
                    color: _selectedIndex == index ? Colors.blue : Colors.grey,
                  ),
                ),
                selected: _selectedIndex == index,
                selectedTileColor: Colors.blue.withOpacity(0.1),
                selectedColor: Colors.blue,
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              );
            },
          ),
        ),
        // Right configuration content
        Expanded(
          child: widget.tabs[_selectedIndex].child ?? Container(),
        ),
      ],
    );
    ;
  }
}
