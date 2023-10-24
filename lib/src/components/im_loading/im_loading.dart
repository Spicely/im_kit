part of im_kit;

class ImLoading extends StatelessWidget {
  const ImLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      // child: LoadingIndicator(
      //   indicatorType: Indicator.lineSpinFadeLoader,
      //   colors: [Colors.black],
      //   strokeWidth: 0.3,
      //   pathBackgroundColor: Colors.black,
      // ),
    );
  }
}
