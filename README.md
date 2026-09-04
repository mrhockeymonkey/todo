# To Do

A "To Do" app catering to my own preferred way of tracking tasks and routines. 

```bash
# run emulator
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia __VK_LAYER_NV_optimus=NVIDIA_only ~/Android/Sdk/emulator/emulator -avd DEV_Oppo_API_31

#Swap DEV_Oppo_API_31 for another AVD name if needed — ~/Android/Sdk/emulator/emulator -list-avds shows the options (you also have Pixel_8_Pro_API_35).

flutter run --flavor dev
flutter run --flavor prod --release

# to regenerate icons
flutter pub run flutter_launcher_icons
```

## Things left  to do...

...until finished:

- ?? swap categories for ike style urgent x important ??
- migrate to material 3
- fix all build warnings and vscode problems
- ui fixes
- - add buttons are awful, redo 
- - pretty print json in export?
- - change flag for arrow up? or remove flags???
- refactor structure
- publish to play store
- fix ndk version error, see https://github.com/flutter/flutter/issues/168906

...someday maybe:

- animated loading bar for daily progress
- group tasks by category in task list
