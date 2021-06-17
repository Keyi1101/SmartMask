class fastproduct {
  final String mode;
  final String tim;
  final String tresp;
  final String tskin;
  final String tenv;
  final String accelx;
  final String accely;
  final String accelz;
 // final String stress;
  final String ppgir;
  final String ppgred;

  const fastproduct({
    this.mode,
    this.tim,
    this.tresp,
    this.tskin,
    this.tenv,
    this.accelx,
    this.accely,
    this.accelz,
  //  this.stress,
    this.ppgir,
    this.ppgred
  });

  factory fastproduct.fromJson(Map<String, dynamic> json) {
    return fastproduct(
      tim: json['tim'].toString(),
      mode: json['mode'].toString(),
      tresp: json['tresp'].toString(),
      tskin: json['tskin'].toString(),
      tenv: json['tenv'].toString(),
      accelx: json['accelx'].toString(),
      accely: json['accely'].toString(),
      accelz: json['accelz'].toString(),
    //  stress: json['stress'].toString(),
      ppgir: json['ppgir'].toString(),
      ppgred: json['ppgred'].toString()

    );
  }
}
