class UnbordingContent {
  String image;
  String title;
  String discription;

  UnbordingContent({required this.image,required this.title,required this.discription});
}

List<UnbordingContent> contents = [
  UnbordingContent(
      title: 'Welcome to\nMarket Manager',
      image: 'assets/images/agriculture.png',
      discription: "Lets explore"
  ),
  UnbordingContent(
      title: 'Quality Food',
      image: 'assets/images/harvest.png',
      discription: "simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the "
          "We organize the market to a sweet spot where both consumer and producer have a common benefit"
          "when an unknown printer took a galley of type and scrambled it "
  ),
  UnbordingContent(
      title: 'Fast Delivery',
      image: 'assets/images/fast-delivery.png',
      discription: "simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the "
          "industry's standard dummy text ever since the 1500s, "
          "when an unknown printer took a galley of type and scrambled it "
  ),
  UnbordingContent(
      title: 'Gov. Control on price',
      image: 'assets/images/access-control.png',
      discription: "simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the "
          "industry's standard dummy text ever since the 1500s, "
          "when an unknown printer took a galley of type and scrambled it "
  ),
  UnbordingContent(
      title: 'Best Value For Money',
      image: 'assets/images/low-cost.png',
      discription: "simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the "
          "industry's standard dummy text ever since the 1500s, "
          "when an unknown printer took a galley of type and scrambled it "
  ),
];