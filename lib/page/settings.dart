import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show ToggleButtons;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../intent.dart';
import '../main.dart';
import '../model/setting_options.dart';

typedef _TextBoxValue = TextEditingController;
typedef _NumberBoxValue = int;
typedef _CheckBoxValue = bool;
typedef _MultipleTextBoxValue = List<(TextEditingController, FocusNode)>;
typedef _ToggleButtonValue = List<(String, bool)>;
typedef _ButtonValue = void;

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static final Future<SharedPreferences> _loadSharedPreferences =
      SharedPreferences.getInstance();

  static void _navigationPop(final BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Actions(
      actions: {
        NavigationPopIntent: CallbackAction<Intent>(
          onInvoke: (final _) => _navigationPop(context),
        )
      },
      child: NavigationView(
        appBar: const NavigationAppBar(title: Text('Settings')),
        content: FutureBuilder(
            future: _loadSharedPreferences,
            builder: (final context, final snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: ProgressBar());
              }

              const minimizedOnLaunchKey = 'minimized_on_launch';
              final minimizedOnLaunchValue =
                  snapshot.data?.getBool(minimizedOnLaunchKey);
              const autoFocusNavigationKey = 'autofocus_navigation';
              final autoFocusNavigationValue =
                  snapshot.data?.getBool(autoFocusNavigationKey);
              const videoPlayCommandsKey = 'video_play_commands';
              final videoPlayCommandsValue =
                  snapshot.data?.getStringList(videoPlayCommandsKey);
              const youtubeAPIKeyKey = 'youtube_api_key';
              final youtubeAPIKeyValue =
                  snapshot.data?.getString(youtubeAPIKeyKey);
              const youtubeResultPerSearchKey = 'youtube_result_per_search';
              final youtubeResultPerSearchValue =
                  snapshot.data?.getInt(youtubeResultPerSearchKey);
              const enableHistoryKey = 'enable_history';
              final enableHistoryValue =
                  snapshot.data?.getBool(enableHistoryKey);
              const historyToKeepKey = 'history_to_keep';
              final historyToKeepValue =
                  snapshot.data?.getInt(historyToKeepKey);

              return ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: Row(
                      children: [
                        Icon(FluentIcons.app_icon_default),
                        SizedBox(width: 16),
                        Text('App Behavior'),
                      ],
                    ),
                  ),
                  _SettingItem(
                    key: UniqueKey(),
                    label: 'Minimized on launch:',
                    value: minimizedOnLaunchValue ?? false,
                    onChanged: (final bool newValue) async {
                      await snapshot.data
                          ?.setBool(minimizedOnLaunchKey, newValue);
                    },
                    autofocus: true,
                  ),
                  const SizedBox(height: 8),
                  _SettingItem(
                    key: UniqueKey(),
                    label: 'On play:',
                    value: OnPlayOptions.nothing,
                  ),
                  const SizedBox(height: 8),
                  _SettingItem(
                    key: UniqueKey(),
                    label: 'Autofocus navigation:',
                    value: autoFocusNavigationValue ?? true,
                    onChanged: (final bool newValue) async {
                      await snapshot.data
                          ?.setBool(autoFocusNavigationKey, newValue);
                    },
                  ),
                  const SizedBox(height: 8),
                  _SettingItem(
                    key: UniqueKey(),
                    label: 'Video play commands:',
                    value: videoPlayCommandsValue ?? [''],
                    multiline: true,
                    onChanged: (final List<String> newValue) async {
                      await snapshot.data
                          ?.setStringList(videoPlayCommandsKey, newValue);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: Row(
                      children: [
                        Icon(FluentIcons.video_search),
                        SizedBox(width: 16),
                        Text('Youtube API Settings'),
                      ],
                    ),
                  ),
                  _SettingItem(
                    key: UniqueKey(),
                    label: 'API key:',
                    value: youtubeAPIKeyValue ?? '',
                    sensitive: true,
                    onChanged: (final String newValue) async {
                      await snapshot.data
                          ?.setString(youtubeAPIKeyKey, newValue);
                    },
                  ),
                  const SizedBox(height: 8),
                  _SettingItem(
                    key: UniqueKey(),
                    label: 'Enable publish date:',
                    value: true,
                  ),
                  const SizedBox(height: 8),
                  _SettingItem(
                    key: UniqueKey(),
                    label: 'Enable watch count:',
                    value: false,
                  ),
                  const SizedBox(height: 8),
                  _SettingItem(
                    key: UniqueKey(),
                    label: 'Result per search:',
                    value: youtubeResultPerSearchValue ?? 10,
                    onChanged: (final int newValue) async {
                      await snapshot.data
                          ?.setInt(youtubeResultPerSearchKey, newValue);
                    },
                  ),
                  const SizedBox(height: 8),
                  _SettingItem(
                    key: UniqueKey(),
                    label: 'Infinite scroll search:',
                    value: false,
                  ),
                  const SizedBox(height: 8),
                  _SettingItem(
                    key: UniqueKey(),
                    label: 'Region id:',
                    value: '',
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: Row(
                      children: [
                        Icon(FluentIcons.color),
                        SizedBox(width: 16),
                        Text('Theme'),
                      ],
                    ),
                  ),
                  _SettingItem(
                    key: UniqueKey(),
                    label: 'Brightness:',
                    value: BrightnessOptions.dark,
                  ),
                  Consumer(
                    builder: (final BuildContext context, final WidgetRef ref,
                        final Widget? child) {
                      return _SettingItem(
                        key: UniqueKey(),
                        label: 'Dark mode:',
                        value: true,
                        onChanged: (final bool newValue) {
                          ref.read(brightnessModeProvider.notifier).switchMode(
                              newValue
                                  ? BrightnessOptions.dark
                                  : BrightnessOptions.light);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _SettingItem(
                    key: UniqueKey(),
                    label: 'Visual Density:',
                    value: VisualDensityOptions.adaptive,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: Row(
                      children: [
                        Icon(FluentIcons.history),
                        SizedBox(width: 16),
                        Text('History and Saved Playlist'),
                      ],
                    ),
                  ),
                  _SettingItem(
                    key: UniqueKey(),
                    label: 'Pause history:',
                    value: !(enableHistoryValue ?? true),
                    onChanged: (final newValue) async {
                      await snapshot.data?.setBool(enableHistoryKey, newValue);
                    },
                  ),
                  const SizedBox(height: 8),
                  _SettingItem(
                    key: UniqueKey(),
                    label: 'History to keep:',
                    value: historyToKeepValue ?? 200,
                    onChanged: (final newValue) async {
                      await snapshot.data?.setInt(historyToKeepKey, newValue);
                    },
                  ),
                  const SizedBox(height: 8),
                  _SettingItem(
                      key: UniqueKey(),
                      label: 'Remove history:',
                      value: _ButtonValue,
                      onChanged: (final _) async {
                        await snapshot.data?.setStringList('history', []);
                      }),
                  const SizedBox(height: 16),
                ],
              );
            }),
      ),
    );
  }
}

