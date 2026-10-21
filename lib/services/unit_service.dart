class UnitService {
  const UnitService();

  double kgToLb(double kg) => kg * 2.2046226218;
  double lbToKg(double lb) => lb / 2.2046226218;

  double fromKg(double kg, String unit) => unit == 'lb' ? kgToLb(kg) : kg;
  double toKg(double value, String unit) => unit == 'lb' ? lbToKg(value) : value;

  String label(String unit) => unit == 'lb' ? 'lb' : 'kg';
}
