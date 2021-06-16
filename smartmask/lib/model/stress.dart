class stressview {
  final String stress;


  const stressview({
    this.stress
  });

  factory stressview.fromJson(Map<String, dynamic> json) {
    return stressview(
      stress: json['stress'].toString(),


    );
  }
}
