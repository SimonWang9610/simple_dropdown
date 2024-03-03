// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'controller.dart';
import 'menu_builder_delegate.dart';
import 'models.dart';

/// A widget that will display a dropdown menu when triggered.
/// The dropdown menu will be built by [DropdownMenuBuilderDelegate] so that users can customize the menu.
///
/// Users can utilize [DropdownController] to:
///   1. [DropdownController.open] to open the dropdown menu.
///   2. [DropdownController.dismiss] to dismiss the dropdown menu.
///   3. [DropdownController.select] to make an item as selected.
///
/// See also:
///   * [SimpleDropdown.list], a simple dropdown that will display items in a [ListView.builder]/[LiveView.separated].
///   * [SimpleDropdown.custom], a simple dropdown that will display items in a custom way.
///   * [DropdownController.single], a single-selection controller that will be used to manage the dropdown menu and items.
///   * [DropdownController.multi], a multiple-selection controller that will be used to manage the dropdown menu and items.
class SimpleDropdown<T> extends StatefulWidget {
  /// The widget that will be used to trigger the dropdown.
  /// It can be a button, a text field, or any other widget.
  ///
  /// if [enabled] is true, the widget will be interactive automatically to open and dismiss the dropdown menu
  /// when tapping inside/outside of the dropdown button/trigger;
  ///
  /// otherwise, you need to call [DropdownController.open] and [DropdownController.dismiss] manually.
  final WidgetBuilder builder;

  /// The controller that will be used to manage the dropdown menu and items.
  ///
  /// See also:
  ///   * [DropdownController.single]
  ///   * [DropdownController.multi]
  final DropdownController<T> controller;

  /// Delegate that will be used to build the dropdown menu.
  ///
  /// See also:
  ///   * [ListViewMenuBuilderDelegate]
  ///   * [CustomMenuBuilderDelegate]
  final DropdownMenuBuilderDelegate<T> delegate;

  /// The decoration that will be used to decorate the dropdown menu.
  /// It only takes effect when the menu is displaying.
  ///
  /// See also:
  ///   * [OverlayedDropdownMenu], the dropdown menu widget used to display the items.
  final BoxDecoration? menuDecoration;

  /// The constraints that will be used to constrain the dropdown menu.
  /// It only takes effect when the menu is displaying.
  /// It will work with [crossAxisConstrained] to constrain the dropdown menu if applicable.
  final BoxConstraints? menuConstraints;

  /// The position that will be used to position the dropdown menu.
  ///
  /// See also
  ///   * [DropdownMenuPosition]
  final DropdownMenuPosition menuPosition;

  /// Whether the dropdown menu should be constrained by the cross axis of the dropdown trigger.
  /// It will work with [menuConstraints] to constrain the dropdown menu if applicable.
  /// It only takes effect when the menu is displaying.
  ///
  /// Typically, it is specific if the dropdown menu should have the same width as the dropdown trigger.
  final bool crossAxisConstrained;

  /// Whether the dropdown menu should be dismissed when the user taps outside of both it and the dropdown button.
  final bool dismissible;

  /// if true, the dropdown will be interactive automatically;
  /// otherwise, you need to call [DropdownController.open] and [DropdownController.dismiss] manually.
  final bool enabled;

  /// Whether the dropdown button/trigger built from [builder] should listen to the controller.
  /// As a result, the button [builder] will be rebuilt when [DropdownController] changes, like selected items
  final bool enableListen;

  const SimpleDropdown({
    super.key,
    required this.controller,
    required this.builder,
    required this.delegate,
    this.menuConstraints,
    this.menuDecoration,
    this.menuPosition = const DropdownMenuPosition(),
    this.crossAxisConstrained = true,
    this.dismissible = true,
    this.enabled = true,
    this.enableListen = true,
  });