const unrecognizedValue = '''
Unrecognized value type. Acceptable types are: String, int, bool, List<String>''';

class _SettingItem<T> extends StatefulWidget {
  final String label;
  final T value;
  final void Function(T)? onChanged;
  final bool sensitive;
  final bool autofocus;
  final bool multiline;

  _SettingItem({
    required this.label,
    required this.value,
    this.onChanged,
    this.sensitive = false,
    this.autofocus = false,
    this.multiline = false,
    super.key,
  })  : assert(
          switch (value) {
            String() => true,
            int() => true,
            bool() => true,
            List<String>() => true,
            SettingOptions() => true,
            _ButtonValue => true,
            _ => false,
          },
          unrecognizedValue,
        ),
        assert(
          !sensitive || value is String,
          'Sensitive option is only valid for String',
        );

  @override
  State<_SettingItem<T>> createState() => _SettingItemState();
}

class _SettingItemState<T> extends State<_SettingItem<T>> {
  late Object initialValue;
  late bool isHidden;

  @override
  void initState() {
    isHidden = widget.sensitive;
    final value = widget.value;
    switch (value) {
      case String():
        initialValue = TextEditingController()..text = value;
      case int():
        initialValue = value;
      case bool():
        initialValue = value;
      case List<String>():
        initialValue = [
          for (final item in value)
            (TextEditingController()..text = item, FocusNode())
        ];
      case SettingOptions():
        final names = value.names();
        final selectedIndex = value.currentIndex();
        final size = value.size();
        initialValue = List.generate(
          size,
          (final index) => (names[index], index == selectedIndex),
        );
      default:
        initialValue = Null;
    }
    super.initState();
  }

  Widget _textBox(final _TextBoxValue value) {
    return Expanded(
      child: TextBox(
        autofocus: widget.autofocus,
        obscureText: widget.sensitive && isHidden,
        controller: value,
        maxLines: widget.multiline ? null : 1,
        onChanged: (final String newValue) {
          widget.onChanged!(newValue as T);
        },
      ),
    );
  }

