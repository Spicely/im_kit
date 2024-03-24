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
    return InkWell(
      onTap: onPressed,
      child: Text(
        label,
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
