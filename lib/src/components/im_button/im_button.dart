part of im_kit;

class ImButton extends StatelessWidget {
  final String label;

  final void Function()? onPressed;

  const ImButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // cursor: MouseCursor.uncontrolled,
      onTap: onPressed,
      child: Text(
        label,
        // style: TextStyle(color: onPressed == null ? ImCore.theme.subtitleColor : Theme.of(context).primaryColor, fontSize: 12),
      ),
    );
  }
}
