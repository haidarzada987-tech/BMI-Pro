class BMIService {
  const BMIService();
  double calculate({required double weightKg,required double heightCm}) { final m=heightCm/100; return m<=0?0:weightKg/(m*m); }
  String category(double bmi)=>bmi<18.5?'underweight':bmi<25?'healthy':bmi<30?'overweight':'obesity';
  double healthyMinKg(double heightCm) { final m=heightCm/100; return 18.5*m*m; }
  double healthyMaxKg(double heightCm) { final m=heightCm/100; return 24.9*m*m; }
}
