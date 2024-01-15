part of im_kit;

class ImLoading extends StatelessWidget {
  final Widget child;

  const ImLoading({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        // LoadingIndicator(
        //   indicatorType: Indicator.lineSpinFadeLoader,
        //   colors: [Colors.black],
        //   strokeWidth: 0.3,
        //   pathBackgroundColor: Colors.black,
        // ),
      ],
    );
  }
}
