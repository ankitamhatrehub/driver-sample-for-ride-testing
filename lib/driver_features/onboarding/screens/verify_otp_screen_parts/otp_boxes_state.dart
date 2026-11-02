part of 'package:rider_app/driver_features/onboarding/screens/verify_otp_screen.dart';

class _OtpBoxesState extends State<_OtpBoxes> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_rebuild);
    widget.controller.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(_OtpBoxes oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_rebuild);
      widget.focusNode.addListener(_rebuild);
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_rebuild);
      widget.controller.addListener(_rebuild);
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_rebuild);
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  int _tappedIndex = 0;

  int get _cursorOffset {
    final text = widget.controller.text;
    final raw = widget.controller.selection.baseOffset;
    if (raw < 0) return text.length;
    return raw.clamp(0, text.length);
  }

  void _selectBox(int index) {
    final text = widget.controller.text;
    final offset = index < text.length ? index + 1 : text.length;
    widget.focusNode.requestFocus();
    widget.controller.value = widget.controller.value.copyWith(
      selection: TextSelection.collapsed(offset: offset),
      composing: TextRange.empty,
    );
    SystemChannels.textInput.invokeMethod<void>('TextInput.show');
  }

  bool _cursorInBox(int index) {
    if (!widget.focusNode.hasFocus) return false;
    final textLength = widget.controller.text.length;
    final offset = _cursorOffset;
    if (offset == textLength) {
      final slot = textLength >= widget.length ? widget.length - 1 : textLength;
      return index == slot;
    }
    if (offset == 0) return index == 0;
    return index == offset - 1;
  }

  bool _cursorBeforeDigit(int index) =>
      widget.focusNode.hasFocus && _cursorOffset == 0 && index == 0;

  @override
  Widget build(BuildContext context) {
    final gap = context.w(8);
    final boxSize =
        (MediaQuery.sizeOf(context).width -
            context.w(48) -
            gap * (widget.length - 1)) /
        widget.length;

    return SizedBox(
      height: boxSize,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          IgnorePointer(
            child: Row(
              children: List.generate(widget.length, (index) {
                final char = index < widget.controller.text.length
                    ? widget.controller.text[index]
                    : '';
                final isActive = _cursorInBox(index);
                final showErrorBorder =
                    widget.hasError && index == widget.length - 1;
                return Padding(
                  padding: EdgeInsets.only(
                    right: index == widget.length - 1 ? 0 : gap,
                  ),
                  child: Container(
                    width: boxSize,
                    height: boxSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.torkk.surface,
                      borderRadius: BorderRadius.circular(context.r(14)),
                      border: Border.all(
                        color: showErrorBorder
                            ? context.legible(AppColors.error)
                            : isActive
                            ? AppColors.primary
                            : AppColors.fieldBorder,
                        width: showErrorBorder || isActive ? 1.6 : 1,
                      ),
                    ),
                    child: _OtpBoxContent(
                      char: char,
                      showCursor: isActive,
                      cursorBeforeDigit: _cursorBeforeDigit(index),
                    ),
                  ),
                );
              }),
            ),
          ),
          Positioned.fill(
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (event) {
                _tappedIndex = (event.localPosition.dx / (boxSize + gap))
                    .floor()
                    .clamp(0, widget.length - 1);
                _selectBox(_tappedIndex);
              },
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.none,
                autofillHints: const [AutofillHints.oneTimeCode],
                autofocus: true,
                showCursor: false,
                cursorWidth: 0,
                maxLength: widget.length,
                enableInteractiveSelection: false,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  color: Colors.transparent,
                  fontSize: 1,
                  height: 1,
                ),
                decoration: const InputDecoration(
                  filled: false,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  counterText: '',
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () {
                  _selectBox(_tappedIndex);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _selectBox(_tappedIndex);
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