  Widget _numberBox(final int value) {
    return Expanded(
      child: NumberBox(
        value: value,
        onChanged: (final int? newValue) {
          if (newValue == null) return;
          widget.onChanged!(newValue as T);
        },
        min: 10,
        smallChange: 10,
        largeChange: 50,
        clearButton: false,
        mode: SpinButtonPlacementMode.inline,
      ),
    );
  }

  Widget _checkBox(final bool value) {
    return SizedBox(
      height: 32,
      child: Center(
        child: Checkbox(
          autofocus: widget.autofocus,
          checked: value,
          onChanged: (final bool? newValue) {
            if (newValue == null) return;
            widget.onChanged!(newValue as T);
            setState(() => initialValue = newValue);
          },
        ),
      ),
    );
  }

  Widget _multipleTextBox(final _MultipleTextBoxValue value) {
    return Expanded(
      child: Column(
        children: [
          for (final (controller, focusNode) in value)
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextBox(
                        focusNode: focusNode,
                        obscureText: widget.sensitive && isHidden,
                        controller: controller,
                        maxLines: widget.multiline ? null : 1,
                        onChanged: (final _) {
                          widget.onChanged!(List<String>.of(
                                  value.map((final e) => e.$1.text.trim()))
                              .toList() as T);
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(FluentIcons.chrome_close),
                      onPressed: value.length > 1
                          ? () {
                              setState(
                                  () => value.remove((controller, focusNode)));
                              widget.onChanged!(List<String>.of(
                                      value.map((final e) => e.$1.text.trim()))
                                  .toList() as T);
                            }
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Button(
              onPressed: value.last.$1.text.isNotEmpty
                  ? () => setState(() => value.add(
                      (TextEditingController(), FocusNode()..requestFocus())))
                  : null,
              child: const SizedBox(
                width: double.infinity,
                child: Text('Add more'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleButtons(final _ToggleButtonValue value) {
    return Expanded(
      child: LayoutBuilder(
        builder: (final context, final constraints) {
          final fluentTheme = FluentTheme.of(context);
          return ToggleButtons(
            isSelected: value.map((final select) => select.$2).toList(),
            constraints: BoxConstraints(
              minWidth:
                  constraints.maxWidth / value.length - (value.length - 1),
              minHeight: 28,
            ),
            onPressed: (final selectedIndex) {
              setState(() {
                initialValue = List.generate(
                  value.length,
                  (final index) => (value[index].$1, selectedIndex == index),
                );
              });
            },
            children: [
              for (final (name, _) in value) Text(name),
            ],
            borderWidth: 1,
            borderColor: const Color.fromRGBO(158, 160, 165, 1),
            selectedBorderColor: fluentTheme.accentColor,
            selectedColor: fluentTheme.brightness == Brightness.light
                ? Colors.white
                : Colors.black,
            fillColor: fluentTheme.brightness == Brightness.light
                ? fluentTheme.accentColor.dark
                : fluentTheme.accentColor.lighter,
            borderRadius: BorderRadius.circular(4),
            splashColor: Colors.transparent,
          );
        },
      ),
    );
  }

  Widget _button() {
    return Expanded(
      child: SizedBox(
        height: 32,
        child: Button(
          onPressed: () {
            widget.onChanged!(() as T);
          },
          child: const Center(child: Text('Clear history')),
        ),
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final value = initialValue;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 146,
            height: 32,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.label,
                style: const TextStyle(fontWeight: FontWeight.w300),
              ),
            ),
          ),
          const SizedBox(width: 8),
          switch (value) {
            _TextBoxValue() => _textBox(value),
            _NumberBoxValue() => _numberBox(value),
            _CheckBoxValue() => _checkBox(value),
            _MultipleTextBoxValue() => _multipleTextBox(value),
            _ToggleButtonValue() => _toggleButtons(value),
            _ => _button(),
          },
          if (widget.sensitive) ...[
            const SizedBox(width: 8),
            Tooltip(
              message: isHidden ? 'Show obscured text' : 'Hide sensitive text',
              child: IconButton(
                icon: Icon(isHidden ? FluentIcons.red_eye : FluentIcons.hide),
                onPressed: () => setState(() => isHidden = !isHidden),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    final value = initialValue;
    switch (value) {
      case TextEditingController():
        value.dispose();
      case List<TextEditingController>():
        for (final item in value) {
          item.dispose();
        }
    }
  }
}