  SimpleDropdown.list({
    super.key,
    required this.builder,
    required this.controller,
    this.menuConstraints,
    this.menuDecoration,
    this.enableListen = true,
    this.menuPosition = const DropdownMenuPosition(),
    this.crossAxisConstrained = true,
    this.dismissible = true,
    this.enabled = true,

    /// The builder that will be used to build the items in the dropdown menu.
    required MenuItemBuilder<T> itemBuilder,

    /// The builder that will be used to build the separator in the dropdown menu.
    /// it would use [LiveView.separated] internally to build the dropdown menu if provided.
    IndexedWidgetBuilder? separatorBuilder,

    /// The builder that will be used to build the loading indicator in the dropdown menu.
    /// Default to a [CircularProgressIndicator] if not provided.
    WidgetBuilder? loadingBuilder,

    /// The builder that will be used to build the empty list indicator in the dropdown menu.
    /// Default to Text("No items") if not provided.
    WidgetBuilder? emptyListBuilder,
  }) : delegate = ListViewMenuBuilderDelegate<T>(
          itemBuilder: itemBuilder,
          position: menuPosition,
          separatorBuilder: separatorBuilder,
          loadingBuilder: loadingBuilder,
          emptyListBuilder: emptyListBuilder,
        );

  SimpleDropdown.custom({
    super.key,
    required this.builder,
    required this.controller,

    /// The builder that will be used to build the dropdown menu.
    required DropdownMenuBuilder<T> menuBuilder,
    this.menuConstraints,
    this.menuDecoration,
    this.enableListen = true,
    this.menuPosition = const DropdownMenuPosition(),
    this.crossAxisConstrained = true,
    this.dismissible = true,
    this.enabled = true,
  }) : delegate = CustomMenuBuilderDelegate<T>(menuBuilder);

  @override
  State<SimpleDropdown<T>> createState() => _DropdownState<T>();
}

class _DropdownState<T> extends State<SimpleDropdown<T>>
    with WidgetsBindingObserver, DropdownOverlayBuilderDelegate {
  final LayerLink _link = LayerLink();

  @override
  void initState() {
    super.initState();
    widget.controller.attach(this);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(covariant SimpleDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.detach();
      widget.controller.attach(this);
    }

    if (oldWidget.menuDecoration != widget.menuDecoration ||
        oldWidget.menuConstraints != widget.menuConstraints ||
        oldWidget.menuPosition != widget.menuPosition ||
        oldWidget.crossAxisConstrained != widget.crossAxisConstrained ||
        oldWidget.dismissible != widget.dismissible ||
        oldWidget.enabled != widget.enabled ||
        oldWidget.delegate != widget.delegate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.controller.rebuildMenu();
      });
    }
  }

  @override
  void dispose() {
    widget.controller.detach();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  OverlayEntry buildMenuOverlay() {
    return OverlayEntry(
      builder: (context) {
        return TapRegion(
          onTapOutside: (event) {
            if (widget.dismissible && !_contain(event.position)) {
              widget.controller.dismiss();
            }
          },
          child: OverlayedDropdownMenu<T>(
            link: _link,
            loading: widget.controller.loading,
            items: widget.controller.currentItems,
            delegate: widget.delegate,
            decoration: widget.menuDecoration,
            constraints: widget.menuConstraints,
            position: widget.menuPosition,
            crossAxisConstrained: widget.crossAxisConstrained,
          ),
        );
      },
    );
  }

  /// if the tapped position is inside the dropdown trigger.
  bool _contain(Offset globalPosition) {
    final renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(globalPosition);
    return renderBox.paintBounds.contains(localPosition);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: TapRegion(
        onTapInside: widget.enabled
            ? (_) {
                if (widget.controller.isOpen) {
                  widget.controller.dismiss();
                } else {
                  widget.controller.open();
                }
              }
            : null,
        child: widget.enableListen
            ? ListenableBuilder(
                listenable: widget.controller,
                builder: (inner, _) => widget.builder(inner),
              )
            : widget.builder(context),
      ),
    );
  }
}
