import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/app_constants.dart';
import 'package:todo/models/category.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:todo/widgets/custom_color_selection_handle.dart';
import 'package:todo/providers/category_provider.dart';
import 'package:todo/widgets/icon_picker.dart';
import '../app_colour.dart';

class CategoryDetailScreen extends StatefulWidget {
  static const String routeName = '/category-detail';

  const CategoryDetailScreen({super.key});

  @override
  State<StatefulWidget> createState() => CategoryDetailScreenState();
}

class CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  bool _isInit = false;
  bool _shouldFocusTitleField = true;
  String? _categoryId;
  String? _categoryTitle;
  String? _categoryIconName = Category.defaultIconName;
  Color _categoryColor = AppColour.colorCustom;
  int? _categoryOrder;
  String? _iconChoice;

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
        _categoryOrder = category.order;
        _shouldFocusTitleField = false;

        _iconChoice = _categoryIconName;
      }

      _isInit = true;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      // TODO we used to change the appbar color
      // onWillPop: () async {
      //   AppColour.resetStatusBarColor();
      //   return true;
      // },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Category"),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _delete,
            )
          ],
          backgroundColor: _categoryColor,
        ),
        body: Column(
          children: <Widget>[
            _buildTitleHeader(),
            _buildOptionsList(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _save,
          backgroundColor: _categoryColor,
          child: const Icon(Icons.check),
        ),
        resizeToAvoidBottomInset: false,
      ),
    );
  }

  Future _save() async {
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

    if (!mounted) return;

    AppColour.resetStatusBarColor();
    Navigator.of(context).pop();
  }

  Future _delete() async {
    if (_categoryId != null) {
      await Provider.of<CategoryProvider>(context, listen: false)
          .delete(_categoryId!);
    }

    if (!mounted) return;

    AppColour.resetStatusBarColor();
    Navigator.of(context).pop();
  }

  Widget _buildTitleHeader() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        height: 72,
        color: _categoryColor,
        child: Form(
          key: _form,
          child: TextFormField(
            style: const TextStyle(color: Colors.white),
            selectionControls: CustomColorSelectionHandle(Colors.white),
            cursorColor: Colors.white,
            textCapitalization: TextCapitalization.words,
            initialValue: _categoryTitle,
            autofocus: _shouldFocusTitleField,
            onSaved: (String? value) {
              _categoryTitle = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Must enter a Category title';
              }
              return null;
            },
            decoration: const InputDecoration(
              hintStyle: TextStyle(color: Colors.white30),
              labelStyle: TextStyle(color: Colors.white),
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
          title: const Text("Icon"),
          leading: Icon(
            Category.icons[_categoryIconName],
            color: _categoryColor,
          ),
          onTap: _selectIcon,
        ),
        ListTile(
          title: const Text("Colour"),
          leading: CircleColor(
            color: _categoryColor,
            circleSize: 20.0,
          ),
          onTap: _selectColor,
        ),
      ],
    );
  }

  Future _selectIcon() async {
    var iconChoice = await showDialog<String>(
        context: context,
        builder: (context) => IconPicker(
              currentIcon: _categoryIconName ?? "pin",
              color: _categoryColor,
              circleSize: AppConstants.pickerCircleSize,
              spacing: AppConstants.pickerCircleSpacing,
            ));

    if (iconChoice != null) {
      setState(() {
        _categoryIconName = iconChoice;
      });
    }
  }

  Future _selectColor() async {
    Color colorChoice = AppColour.colorCustom;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color!'),
        content: MaterialColorPicker(
          allowShades: false,
          onMainColorChange: (value) {
            if (value != null) {
              colorChoice = value[500] ?? AppColour.colorCustom;
            }
          },
          selectedColor: _categoryColor,
          elevation: 0.0,
          circleSize: AppConstants.pickerCircleSize,
          spacing: AppConstants.pickerCircleSpacing,
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('OK'),
            onPressed: () {
              setState(() {
                _categoryColor = colorChoice;
              });
              AppColour.setStatusBarColor(_categoryColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
