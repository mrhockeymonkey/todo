import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:todo/models/category.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
// import 'package:icon_picker/icon_picker.dart';
import 'package:todo/models/routine.dart';
import 'package:todo/providers/category_provider.dart';
import 'package:todo/providers/routine_provider.dart';
import 'package:todo/widgets/repeat_picker.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import '../app_colour.dart';

class CategoryDetailScreen extends StatefulWidget {
  static const String routeName = '/category-detail';

  @override
  State<StatefulWidget> createState() => CategoryDetailScreenState();
}

class CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  bool _isInit = false;
  bool _shouldFocusTitleField = true;
  String? _categoryId;
  String? _categoryTitle;
  String? _categoryIconName;
  IconData? _iconData;
  Color _categoryColor = AppColour.colorCustom; // TODO
  int? _categoryOrder;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      var categoryId = ModalRoute.of(context)?.settings.arguments;

      if (categoryId is String) {
        final category = Provider.of<CategoryProvider>(context, listen: false)
            .getItemById(categoryId);

        _categoryId = category.id;
        _categoryTitle = category.title;
        _categoryColor = category.color;
        _categoryIconName = category.iconName;
        _iconData = Category.icons[_categoryIconName];
        _categoryOrder = category.order;
        _shouldFocusTitleField = false;
      }

      _isInit = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Category"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _delete,
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          _buildTitleHeader(),
          _buildOptionsList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: _save,
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  void _save() async {
    // validate and save the form data
    final isValid = _form.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    _form.currentState?.save();

    // save item via provider and pop
    final category = Category(
      id: _categoryId,
      name: _categoryTitle ?? "Title",
      color: _categoryColor,
      iconName: _categoryIconName ?? "pin",
      order: _categoryOrder ?? 9999,
    );

    await Provider.of<CategoryProvider>(context, listen: false)
        .addOrUpdate(category);
    Navigator.of(context).pop();
  }

  void _delete() async {
    if (_categoryId != null) {
      await Provider.of<CategoryProvider>(context, listen: false)
          .delete(_categoryId!);
    }
    Navigator.of(context).pop();
  }

  Widget _buildTitleHeader() => Container(
        padding: EdgeInsets.symmetric(horizontal: 25),
        height: 72,
        color: AppColour.colorCustom,
        child: Form(
          key: _form,
          child: TextFormField(
            style: TextStyle(color: Colors.white),
            textCapitalization: TextCapitalization.words,
            initialValue: _categoryTitle,
            autofocus: _shouldFocusTitleField,
            onSaved: (String? value) {
              _categoryTitle = value;
            },
            decoration: InputDecoration(
              hintText: 'New Category',
              labelText: 'Name',
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
            ),
          ),
        ),
      );

  Widget _buildOptionsList() {
    return ListView(
      shrinkWrap: true, // constrain listview within remaining column space
      children: [
        ListTile(
          title: Text("Icon"),
          leading: Icon(
            Category.icons[_categoryIconName],
            color: _categoryColor,
          ),
          onTap: _selectIcon,
          // subtitle:
          //     Text("Every ${_routineRecurNum.toString()} $_routineRecurLen"),
          // onTap: _selectSchedule,
        ),
        ListTile(
          title: Text("Colour"),
          leading: Icon(
            Icons.square,
            color: _categoryColor,
          ),
          onTap: _selectColor,
          // subtitle: Text("Coming Soon"),
          // onTap: () {
          //   setState(() {
          //     _displayOnPinned = !_displayOnPinned;
          //   });
          // }
        ),
        // ListTile(
        //   title: TextFormField(
        //     initialValue: _notesValue,
        //     keyboardType: TextInputType.multiline,
        //     maxLines: null,
        //     decoration: InputDecoration(
        //       hintText: "Notes",
        //       hintStyle: TextStyle(color: Colors.black54),
        //     ),
        //     cursorColor: Colors.black,
        //     onChanged: (value) {
        //       var oldValue = _notesValue;
        //       _notesValue = value;

        //       if (oldValue == "" && value != "") setState(() {});
        //       if (oldValue != "" && value == "") setState(() {});
        //     },
        //   ),
        //   leading: Icon(
        //     //Icons.subject,
        //     FontAwesome.sticky_note,
        //     color: _notesValue != ""
        //         ? AppColour.colorCustom
        //         : AppColour.InactiveColor,
        //   ),
        // ),
      ],
    );
  }

  // Future _selectIcon() async {
  //   await showDialog(
  //     context: context,
  //     builder: (context) => IconPicker(
  //       initialValue: 'favorite',
  //       icon: Icon(Icons.apps),
  //       labelText: "Icon",
  //       title: "Select an icon",
  //       cancelBtn: "CANCEL",
  //       enableSearch: true,
  //       searchHint: 'Search icon',
  //       iconCollection: Category.icons,
  //       onChanged: (val) => print(val),
  //       onSaved: (val) => print(val),
  //     ),
  //   );
  // }

  Future _selectIcon() async {
    String? choice;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Pick an icon"),
        content: Container(
          height: 500,
          width: 600,
          child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
              ),
              itemCount: Category.icons.length,
              itemBuilder: (BuildContext context, int index) {
                var icon = Category.icons.entries.toList()[index];
                return IconButton(
                  onPressed: () {
                    choice = icon.key;
                  },
                  icon: Icon(icon.value),
                );
              }),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('OK'),
            onPressed: () {
              setState(() => _categoryIconName = choice);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future _selectColor() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color!'),
        content: MaterialColorPicker(
          onColorChange: (Color color) {
            setState(() {
              _categoryColor = color;
            });
          },
          selectedColor: _categoryColor,
          // colors: [
          //   Colors.red,
          //   Colors.deepOrange,
          //   Colors.blue,
          //   Colors.amber,
          //   Colors.deepPurple,
          //   Colors.green,
          // ],
          onlyShadeSelection: true,
        ),

        // SingleChildScrollView(
        //   // child: ColorPicker(
        //   //   pickerColor: Colors.black,
        //   //   onColorChanged: (value) {
        //   //     print(value);
        //   //   },
        //   // ),
        //   // Use Material color picker:
        //   //
        //   // child: MaterialPicker(
        //   //   pickerColor: pickerColor,
        //   //   onColorChanged: changeColor,
        //   //   showLabel: true, // only on portrait mode
        //   // ),
        //   //
        //   // Use Block color picker:
        //   //
        //   child: BlockPicker(
        //     pickerColor: _categoryColor,
        //     onColorChanged: (value) {
        //       print(value);
        //     },
        //   ),
        //
        // child: MultipleChoiceBlockPicker(
        //   pickerColors: currentColors,
        //   onColorsChanged: changeColors,
        // ),
        // ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('OK'),
            onPressed: () {
              //setState(() => currentColor = pickerColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
